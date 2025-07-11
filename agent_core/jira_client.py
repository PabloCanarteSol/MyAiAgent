import os
import requests
from requests.auth import HTTPBasicAuth
import dateutil.parser
from datetime import datetime

JIRA_URL = os.getenv("JIRA_BASE_URL")
JIRA_EMAIL = os.getenv("JIRA_EMAIL")
JIRA_TOKEN = os.getenv("JIRA_API_TOKEN")

auth = HTTPBasicAuth(JIRA_EMAIL, JIRA_TOKEN)
headers = {"Accept": "application/json", "Content-Type": "application/json"}

def fetch_issue_by_key(key: str):
    url = f"{JIRA_URL}/rest/api/3/issue/{key}"
#    params = {"fields": "summary,description"}
    params = {}
    response = requests.get(url, headers=headers, auth=auth, params=params)
    response.raise_for_status()
    data = response.json()
    return data
def get_issues_by_status(status_name: str, assignee: str = None, max_results: int = 10):
    jql = f'status = "{status_name}"'
    if assignee:
        jql += f' AND assignee = "{assignee}"'
    else:
        print("No assignee provided, fetching issues for all users.")
    jql += " ORDER BY updated DESC"

    url = f"{JIRA_URL}/rest/api/3/search"
    params = {"jql": jql, "maxResults": max_results}

    response = requests.get(url, headers=headers, auth=auth, params=params)
    response.raise_for_status()
    data = response.json()

    return  data.get("issues", [])

def get_jira_fields():
    url = f"{JIRA_URL}/rest/api/3/field"
    response = requests.get(url, headers=headers, auth=auth)
    response.raise_for_status()
    return response.json()

def get_acceptance_criteria_field_id():
    fields = get_jira_fields()
    for field in fields:
        if "acceptance criteria" in field['name'].lower():
            return field['id']
    raise ValueError("Campo 'Acceptance Criteria' no encontrado en Jira.")


def get_comments_after(issue_key, after_date: datetime | None = None):
    url = f"{JIRA_URL}/rest/api/3/issue/{issue_key}/comment"
    resp = requests.get(url, headers=headers, auth=auth)
    resp.raise_for_status()
    comments = resp.json().get("comments", [])
    result = []

    for comment in comments:
        created_str = comment.get("created")
        if created_str:
            created_dt = dateutil.parser.parse(created_str)
            if not after_date  or created_dt > after_date:
                result.append(comment)
    return result

def get_last_updated_user(issue):
    # Usa author del último comentario o editor del issue
    try:
        comments = get_comments_after(issue["key"])
        return comments[-1]["author"]["displayName"]
    except:
        return issue["fields"].get("reporter", {}).get("displayName", "usuario")
    
def get_field_last_update(issue_key: str, field_name: str) -> datetime | None:
    url = f"{JIRA_URL}/rest/api/3/issue/{issue_key}"
    params = {"expand": "changelog"}
    response = requests.get(url, headers=headers, auth=auth, params=params)
    response.raise_for_status()
    data = response.json()

    changes = [
        hist for hist in data.get("changelog", {}).get("histories", [])
        for item in hist.get("items", [])
        if item["field"] == field_name
    ]
    if not changes:
        return None

    latest = max(changes, key=lambda h: h["created"])
    return datetime.strptime(latest["created"], "%Y-%m-%dT%H:%M:%S.%f%z")

def transition_issue(issue_key: str, transition_id: str):
    url = f"{JIRA_URL}/rest/api/3/issue/{issue_key}/transitions"
    payload = {
        "transition": {
            "id": transition_id
        }
    }
    response = requests.post(url, headers=headers, auth=auth, json=payload)
    print(response.status_code, response.text)
    response.raise_for_status()

def post_comment_to_jira(issue_key: str, message: str):
    issue_data = fetch_issue_by_key(issue_key)
    reporter = issue_data["fields"].get("reporter")
    assignee = issue_data["fields"].get("assignee")

    # Mensaje
    content=([{"type": "text", "text": f"{message}"}])

    content.append ({"type": "text", "text": "\n\nTHX "})

    # Mencionar al reporter si existe
    if reporter:
        content.append({
            "type": "mention",
            "attrs": {
                "id": reporter["accountId"],
                "text": f"@{reporter.get('displayName', 'reporter')}"
            }
        })
        content.append({"type": "text", "text": " y "})

    # Mencionar al assignee si existe
    if assignee:
        content.append({
            "type": "mention",
            "attrs": {
                "id": assignee["accountId"],
                "text": f"@{assignee.get('displayName', 'assignee')}"
            }
        })


    comment_body = {
        "body": {
            "type": "doc",
            "version": 1,
            "content": [{
                "type": "paragraph",
                "content": content
            }]
        }
    }

    url = f"{JIRA_URL}/rest/api/3/issue/{issue_key}/comment"
    response = requests.post(url, headers=headers, auth=auth, json=comment_body)
    response.raise_for_status()