extends Node3D
class_name Turnstile

@export var opened: bool:
    set(value):
        opened = value
        _animate_to(value)
@export var live: bool = true
@export var _turnstile: Node3D
@export var _open_area: Area3D
@export var _close_area: Area3D
@export var _anim_duration: float = 1.0
@export var _delay_open: float = 0.25
@export var _delay_close: float = 1.5
const _OPEN_ANGLE: float = -PI * 0.65
var _tween: Tween
var _tweening_to_open: bool

func _enter_tree() -> void:
    if _open_area.body_entered.connect(_handle_enter_open) != OK:
        push_error("Failed to connect handle open")
    if _close_area.body_entered.connect(_handle_enter_close) != OK:
        push_error("Failed to connect handle close")

func _ready() -> void:
    if opened:
        _turnstile.rotation.y = _OPEN_ANGLE

func _handle_enter_open(body: Node3D) -> void:
    if !live || body is StaticBody3D:
        return
    _animate_to(true, _delay_open)

func _handle_enter_close(body: Node3D) -> void:
    if !live || body is StaticBody3D:
        return
    _animate_to(false, _delay_close)

func _animate_to(open: bool, delay: float = 0.0) -> void:
    if _tweening_to_open == open:
        return

    _tweening_to_open = open
    if _tween && _tween.is_running():
        _tween.kill()

    if delay:
        await get_tree().create_timer(delay).timeout
        if _tweening_to_open != open:
            return

    _tween = create_tween()
    _tween.tween_property(_turnstile, "rotation:y", _OPEN_ANGLE if open else 0.0, _anim_duration).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
    _tween.finished.connect(
        func () -> void:
            if opened != open:
                opened = open
            ,
    )
