from agent_core.jira_client import get_field_last_update, get_issues_by_status, fetch_issue_by_key, get_acceptance_criteria_field_id,get_comments_after, transition_issue, post_comment_to_jira 
from agent_core.llm_selector import generate
import base64
import os

def extract_text_from_adf(adf):
    if not isinstance(adf, dict):
        return ""

    def extract_node_text(node):
        if not isinstance(node, dict):
            return ""

        node_type = node.get("type")

        if node_type == "text":
            return node.get("text", "")

        elif node_type == "hardBreak":
            return "\n"

        elif node_type in ("paragraph", "heading", "listItem"):
            return "".join(extract_node_text(child) for child in node.get("content", [])) + "\n"

        elif node_type in ("bulletList", "orderedList"):
            return "\n".join("- " + extract_node_text(item).strip() for item in node.get("content", []))

        elif node_type in ("inlineCard", "applicationCard"):
            # Most Jira cards have a "url" and sometimes a "text" or "title"
            attrs = node.get("attrs", {})
            url = attrs.get("url", "")
            title = attrs.get("text") or attrs.get("title") or url
            return f"{title}\n" if url else ""

        elif node_type == "mention":
            return f"@{node.get('attrs', {}).get('text', '')}"

        elif node_type == "doc":
            return "\n".join(extract_node_text(child) for child in node.get("content", []))

        elif "content" in node:
            return "".join(extract_node_text(child) for child in node["content"])

        return ""

    return extract_node_text(adf).strip()

def has_already_commented(comments, tag):
    for c in comments:
        if extract_text_from_adf(c['body']).startswith(tag):
##            print(f"\nAlready commented with tag '{tag}':\n {extract_text_from_adf(c['body'])}\n\n")
            return True
 
def load_feature_files_as_examples(folder_path: str) -> str:
    examples = []
    for filename in os.listdir(folder_path):
        if filename.endswith(".feature"):
            file_path = os.path.join(folder_path, filename)
            with open(file_path, "r", encoding="utf-8") as file:
                content = file.read()
                examples.append(f"--- {filename} ---\n{content.strip()}")
    return "\n\n".join(examples)

def summarize_ready_for_qa_tasks(user_email: str = None):
    issues = get_issues_by_status("Ready for QA", assignee=user_email)
    return _summarize_issues(issues, "for each issue, check it make sense, no errors, and it's really understandable")

def summarize_test_case_refinement_tasks(user_email: str = None):
    feature_examples = load_feature_files_as_examples("features/")
#    issues = get_issues_by_status("REFINEMENT", assignee=user_email)
    issues = get_issues_by_status("TEST CASE REFINEMENT", assignee=user_email)
#    issues = get_issues_by_status("REQUIREMENTS REVIEW", assignee=user_email)
    for issue in issues:


        last_description_change = get_field_last_update(issue["key"], "description")
        last_ac_change = get_field_last_update(issue["key"], "Acceptance Criteria")
        last_updated = max(last_description_change, last_ac_change) if last_description_change and last_ac_change else None
        comments = get_comments_after(issue["key"],after_date=last_updated)
        
        if not has_already_commented(comments, os.getenv('TEST_CASE_REFINEMENT_TAG')):
            prompt = base64.b64decode(os.getenv('TEST_CASE_REFINEMENT_PROMPT')).decode('utf-8') 
            tasks = base64.b64decode(os.getenv('TEST_CASE_REFINEMENT_TASKS')).decode('utf-8')
            rules = base64.b64decode(os.getenv('TEST_CASE_REFINEMENT_RULES')).decode('utf-8')
            close_prompt = base64.b64decode(os.getenv('TEST_CASE_REFINEMENT_CLOSE_PROMPT')).decode('utf-8')
            response = _summarize_issue(issue, prompt,rules, tasks)
            if not response:
                return
            print(f"Response for issue {issue['key']}:\n{response}\n")
            if response.startswith("Blocker:True") or response.startswith("Blocker: True"):
                 transition_issue(issue["key"], "4")  # Transition to "Blocked" status
            post_comment_to_jira(issue["key"],  f"{os.getenv('TEST_CASE_REFINEMENT_TAG')}\nHi \n{response}")
            return response

###After that write Test Cases in gherkins, use this as example:
###{feature_examples}
###Add @JREQ-<issue_key> to each test case, where <issue_key> is the key of the issue you are working on.


def _summarize_issue(i: dict, prompt_intro: str,rules: str, tasks: str) -> str:

    if not i:
        return "No se encontraron tareas en este estado."
    ACCEPTANCE_CRITERIA_FIELD_ID = get_acceptance_criteria_field_id()
    issue_as_txt = f"###US - {i['key']}: {i['fields']['summary']} ###\nDescription:\n{extract_text_from_adf(i['fields'].get('description'))}\nAcceptance Criteria:\n{extract_text_from_adf(i['fields'].get(ACCEPTANCE_CRITERIA_FIELD_ID))}\n### END US ###\n"
#        + (
#            (lambda parent: (
#                f"\n  Parent US: {parent['key']} {parent['fields'].get('summary', '')}\n"
#                f"  Parent description: {extract_text_from_adf(parent['fields'].get('description'))}\n"
#                f"  Acceptance Criteria:\n{extract_text_from_adf(parent['fields'].get(ACCEPTANCE_CRITERIA_FIELD_ID))}\n"
#            ))(fetch_issue_by_key(i['fields']['parent']['key']))
#            if i['fields'].get("parent") else ""
#        )
        
    

    full_prompt = f"{prompt_intro}\n{issue_as_txt}"
    full_prompt += f"{rules}\n"
    full_prompt += f"{tasks}\n"

    print(full_prompt)
    response = ""
    response = generate(full_prompt)

    return response
