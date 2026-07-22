extends UISettingsBase
class_name UIToggleSetting

@export var button: CheckButton

func _set_disabled(value: bool) -> void:
    super._set_disabled(value)

    if button:
        button.disabled = value

    _update_style()

func _enter_tree() -> void:
    super._enter_tree()

    if button:
        if button.focus_entered.connect(_focus.bind(button, true)) != OK:
            push_error("Failed to connect focus enter")
        if button.focus_exited.connect(_focus.bind(button, false)) != OK:
            push_error("Failed to connect focus exit")
        if button.mouse_entered.connect(_hover.bind(button, true)) != OK:
            push_error("Failed to connect mouse entered")
        if button.mouse_exited.connect(_hover.bind(button, false)) != OK:
            push_error("Failed to connect mouse exited")
        if button.button_down.connect(_press.bind(button, true)) != OK:
            push_error("Failed to connect button down")
        if button.button_up.connect(_press.bind(button, false)) != OK:
            push_error("Failed to connect button up")

func _ready() -> void:
    super._ready()

    if button:
        button.disabled = disabled

func _handle_clicked() -> void:
    if button:
        button.button_pressed = !button.button_pressed
        button.grab_focus()
