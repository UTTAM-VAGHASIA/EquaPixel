import sys
from tkinter import filedialog as fd
from ctypes import windll

def open_file_picker():

    if sys.platform == 'win32':
        windll.shcore.SetProcessDpiAwareness(1)
    file = fd.askopenfile()
    print(f'Selected file: {file.name}')


open_file_picker()