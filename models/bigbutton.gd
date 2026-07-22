extends Node3D
class_name BigButton

@export var player: AnimationPlayer
@export var press_animation: String = "pressing"
@export var press_delay: float = 0.25
@export var anim_duration: float = 1.0

var _pressing: bool

func press(callback: Callable) -> bool:
    if _pressing:
        return false
    _pressing = true
    _exec_press(callback)
    return true

func _exec_press(callback: Callable) -> void:
    if player:
        player.play(press_animation)
    await get_tree().create_timer(press_delay).timeout

    callback.call()

    await get_tree().create_timer(anim_duration - press_delay).timeout

    _pressing = false
