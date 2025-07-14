import os
import requests
from requests.auth import HTTPBasicAuth
from dotenv import load_dotenv
load_dotenv()

CONFLUENCE_URL = os.getenv("JIRA_BASE_URL")+ "/wiki"
CONFLUENCE_SPACE = os.getenv("CONFLUENCE_SPACE")
CONFLUENCE_EMAIL = os.getenv("JIRA_EMAIL")
CONFLUENCE_TOKEN = os.getenv("JIRA_API_TOKEN")

AUTH = HTTPBasicAuth(CONFLUENCE_EMAIL, CONFLUENCE_TOKEN)
HEADERS = {
    "Accept": "application/json"
}

def search_page_by_title(title):
    params = {
        "title": title,
        "expand": "body.storage",
    }
    if CONFLUENCE_SPACE:
        params["spaceKey"] = CONFLUENCE_SPACE

    response = requests.get(
        f"{CONFLUENCE_URL}/rest/api/content",
        headers=HEADERS,
        auth=AUTH,
        params=params,
    )
    response.raise_for_status()
    results = response.json().get("results", [])
    if not results:
        return None
    return results[0]["body"]["storage"]["value"]  # HTML format