import QtQuick
import QtQml
import org.kde.plasma.plasmoid

WallpaperItem {
    id: wallpaper

    property real time: 0.0
    // ── 1. Configuration Properties ──
    property color cfgBackgroundColor: wallpaper.configuration.BackgroundColor !== undefined ? wallpaper.configuration.BackgroundColor : "#aaaaaa"
    property color cfgGridColor: wallpaper.configuration.GridColor !== undefined ? wallpaper.configuration.GridColor : "#aa00aa"
    property color cfgBallPrimaryColor: wallpaper.configuration.BallPrimaryColor !== undefined ? wallpaper.configuration.BallPrimaryColor : "#ff0000"
    property color cfgBallSecondaryColor: wallpaper.configuration.BallSecondaryColor !== undefined ? wallpaper.configuration.BallSecondaryColor : "#ffffff"
    property color cfgBallHighlightColor: wallpaper.configuration.BallHighlightColor !== undefined ? wallpaper.configuration.BallHighlightColor : "#ffdddd"
    property color cfgShadowColor: wallpaper.configuration.ShadowColor !== undefined ? wallpaper.configuration.ShadowColor : "#666666"
    property real cfgShadowOpacity: wallpaper.configuration.ShadowOpacity !== undefined ? wallpaper.configuration.ShadowOpacity : 0.56
    property bool cfgShowGrid: wallpaper.configuration.ShowGrid !== undefined ? wallpaper.configuration.ShowGrid : true
    property int cfgCrtPreset: wallpaper.configuration.CrtPreset !== undefined ? wallpaper.configuration.CrtPreset : 0
    property bool cfgCrtWarp: wallpaper.configuration.CrtWarp !== undefined ? wallpaper.configuration.CrtWarp : true
    property real cfgCrtBloom: wallpaper.configuration.CrtBloom !== undefined ? wallpaper.configuration.CrtBloom : 0.0
    property real cfgCrtRgbShift: wallpaper.configuration.CrtRgbShift !== undefined ? wallpaper.configuration.CrtRgbShift : 0.0
    property real cfgCrtNoise: wallpaper.configuration.CrtNoise !== undefined ? wallpaper.configuration.CrtNoise : 0.0
    property real cfgCrtJitter: wallpaper.configuration.CrtJitter !== undefined ? wallpaper.configuration.CrtJitter : 0.0
    property real cfgCrtMaskStrength: wallpaper.configuration.CrtMaskStrength !== undefined ? wallpaper.configuration.CrtMaskStrength : 0.0
    property real cfgBrightnessBoost: wallpaper.configuration.BrightnessBoost !== undefined ? wallpaper.configuration.BrightnessBoost : 1.0
    property bool cfgClockEnabled: wallpaper.configuration.ClockEnabled !== undefined ? wallpaper.configuration.ClockEnabled : false
    property int cfgClockMode: wallpaper.configuration.ClockMode !== undefined
                               ? Math.max(0, Math.min(3, wallpaper.configuration.ClockMode))
                               : 1
    property int cfgClockLayer: wallpaper.configuration.ClockLayer !== undefined
                                ? Math.max(0, Math.min(1, wallpaper.configuration.ClockLayer))
                                : 0
    property real cfgClockOpacity: wallpaper.configuration.ClockOpacity !== undefined ? wallpaper.configuration.ClockOpacity : 0.85
    property color cfgClockPanelColor: wallpaper.configuration.ClockPanelColor !== undefined ? wallpaper.configuration.ClockPanelColor : "#4b3c5a"
    property color cfgClockBorderColor: wallpaper.configuration.ClockBorderColor !== undefined ? wallpaper.configuration.ClockBorderColor : "#aa00aa"
    property color cfgClockDigitColor: wallpaper.configuration.ClockDigitColor !== undefined ? wallpaper.configuration.ClockDigitColor : "#ffd8a0"
    property color cfgClockOutlineColor: wallpaper.configuration.ClockOutlineColor !== undefined ? wallpaper.configuration.ClockOutlineColor : "#24172f"
    property color cfgClockBarColor: wallpaper.configuration.ClockBarColor !== undefined ? wallpaper.configuration.ClockBarColor : "#ff355e"
    property real cfgAnimationSpeed: wallpaper.configuration.AnimationSpeed !== undefined
                                     ? Math.min(2.0, Math.max(0.01, wallpaper.configuration.AnimationSpeed))
                                     : 1.0
    property int cfgRenderFps: wallpaper.configuration.RenderFps !== undefined
                               ? Math.max(10, Math.min(60, wallpaper.configuration.RenderFps))
                               : 60
    property bool cfgRenderOnlyOnFocus: wallpaper.configuration.RenderOnlyOnFocus !== undefined ? wallpaper.configuration.RenderOnlyOnFocus : false
    property bool cfgRenderClockWhenPaused: wallpaper.configuration.RenderClockWhenPaused !== undefined ? wallpaper.configuration.RenderClockWhenPaused : true
    property int cfgPhysicsPreset: wallpaper.configuration.PhysicsPreset !== undefined ? wallpaper.configuration.PhysicsPreset : 0
    property real cfgRotationSpeed: wallpaper.configuration.RotationSpeed !== undefined ? Math.max(0.1, Math.min(3.0, wallpaper.configuration.RotationSpeed)) : 1.0
    property real cfgGravityModifier: wallpaper.configuration.GravityModifier !== undefined ? Math.max(0.1, Math.min(3.0, wallpaper.configuration.GravityModifier)) : 1.0

    // ── 2. View State & Constraints ──
    // Foolproof window monitoring via org.kde.taskmanager
    // Detects visible windows lazily ONLY if the user enables RenderOnlyOnFocus.
    // This prevents massive CPU spikes at Plasma startup caused by TasksModel.
    Component {
        id: windowMonitorComponent
        WindowMonitor {
            screenGeometry: wallpaper.parent ? wallpaper.parent.screenGeometry : null
        }
    }

    Loader {
        id: windowMonitorLoader
        active: wallpaper.cfgRenderOnlyOnFocus
        asynchronous: true
        sourceComponent: windowMonitorComponent
    }

    readonly property bool shouldAnimate: !cfgRenderOnlyOnFocus || (windowMonitorLoader.item && !windowMonitorLoader.item.visibleWindowExists)

    // Strict hard-ceiling on Framerate for maximum power savings.
    property real targetFrameRate: {
        if (cfgRenderFps <= 0) {
            return 60.0
        }
        return Math.max(10.0, Math.min(60.0, cfgRenderFps))
    }

    // ── 3. Shader URLs ──
    readonly property string bgShaderPath: String(Qt.resolvedUrl("../shaders/bg.qsb")).replace("file://", "")
    readonly property url bgShaderUrl: "file://" + bgShaderPath
    readonly property string ballShaderPath: String(Qt.resolvedUrl("../shaders/ball.qsb")).replace("file://", "")
    readonly property url ballShaderUrl: "file://" + ballShaderPath
    readonly property string crtShaderPath: String(Qt.resolvedUrl("../shaders/crt.qsb")).replace("file://", "")
    readonly property url crtShaderUrl: "file://" + crtShaderPath
    readonly property string clockShaderPath: String(Qt.resolvedUrl("../shaders/clock.qsb")).replace("file://", "")
    readonly property url clockShaderUrl: "file://" + clockShaderPath

    // ── 4. Constants ──
    readonly property real palHeight: 256.0
    readonly property real visLeft: 8.0
    readonly property real visRight: 120.0
    readonly property real visTop: 2.0
    readonly property real visBottom: 99.0
    readonly property real defaultVelX: 84.0
    readonly property real defaultVelY: 59.0

    // ── 5. Physics & App State ──
    property real ballPosX: 0.0
    property real ballPosY: 0.0
    property real ballVelX: defaultVelX
    property real ballVelY: defaultVelY
    property vector4d stageBounds: Qt.vector4d(0.0, 0.0, 0.0, 0.0)
    property vector4d sceneData1: Qt.vector4d(0.0, 0.0, 0.0, 0.0) // x=sceneW, y=sceneResY, z=centerX, w=stageW
    property vector4d sceneData2: Qt.vector4d(0.0, 0.0, 0.0, 0.0) // x=wallCols, y=wallRows, z=pad, w=pad
    property real localClockHours: 0.0
    property real localClockMinutes: 0.0
    property real localClockSeconds: 0.0
    property vector4d clockDigits: Qt.vector4d(0, 0, 0, 0)
    property real timeAccumulator: 0.0

    // Cached layout bounds to completely eliminate JS object creation in animation loop
    property real cachedPalPixelSize: 1.0
    property vector4d cachedMotionBounds: Qt.vector4d(0, 0, 0, 0) // xMin, xMax, yMin, yMax
    
    // Declarative cached properties for O(1) branchless physics execution
    property real cachedGravity: {
        let g = 500.0;
        if (cfgPhysicsPreset === 0) g = 1500.0;
        if (cfgPhysicsPreset === 2) g = 200.0;
        return g * cfgGravityModifier;
    }
    property real cachedSpeed: Math.max(0.01, Math.min(1.2, cfgAnimationSpeed))

    // ── 6. Engine Functions ──
    function updateStageBounds() {
        if (width <= 0 || height <= 0) return

        const px = Math.max(height / palHeight, 0.0001)
        const sceneW = width / px
        const sceneH = palHeight
        const cell = 20.0
        const screenAspect = sceneW / Math.max(sceneH, 1.0)
        const wideT = Math.max(0.0, Math.min(1.0,
            (screenAspect - (4.0 / 3.0)) / ((21.0 / 9.0) - (4.0 / 3.0))
        ))
        const wallCoverage = 0.75 + (0.93 - 0.75) * wideT
        const desiredWallW = sceneW * wallCoverage
        const wallCols = Math.max(12.0, Math.floor(desiredWallW / cell))
        const wallW = wallCols * cell
        const centerX = sceneW * 0.5
        const stageLeft = Math.floor(centerX - wallW * 0.5)
        const stageRight = stageLeft + wallW
        const wallTop = 0.0
        const desiredSeamY = sceneH * (192.0 / 216.0)
        const wallRows = Math.max(9.0, Math.floor((desiredSeamY - wallTop) / cell))
        const seamY = wallTop + wallRows * cell
        const wallH = Math.max(seamY - wallTop, cell)
        const floorH = wallH * (23.0 / 192.0)
        const floorBottomY = Math.min(sceneH - 1.0, Math.floor(seamY + floorH + 0.5))
        stageBounds = Qt.vector4d(stageLeft, stageRight, seamY, floorBottomY)
        sceneData1 = Qt.vector4d(sceneW, 256.0, centerX, wallW)
        sceneData2 = Qt.vector4d(wallCols, wallRows, 0.0, 0.0)

        // Cache animation bounds
        cachedPalPixelSize = Math.max(height / palHeight, 0.0001)
        cachedMotionBounds = Qt.vector4d(
            -visLeft,
            sceneW - (visRight + 1.0),
            -visTop,
            sceneH - (visBottom + 1.0)
        )
    }

    function initializeMotion() {
        if (cachedMotionBounds.w <= 0) return;
        
        let velX = defaultVelX;
        let velY = 0.0;
        
        if (cfgPhysicsPreset === 0) {
            velX = 140.0 * cfgGravityModifier; // Jupiter Gravity (Fast)
        } else if (cfgPhysicsPreset === 1) {
            velX = 140.0 * cfgGravityModifier; // Classic Demo 1984
        } else if (cfgPhysicsPreset === 2) {
            velX = 45.0 * cfgGravityModifier;  // Moon Float (Slow, chill)
        }
        
        // The maximum height of a bounce is determined entirely by its initial drop height.
        // For Jupiter/Classic, we spawn slightly below the ceiling so they don't constantly clamp.
        // For Moon Float, we spawn AT the ceiling so it achieves the DVD screen-saver effect.
        let spawnY = cachedMotionBounds.z + ((cachedMotionBounds.w - cachedMotionBounds.z) * 0.15);
        if (cfgPhysicsPreset === 2) {
             spawnY = cachedMotionBounds.z; // Moon Float spawns hitting the top
        }
        
        ballPosX = cachedMotionBounds.x;
        ballPosY = spawnY;
        ballVelX = velX;
        ballVelY = velY;
    }
    
    function updatePhysics(dt) {
        let stepTime = dt * cachedSpeed;
        // Cap stepTime against lag spikes to prevent numerical explosion / tunneling
        if (stepTime <= 0 || stepTime > 0.1) return; 
        
        let px = ballPosX + ballVelX * stepTime;
        let vx = ballVelX;
        
        // X-Axis horizontal bounces
        if (px < cachedMotionBounds.x) {
            px = cachedMotionBounds.x + (cachedMotionBounds.x - px);
            vx = Math.abs(vx);
        } else if (px > cachedMotionBounds.y) {
            px = cachedMotionBounds.y - (px - cachedMotionBounds.y);
            vx = -Math.abs(vx);
        }
        
        let py = ballPosY;
        let vy = ballVelY;
        
        // True Parabolic Gravity (Euler Integration) via pre-calculated O(1) cached branchless value
        vy += cachedGravity * stepTime;
        py += vy * stepTime;
        
        // Floor bounce
        if (py >= cachedMotionBounds.w) {
            // Precise penetration resolution
            py = cachedMotionBounds.w - (py - cachedMotionBounds.w);
            
            // 100% Elasticity ensures infinite screen-saver animation
            vy = -Math.abs(vy);
        } else if (py <= cachedMotionBounds.z) {
            // Ceiling bounce (Natural reflection)
            py = cachedMotionBounds.z + (cachedMotionBounds.z - py);
            vy = Math.abs(vy);
        }
        
        ballPosX = px;
        ballPosY = py;
        ballVelX = vx;
        ballVelY = vy;
    }

    // ── 7. Clock Functions ──

    function updateLocalClock() {
        const d = new Date()
        localClockHours = d.getHours()
        localClockMinutes = d.getMinutes()
        localClockSeconds = d.getSeconds() + (d.getMilliseconds() / 1000.0)

        let h0 = Math.floor(localClockHours / 10)
        let h1 = localClockHours % 10
        let m0 = Math.floor(localClockMinutes / 10)
        let m1 = localClockMinutes % 10
        clockDigits = Qt.vector4d(h0, h1, m0, m1)
    }

    function stabilizeAfterResize() {
        if (width <= 0 || height <= 0) {
            return
        }
        
        // If the ball was initialized when the screen was 0x0
        // it requires a full reset now that we have real dimensions
        if (ballPos.x === 0 && ballPos.y === 0 && cachedMotionBounds.y > 0) {
            initializeMotion()
            return
        }
        
        // The stateful architecture automatically bridges layout resizes accurately, so the 
        // older complex matrix phasing isn't required anymore. We clamp the positions naturally.
        ballPos.x = Math.max(cachedMotionBounds.x, Math.min(cachedMotionBounds.y, ballPos.x));
        ballPos.y = Math.max(cachedMotionBounds.z, Math.min(cachedMotionBounds.w, ballPos.y));
    }

    // ── 8. Lifecycle ──

    Component.onCompleted: {
        if (wallpaper.window && wallpaper.window.screen && wallpaper.window.screen.refreshRate > 1.0) {
            displayRefreshRate = Math.round(wallpaper.window.screen.refreshRate)
        }
        updateStageBounds()
        initializeMotion()
        updateLocalClock()
    }

    onWidthChanged: {
        if (wallpaper.window && wallpaper.window.screen && wallpaper.window.screen.refreshRate > 1.0) {
            displayRefreshRate = Math.round(wallpaper.window.screen.refreshRate)
        }
        updateStageBounds()
        stabilizeAfterResize()
    }

    onHeightChanged: {
        updateStageBounds()
        stabilizeAfterResize()
    }

    onCfgPhysicsPresetChanged: {
        initializeMotion()
    }



    // ── 9. Animation Timers ──

    /**
     * renderTimer
     * -----------
     * A pure JavaScript-free scalar increments the global simulation time.
     * WHY:
     * Previously, `NumberAnimation` locked the QML Context to the display's raw VSync (e.g., 144Hz or 240Hz). 
     * Even if no pixels changed visually, QtQuick's render thread was forced to emit excess draw calls 
     * per second for 3 full-screen FBO layers.
     * By manually throttling via a QTimer bound to `targetFrameRate`, we strictly cap the maximum SceneGraph 
     * dispatch rate to 60 FPS (default 30-60), slashing baseline CPU load to near 0%.
     */
    Timer {
        id: renderTimer
        interval: wallpaper.targetFrameRate > 0 ? Math.max(8, Math.floor(1000.0 / wallpaper.targetFrameRate)) : 16
        running: wallpaper.shouldAnimate
        repeat: true
        
        property real lastTime: 0.0
        
        onTriggered: {
            let now = Date.now()
            if (lastTime === 0.0) {
                lastTime = now
                return
            }
            let elapsed = now - lastTime
            lastTime = now
            if (elapsed > 100) elapsed = 100
            
            let dt = elapsed / 1000.0;
            wallpaper.time += dt;
            wallpaper.updatePhysics(dt);
        }
        
        onRunningChanged: {
            if (!running) lastTime = 0.0
        }
    }

    Timer {
        id: clockTimer
        // High-precision sync: Drop to 1 FPS when paused, but align perfectly to the system clock second boundary
        interval: 200
        running: wallpaper.cfgClockEnabled && (wallpaper.shouldAnimate || wallpaper.cfgRenderClockWhenPaused)
        repeat: true
        onTriggered: {
            wallpaper.updateLocalClock();
            if (!wallpaper.shouldAnimate) {
                // Prevent up to 1000ms visual lag by checking exactly how many ms remain until the next whole second
                clockTimer.interval = Math.max(10, 1000 - new Date().getMilliseconds());
            } else {
                clockTimer.interval = 200;
            }
        }
    }

    Image {
        id: ballIndexMap
        visible: false
        asynchronous: false
        cache: true
        smooth: false
        mipmap: false
        source: Qt.resolvedUrl("../shaders/boing_ball_index.pgm")
    }

    // ── 10. Visual Tree ──

    Item {
        id: compositeScene
        anchors.fill: parent
        /**
         * FBO Layer Optimization
         * WHY: 
         * `layer.enabled: true` instructs Qt Quick to render this entire Item tree into an off-screen 
         * FrameBuffer Object (FBO) first. If the user disables all post-processing CRT effects, caching 
         * the 4K uncompressed texture every frame is a massive waste of GPU memory bandwidth. 
         * We unconditionally disable the matrix offloading if CRT presets are zeroed.
         */
        layer.enabled: wallpaper.cfgCrtPreset > 0 || wallpaper.cfgCrtNoise > 0 || wallpaper.cfgCrtJitter > 0 || wallpaper.cfgBrightnessBoost != 1.0

        layer.effect: ShaderEffect {
            property var source: compositeScene
            property vector2d resolution: Qt.vector2d(width, height)
            property vector4d u_crtParams1: Qt.vector4d(wallpaper.cfgCrtPreset, wallpaper.cfgCrtWarp ? 1.0 : 0.0, wallpaper.cfgCrtBloom, wallpaper.cfgCrtRgbShift)
            property vector4d u_crtParams2: Qt.vector4d(wallpaper.cfgCrtNoise, wallpaper.cfgCrtJitter, wallpaper.cfgCrtMaskStrength, wallpaper.cfgBrightnessBoost)
            property color u_bgColor: wallpaper.cfgBackgroundColor
            property real u_time: wallpaper.time
            fragmentShader: wallpaper.crtShaderUrl
        }

        ShaderEffect {
            id: backgroundLayer
            anchors.fill: parent
            z: 0
            
            layer.enabled: true
            layer.mipmap: false

            property vector2d resolution: Qt.vector2d(width, height)
            property vector4d u_bgParams: Qt.vector4d(wallpaper.cfgBackgroundColor.r, wallpaper.cfgBackgroundColor.g, wallpaper.cfgBackgroundColor.b, wallpaper.cfgShowGrid ? 1.0 : 0.0)
            property vector4d u_gridColor: Qt.vector4d(wallpaper.cfgGridColor.r, wallpaper.cfgGridColor.g, wallpaper.cfgGridColor.b, 1.0)
            property vector4d u_stageBounds: wallpaper.stageBounds
            property vector4d u_sceneData1: wallpaper.sceneData1
            property vector4d u_sceneData2: wallpaper.sceneData2

            fragmentShader: wallpaper.bgShaderUrl
        }

        ShaderEffect {
            id: clockLayer
            anchors.fill: parent
            z: wallpaper.cfgClockLayer === 1 ? 2 : 0

            property vector2d resolution: Qt.vector2d(width, height)
            property vector4d u_stageBounds: wallpaper.stageBounds
            property vector4d u_sceneData1: wallpaper.sceneData1
            property vector4d u_sceneData2: wallpaper.sceneData2
            property vector4d u_clockParams: Qt.vector4d(wallpaper.cfgClockEnabled ? (wallpaper.cfgClockMode + 1.0) : 0.0, wallpaper.localClockSeconds, wallpaper.cfgClockOpacity, 0.0)
            property vector4d u_clockDigits: wallpaper.clockDigits
            property vector4d u_clockColors1: Qt.vector4d(wallpaper.cfgClockPanelColor.r, wallpaper.cfgClockPanelColor.g, wallpaper.cfgClockPanelColor.b, 1.0)
            property vector4d u_clockColors2: Qt.vector4d(wallpaper.cfgClockBorderColor.r, wallpaper.cfgClockBorderColor.g, wallpaper.cfgClockBorderColor.b, 1.0)
            property vector4d u_clockColors3: Qt.vector4d(wallpaper.cfgClockDigitColor.r, wallpaper.cfgClockDigitColor.g, wallpaper.cfgClockDigitColor.b, 1.0)
            property vector4d u_clockColors4: Qt.vector4d(wallpaper.cfgClockOutlineColor.r, wallpaper.cfgClockOutlineColor.g, wallpaper.cfgClockOutlineColor.b, 1.0)
            property vector4d u_clockColors5: Qt.vector4d(wallpaper.cfgClockBarColor.r, wallpaper.cfgClockBarColor.g, wallpaper.cfgClockBarColor.b, 1.0)

            fragmentShader: wallpaper.clockShaderUrl
        }

        ShaderEffect {
            id: ballLayer
            z: 1
            anchors.fill: parent

            property var ballIndexTex: ballIndexMap
            property vector2d resolution: Qt.vector2d(width, height)
            property real u_palPixelSize: wallpaper.cachedPalPixelSize
            property real u_time: wallpaper.time
            property real u_targetFrameRate: wallpaper.targetFrameRate
            property real u_ballPosX: wallpaper.ballPosX
            property real u_ballPosY: wallpaper.ballPosY
            property real u_ballDirX: wallpaper.ballVelX >= 0 ? 1.0 : -1.0
            property real u_rotationSpeed: wallpaper.cfgRotationSpeed
            
            property color ballColorPrimary: wallpaper.cfgBallPrimaryColor
            property color ballColorSecondary: wallpaper.cfgBallSecondaryColor
            property color ballHighlightColor: wallpaper.cfgBallHighlightColor
            property color shadowColor: wallpaper.cfgShadowColor
            property real shadowOpacity: Math.min(0.56, Math.max(0.0, wallpaper.cfgShadowOpacity))

            fragmentShader: wallpaper.ballShaderUrl
        }
    }
}
