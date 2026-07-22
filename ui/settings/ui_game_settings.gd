extends Control

@export var subtitles: UIToggleSetting
@export var subtitles_size: UISlidingValueSetting

@export var reticle_size: UISlidingValueSetting
@export var reticle_transparency: UISlidingValueSetting
@export var reticle_text_size: UISlidingValueSetting

@export var mouse_invert_y: UIToggleSetting
@export var mouse_sense: UISlidingValueSetting

@export var joy_invert_y: UIToggleSetting
@export var joy_sense: UISlidingValueSetting


func _enter_tree() -> void:
    if subtitles:
        if subtitles.button.toggled.connect(_handle_toggle_subtitles) != OK:
            push_error("Failed to connect toggle subtitles")

    if subtitles_size:
        if subtitles_size.slider.value_changed.connect(_handle_subtitle_size_change) != OK:
            push_error("Failed to connect subtitle size change")

    if mouse_invert_y:
        if mouse_invert_y.button.toggled.connect(_handle_toggle_mouse_invert_y) != OK:
            push_error("Failed to connect mouse invert y")

    if joy_invert_y:
        if joy_invert_y.button.toggled.connect(_handle_toggle_joy_invert_y) != OK:
            push_error("Failed to connect joy invert y")

    if mouse_sense:
        if mouse_sense.slider.value_changed.connect(_handle_mouse_sense_change) != OK:
            push_error("Failed to connect mouse sens chage")

    if joy_sense:
        if joy_sense.slider.value_changed.connect(_handle_joy_sense_change) != OK:
            push_error("Failed to connect joy sense change")

    if reticle_size:
        if reticle_size.slider.value_changed.connect(_handle_reticle_size_change) != OK:
            push_error("Failed to connect reticle size change")

    if reticle_transparency:
        if reticle_transparency.slider.value_changed.connect(_handle_reticle_transparency_change) != OK:
            push_error("Failed to connect reticle transparency change")

    if reticle_text_size:
        if reticle_text_size.slider.value_changed.connect(_handle_reticle_text_size_change) != OK:
            push_error("Failed to connect reticle text size change")

var _syncing: bool

func _ready() -> void:
    _syncing = true

    if subtitles:
        subtitles.button.button_pressed = AccessibilitySettings.subtitles

    if subtitles_size:
        subtitles_size.slider.value = AccessibilitySettings.subtitles_size

    if mouse_invert_y:
        mouse_invert_y.button.button_pressed = AccessibilitySettings.mouse_inverted_y

    if mouse_sense:
        mouse_sense.slider.value = AccessibilitySettings.mouse_sensitivity

    if joy_invert_y:
        joy_invert_y.button.button_pressed = AccessibilitySettings.joy_inverted_y

    if joy_sense:
        joy_sense.slider.value = AccessibilitySettings.joy_sensitivity

    if reticle_size:
        reticle_size.slider.value = AccessibilitySettings.reticle_size

    if reticle_transparency:
        reticle_transparency.slider.value = 100.0 * (1.0 - AccessibilitySettings.reticle_alpha)

    if reticle_text_size:
        reticle_text_size.slider.value = AccessibilitySettings.reticle_text_size

    _syncing = false

func _handle_toggle_subtitles(value: bool) -> void:
    if !_syncing:
        AccessibilitySettings.subtitles = value

func _handle_subtitle_size_change(value: float) -> void:
    if !_syncing:
        AccessibilitySettings.subtitles_size = roundi(value)

func _handle_toggle_mouse_invert_y(value: bool) -> void:
    if !_syncing:
        AccessibilitySettings.mouse_inverted_y = value

func _handle_toggle_joy_invert_y(value: bool) -> void:
    if !_syncing:
        AccessibilitySettings.joy_inverted_y = value

func _handle_mouse_sense_change(value: float) -> void:
    if !_syncing:
        AccessibilitySettings.mouse_sensitivity = value

func _handle_joy_sense_change(value: float) -> void:
    if !_syncing:
        AccessibilitySettings.joy_sensitivity = value

func _handle_reticle_size_change(value: float) -> void:
    if !_syncing:
        AccessibilitySettings.reticle_size = roundi(value)

func _handle_reticle_transparency_change(value: float) -> void:
    if !_syncing:
        AccessibilitySettings.reticle_alpha = clampf(1.0 - value * 0.01, 0.0, 1.0)

func _handle_reticle_text_size_change(value: float) -> void:
    if !_syncing:
        AccessibilitySettings.reticle_text_size = roundi(value)
