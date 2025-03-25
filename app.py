import requests

# GitHub repository details
OWNER = "RaannaKasturi"
REPO = "scientry_app"
COMMIT_SHA = "09ac7d8224e267c9eae70eaeb5625aa6d27b08e0"  # Specific commit SHA

# GitHub API URL to fetch tree structure of the commit
API_URL = f"https://api.github.com/repos/{OWNER}/{REPO}/git/trees/{COMMIT_SHA}?recursive=1"

# (Optional) Add a GitHub token if the repo is private
GITHUB_TOKEN = None  # Replace with "your_github_token" if needed

HEADERS = {"Authorization": f"token {GITHUB_TOKEN}"} if GITHUB_TOKEN else {}

def fetch_files():
    """ Fetches all file paths in the repository at a specific commit """
    response = requests.get(API_URL, headers=HEADERS)
    with open("files.txt", "a") as f:
        if response.status_code == 200:
            data = response.json()
            if "tree" in data:
                for item in data["tree"]:
                    if item["type"] == "blob":  # Only fetch files, not folders
                        file_path = item["path"]
                        raw_url = f"https://raw.githubusercontent.com/{OWNER}/{REPO}/{COMMIT_SHA}/{file_path}"
                        print(raw_url)  # Print the raw file URL
                        f.write(raw_url + "\n")
        else:
            print(f"Error: {response.status_code} - {response.text}")

# Run the function to fetch file links
fetch_files()
