extends Area3D

@export var player: HubPlayerCharacter
@export_file("*.tscn") var next_scene: String
@export var notes: Array[Label3D]

var _entries: int
var _room_completed: bool
var _transitioning: bool

func _enter_tree() -> void:
    if SignalBus.on_room_completed.connect(_handle_room_completed) != OK:
        push_error("Failed to connect room completed")
    if body_entered.connect(_handle_player_enter) != OK:
        push_error("Failed to connect player enter")
    if body_exited.connect(_handle_player_exit) != OK:
        push_error("Failed to connect player exit")

func _ready() -> void:
    for note: Label3D in notes:
        note.visible = false

func _handle_room_completed() -> void:
    _room_completed = true

func _handle_player_enter(body: Node3D) -> void:
    if _transitioning || !NodeUtils.is_parent(player, body):
        return

    _entries += 1

    if _entries == 1:
        return

    if _room_completed:
        _transitioning = true
        await get_tree().create_timer(1.0).timeout
        # TODO: Have some effects
        if next_scene.is_empty():
            return
        get_tree().change_scene_to_file(next_scene)
    else:
        for note: Label3D in notes:
            note.visible = true

func _handle_player_exit(body: Node3D) -> void:
    if !NodeUtils.is_parent(player, body):
        return

    for note: Label3D in notes:
        note.visible = false
