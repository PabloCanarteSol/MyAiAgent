import os
import requests
from requests.auth import HTTPBasicAuth

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