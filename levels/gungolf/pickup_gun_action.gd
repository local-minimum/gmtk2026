extends InteractableAction
class_name PickupGunAction

@export var gun: Gun
@export var player: HubPlayerCharacter
@export var turnstile: Turnstile
@export var hold_distance: Vector3 = Vector3(0, -0.071, -0.35)

func _enter_tree() -> void:
    gun.live = false
    gun.litLamps = 0
    gun.sync_lamps()

func perform(interactable: Interactable) -> void:
    if gun.live:
        return

    SignalBus.on_pointer_visible.emit(false)

    interactable.live = false
    turnstile.live = true
    gun.live = true

    var cam: Node3D = player.cam
    gun.reparent(cam)
    var rot: Callable = QuaternionUtils.create_tween_rotation_progress_method(gun, gun.basis.get_rotation_quaternion(), Quaternion.IDENTITY, false)

    var t: Tween = create_tween()
    t.tween_property(gun, "position", hold_distance, 0.5).set_trans(Tween.TRANS_BOUNCE)
    t.tween_method(rot, 0.0, 1.0, 0.4).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)

func abort(_interactable: Interactable) -> void:
    pass
