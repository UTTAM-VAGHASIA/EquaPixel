# EquaPixel — String Art Generator

Generate string art from images. Given an input image, the tool simulates a board with nails and computes an ordered thread path that approximates the image. Results can be previewed and exported (e.g., SVG) along with a step-by-step thread instruction list.

## Features
- Convert image → string art path (greedy/heuristic solver)
- Configurable nail layout (circle or custom), nail count, and board size
- Adjustable iterations, contrast/brightness, thread thickness, and background color
- Preview output and export to SVG/PNG
- Optional step list (which nail to go next) for physical builds

## Requirements
- Python 3.9+
- Dependencies: `numpy`, `Pillow`, `tqdm`, `svgwrite`, `tk`

## Setup

Recommended virtual environment:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -U pip
pip install numpy pillow tqdm svgwrite tk
```

> macOS/Linux users can activate with `. .venv/bin/activate` and run the same installs.

## Roadmap
- Basic circular board solver (greedy error reduction)
- SVG export and live preview
- Custom nail layouts and masks
- Advanced solvers (multi-pass, tabu search, or GA)

## License
MIT
