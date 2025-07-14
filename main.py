import os
from dotenv import load_dotenv
from agent_core.confluence_client import search_page_by_title
from agent_core.toolbox import (
    extract_plain_text
)
import time
load_dotenv()

from agent_core.task_agent import (
    summarize_ready_for_qa_tasks,
    summarize_test_case_refinement_tasks,
)
def check_and_print(result,wait):
    if  result:
        wait=10  # Default value if no result
        print(result)
    return wait

if __name__ == "__main__":
#    print("=== READY FOR QA ===")
#    print(summarize_ready_for_qa_tasks())
#    DOR=extract_plain_text(search_page_by_title("Definition of Ready (DoR)"))
#    print(DOR)
    while True:
        wait= int( os.getenv("JIRA_CHECK_INTERVAL_SECONDS", "600"))
        print("\n=== TEST CASE REFINEMENT ===")
        wait=check_and_print(summarize_test_case_refinement_tasks(),wait)
        print("Sleeping for", wait, "seconds")
        time.sleep(wait)