extends Node3D
class_name Gun

@export var player: HubPlayerCharacter
@export var lamps: Array[MeshInstance3D]
@export var lampMaterials: Array[Material]
@export var litLamps: int = 3
@export var live: bool:
    set(value):
        live = value
        set_process(value)
        if value:
            current_step = 0.0

@export var step_length: float = 1.5

@export var bullets: Node3D
@export var projectile: PackedScene
@export var projectile_spawn: Node3D
@export var projectile_aim: Node3D
@export var projectile_speed: float = 600
@export var line3d: Line3D

var current_step: float


var _last_bullet: RigidBody3D
var _last_bullet_position: Vector3


func _ready() -> void:
    sync_lamps()
    if !live:
        set_process(false)

func sync_lamps() -> void:
    if lampMaterials.is_empty():
        return

    var unlit_mat: Material = lampMaterials[0]
    var lit_mat: Material = lampMaterials[clampi(litLamps, 0, lampMaterials.size() - 1)]
    var idx: int = 1
    for lamp: MeshInstance3D in lamps:
        lamp.material_override = lit_mat if idx <= litLamps else unlit_mat
        idx += 1


func _process(delta: float) -> void:
    current_step += delta
    if current_step >= step_length:
        if litLamps > 0:
            litLamps -= 1
            if litLamps == 0:
                shoot()
        else:
            litLamps = lamps.size()

        sync_lamps()
        current_step -= step_length

    if _last_bullet && line3d:
       _update_line()

func shoot() -> void:
    var bullet: Projectile = projectile.instantiate()
    bullet.cam = player.cam
    bullets.add_child(bullet)
    _last_bullet = bullet
    bullet.global_position = projectile_spawn.global_position
    bullet.linear_velocity = (projectile_aim.global_position - projectile_spawn.global_position).normalized() * projectile_speed
    _last_bullet_position = bullet.global_position
    if line3d:
        line3d.clear_points()

    await get_tree().create_timer(10).timeout
    bullet.queue_free()

func _update_line() -> void:
    if _last_bullet.linear_velocity.length_squared() < 0.1:
        _last_bullet = null
        line3d.clear_points()
        return

    var delta: Vector3 = _last_bullet.global_position - _last_bullet_position
    if delta != Vector3.ZERO:
        line3d.add_global_point(_last_bullet.global_position)
        _last_bullet_position = _last_bullet.global_position
