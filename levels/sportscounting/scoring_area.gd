extends MeshInstance3D

@export var counting: SportsCounting
@export var player: HubPlayerCharacter
@export var area: Area3D
@export var lookTarget: Node3D

func _enter_tree() -> void:
    if area.body_entered.connect(_handle_body_entered) != OK:
        push_error("Failed to connect body entered")


func _handle_body_entered(body: Node3D) -> void:
    if counting.scored || !NodeUtils.is_parent(player, body):
        return

    player.add_cinematic_reason(self)
    await get_tree().create_timer(1.5).timeout
    SignalBus.on_show_score_card.emit(true)
    await get_tree().create_timer(0.5).timeout
    SignalBus.on_check_score.emit()
    await get_tree().create_timer(3.0).timeout
    player.remove_cinematic_reason(self)
