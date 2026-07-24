extends Node
class_name Cutscene

@export_file("*.tscn") var next_scene: String

var t0: int

func _ready() -> void:
    t0 = Time.get_ticks_msec()


func _input(event: InputEvent) -> void:
    if (Time.get_ticks_msec() - t0) < 500 || next_scene.is_empty():
        return

    if (event is InputEventKey || event is InputEventJoypadButton || event is InputEventMouseButton) && event.is_pressed():
        get_tree().change_scene_to_file(next_scene)
