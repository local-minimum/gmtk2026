@tool
extends Button
class_name LoopingButton

@export var values: Array[String]
@export var selected: int = 0:
    set(value):
        selected = value
        sync()

signal value_changed(value: String, selected: int)

func _enter_tree() -> void:
    if Engine.is_editor_hint():
        return
    if pressed.connect(_handle_pressed) != OK:
        push_error("Failed to connect pressed")

func _ready() -> void:
    sync()

func sync() -> void:
    if values.is_empty():
        text = ""
        disabled = true
        return

    text = values[selected]

func _handle_pressed() -> void:
    if values.is_empty():
        selected = -1
        value_changed.emit("", selected)
    else:
        selected = (selected + 1) % values.size()
        value_changed.emit(values[selected], selected)
