from agent_core.jira_client import get_issues_by_status, fetch_issue_by_key, get_acceptance_criteria_field_id
from agent_core.llm_selector import generate
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
    issues = get_issues_by_status("TEST CASE REFINEMENT", assignee=user_email)
    prompt = f"""You are a QA. You need to report critical things to BA and SA.\nFor each issue, check it make sense, no errors, and it's really understandable. Make the response as short as you can.
After that write Test Cases in gherkins, use this as example:
{feature_examples}
Add @JREQ-<issue_key> to each test case, where <issue_key> is the key of the issue you are working on.
List of issues:

"""
    return _summarize_issues(issues, prompt)


def _summarize_issues(issues: list, prompt_intro: str) -> str:

    if not issues:
        return "No se encontraron tareas en este estado."
    ACCEPTANCE_CRITERIA_FIELD_ID = get_acceptance_criteria_field_id()
    issue_list = "\n\n".join(
        f"- {i['key']}: {i['fields']['summary']}\n"
        f"  Description:\n{extract_text_from_adf(i['fields'].get('description'))}\n"
        f"  Acceptance Criteria:\n{extract_text_from_adf(i['fields'].get(ACCEPTANCE_CRITERIA_FIELD_ID))}\n"
        + (
            (lambda parent: (
                f"\n  Parent US: {parent['key']} {parent['fields'].get('summary', '')}\n"
                f"  Parent description: {extract_text_from_adf(parent['fields'].get('description'))}\n"
                f"  Acceptance Criteria:\n{extract_text_from_adf(parent['fields'].get(ACCEPTANCE_CRITERIA_FIELD_ID))}\n"
            ))(fetch_issue_by_key(i['fields']['parent']['key']))
            if i['fields'].get("parent") else ""
        )
        for i in issues
    )

    full_prompt = f"{prompt_intro}\n{issue_list}"
#    print(full_prompt)

    return generate(full_prompt)
