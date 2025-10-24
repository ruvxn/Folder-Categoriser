#!/usr/bin/env python3
"""
Creates a simple, professional DMG background image
"""

from PIL import Image, ImageDraw, ImageFont
import os

# DMG window dimensions
WIDTH = 600
HEIGHT = 400

# Create image with gradient background
img = Image.new('RGB', (WIDTH, HEIGHT), color='#f5f5f7')
draw = ImageDraw.Draw(img)

# Draw subtle gradient (lighter at top)
for y in range(HEIGHT):
    # Gradient from light gray to slightly darker
    brightness = int(245 - (y / HEIGHT * 10))
    color = (brightness, brightness, brightness + 2)
    draw.line([(0, y), (WIDTH, y)], fill=color)

# Add subtle grid pattern
grid_color = (235, 235, 237)
for x in range(0, WIDTH, 40):
    draw.line([(x, 0), (x, HEIGHT)], fill=grid_color, width=1)
for y in range(0, HEIGHT, 40):
    draw.line([(0, y), (WIDTH, y)], fill=grid_color, width=1)

# Add text instruction at bottom
text = "Drag Folder Categoriser to Applications to install"
text_color = (100, 100, 120)

# Try to use a nice font, fall back to default
try:
    font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 16)
except:
    font = ImageFont.load_default()

# Get text bounding box
bbox = draw.textbbox((0, 0), text, font=font)
text_width = bbox[2] - bbox[0]
text_height = bbox[3] - bbox[1]

# Center text at bottom
text_x = (WIDTH - text_width) // 2
text_y = HEIGHT - 50

# Draw text with shadow
shadow_offset = 1
draw.text((text_x + shadow_offset, text_y + shadow_offset), text,
          fill=(200, 200, 210), font=font)
draw.text((text_x, text_y), text, fill=text_color, font=font)

# Add arrow or decoration
arrow_y = HEIGHT // 2 - 20
# Left arrow (pointing to app position)
draw.polygon([
    (200, arrow_y),
    (220, arrow_y - 10),
    (220, arrow_y + 10)
], fill=(100, 149, 237, 180))

# Right arrow (pointing to Applications)
draw.polygon([
    (400, arrow_y),
    (380, arrow_y - 10),
    (380, arrow_y + 10)
], fill=(100, 149, 237, 180))

# Save
output_path = 'dmg-background.png'
img.save(output_path, 'PNG')
print(f"✓ DMG background created: {output_path}")
print(f"  Dimensions: {WIDTH}x{HEIGHT}")
