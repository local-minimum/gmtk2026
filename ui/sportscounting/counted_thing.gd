extends HBoxContainer
class_name CountedThing

@export var number10x: LoopingButton
@export var number1x: LoopingButton
@export var sport: LoopingButton
@export var thing: LoopingButton
@export var check: TextureRect

@export var wanted_count: int
@export var wanted_sport: String
@export var wanted_thing: String
@export var alt_wanted_thing: String

@export var error_color: Color = Color.RED
@export var correct_color: Color = Color.WEB_GREEN
@export var err_texture: Texture2D
@export var correct_texture: Texture2D

func gain_focus() -> void:
    if !number10x.disabled:
        number10x.grab_focus()
        return
    if !number1x.disabled:
        number1x.grab_focus()
        return
    if !sport.disabled:
        sport.grab_focus()
        return
    if !thing.disabled:
        thing.grab_focus()
        return

func _ready() -> void:
    check.visible = false

func check_corret() -> bool:
    number10x.disabled = true
    number1x.disabled = true
    sport.disabled = true
    thing.disabled = true

    var count: int = int(number10x.text) + int(number1x.text)
    var has_error: bool = false
    if count != wanted_count:
        has_error = true
        number10x.modulate = error_color
        number1x.modulate = error_color

    if wanted_sport != sport.text:
        has_error = true
        sport.modulate = error_color

    if wanted_thing != thing.text && (alt_wanted_thing.is_empty() || wanted_thing != alt_wanted_thing):
        has_error = true
        thing.modulate = error_color

    check.visible = true
    check.texture = err_texture if has_error else correct_texture
    check.modulate = error_color if has_error else correct_color
    return !has_error
