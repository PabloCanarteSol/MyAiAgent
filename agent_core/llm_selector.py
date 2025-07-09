import os
from dotenv import load_dotenv

load_dotenv()

if os.getenv("GEMINI_API_KEY"):
    import google.generativeai as genai
    genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

    def generate(prompt: str) -> str:
        model = genai.GenerativeModel("gemini-1.5-flash")
        resp = model.generate_content(prompt)
        return resp.text

elif os.getenv("OPENAI_API_KEY"):
    import openai
    openai.api_key = os.getenv("OPENAI_API_KEY")

    def generate(prompt: str) -> str:
        resp = openai.ChatCompletion.create(
            model="gpt-4",
            messages=[{"role": "user", "content": prompt}]
        )
        return resp.choices[0].message.content
else:
    raise EnvironmentError("Define GEMINI_API_KEY o OPENAI_API_KEY en .env")
