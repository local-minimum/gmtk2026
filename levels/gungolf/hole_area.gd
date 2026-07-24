extends Area3D

@export var hole_ball: RigidBody3D
@export var hole_ball_spawn: Node3D

func _enter_tree() -> void:
    if body_entered.connect(_handle_player_enter) != OK:
        push_error("Failed to connect player enter")
    if body_exited.connect(_handle_player_exit) != OK:
        push_error("Failed to connect player exit")

func _ready() -> void:
    set_process_input(false)

func _handle_player_enter(_body: Node3D) -> void:
    set_process_input(true)

func _handle_player_exit(_body: Node3D) -> void:
    set_process_input(false)

func _input(event: InputEvent) -> void:
    if event.is_action_pressed(&"player_reset"):
        hole_ball.linear_velocity = Vector3.ZERO
        hole_ball.angular_velocity = Vector3.ZERO
        await get_tree().create_timer(0.03).timeout
        hole_ball.global_position = hole_ball_spawn.global_position
