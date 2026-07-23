extends Control

@export var player: HubPlayerCharacter
@export var counted_things: Array[CountedThing]
@export var score: Label
@export var count_delay: float = 0.5
@export var count_step_delay: float = 0.25
@export var show_hide_duration: float = 0.5

var _scored: bool

func _enter_tree() -> void:
    if SignalBus.on_check_score.connect(_handle_count_score) != OK:
        push_error("Failed to connect count/check score")

    if SignalBus.on_show_score_card.connect(_handle_show_counting) != OK:
        push_error("Failed to connect show counting")

func _ready() -> void:
    score.text = ""
    visible = false
    offset_transform_position_ratio.y = 1.0

func _handle_count_score() -> void:
    if _scored:
        return

    _scoring = true
    _scored = true

    if !visible:
        visible = true
        await get_tree().create_timer(count_delay).timeout

    var _score: int = 0
    score.text = "0"
    await  get_tree().create_timer(count_delay).timeout

    for ct: CountedThing in counted_things:
        if ct.check_corret():
            _score += 1
            score.text = "%s" % [_score]

        await  get_tree().create_timer(count_step_delay).timeout

    _scoring = false

var _scoring: bool
var _showing: bool = false
var _show_tween: Tween

func _input(event: InputEvent) -> void:
    if !_showing && event.is_action_pressed(&"player_interact"):
        SignalBus.on_show_score_card.emit(!_showing)
        get_viewport().set_input_as_handled()
    if _showing && event.is_action_pressed(&"ui_cancel"):
        SignalBus.on_show_score_card.emit(!_showing)
        get_viewport().set_input_as_handled()

func _handle_show_counting(shown: bool) -> void:
    if _scoring:
        return

    if _show_tween && _show_tween.is_running():
        _show_tween.kill()

    _showing = shown

    # Handle mouse
    if _showing:
        visible = true
        player.add_cinematic_reason(self)
    else:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
        player.remove_cinematic_reason(self)

    _show_tween = create_tween()
    _show_tween.tween_property(self, "offset_transform_position_ratio:y", 0.0 if _showing else 1.0, show_hide_duration).set_trans(Tween.TRANS_CUBIC)
    _show_tween.finished.connect(
        func () -> void:
            if _showing:
                Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
                counted_things[0].gain_focus()
            else:
                visible = false
    )
