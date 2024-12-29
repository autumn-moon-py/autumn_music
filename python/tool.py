import json
import os
import requests


with open("cookie.txt", "r", encoding="utf-8") as f:
    cookie = f.read()
headers = {
    "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:133.0) Gecko/20100101 Firefox/133.0",
    "Cookie": cookie,
}


def write_json(data, file_name):
    with open(f"{file_name}.json", "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False)


def read_json(file_name):
    data: any
    with open(f"{file_name}.json", "r", encoding="utf-8") as f:
        data = json.load(f)
    return data


def http_get(url) -> dict:
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        return json.loads(response.text)
    else:
        return {}


def http_post(url, data) -> dict:
    response = requests.post(url, data=data, headers=headers)
    if response.status_code == 200:
        return json.loads(response.text)
    else:
        return {}


def download_file(url, file_path):
    if os.path.exists(file_path):
        return 1024 * 1024
    response = requests.get(url)
    with open(file_path, "wb") as file:
        file.write(response.content)
        file.close()
        return len(response.content)


def remove_all_json_files():
    for file in os.listdir("."):
        if file.endswith(".json"):
            os.remove(file)


def traverse_folder(folder_path, prefix=""):
    if os.path.exists("updata.txt"):
        os.remove("updata.txt")
    with open("update.txt", "a", encoding="utf-8") as f:
        for filename in os.listdir(folder_path):
            file_path = os.path.join(folder_path, filename)
            if os.path.isfile(file_path):
                f.write(f"{prefix}{filename}\n")


def clear_folder(folder_path):
    for filename in os.listdir(folder_path):
        file_path = os.path.join(folder_path, filename)
        if os.path.isfile(file_path):
            os.remove(file_path)
        elif os.path.isdir(file_path):
            clear_folder(file_path)
    os.removedirs(folder_path)
