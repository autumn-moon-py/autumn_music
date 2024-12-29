import os
import boto3


ENDPOINT_URL = "https://bc849e61e1571b67c8bdfc9d40583fdb.r2.cloudflarestorage.com"
ACCESS_KEY = "42dd92f4685141e7edcff105c9b37f8b"
SECRET_KEY = "914d44c6b2a5df9b9d9ee5d9d0209673d6607b24421491f9fea1dc561b70e891"
BUCKET_NAME = "subrecovery"


s3_client = boto3.client(
    "s3",
    endpoint_url=ENDPOINT_URL,
    aws_access_key_id=ACCESS_KEY,
    aws_secret_access_key=SECRET_KEY,
)


def delete_all_objects():
    s3 = boto3.resource(
        "s3",
        endpoint_url=ENDPOINT_URL,
        aws_access_key_id=ACCESS_KEY,
        aws_secret_access_key=SECRET_KEY,
    )
    bucket = s3.Bucket(BUCKET_NAME)
    bucket.objects.all().delete()


def upload_folder_to_s3(folder_path, s3_folder):
    for root, _, files in os.walk(folder_path):
        for filename in files:
            local_path = os.path.join(root, filename)
            relative_path = os.path.relpath(local_path, folder_path)
            s3_path = os.path.join(s3_folder, relative_path).replace("\\", "/")
            s3_client.upload_file(local_path, BUCKET_NAME, s3_path)
            print(f"Uploaded {local_path} to {s3_path}")


def delete_file(file_name):
    s3_client.delete_object(Bucket=BUCKET_NAME, Key=file_name)


def upload_update_song_list():
    name = "update.txt"
    delete_file(name)
    s3_client.upload_file(name, BUCKET_NAME, name)
