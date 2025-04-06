import json
from gradio_client import Client
from fetch_doi_data import fetch_doi_data

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
