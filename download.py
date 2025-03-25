import os
import requests
from tqdm import tqdm  # Progress bar

# Load file URLs from files.txt
files = []
with open("files.txt") as f:
    for line in f:
        files.append(line.strip())

# Total number of files
total_files = len(files)

# Download files with progress bar
for file in tqdm(files, desc="Downloading files", unit="file", total=total_files):
    response = requests.get(file, stream=True)  # Stream to handle large files
    if response.status_code == 200:
        try:
            filename = file.split("09ac7d8224e267c9eae70eaeb5625aa6d27b08e0/")[1]
            directory = os.path.dirname(filename)

            # Create directories if needed
            if directory and not os.path.exists(directory):
                os.makedirs(directory)

            # Save the file
            with open(filename, "wb") as f:
                for chunk in response.iter_content(chunk_size=8192):  # Efficient writing
                    f.write(chunk)

        except Exception as e:
            print(f"\nError saving file {file}: {e}")

    else:
        print(f"\nError: {response.status_code} - {file}")

print("Download completed!")
