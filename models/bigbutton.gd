extends Node3D
class_name BigButton

signal on_pressed()

@export var player: AnimationPlayer
@export var press_animation: String = "pressing"
@export var press_delay: float = 0.25
@export var anim_duration: float = 1.0

var _pressing: bool

func press() -> void:
    if _pressing:
        return
    _pressing = true
    if player:
        player.play(press_animation)
    await get_tree().create_timer(press_delay).timeout
    on_pressed.emit()
    await get_tree().create_timer(anim_duration - press_delay).timeout
    _pressing = false
