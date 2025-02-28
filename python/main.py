from get_music import (
    download_music,
    format_song_list,
    get_all_song_info,
    get_playlist,
    handle_new,
)
from tool import clear_folder, remove_all_json_files, traverse_folder
from r2_upload import upload_folder_to_s3, upload_update_song_list

# clear_folder("music")
# remove_all_json_files()
# get_playlist()
# get_all_song_info()
# format_song_list()
# handle_new()
# download_music()
traverse_folder("./music", "music/")
upload_update_song_list()
upload_folder_to_s3("music", "music")
remove_all_json_files()
