extends Node
class_name _GameSettings

var _considered_input_method: BindingSettings.InputMethod

func _enter_tree() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    AccessibilitySettings.initialize()
    AudioSettings.initialize()
    BindingSettings.initialize()
    VideoSettings.initialize()

func reset_defaults() -> void:
    AccessibilitySettings.reset_default()
    AudioSettings.reset_default()
    BindingSettings.reset_default()
    VideoSettings.reset_default()

func _ready() -> void:
    _considered_input_method = BindingSettings.active_input_method

func _input(event: InputEvent) -> void:
    _unhandled_input(event)

func _unhandled_input(event: InputEvent) -> void:
    if BindingSettings.is_valid_action_event(event, BindingSettings.InputMethod.KEYBOARD_AND_MOUSE, true):
        _consider_switch_to(BindingSettings.InputMethod.KEYBOARD_AND_MOUSE)
    elif BindingSettings.is_valid_action_event(event, BindingSettings.InputMethod.JOYPAD):
        _consider_switch_to(BindingSettings.InputMethod.JOYPAD)

func _consider_switch_to(im: BindingSettings.InputMethod) -> void:
    if im == _considered_input_method:
        return

    _considered_input_method = im
    await get_tree().create_timer(0.1).timeout
    if im == _considered_input_method:
        BindingSettings.active_input_method = im
