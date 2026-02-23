import QtQuick
import QtQuick.Controls as QtControls
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: root

    property string cfg_Theme: "Amiga Original"
    property color cfg_BackgroundColor: "#aaaaaa"
    property color cfg_GridColor: "#aa00aa"
    property color cfg_BallPrimaryColor: "#ff0000"
    property color cfg_BallSecondaryColor: "#ffffff"
    property color cfg_BallHighlightColor: "#ffdddd"
    property color cfg_ShadowColor: "#1a1a1a"
    property real cfg_ShadowOpacity: 0.5
    property bool cfg_ShowGrid: true
    property real cfg_BrightnessBoost: 1.0
    property int cfg_CrtPreset: 0
    property bool cfg_CrtWarp: true
    property real cfg_CrtBloom: 0.0
    property real cfg_CrtRgbShift: 0.0
    property real cfg_CrtNoise: 0.0
    property real cfg_CrtJitter: 0.0
    property real cfg_CrtMaskStrength: 0.0
    property bool cfg_ClockEnabled: false
    property int cfg_ClockMode: 1
    property int cfg_ClockLayer: 0
    property real cfg_ClockOpacity: 0.85
    property color cfg_ClockPanelColor: "#4b3c5a"
    property color cfg_ClockBorderColor: "#aa00aa"
    property color cfg_ClockDigitColor: "#ffd8a0"
    property color cfg_ClockOutlineColor: "#24172f"
    property color cfg_ClockBarColor: "#ff355e"
    property real cfg_AnimationSpeed: 0.6
    property int cfg_RenderFps: 60
    property bool cfg_RenderOnlyOnFocus: false
    property bool cfg_RenderClockWhenPaused: true
    property int cfg_PhysicsPreset: 0
    property real cfg_GravityModifier: 1.0
    property real cfg_RotationSpeed: 1.0
    property bool syncingTheme: false
    readonly property var renderFpsValues: [10, 15, 25, 30, 45, 60]
    readonly property var renderFpsLabels: ["10 FPS", "15 FPS", "25 FPS", "30 FPS", "45 FPS", "60 FPS"]
    readonly property var themeNames: ["Amiga Original", "Amber", "Catppuccin", "Dracula", "Emerald", "Everforest", "Gruvbox", "Kii", "Monochrome", "Nord", "Paper Light", "Rose Pine", "Tokyo Night"]
    readonly property var themePresets: ({
        "Amiga Original": {
            "background": "#aaaaaa",
            "grid": "#aa00aa",
            "ballPrimary": "#ff0000",
            "ballSecondary": "#ffffff",
            "highlight": "#ffdddd",
            "shadow": "#1a1a1a",
            "clockPanel": "#4b3c5a",
            "clockBorder": "#aa00aa",
            "clockDigit": "#ffd8a0",
            "clockOutline": "#24172f",
            "clockBar": "#ff355e"
        },
        "Amber": {
            "background": "#3a2b16",
            "grid": "#f0b35a",
            "ballPrimary": "#f7a600",
            "ballSecondary": "#fff1d8",
            "highlight": "#ffe0a2",
            "shadow": "#24190d",
            "clockPanel": "#2a1f10",
            "clockBorder": "#ffbf66",
            "clockDigit": "#ffdca8",
            "clockOutline": "#130c04",
            "clockBar": "#ff9f1c"
        },
        "Catppuccin": {
            "background": "#1e1e2e",
            "grid": "#cba6f7",
            "ballPrimary": "#f38ba8",
            "ballSecondary": "#f5e0dc",
            "highlight": "#ffd9e4",
            "shadow": "#45475a",
            "clockPanel": "#313244",
            "clockBorder": "#b4befe",
            "clockDigit": "#cdd6f4",
            "clockOutline": "#11111b",
            "clockBar": "#fab387"
        },
        "Dracula": {
            "background": "#282a36",
            "grid": "#bd93f9",
            "ballPrimary": "#ff5555",
            "ballSecondary": "#f8f8f2",
            "highlight": "#ffb86c",
            "shadow": "#44475a",
            "clockPanel": "#44475a",
            "clockBorder": "#bd93f9",
            "clockDigit": "#f8f8f2",
            "clockOutline": "#21222c",
            "clockBar": "#ff79c6"
        },
        "Emerald": {
            "background": "#1f3a35",
            "grid": "#6fc9a8",
            "ballPrimary": "#48b58b",
            "ballSecondary": "#e3f7ef",
            "highlight": "#f3fff9",
            "shadow": "#122420",
            "clockPanel": "#16302a",
            "clockBorder": "#6fc9a8",
            "clockDigit": "#dbffe9",
            "clockOutline": "#0b1916",
            "clockBar": "#48b58b"
        },
        "Everforest": {
            "background": "#2d353b",
            "grid": "#a7c080",
            "ballPrimary": "#e67e80",
            "ballSecondary": "#d3c6aa",
            "highlight": "#dbbc7f",
            "shadow": "#475258",
            "clockPanel": "#323c41",
            "clockBorder": "#a7c080",
            "clockDigit": "#d3c6aa",
            "clockOutline": "#1e2326",
            "clockBar": "#e69875"
        },
        "Gruvbox": {
            "background": "#282828",
            "grid": "#d3869b",
            "ballPrimary": "#fb4934",
            "ballSecondary": "#ebdbb2",
            "highlight": "#fabd2f",
            "shadow": "#504945",
            "clockPanel": "#3c3836",
            "clockBorder": "#d3869b",
            "clockDigit": "#fbf1c7",
            "clockOutline": "#1d2021",
            "clockBar": "#fe8019"
        },
        "Kii": {
            "background": "#ffffff",
            "grid": "#939394",
            "ballPrimary": "#00aeff",
            "ballSecondary": "#f0f0f0",
            "highlight": "#ffffff",
            "shadow": "#939394",
            "clockPanel": "#f0f0f0",
            "clockBorder": "#939394",
            "clockDigit": "#005075",
            "clockOutline": "#ffffff",
            "clockBar": "#a4d65e"
        },
        "Monochrome": {
            "background": "#9f9f9f",
            "grid": "#5d5d5d",
            "ballPrimary": "#3a3a3a",
            "ballSecondary": "#ececec",
            "highlight": "#ffffff",
            "shadow": "#404040",
            "clockPanel": "#4a4a4a",
            "clockBorder": "#d9d9d9",
            "clockDigit": "#ffffff",
            "clockOutline": "#121212",
            "clockBar": "#c8c8c8"
        },
        "Nord": {
            "background": "#2e3440",
            "grid": "#88c0d0",
            "ballPrimary": "#bf616a",
            "ballSecondary": "#e5e9f0",
            "highlight": "#ebcb8b",
            "shadow": "#4c566a",
            "clockPanel": "#3b4252",
            "clockBorder": "#88c0d0",
            "clockDigit": "#eceff4",
            "clockOutline": "#2e3440",
            "clockBar": "#ebcb8b"
        },
        "Paper Light": {
            "background": "#f2ebe3",
            "grid": "#a35ec4",
            "ballPrimary": "#d65a31",
            "ballSecondary": "#fff8ee",
            "highlight": "#ffd2bf",
            "shadow": "#8b8177",
            "clockPanel": "#d6c4ad",
            "clockBorder": "#7a5a42",
            "clockDigit": "#2f2216",
            "clockOutline": "#f8eee0",
            "clockBar": "#b75a3a"
        },
        "Rose Pine": {
            "background": "#191724",
            "grid": "#c4a7e7",
            "ballPrimary": "#eb6f92",
            "ballSecondary": "#e0def4",
            "highlight": "#f6c177",
            "shadow": "#403d52",
            "clockPanel": "#1f1d2e",
            "clockBorder": "#c4a7e7",
            "clockDigit": "#e0def4",
            "clockOutline": "#191724",
            "clockBar": "#f6c177"
        },
        "Tokyo Night": {
            "background": "#1a1b26",
            "grid": "#bb9af7",
            "ballPrimary": "#f7768e",
            "ballSecondary": "#c0caf5",
            "highlight": "#ff9e64",
            "shadow": "#414868",
            "clockPanel": "#24283b",
            "clockBorder": "#bb9af7",
            "clockDigit": "#c0caf5",
            "clockOutline": "#16161e",
            "clockBar": "#7dcfff"
        }
    })

    function applyTheme(name) {
        const p = themePresets[name];
        if (!p)
            return ;

        cfg_BackgroundColor = p.background;
        cfg_GridColor = p.grid;
        cfg_BallPrimaryColor = p.ballPrimary;
        cfg_BallSecondaryColor = p.ballSecondary;
        cfg_BallHighlightColor = p.highlight;
        cfg_ShadowColor = p.shadow;
        cfg_ClockPanelColor = p.clockPanel;
        cfg_ClockBorderColor = p.clockBorder;
        cfg_ClockDigitColor = p.clockDigit;
        cfg_ClockOutlineColor = p.clockOutline;
        cfg_ClockBarColor = p.clockBar;
    }

    function resetAppearanceDefaults() {
        cfg_Theme = "Amiga Original";
        applyTheme("Amiga Original");
        cfg_ShadowOpacity = 0.5;
        cfg_BrightnessBoost = 1.0;
        cfg_CrtPreset = 0;
        cfg_CrtWarp = false;
        cfg_CrtBloom = 0.0;
        cfg_CrtRgbShift = 0.0;
        cfg_CrtNoise = 0.0;
        cfg_CrtJitter = 0.0;
        cfg_CrtMaskStrength = 0.0;
        cfg_ShowGrid = true;
    }

    function resetClockDefaults() {
        cfg_ClockEnabled = false;
        cfg_RenderClockWhenPaused = true;
        cfg_ClockMode = 1;
        cfg_ClockLayer = 1;
        cfg_ClockOpacity = 0.85;
        const p = themePresets["Amiga Original"];
        cfg_ClockPanelColor = p.clockPanel;
        cfg_ClockDigitColor = p.clockDigit;
        cfg_ClockOutlineColor = p.clockOutline;
        cfg_ClockBarColor = p.clockBar;
    }

    function resetPerformanceDefaults() {
        cfg_AnimationSpeed = 0.6;
        cfg_RenderFps = 30;
        cfg_RenderOnlyOnFocus = false;
        cfg_PhysicsPreset = 1;
        cfg_GravityModifier = 1.0;
        cfg_RotationSpeed = 1.0;
    }

    function setThemeIndex() {
        if (!themeCombo)
            return ;

        const idx = themeNames.indexOf(cfg_Theme);
        if (idx >= 0 && themeCombo.currentIndex !== idx) {
            syncingTheme = true;
            themeCombo.currentIndex = idx;
            syncingTheme = false;
        }
    }

    function renderFpsIndex(value) {
        const idx = renderFpsValues.indexOf(value);
        return idx >= 0 ? idx : 3;
    }

    Component.onCompleted: setThemeIndex()
    onCfg_ThemeChanged: setThemeIndex()

    QtControls.TabBar {
        id: tabBar

        Layout.fillWidth: true

        QtControls.TabButton {
            text: "Appearance"
        }

        QtControls.TabButton {
            text: "Clock"
        }

        QtControls.TabButton {
            text: "Performance"
        }

    }

    StackLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        currentIndex: tabBar.currentIndex

        // ── Appearance Tab ──
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            QtControls.ScrollView {
                anchors.fill: parent
                clip: true

                Kirigami.FormLayout {
                    width: parent.width

                    RowLayout {
                        Kirigami.FormData.label: "Theme preset:"
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        QtControls.ComboBox {
                            id: themeCombo

                            Layout.fillWidth: true
                            Layout.maximumWidth: Kirigami.Units.gridUnit * 15
                            model: root.themeNames
                            onCurrentIndexChanged: {
                                if (root.syncingTheme || currentIndex < 0 || currentIndex >= root.themeNames.length)
                                    return ;

                                const selected = root.themeNames[currentIndex];
                                if (root.cfg_Theme !== selected)
                                    root.cfg_Theme = selected;

                                root.applyTheme(selected);
                            }
                        }
                    }

                    Kirigami.Separator {
                        Layout.fillWidth: true
                        Layout.topMargin: Kirigami.Units.largeSpacing
                        Layout.bottomMargin: Kirigami.Units.smallSpacing
                    }

                    ColorSettingRow {
                        formLabel: "Background:"
                        colorValue: root.cfg_BackgroundColor
                        pickerDialog: backgroundDialog
                    }

                    ColorSettingRow {
                        formLabel: "Grid:"
                        colorValue: root.cfg_GridColor
                        pickerDialog: gridDialog
                    }

                    Kirigami.Separator {
                        Layout.fillWidth: true
                        Layout.topMargin: Kirigami.Units.largeSpacing
                        Layout.bottomMargin: Kirigami.Units.smallSpacing
                    }

                    ColorSettingRow {
                        formLabel: "Ball primary:"
                        colorValue: root.cfg_BallPrimaryColor
                        pickerDialog: ballPrimaryDialog
                    }

                    ColorSettingRow {
                        formLabel: "Ball secondary:"
                        colorValue: root.cfg_BallSecondaryColor
                        pickerDialog: ballSecondaryDialog
                    }

                    ColorSettingRow {
                        formLabel: "Ball highlight:"
                        colorValue: root.cfg_BallHighlightColor
                        pickerDialog: ballHighlightDialog
                    }

                    ColorSettingRow {
                        formLabel: "Ball shadow:"
                        colorValue: root.cfg_ShadowColor
                        pickerDialog: shadowDialog
                    }

                    RowLayout {
                        Kirigami.FormData.label: "Ball shadow opacity:"
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        QtControls.Slider {
                            Layout.fillWidth: true
                            Layout.maximumWidth: Kirigami.Units.gridUnit * 15
                            from: 0
                            to: 1.0
                            stepSize: 0.01
                            value: root.cfg_ShadowOpacity
                            onMoved: root.cfg_ShadowOpacity = value
                            onValueChanged: root.cfg_ShadowOpacity = value
                        }

                        QtControls.Label {
                            text: Number(root.cfg_ShadowOpacity).toFixed(2)
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                        }

                    }

                    RowLayout {
                        Kirigami.FormData.label: "Brightness boost:"
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        QtControls.Slider {
                            Layout.fillWidth: true
                            Layout.maximumWidth: Kirigami.Units.gridUnit * 15
                            from: 0.5
                            to: 1.5
                            stepSize: 0.05
                            value: root.cfg_BrightnessBoost
                            onMoved: root.cfg_BrightnessBoost = value
                            onValueChanged: root.cfg_BrightnessBoost = value
                        }

                        QtControls.Label {
                            text: Number(root.cfg_BrightnessBoost).toFixed(2) + "x"
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                        }
                    }

                    Kirigami.Separator {
                        Layout.fillWidth: true
                        Layout.topMargin: Kirigami.Units.largeSpacing
                        Layout.bottomMargin: Kirigami.Units.smallSpacing
                    }

                    RowLayout {
                        Kirigami.FormData.label: "CRT filter:"
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        QtControls.ComboBox {
                            Layout.fillWidth: true
                            Layout.maximumWidth: Kirigami.Units.gridUnit * 15
                            model: ["Off", "ZFast", "Easymode", "Geom", "Royale-Lite"]
                            currentIndex: Math.max(0, Math.min(4, root.cfg_CrtPreset))
                            onActivated: root.cfg_CrtPreset = currentIndex
                        }
                    }

                    QtControls.CheckBox {
                        Kirigami.FormData.label: "Screen curvature:"
                        text: "Enable CRT screen warp"
                        checked: root.cfg_CrtWarp
                        enabled: root.cfg_CrtPreset >= 1
                        onToggled: root.cfg_CrtWarp = checked
                    }

                    RowLayout {
                        Kirigami.FormData.label: "Bloom:"
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing
                        enabled: root.cfg_CrtPreset >= 1

                        QtControls.Slider {
                            Layout.fillWidth: true
                            Layout.maximumWidth: Kirigami.Units.gridUnit * 15
                            from: -1; to: 1; stepSize: 0.05
                            value: root.cfg_CrtBloom
                            onMoved: root.cfg_CrtBloom = value
                        }
                        QtControls.Label {
                            text: Number(root.cfg_CrtBloom).toFixed(2)
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                        }
                    }

                    RowLayout {
                        Kirigami.FormData.label: "Chromatic aberration:"
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing
                        enabled: root.cfg_CrtPreset >= 1

                        QtControls.Slider {
                            Layout.fillWidth: true
                            Layout.maximumWidth: Kirigami.Units.gridUnit * 15
                            from: 0; to: 1; stepSize: 0.05
                            value: root.cfg_CrtRgbShift
                            onMoved: root.cfg_CrtRgbShift = value
                        }
                        QtControls.Label {
                            text: Number(root.cfg_CrtRgbShift).toFixed(2)
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                        }
                    }

                    RowLayout {
                        Kirigami.FormData.label: "Signal noise:"
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing
                        enabled: root.cfg_CrtPreset >= 1

                        QtControls.Slider {
                            Layout.fillWidth: true
                            Layout.maximumWidth: Kirigami.Units.gridUnit * 15
                            from: 0; to: 0.5; stepSize: 0.01
                            value: root.cfg_CrtNoise
                            onMoved: root.cfg_CrtNoise = value
                        }
                        QtControls.Label {
                            text: Number(root.cfg_CrtNoise).toFixed(2)
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                        }
                    }

                    RowLayout {
                        Kirigami.FormData.label: "Scanline jitter:"
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing
                        enabled: root.cfg_CrtPreset >= 1

                        QtControls.Slider {
                            Layout.fillWidth: true
                            Layout.maximumWidth: Kirigami.Units.gridUnit * 15
                            from: 0; to: 1; stepSize: 0.05
                            value: root.cfg_CrtJitter
                            onMoved: root.cfg_CrtJitter = value
                        }
                        QtControls.Label {
                            text: Number(root.cfg_CrtJitter).toFixed(2)
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                        }
                    }

                    RowLayout {
                        Kirigami.FormData.label: "Phosphor mask:"
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing
                        enabled: root.cfg_CrtPreset >= 1

                        QtControls.Slider {
                            Layout.fillWidth: true
                            Layout.maximumWidth: Kirigami.Units.gridUnit * 15
                            from: 0; to: 1; stepSize: 0.05
                            value: root.cfg_CrtMaskStrength
                            onMoved: root.cfg_CrtMaskStrength = value
                        }
                        QtControls.Label {
                            text: Number(root.cfg_CrtMaskStrength).toFixed(2)
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                        }
                    }


                    Kirigami.Separator {
                        Layout.fillWidth: true
                        Layout.topMargin: Kirigami.Units.largeSpacing
                        Layout.bottomMargin: Kirigami.Units.smallSpacing
                    }

                    QtControls.CheckBox {
                        Kirigami.FormData.label: "Grid:"
                        text: "Show grid overlay"
                        checked: root.cfg_ShowGrid
                        onToggled: root.cfg_ShowGrid = checked
                    }

                    QtControls.Button {
                        text: "Reset to Defaults"
                        icon.name: "edit-undo"
                        Layout.topMargin: Kirigami.Units.largeSpacing
                        onClicked: root.resetAppearanceDefaults()
                    }

                }

            }

        }

        // ── Clock Tab ──
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            QtControls.ScrollView {
                anchors.fill: parent
                clip: true

                Kirigami.FormLayout {
                    width: parent.width

                    QtControls.CheckBox {
                        Kirigami.FormData.label: "Visibility:"
                        text: "Enable digital pixel clock"
                        checked: root.cfg_ClockEnabled
                        onToggled: root.cfg_ClockEnabled = checked
                    }



                    RowLayout {
                        Kirigami.FormData.label: "Size:"
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.largeSpacing
                        enabled: root.cfg_ClockEnabled

                        QtControls.RadioButton {
                            text: "Wristwatch"
                            checked: root.cfg_ClockMode === 0
                            onClicked: root.cfg_ClockMode = 0
                        }
                        QtControls.RadioButton {
                            text: "Desk Clock"
                            checked: root.cfg_ClockMode === 1
                            onClicked: root.cfg_ClockMode = 1
                        }
                        QtControls.RadioButton {
                            text: "Wall Clock"
                            checked: root.cfg_ClockMode === 2
                            onClicked: root.cfg_ClockMode = 2
                        }
                        QtControls.RadioButton {
                            text: "Jumbotron"
                            checked: root.cfg_ClockMode === 3
                            onClicked: root.cfg_ClockMode = 3
                        }
                    }

                    RowLayout {
                        Kirigami.FormData.label: "Clock position:"
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing
                        enabled: root.cfg_ClockEnabled

                        QtControls.ComboBox {
                            Layout.fillWidth: true
                            Layout.maximumWidth: Kirigami.Units.gridUnit * 15
                            model: ["Behind the ball", "In front of the ball"]
                            currentIndex: Math.max(0, Math.min(1, root.cfg_ClockLayer))
                            onActivated: root.cfg_ClockLayer = currentIndex
                        }
                    }

                    RowLayout {
                        Kirigami.FormData.label: "Opacity:"
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing
                        enabled: root.cfg_ClockEnabled

                        QtControls.Slider {
                            Layout.fillWidth: true
                            Layout.maximumWidth: Kirigami.Units.gridUnit * 15
                            from: 0
                            to: 1.0
                            stepSize: 0.01
                            value: root.cfg_ClockOpacity
                            onMoved: root.cfg_ClockOpacity = value
                            onValueChanged: root.cfg_ClockOpacity = value
                        }

                        QtControls.Label {
                            text: Number(root.cfg_ClockOpacity).toFixed(2)
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                        }
                    }

                    Kirigami.Separator {
                        Layout.fillWidth: true
                        Layout.topMargin: Kirigami.Units.largeSpacing
                        Layout.bottomMargin: Kirigami.Units.smallSpacing
                    }

                    ColorSettingRow {
                        formLabel: "Clock panel:"
                        colorValue: root.cfg_ClockPanelColor
                        pickerDialog: clockPanelDialog
                    }

                    ColorSettingRow {
                        formLabel: "Clock digits:"
                        colorValue: root.cfg_ClockDigitColor
                        pickerDialog: clockDigitDialog
                    }

                    ColorSettingRow {
                        formLabel: "Clock outline:"
                        colorValue: root.cfg_ClockOutlineColor
                        pickerDialog: clockOutlineDialog
                    }

                    ColorSettingRow {
                        formLabel: "Clock bar:"
                        colorValue: root.cfg_ClockBarColor
                        pickerDialog: clockBarDialog
                    }

                    QtControls.Button {
                        text: "Reset to Defaults"
                        icon.name: "edit-undo"
                        Layout.topMargin: Kirigami.Units.largeSpacing
                        onClicked: root.resetClockDefaults()
                    }

                }

            }

        }

        // ── Performance Tab ──
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            QtControls.ScrollView {
                anchors.fill: parent
                clip: true

                Kirigami.FormLayout {
                    width: parent.width

                    RowLayout {
                        Kirigami.FormData.label: "Physics model:"
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        QtControls.ComboBox {
                            Layout.fillWidth: true
                            Layout.maximumWidth: Kirigami.Units.gridUnit * 15
                            model: ["Jupiter Gravity", "Classic Demo 1984", "Moon Float"]
                            currentIndex: Math.max(0, Math.min(2, root.cfg_PhysicsPreset))
                            onActivated: root.cfg_PhysicsPreset = currentIndex
                        }
                    }

                    RowLayout {
                        Kirigami.FormData.label: "Gravity modifier:"
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        QtControls.Slider {
                            Layout.fillWidth: true
                            Layout.maximumWidth: Kirigami.Units.gridUnit * 15
                            from: 0.1
                            to: 3.0
                            stepSize: 0.1
                            value: root.cfg_GravityModifier
                            onMoved: root.cfg_GravityModifier = value
                            onValueChanged: root.cfg_GravityModifier = value
                        }

                        QtControls.Label {
                            text: Number(root.cfg_GravityModifier).toFixed(1) + "x"
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                        }
                    }

                    RowLayout {
                        Kirigami.FormData.label: "Rotation speed:"
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        QtControls.Slider {
                            Layout.fillWidth: true
                            Layout.maximumWidth: Kirigami.Units.gridUnit * 15
                            from: 0.1
                            to: 3.0
                            stepSize: 0.1
                            value: root.cfg_RotationSpeed
                            onMoved: root.cfg_RotationSpeed = value
                            onValueChanged: root.cfg_RotationSpeed = value
                        }

                        QtControls.Label {
                            text: Number(root.cfg_RotationSpeed).toFixed(1) + "x"
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                        }
                    }

                    RowLayout {
                        Kirigami.FormData.label: "Animation speed:"
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        QtControls.Slider {
                            Layout.fillWidth: true
                            Layout.maximumWidth: Kirigami.Units.gridUnit * 15
                            from: 0.1
                            to: 1.2
                            stepSize: 0.1
                            value: root.cfg_AnimationSpeed
                            onMoved: root.cfg_AnimationSpeed = value
                            onValueChanged: root.cfg_AnimationSpeed = value
                        }

                        QtControls.Label {
                            text: Number(root.cfg_AnimationSpeed / 0.6).toFixed(1) + "x"
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                        }

                    }

                    RowLayout {
                        Kirigami.FormData.label: "Render FPS:"
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        QtControls.Slider {
                            Layout.fillWidth: true
                            Layout.maximumWidth: Kirigami.Units.gridUnit * 15
                            from: 0
                            to: root.renderFpsValues.length - 1
                            stepSize: 1
                            snapMode: QtControls.Slider.SnapAlways
                            value: root.renderFpsIndex(root.cfg_RenderFps)
                            onMoved: root.cfg_RenderFps = root.renderFpsValues[value]
                        }

                        QtControls.Label {
                            text: root.renderFpsLabels[root.renderFpsIndex(root.cfg_RenderFps)]
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                        }
                    }


                    Kirigami.Separator {
                        Layout.fillWidth: true
                        Layout.topMargin: Kirigami.Units.largeSpacing
                        Layout.bottomMargin: Kirigami.Units.smallSpacing
                    }

                    QtControls.CheckBox {
                        Kirigami.FormData.label: "Power saving:"
                        text: "Render only on focus"
                        checked: root.cfg_RenderOnlyOnFocus
                        onToggled: root.cfg_RenderOnlyOnFocus = checked
                    }

                    QtControls.Label {
                        Kirigami.FormData.label: ""
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: Kirigami.Theme.disabledTextColor
                        text: "Pauses the animation to save power when the desktop is hidden."
                    }

                    QtControls.CheckBox {
                        Kirigami.FormData.label: ""
                        text: "Keep clock running while paused"
                        checked: root.cfg_RenderClockWhenPaused
                        enabled: root.cfg_RenderOnlyOnFocus
                        onToggled: root.cfg_RenderClockWhenPaused = checked
                    }

                    QtControls.Label {
                        Kirigami.FormData.label: ""
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                        color: Kirigami.Theme.disabledTextColor
                        visible: root.cfg_RenderOnlyOnFocus
                        text: "Allows the clock digits to update in the background."
                    }

                    QtControls.Button {
                        text: "Reset to Defaults"
                        icon.name: "edit-undo"
                        Layout.topMargin: Kirigami.Units.largeSpacing
                        onClicked: root.resetPerformanceDefaults()
                    }

                }

            }

        }

    }

    ColorDialog {
        id: backgroundDialog

        title: "Select background color"
        selectedColor: root.cfg_BackgroundColor
        onAccepted: root.cfg_BackgroundColor = selectedColor
    }

    ColorDialog {
        id: gridDialog

        title: "Select grid color"
        selectedColor: root.cfg_GridColor
        onAccepted: root.cfg_GridColor = selectedColor
    }

    ColorDialog {
        id: ballPrimaryDialog

        title: "Select primary ball color"
        selectedColor: root.cfg_BallPrimaryColor
        onAccepted: root.cfg_BallPrimaryColor = selectedColor
    }

    ColorDialog {
        id: ballSecondaryDialog

        title: "Select secondary ball color"
        selectedColor: root.cfg_BallSecondaryColor
        onAccepted: root.cfg_BallSecondaryColor = selectedColor
    }

    ColorDialog {
        id: ballHighlightDialog

        title: "Select highlight color"
        selectedColor: root.cfg_BallHighlightColor
        onAccepted: root.cfg_BallHighlightColor = selectedColor
    }

    ColorDialog {
        id: shadowDialog

        title: "Select shadow color"
        selectedColor: root.cfg_ShadowColor
        onAccepted: root.cfg_ShadowColor = selectedColor
    }

    ColorDialog {
        id: clockPanelDialog

        title: "Select clock panel color"
        selectedColor: root.cfg_ClockPanelColor
        onAccepted: root.cfg_ClockPanelColor = selectedColor
    }

    ColorDialog {
        id: clockDigitDialog

        title: "Select clock digit color"
        selectedColor: root.cfg_ClockDigitColor
        onAccepted: root.cfg_ClockDigitColor = selectedColor
    }

    ColorDialog {
        id: clockOutlineDialog

        title: "Select clock outline color"
        selectedColor: root.cfg_ClockOutlineColor
        onAccepted: root.cfg_ClockOutlineColor = selectedColor
    }

    ColorDialog {
        id: clockBarDialog

        title: "Select clock bar color"
        selectedColor: root.cfg_ClockBarColor
        onAccepted: root.cfg_ClockBarColor = selectedColor
    }

    component ColorSettingRow: RowLayout {
        id: colorRow

        required property string formLabel
        required property color colorValue
        required property var pickerDialog

        Kirigami.FormData.label: formLabel
        spacing: Kirigami.Units.smallSpacing

        QtControls.Button {
            text: "Choose..."
            onClicked: colorRow.pickerDialog.open()
        }

        Rectangle {
            width: Kirigami.Units.gridUnit * 2
            height: Kirigami.Units.gridUnit
            radius: Kirigami.Units.smallSpacing
            color: colorRow.colorValue
            border.width: 1
            border.color: Qt.rgba(0, 0, 0, 0.35)
        }

        QtControls.Label {
            text: colorRow.colorValue.toString()
            color: Kirigami.Theme.disabledTextColor
            font.pointSize: Math.max(8, Kirigami.Theme.defaultFont.pointSize - 1)
        }

    }

}
