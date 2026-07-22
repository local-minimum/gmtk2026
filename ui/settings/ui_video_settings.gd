extends Control

@export var window_mode: UIDropDownSetting
@export var borderless: UIToggleSetting
@export var screen: UIDropDownSetting
@export var resolution_scale: UISteppedValueSetting
@export var brightness: UISlidingValueSetting
@export var contrast: UISlidingValueSetting
@export var saturation: UISlidingValueSetting
@export var motion_sickness: UISteppedValueSetting
@export var fov: UISlidingValueSetting

const _WINDOW_MODES: Array[DisplayServer.WindowMode] = [
    DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN,
    DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN,
    DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED,
    DisplayServer.WindowMode.WINDOW_MODE_WINDOWED,
]

const _WINDOW_MODE_NAMES: Array[String] = [
    "Exclusive Fullscreen",
    "Fullscreen",
    "Maximized",
    "Windowed",
]

const _RESOLUTION_SCALES: Array[float] = [0.5, 0.67, 0.75, 0.85, 1.0, 1.33, 1.5, 2.0]

const _MOTION_SICKNESS_LEVELS: Dictionary[int, String] = {
        AccessibilitySettings.MotionSickness.VERY_SENSITIVE: "Very sensitive",
        AccessibilitySettings.MotionSickness.YES: "Yes",
        AccessibilitySettings.MotionSickness.SOMETIMES: "Sometimes",
        AccessibilitySettings.MotionSickness.NO: "No",
        AccessibilitySettings.MotionSickness.IMPOSSIBLE: "Impossible",
}

func _enter_tree() -> void:
    if borderless && borderless.button:
        if borderless.button.toggled.connect(_handle_toggle_borderless) != OK:
            push_error("Failed to connect toggle borderless")
    if resolution_scale:
        if resolution_scale.on_change_value.connect(_handle_change_resolution_scale) != OK:
            push_error("Failed to connect change resolution scale")
    if brightness:
        if brightness.slider.value_changed.connect(_handle_change_brightness) != OK:
            push_error("Failed to connect change brightness")
    if contrast:
        if contrast.slider.value_changed.connect(_handle_change_contrast) != OK:
            push_error("Failed to connect change contrast")
    if saturation:
        if saturation.slider.value_changed.connect(_handle_change_saturation) != OK:
            push_error("Failed to connect change saturation")
    if motion_sickness:
        if motion_sickness.on_change_value.connect(_handle_change_motion_sickness) != OK:
            push_error("Failed to connect motion sickness change")
    if fov:
        if fov.slider.value_changed.connect(_handle_change_fov) != OK:
            push_error("Failed to connect fov change")

var _syncing: bool

func _ready() -> void:
    _syncing = true

    var mode: DisplayServer.WindowMode = VideoSettings.window_mode
    var desktop: bool = OS.get_name() not in ["Android", "iOS", "Web"]

    if window_mode:
        if desktop:
            var selected: int = _WINDOW_MODES.find(mode)
            if selected < 0:
                selected = _WINDOW_MODES.find(Window.Mode.MODE_WINDOWED)

            window_mode.set_options(_WINDOW_MODE_NAMES, _handle_change_window_mode, selected)
        else:
            window_mode.visible = false

    if screen:
        var opts: Array[String] = []
        var primary: int = DisplayServer.get_primary_screen()
        var current: int = DisplayServer.window_get_current_screen()
        for i in DisplayServer.get_screen_count():
            opts.append("#%s%s" % [i + 1, " [Primary]" if primary == i else ""])
        screen.set_options(opts, _handle_change_screen, current)

    if resolution_scale:
        var current: float = VideoSettings.resolution_scale

        var min_diff: float = -1.0
        var best: float = -1
        for opt: float in _RESOLUTION_SCALES:
            var diff: float = absf(opt - current)
            if best < 0 || diff < min_diff:
                best = opt
                min_diff = diff

        resolution_scale.set_steps({
            0: "Maximum Performance",
            1: "High Performance",
            2: "Performance",
            3: "Downscaled",
            4: "Native",
            5: "Upscaled",
            6: "High Quality",
            7: "Maximum Quality",
        }, _RESOLUTION_SCALES.find(best))

    if borderless:
        borderless.button.button_pressed = VideoSettings.borderless

    if brightness:
        brightness.slider.value = VideoSettings.brightness * 100.0

    if contrast:
        contrast.slider.value = VideoSettings.contrast * 100.0

    if saturation:
        saturation.slider.value = VideoSettings.saturation * 100.0

    if motion_sickness:
        motion_sickness.set_steps(_MOTION_SICKNESS_LEVELS, AccessibilitySettings.motion_sickness)

    if fov:
        fov.slider.value = VideoSettings.field_of_view

    _syncing = false

func _handle_change_resolution_scale(new_scale: int) -> void:
    if !_syncing:
        VideoSettings.resolution_scale = _RESOLUTION_SCALES[clampi(new_scale, 0, _RESOLUTION_SCALES.size() - 1)]

func _handle_change_screen(new_screen: int) -> void:
    if !_syncing:
        VideoSettings.screen = new_screen

func _handle_change_window_mode(selected: int) -> void:
    if selected < 0 || selected >= _WINDOW_MODES.size():
        return

    var mode: DisplayServer.WindowMode = _WINDOW_MODES[selected]

    if !_syncing:
        VideoSettings.window_mode = mode

        if mode == DisplayServer.WindowMode.WINDOW_MODE_WINDOWED:
            VideoSettings.borderless = false

    if borderless:
        borderless.disabled = mode != DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED

func _handle_toggle_borderless(on: bool) -> void:
    if !_syncing:
        VideoSettings.borderless = on

func _handle_change_brightness(value: float) -> void:
    if !_syncing:
        VideoSettings.brightness = value * 0.01

func _handle_change_contrast(value: float) -> void:
    if !_syncing:
        VideoSettings.contrast = value * 0.01

func _handle_change_saturation(value: float) -> void:
    if !_syncing:
        VideoSettings.saturation = value * 0.01

func _handle_change_motion_sickness(value: int) -> void:
    if !_syncing:
        AccessibilitySettings.motion_sickness = AccessibilitySettings.int_to_motion_sickness(value)

func _handle_change_fov(value: float) -> void:
    if !_syncing:
        VideoSettings.field_of_view = value
