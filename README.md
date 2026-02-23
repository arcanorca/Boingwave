# Boingwave (KDE Plasma 6 Live Wallpaper)

<div align="center">
  <br/> <img src="https://raw.githubusercontent.com/arcanorca/boingwave/main/logo.svg" width="200" />
  <br/> <br/> 
</div>

A lightweight, mathematically rigorous recreation of the historic 1984 Amiga Boing Ball tech demo. Optimized for modern hardware, interactive, and performance-friendly.

## // DEMO

https://github.com/user-attachments/assets/your-demo-video-link.webm

<div align="center">
  <h3>[Screenshots]</h3>
  
  <img src="https://github.com/user-attachments/assets/screenshot-1-link" width="45%" style="margin:5px;" />
  <img src="https://github.com/user-attachments/assets/screenshot-2-link" width="45%" style="margin:5px;" />
  
  <br/>

  <img src="https://github.com/user-attachments/assets/screenshot-3-link" width="45%" style="margin:5px;" />
  <img src="https://github.com/user-attachments/assets/screenshot-4-link" width="45%" style="margin:5px;" />

  <br/><br/>

  <h3>[Settings GUI]</h3>
  <img src="https://github.com/user-attachments/assets/settings-gui-link" width="30%" style="box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2); border-radius: 10px;" />
</div>

## // HOW IT WORKS

Boingwave is not just a visual homage; it is an exercise in Qt/QML and OpenGL/Vulkan performance optimization. It runs a true 0-allocation physics simulation and uses layered GPU shader processing to minimize resource usage while delivering a smooth, retro aesthetic.

### 1. Layered Drawing (The Shader Pipeline)

Instead of using standard, heavy desktop drawing methods, Boingwave splits the visual work into four independent, highly optimized "layers" that run directly on your Graphics Card (GPU):
* **Background (`bg.frag`):** Draws the endless 3D grid using pure mathematics without bothering your computer's main processor (CPU).
* **The Ball (`ball.frag`):** Renders the perfect 3D sphere, lighting, and shadow. It recreates the classic 1984 color-spinning illusion just by tracking where the ball is on the screen.
* **Retro Effects (`crt.frag`):** Adds the vintage television look, including glowing colors (bloom), curved edges, and analog static noise.
* **Digital Clock (`clock.frag`):** A lightweight overlay that displays the time without slowing down the physics.

### 2. Zero-Lag Physics

Most animated wallpapers use standard JavaScript to calculate where things should bounce. This creates temporary memory junk, forcing your computer to pause and "clean up the trash" (Garbage Collection), which causes micro-stutters.
* **Math, Not Objects:** Boingwave's physics engine completely bypasses this issue. It uses raw numbers instead of complex code objects, meaning it generates **zero memory trash**.
* **Instant Calculations:** When you change settings like Gravity, the engine pre-calculates the formulas instantly. The actual bouncing loop is a pure, frictionless math equation.

### 3. Smart Power Savings

* **Strict FPS Limit:** Modern monitors often run at 144Hz or 240Hz. A bouncing ball doesn't need to be drawn 240 times a second. Boingwave lets you put a hard cap on the framerate (e.g., 60 FPS), which dramatically reduces power consumption and heat.
* **Smart Pause:** An optional feature allows the wallpaper to completely turn itself off when you maximize a window over it. If you can't see the desktop, it uses exactly 0% of your CPU and GPU.

## // INSTALLATION

**Requirements**: KDE Plasma 6 + kpackagetool6 ( `plasma-workspace` and `qt6-declarative` )

### KDE Store

`Desktop and Wallpaper` -> `Get New Plugins...` -> search `Boingwave`

### Git (Local Deploy)

```bash
# 1. Clone the repo
git clone https://github.com/arcanorca/boingwave.git
cd boingwave

# 2. Build shaders and deploy
./build_and_deploy.sh

# If Plasma still shows stale QML/settings, restart the shell:
# plasmashell --replace & disown
```

## // CONTROLS & CONFIG

**Settings Menu:**
* **Theme Presets:** Select from 13 different aesthetic palettes: Amiga Original, Amber, Catppuccin, Dracula, Emerald, Everforest, Gruvbox, Kii (Wii-inspired UI), Monochrome, Nord, Paper Light, Rose Pine, and Tokyo Night.
* **Physics Modifiers:** Shift seamlessly between "Jupiter" (Heavy), "Classic 1984", and "Moon Float" You can also manually adjust the animation speed multiplier.
* **CRT & Analog Effects:** Granular toggles for Bloom, Noise, Jitter, RGB Shifting, Scanline intensity, and Screen Warp (Curvature).
* **Digital Clock:** Optional, customizable clock overlay integrated into the background layer.

## // BUILDING SHADERS (.qsb)

If you modify the `.frag` files, you must recompile them using Qt Shader Baker:

```bash
qsb --glsl "150,120" --spirv -o contents/shaders/bg.qsb contents/shaders/bg.frag
qsb --glsl "150,120" --spirv -o contents/shaders/ball.qsb contents/shaders/ball.frag
qsb --glsl "150,120" --spirv -o contents/shaders/crt.qsb contents/shaders/crt.frag
qsb --glsl "150,120" --spirv -o contents/shaders/clock.qsb contents/shaders/clock.frag
```
*(A helper script `build_shaders.sh` is included in the project root).*

## // CREDITS

* **Developer:** arcanorca
* **License:** GPL-3.0-or-later
* **Stack:** KDE Plasma 6 • Qt 6 (QML/JS) • GLSL (.qsb via Qt RHI) • kpackagetool6
