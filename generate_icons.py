#!/usr/bin/env python3
"""Generate a joystick icon in PNG format."""

try:
    from PIL import Image, ImageDraw, ImageFilter
    PIL_AVAILABLE = True
except ImportError:
    PIL_AVAILABLE = False

def create_joystick_icon(size=1024):
    """Create a joystick icon and return PIL Image."""
    if not PIL_AVAILABLE:
        print("PIL/Pillow not available")
        return None
    
    # Create image with white background
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Scale values based on size
    s = size / 200.0
    
    # Base (arcade cabinet style) - dark gray square
    base_x = int(20 * s)
    base_y = int(80 * s)
    base_w = int(160 * s)
    base_h = int(100 * s)
    base_color = (44, 44, 44, 255)
    draw.rectangle([base_x, base_y, base_x + base_w, base_y + base_h], 
                   fill=base_color, outline=(26, 26, 26, 255), width=int(2*s))
    
    # Stick ball mount (circular base for stick)
    mount_x = int(100 * s)
    mount_y = int(100 * s)
    mount_r = int(28 * s)
    draw.ellipse([mount_x - mount_r, mount_y - mount_r, mount_x + mount_r, mount_y + mount_r],
                 fill=(60, 60, 60, 255), outline=(10, 10, 10, 255), width=int(2*s))
    
    # Inner circle
    inner_r = int(24 * s)
    draw.ellipse([mount_x - inner_r, mount_y - inner_r, mount_x + inner_r, mount_y + inner_r],
                 fill=(26, 26, 26, 255), outline=(10, 10, 10, 255), width=int(1*s))
    
    # The stick itself (pointing up) - orange/red
    stick_x1 = int(90 * s)
    stick_y1 = int(30 * s)
    stick_x2 = int(110 * s)
    stick_y2 = int(105 * s)
    stick_color = (255, 107, 53, 255)
    draw.rectangle([stick_x1, stick_y1, stick_x2, stick_y2],
                   fill=stick_color, outline=(199, 58, 14, 255), width=int(1*s))
    
    # Stick ball (top of stick)
    ball_x = int(100 * s)
    ball_y = int(25 * s)
    ball_r = int(12 * s)
    draw.ellipse([ball_x - ball_r, ball_y - ball_r, ball_x + ball_r, ball_y + ball_r],
                 fill=stick_color, outline=(199, 58, 14, 255), width=int(2*s))
    
    # Highlight on stick ball
    highlight_r = int(4 * s)
    draw.ellipse([ball_x - 2*s - highlight_r, ball_y - 2*s - highlight_r, 
                  ball_x - 2*s + highlight_r, ball_y - 2*s + highlight_r],
                 fill=(255, 140, 83, 200))
    
    # Buttons on base
    # Red button
    button_r = int(10 * s)
    red_x = int(60 * s)
    red_y = int(150 * s)
    draw.ellipse([red_x - button_r, red_y - button_r, red_x + button_r, red_y + button_r],
                 fill=(255, 68, 68, 200), outline=(204, 0, 0, 255), width=int(1*s))
    
    # Blue button
    blue_x = int(140 * s)
    blue_y = int(150 * s)
    draw.ellipse([blue_x - button_r, blue_y - button_r, blue_x + button_r, blue_y + button_r],
                 fill=(68, 68, 255, 200), outline=(0, 0, 204, 255), width=int(1*s))
    
    # Yellow button
    button_r_y = int(8 * s)
    yellow_x = int(100 * s)
    yellow_y = int(160 * s)
    draw.ellipse([yellow_x - button_r_y, yellow_y - button_r_y, yellow_x + button_r_y, yellow_y + button_r_y],
                 fill=(255, 221, 0, 200), outline=(204, 170, 0, 255), width=int(1*s))
    
    return img

if __name__ == "__main__":
    if PIL_AVAILABLE:
        print("Creating joystick icons...")
        
        # Create 1024x1024 master image
        master_img = create_joystick_icon(1024)
        master_img.save("assets/joystick.png")
        print("✓ Created assets/joystick.png (1024x1024)")
        
        # Create Play Store icon (512x512)
        store_img = master_img.resize((512, 512), Image.Resampling.LANCZOS)
        store_img.save("assets/joystick_512.png")
        print("✓ Created assets/joystick_512.png (512x512 - Play Store)")
        
        # Create smaller versions for preview
        small_img = master_img.resize((256, 256), Image.Resampling.LANCZOS)
        small_img.save("assets/joystick_256.png")
        print("✓ Created assets/joystick_256.png (256x256)")
        
        print("\nAll icons generated successfully!")
    else:
        print("❌ PIL/Pillow not installed. Please install with: pip install Pillow")
        exit(1)
