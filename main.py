import os
from dotenv import load_dotenv

load_dotenv()

from agent_core.task_agent import (
    summarize_ready_for_qa_tasks,
    summarize_test_case_refinement_tasks,
)


if __name__ == "__main__":
#    print("=== READY FOR QA ===")
#    print(summarize_ready_for_qa_tasks())

    print("\n=== TEST CASE REFINEMENT ===")
    print(summarize_test_case_refinement_tasks())