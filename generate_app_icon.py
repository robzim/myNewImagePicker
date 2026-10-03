#!/usr/bin/env python3
"""
Generate modern app icon for Photo Dance Party
Run: python3 generate_app_icon.py
Requires: pip3 install Pillow
"""

from PIL import Image, ImageDraw, ImageFilter
import math
import os

def create_gradient(size, color1, color2, direction='diagonal'):
    """Create a gradient image"""
    img = Image.new('RGBA', (size, size))
    draw = ImageDraw.Draw(img)

    for y in range(size):
        for x in range(size):
            if direction == 'diagonal':
                ratio = (x + y) / (2 * size)
            else:
                ratio = y / size

            r = int(color1[0] + (color2[0] - color1[0]) * ratio)
            g = int(color1[1] + (color2[1] - color1[1]) * ratio)
            b = int(color1[2] + (color2[2] - color1[2]) * ratio)
            draw.point((x, y), fill=(r, g, b, 255))

    return img

def draw_rounded_rect(draw, bounds, radius, fill):
    """Draw a rounded rectangle"""
    x1, y1, x2, y2 = bounds
    draw.rectangle([x1 + radius, y1, x2 - radius, y2], fill=fill)
    draw.rectangle([x1, y1 + radius, x2, y2 - radius], fill=fill)
    draw.ellipse([x1, y1, x1 + radius * 2, y1 + radius * 2], fill=fill)
    draw.ellipse([x2 - radius * 2, y1, x2, y1 + radius * 2], fill=fill)
    draw.ellipse([x1, y2 - radius * 2, x1 + radius * 2, y2], fill=fill)
    draw.ellipse([x2 - radius * 2, y2 - radius * 2, x2, y2], fill=fill)

def create_app_icon(size):
    """Create the app icon at specified size"""

    # Create gradient background (deep purple to magenta/pink)
    color1 = (40, 20, 80)    # Deep purple
    color2 = (180, 50, 120)  # Magenta/pink
    img = create_gradient(size, color1, color2, 'diagonal')
    draw = ImageDraw.Draw(img)

    # Add subtle sparkle/star effects
    import random
    random.seed(42)  # Consistent sparkles
    for _ in range(15):
        x = random.randint(0, size)
        y = random.randint(0, size)
        sparkle_size = random.randint(2, int(size * 0.015))
        alpha = random.randint(100, 200)
        draw.ellipse([x - sparkle_size, y - sparkle_size,
                      x + sparkle_size, y + sparkle_size],
                     fill=(255, 255, 255, alpha))

    # Calculate photo frame dimensions
    frame_size = int(size * 0.28)
    frame_radius = int(size * 0.035)
    border_width = int(size * 0.012)

    # Photo frame colors (gradient effect)
    frame_colors = [
        (255, 120, 180, 240),  # Pink
        (120, 200, 255, 240),  # Cyan
        (180, 130, 255, 240),  # Purple
        (255, 180, 100, 240),  # Orange
        (130, 255, 180, 240),  # Green
    ]

    # Draw 5 cascading photo frames (diagonal from top-left to bottom-right)
    start_x = int(size * 0.12)
    start_y = int(size * 0.12)
    step_x = int(size * 0.12)
    step_y = int(size * 0.12)

    # Draw frames from back to front
    for i in range(4, -1, -1):
        x = start_x + i * step_x
        y = start_y + i * step_y

        # Shadow
        shadow_offset = int(size * 0.015)
        draw_rounded_rect(draw,
                          [x + shadow_offset, y + shadow_offset,
                           x + frame_size + shadow_offset, y + frame_size + shadow_offset],
                          frame_radius, (0, 0, 0, 80))

        # Frame border (white/light)
        draw_rounded_rect(draw,
                          [x - border_width, y - border_width,
                           x + frame_size + border_width, y + frame_size + border_width],
                          frame_radius + border_width, (255, 255, 255, 200))

        # Frame fill with color
        draw_rounded_rect(draw,
                          [x, y, x + frame_size, y + frame_size],
                          frame_radius, frame_colors[i])

        # Inner gradient/shine effect
        inner_margin = int(size * 0.02)
        shine_color = (255, 255, 255, 60)
        draw_rounded_rect(draw,
                          [x + inner_margin, y + inner_margin,
                           x + frame_size - inner_margin, y + int(frame_size * 0.4)],
                          frame_radius // 2, shine_color)

    # Add music note symbol in bottom right
    note_x = int(size * 0.72)
    note_y = int(size * 0.65)
    note_size = int(size * 0.18)

    # Music note head
    draw.ellipse([note_x, note_y + int(note_size * 0.6),
                  note_x + int(note_size * 0.5), note_y + note_size],
                 fill=(255, 255, 255, 220))

    # Music note stem
    stem_width = int(size * 0.025)
    draw.rectangle([note_x + int(note_size * 0.4), note_y,
                    note_x + int(note_size * 0.4) + stem_width, note_y + int(note_size * 0.7)],
                   fill=(255, 255, 255, 220))

    # Music note flag
    flag_points = [
        (note_x + int(note_size * 0.4) + stem_width, note_y),
        (note_x + int(note_size * 0.8), note_y + int(note_size * 0.25)),
        (note_x + int(note_size * 0.4) + stem_width, note_y + int(note_size * 0.35)),
    ]
    draw.polygon(flag_points, fill=(255, 255, 255, 220))

    # Add a subtle glow around the whole composition
    # (Apply gaussian blur to a copy and composite)
    glow = img.copy()
    glow = glow.filter(ImageFilter.GaussianBlur(radius=size//30))
    img = Image.blend(glow, img, 0.7)

    return img

def main():
    # Icon sizes needed
    sizes = {
        'Icon-20.png': 20,
        'Icon-20@2x.png': 40,
        'Icon-20@3x.png': 60,
        'Icon-29.png': 29,
        'Icon-29@2x.png': 58,
        'Icon-29@3x.png': 87,
        'Icon-40.png': 40,
        'Icon-40@2x.png': 80,
        'Icon-40@3x.png': 120,
        'Icon-60@2x.png': 120,
        'Icon-60@3x.png': 180,
        'Icon-76.png': 76,
        'Icon-76@2x.png': 152,
        'Icon-83_5@2x.png': 167,
        'ios-marketing.png': 1024,
    }

    # Output directory
    output_dir = os.path.join(os.path.dirname(__file__),
                              'myNewImagePicker/Images.xcassets/AppIcon.appiconset')

    print("Generating Photo Dance Party app icons...")
    print(f"Output directory: {output_dir}")

    # Create high-res master icon first
    master_size = 1024
    master_icon = create_app_icon(master_size)

    for filename, size in sizes.items():
        # Resize from master for quality
        icon = master_icon.resize((size, size), Image.Resampling.LANCZOS)

        # Convert to RGB (remove alpha for App Store)
        if filename == 'ios-marketing.png':
            rgb_icon = Image.new('RGB', icon.size, (40, 20, 80))
            rgb_icon.paste(icon, mask=icon.split()[3] if icon.mode == 'RGBA' else None)
            icon = rgb_icon

        # Save
        filepath = os.path.join(output_dir, filename)
        icon.save(filepath, 'PNG')
        print(f"  Created: {filename} ({size}x{size})")

    print("\nApp icons generated successfully!")
    print("Open Xcode and check Images.xcassets > AppIcon to see the new icons.")

if __name__ == '__main__':
    main()
