import os
import json

from tool import download_file, http_get, http_post, read_json, write_json

# https://music.163.com/api/v6/playlist/detail?id=986150480
# https://music.163.com/api/song/detail?ids=[537407937]
# https://music.163.com/song/media/outer/url?id={id}.mp3

cookie = ""
last = "喜头悲尾"
myPlaylistID = "986150480"

netV6Url = "https://music.163.com/api/v6/playlist/detail"


def netSongsUrl(ids: list):
    return f"https://music.163.com/api/song/detail?ids={ids}"


def netMP3Url(id):
    return f"https://music.163.com/song/media/outer/url?id={id}.mp3"


def get_playlist():
    data = {"id": myPlaylistID}
    result = http_post(netV6Url, data)
    result = result["playlist"]["trackIds"]
    write_json(result, "music_id_list")


def get_all_song_info():
    json_list = read_json("music_id_list")
    id_list = [j["id"] for j in json_list]
    song_list = []
    result = http_get(netSongsUrl(id_list))
    song_list = result["songs"]
    write_json(song_list, "music_list")


def format_song_list():
    original_song_list = read_json("music_list")
    format_song_list = []
    for song in original_song_list:
        id = song["id"]
        name = song["name"]
        artists = [artist["name"] for artist in song["artists"]]
        url = netMP3Url(id)
        data = {"id": id, "name": name, "artists": artists, "url": url}
        format_song_list.append(data)
    write_json(format_song_list, "format_music_list")


music_list = []
music_list_new = []


def handle_new():
    music_list = read_json("format_music_list")
    for i in range(len(music_list)):
        if music_list[i]["name"] == last:
            break
    for j in range(i):
        music_list_new.append(music_list[j])


def download_music():
    error_list = []
    if not os.path.exists("music"):
        os.mkdir("music")
    for music in music_list_new:
        name = music["name"]
        music_artist = ""
        for art in music["artists"]:
            music_artist += "-" + art
        music_url = music["url"]
        music_file_name = name + music_artist + ".mp3"
        invalid_chars = ':*?"<>|[],'
        for char in invalid_chars:
            music_file_name = music_file_name.replace(char, "")
        music_file_path = os.path.join("music", music_file_name)
        size = download_file(music_url, music_file_path)
        if (size if size != None else 0) < 1024 * 1024:
            error_list.append(music)
            os.remove(music_file_path)
            print(f"{name}——下载失败")
        else:
            print(f"{name}——下载完成")
    if len(error_list) > 0:
        print(f"下载失败{len(error_list)}首")
        with open("error.json", "w", encoding="utf-8") as f:
            json.dump(error_list, f, ensure_ascii=False, indent=4)
