from bs4 import BeautifulSoup

def extract_plain_text(html_content):
    soup = BeautifulSoup(html_content, "html.parser")
    return soup.get_text(separator="\n")