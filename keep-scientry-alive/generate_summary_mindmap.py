import json
from gradio_client import Client
import requests

def upload_pdf():
    pdf_url = "https://www.mdpi.com/2073-4352/15/5/393/pdf"
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3"
    }
    with open("temp.pdf", "wb") as f:
        f.write(requests.get(pdf_url, headers=headers).content)
    api_url = "https://tmpfiles.org/api/v1/upload"
    with open("temp.pdf", 'rb') as file:
        files = {'file': file}
        response = requests.post(api_url, files=files)
    url = response.json()['data']['url']
    download_url = f"https://tmpfiles.org/dl/{url.split('.org/')[-1]}"
    return download_url

def fetch_doi_data():
    pdf_url = upload_pdf()
    client = Client("raannakasturi/ScientryPDFDataAPI")
    result = client.predict(
            pdf_url=pdf_url,
            api_name="/getDOIData"
    )
    result = json.loads(result)
    return pdf_url, result

def generate_summary_mindmap(pdf_url, doi):
    client = Client("raannakasturi/ScientryAPI")
    result = client.predict(
            url=pdf_url,
            id=doi,
            access_key="scientrypass",
            api_name="/rexplore_summarizer"
    )
    return result

def main():
    pdf_url, doi_data = fetch_doi_data()
    summary_mindmap = generate_summary_mindmap(pdf_url, doi_data["doi"])
    return summary_mindmap

if __name__ == "__main__":
    print(main())
