#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
"""compose.py <window png> <dusk|moss> <out png>: lay a window grab over the palette's blurred wallpaper, 40 px in."""
import sys
from pathlib import Path
from PIL import Image

window = Image.open(sys.argv[1]).convert("RGBA")
wall = Path(__file__).parent / "palettes" / f"wall-{sys.argv[2]}-blur.jpg"
canvas = Image.open(wall).convert("RGBA").resize((window.width + 80, window.height + 80))
canvas.alpha_composite(window, (40, 40))
canvas.convert("RGB").save(sys.argv[3])
