extends Label

@export var hint_pattern: String
@export var binding: StringName

func _enter_tree() -> void:
    if SignalBus.on_change_input_method.connect(_handle_change_input_method) != OK:
        push_error("Failed to connect change input method")

func _handle_change_input_method(_input_method: BindingSettings.InputMethod) -> void:
    sync()

func _ready() -> void:
    sync()

func sync() -> void:
    var evt: InputEvent = BindingSettings.get_first_binding(BindingSettings.active_input_method, binding)
    if evt is InputEventMouseButton:
        _set_text(BindingSettings.mouse_event_to_text(evt))
    elif evt is InputEventKey:
        _set_text(BindingSettings.key_event_to_text(evt))
    elif evt is InputEventJoypadButton:
        _set_text(BindingSettings.joy_btn_event_to_text(evt))
    elif evt is InputEventJoypadMotion:
        _set_text(BindingSettings.joy_axis_event_to_text(evt))
    else:
        _set_text("")

func _set_text(bind: String) -> void:
    text = hint_pattern % [bind]
