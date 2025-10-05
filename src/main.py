import PIL

from utils.file_picker import open_file_picker, Mode

if __name__ == "__main__":
    selected_files = open_file_picker(mode="open", multiple=True)
    print(selected_files)