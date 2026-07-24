extends Node3D
class_name Gun

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

var current_step: float

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

func shoot() -> void:
    pass
