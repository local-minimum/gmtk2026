extends Node3D

@export var current_value: int = 99:
    set(value):
        current_value = value
        _sync()

@export var off: bool:
    set(value):
        off = value
        _sync()

@export var glitched: bool:
    set(value):
        glitched = value
        set_process(value)
        _sync()

@export var glitched_update_prob: float = 0.05
@export var left_digit: Array[MeshInstance3D]
@export var right_digit: Array[MeshInstance3D]

const NUM_TO_MESHES: Dictionary[int, Array] = {
    0: [0, 1, 2, 3, 4, 5],
    1: [1, 2],
    2: [0, 1, 6, 4, 3],
    3: [0, 1, 2, 3, 6],
    4: [1, 2, 6, 5],
    5: [0, 5, 6, 2, 3],
    6: [0, 5, 4, 3, 2, 6],
    7: [0, 1, 2],
    8: [0, 1, 2, 3, 4, 5, 6],
    9: [6, 5, 0, 1, 2],
}

func _sync() -> void:
    if !glitched:
        set_process(false)

    var left: int = floori(current_value / 10.0)
    var right: int = posmod(current_value, 10)
    _sync_digit(left, left_digit)
    _sync_digit(right, right_digit)

func _sync_digit(val: int, meshes: Array[MeshInstance3D]) -> void:
    var filt: Array = NUM_TO_MESHES[val]
    for idx: int in meshes.size():
        meshes[idx].visible = !off && (randf() < 0.5 if glitched else filt.has(idx))

func _ready() -> void:
    _sync()

func _process(_delta: float) -> void:
    if glitched && randf() < glitched_update_prob:
        _sync()
