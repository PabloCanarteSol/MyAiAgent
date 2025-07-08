import os
from dotenv import load_dotenv

# Carga el archivo .env
load_dotenv()

# Usa las variables
if "GEMINI_API_KEY" in os.environ:
    import google.generativeai as genai
    genai.configure(api_key=os.environ["GEMINI_API_KEY"])
    def generate(prompt: str):
        model = genai.GenerativeModel("gemini-1.5-flash")  # o el modelo que desees
        response = model.generate_content(prompt)
        return response.text

elif "OPENAI_API_KEY" in os.environ:
    import openai
    openai.api_key = os.environ["OPENAI_API_KEY"]
    def generate(prompt: str):
        response = openai.ChatCompletion.create(
            model="gpt-4",
            messages=[{"role": "user", "content": prompt}]
        )
        return response.choices[0].message.content

else:
    raise
print(generate(prompt="¿Cuál es la capital de Francia?"))