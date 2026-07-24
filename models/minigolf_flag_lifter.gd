extends Area3D

@export var flag: Node3D
@export var lifted_position: Node3D
@export var lift_time: float = 0.5

var _resting_position: Vector3

func _enter_tree() -> void:
    _resting_position = flag.position

    if body_entered.connect(_handle_enter) != OK:
        push_error("Failed to connect body entered")
    if body_exited.connect(_handle_exit) != OK:
        push_error("Failed to connect body exited")

var _tween: Tween
var _lifting: bool

func _handle_enter(_body: Node3D) -> void:
    if _lifting:
        return

    _lifting = true

    if _tween && _tween.is_running():
        _tween.kill()

    _tween = create_tween()
    _tween.tween_property(flag, "global_position", lifted_position.global_position, lift_time)

func _handle_exit(_body: Node3D) -> void:
    if !_lifting:
        return

    _lifting = false

    if _tween && _tween.is_running():
        _tween.kill()

    _tween = create_tween()
    _tween.tween_property(flag, "position", _resting_position, lift_time)
