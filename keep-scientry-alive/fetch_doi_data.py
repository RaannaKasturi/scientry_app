from gradio_client import Client
import json

import requests

def upload_pdf():
    pdf_url = "https://pmc.ncbi.nlm.nih.gov/articles/PMC4776148/pdf/srep22492.pdf"
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

if __name__ == "__main__":
    print(fetch_doi_data())
