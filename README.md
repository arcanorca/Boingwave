# Boingwave (KDE Plasma 6 Live Wallpaper)

<div align="center">
  <br/> <img src="https://github.com/arcanorca/Boingwave/blob/main/boingwave_animated.svg" width="200" />
  <br/> <br/> 
</div>

A visual recreation of the 1984 Amiga Boing Ball tech demo as a KDE Plasma 6 live wallpaper. Implemented using Qt/QML and Qt RHI shaders for hardware-accelerated rendering and consistent performance.

## // DEMO

https://github.com/user-attachments/assets/b895d35c-c34f-4201-8ab4-19307b759437

<br/>

<div align="center">
  <h3>[Settings GUI]</h3>
  <img src="https://github.com/user-attachments/assets/fc50d9b9-923a-414d-b2ba-6f931dde2ca1" alt="Appearence" width="32%" style="margin: 0.5%;" />
  <img src="https://github.com/user-attachments/assets/d5dadffe-e896-40b6-80cb-d444f6c6c4af" alt="Clock" width="32%" style="margin: 0.5%;" />
  <img src="https://github.com/user-attachments/assets/287face2-5a16-4fe8-8787-3e9d3221138e" alt="Performance" width="32%" style="margin: 0.5%;" />
</div>

<br/>

## // CONTROLS & CONFIG

**Settings Menu:**
* **Customizable Themes:** Select from built-in palettes: Amiga Original, Amber, Catppuccin, Dracula, Emerald, Everforest, Gruvbox, Kii (Wii-inspired UI), Monochrome, Nord, Paper Light, Rose Pine, and Tokyo Night.
* **Physics Modifiers:** Presets for bounce behavior ("Jupiter", "Classic 1984", and "Moon Float"), alongside manual animation speed multipliers.
* **CRT & Analog Effects:** Configurable parameters for Bloom, Noise, Jitter, RGB Shifting, Scanline intensity, and Screen Warp (Curvature).
* **Digital Clock:** Optional time overlay integrated into the shader background layer.


## // HOW IT WORKS

Boingwave utilizes Qt/QML and Qt RHI for rendering. It relies on a zero-allocation physics loop and layered fragment shaders to reduce CPU overhead.

### 1. Layered Drawing (The Shader Pipeline)

Rendering is separated into four distinct fragment shaders executed directly on the GPU, avoiding CPU-based rendering pipelines:
* **Background (`bg.frag`):** Renders the 3D perspective grid mathematically, offloading spatial calculations from the CPU.
* **The Ball (`ball.frag`):** Computes sphere geometry, lighting, and shadows. The color-cycling animation is mapped directly to the sphere's screen-space coordinates.
* **Retro Effects (`crt.frag`):** Applies post-processing filters, including bloom, screen curvature distortion, and analog noise simulation.
* **Digital Clock (`clock.frag`):** An overlay rendering the system time natively within the shader pipeline.

### 2. Power Savings

* **FPS Limit:** Rendering can be capped at specific intervals (15, 25, 30, 45, or 60 FPS) to minimize CPU wake-ups (cost of waking up the KDE Plasma)
* **Smart Pause:** An optional toggle that pauses the wallpaper when the desktop is covered by other windows, saving system resources, optionally it can still render the clock.

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
// BUILDING SHADERS (.qsb)

If you modify the .frag files, you must recompile them using Qt Shader Baker:

qsb --glsl "150,120" --spirv -o contents/shaders/bg.qsb contents/shaders/bg.frag
qsb --glsl "150,120" --spirv -o contents/shaders/ball.qsb contents/shaders/ball.frag
qsb --glsl "150,120" --spirv -o contents/shaders/crt.qsb contents/shaders/crt.frag
qsb --glsl "150,120" --spirv -o contents/shaders/clock.qsb contents/shaders/clock.frag

// CREDITS

* **Developer:** arcanorca
* **License:** GPL-3.0-or-later
* **Stack:** KDE Plasma 6 | Qt 6 (QML/JS) | GLSL (.qsb via Qt RHI) | kpackagetool6
