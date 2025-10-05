from typing import Optional, List, Union, Tuple
from typing import Literal
import sys
from tkinter import Tk
from tkinter import filedialog as fd
from ctypes import windll

Mode = Literal["open", "save", "directory"]

def open_file_picker(
    multiple: bool = False,
    mode: Mode = "open",
    filetypes: Optional[List[Tuple[str, str]]] = None,
    parent=None,
    **kwargs
) -> Optional[Union[str, Tuple[str, ...], List[str]]]:
    """
    Open a native file/directory dialog.

    Parameters:
    - multiple: when mode="open", allow selecting multiple files.
    - mode: one of "open" (files), "save" (save as), "directory" (pick folder).
    - filetypes: e.g., [("Text files", "*.txt"), ("All files", "*.*")]
    - parent: optional Tk widget to parent the dialog.
    - **kwargs: forwarded to filedialog (e.g., title, initialdir, defaultextension).

    Returns:
    - For mode="open":
        - multiple=False: str path or None
        - multiple=True: list[str] (or tuple[str, ...] if you prefer) or None
    - For mode="save": str path or None
    - For mode="directory": str path or None
    """

    # Windows: try to enable DPI awareness safely
    if sys.platform == "win32":
        try:
            windll.shcore.SetProcessDpiAwareness(1)
        except Exception:
            pass

    # Ensure no ghost root window appears if no parent provided
    created_root = None
    if parent is None:
        created_root = Tk()
        created_root.withdraw()

    dialog_options = {}
    if filetypes:
        dialog_options["filetypes"] = filetypes
    if "title" in kwargs:
        dialog_options["title"] = kwargs.pop("title")

    dialog_options.update(kwargs)
    if parent is not None:
        dialog_options["parent"] = parent

    try:
        if mode == "open":
            if multiple:
                paths = fd.askopenfilenames(**dialog_options)
                # Convert tuple to list for ergonomics (optional)
                return list(paths) if paths else None
            else:
                path = fd.askopenfilename(**dialog_options)
                return path or None

        if mode == "save":
            path = fd.asksaveasfilename(**dialog_options)
            return path or None

        if mode == "directory":
            path = fd.askdirectory(**dialog_options)
            return path or None
            
    finally:
        if created_root is not None:
            created_root.destroy()


if __name__ == "__main__":
    # --- Examples of using the helper function ---

    # Example 1: Open a dialog to select a single text file
    print("--- Selecting a single text file ---")
    selected_file = open_file_picker(
        mode='open', 
        filetypes=[("Text files", "*.txt")]
    )
    if selected_file:
        print(f"Selected file: {selected_file}\n")

    # Example 2: Open a dialog to select multiple image files
    print("--- Selecting multiple image files ---")
    selected_files = open_file_picker(
        multiple=True,
        mode='open', 
        filetypes=[("Image files", "*.png *.jpg *.jpeg")]
    )
    if selected_files:
        print(f"Selected files: {selected_files}\n")

    # Example 3: Open a dialog to save a new file
    print("--- Saving a new file as... ---")
    saved_file = open_file_picker(
        mode='save', 
        title="Save Your Work",
        filetypes=[("JSON files", "*.json")],
        defaultextension=".json"
    )
    if saved_file:
        print(f"File to be saved as: {saved_file}\n")
        
    # Example 4: Open a dialog to select a directory
    print("--- Selecting a directory ---")
    selected_dir = open_file_picker(
        mode='directory',
        initialdir="C:/Users/", # Customize initial directory
        title="Select a project folder"
    )
    if selected_dir:
        print(f"Selected directory: {selected_dir}\n")