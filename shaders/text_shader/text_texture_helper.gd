@tool
extends Node
class_name TextWriterHelper

const SPACE: int = -1
const MAX_TEXT_LENGTH: int = 32

@export var mesh: MeshInstance3D:
    set(value):
        mesh = value
        _sync()
    get():
        if mesh:
            return mesh
        var p: Node = get_parent()
        if p is MeshInstance3D:
            return p

        return null

@export var override_mat_idx: int = 0:
    set(value):
        override_mat_idx = value
        _sync()

@export var alphabet: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.,;:?!\"'+-=*%_()[]{}~#&@©®™°^`|/\\<>…€$£¢¿¡“”‘’«»‹›„‚·•ÀÁÂÄÃÅĄÆÇĆÐÈÉÊËĘĞÌÍÎÏİŁÑŃÒÓÔÖÕŐØŒŚŞẞÞÙÚÛÜŰÝŸŹŻàáâäãåąæçćðèéêëęğìíîïıłñńòóôöõőøœśşßþùúûüűýÿźżАБВГҐДЕЁЄЖЗИІЇЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгґдеёєжзиіїйклмнопрстуфхцчшщъыьэюя":
    set(value):
        alphabet = value
        _sync()

@export var text: String:
    set(value):
        text = value
        _sync()

@export var unsupported_character: String = " "

var word_spacing: int:
    set(value):
        if mesh == null:
            return

        var mat: ShaderMaterial = mesh.get_surface_override_material(override_mat_idx)
        if mat == null:
            return

        mat.set_shader_parameter("word_spacing", value)

    get():
        if mesh == null:
            return -1

        var mat: ShaderMaterial = mesh.get_surface_override_material(override_mat_idx)
        if mat == null:
            return -1

        return mat.get_shader_parameter("word_spacing") as int

func _sync() -> void:
    if mesh == null:
        return

    var mat: ShaderMaterial = mesh.get_surface_override_material(override_mat_idx)
    if mat == null:
        push_warning("%s of %s isn't a shader material" % [mesh.get_surface_override_material(override_mat_idx), mesh])
        return

    var packed: PackedInt32Array = PackedInt32Array()

    # Add space for end of word when needed
    var length = mini(text.length(), MAX_TEXT_LENGTH)
    packed.resize(length)

    var idx: int = 0
    for ch: String in text:
        if ch == " ":
            packed[idx] = SPACE
        else:
            var id: int = alphabet.find(ch)
            if id < 0:
                push_warning("'%s' not in alphabet" % [ch])

                id = alphabet.find(unsupported_character[0])

            packed[idx] = id

        idx += 1

        if idx >= MAX_TEXT_LENGTH:
            break

    mat.set_shader_parameter("word", packed)
    mat.set_shader_parameter("word_length", length)
    #print_debug("Setting %s to '%s' (%s)" % [mesh, text, packed])
