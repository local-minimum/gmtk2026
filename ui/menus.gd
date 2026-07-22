extends TextureRect
class_name Menus

@export var resume_btn: Button
@export var exit_btn: Button

func _enter_tree() -> void:
    visible = false
    if resume_btn.pressed.connect(_resume_game) != OK:
        push_error("Failed to connect resume game")
    if exit_btn.pressed.connect(_quit) != OK:
        push_error("Failed to connect quit")
    if SignalBus.on_pause_game.connect(_handle_pause) != OK:
        push_error("Failed to connect handle pause")
    if SignalBus.on_change_input_method.connect(_handle_update_input_method) != OK:
        push_error("Failed to connect change input method")

var update_mouse: bool
var return_mode: Input.MouseMode

func _handle_pause(paused: bool) -> void:
    visible = paused
    get_tree().paused = paused

    if paused:
        update_mouse = BindingSettings.active_input_method == BindingSettings.InputMethod.KEYBOARD_AND_MOUSE
        if update_mouse:
            return_mode = Input.mouse_mode
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    elif update_mouse:
        Input.mouse_mode = return_mode

func _handle_update_input_method(im: BindingSettings.InputMethod) -> void:
    if !visible:
        return

    if im == BindingSettings.InputMethod.KEYBOARD_AND_MOUSE:
        if !update_mouse:
            return_mode = Input.mouse_mode
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    else:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _resume_game() -> void:
    SignalBus.on_pause_game.emit(false)

func _quit() -> void:
    get_tree().quit()
