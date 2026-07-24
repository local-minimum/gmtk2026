extends Node

@export var clock: CountDownClock
@export var button: BigButton
@export var spot_light: Light3D
@export var count_from: int = 60
@export var count_step: float = 0.15

func _enter_tree() -> void:
    if SignalBus.on_count_down_room_press_big_button.connect(_handle_interact_button) != OK:
        push_error("Failed to connect interact with button")


enum GamePhase { WAITING, INITING, READY, COUNTING, PLAYER_PRESSED, PLAYER_STOPPED, ENDED }
var _phase: GamePhase = GamePhase.WAITING

func _handle_interact_button(_press_idx: int) -> void:
    match _phase:
        GamePhase.WAITING:
            _phase = GamePhase.INITING
            button.press(_handle_init)
        GamePhase.READY:
            _phase = GamePhase.COUNTING
            button.press(_handle_count)
        GamePhase.COUNTING:
            _phase = GamePhase.PLAYER_PRESSED
            button.press(_stop_clock)
        GamePhase.ENDED:
            button.press(_show_clock)
        _:
            button.press(_do_nothing)

func _do_nothing() -> void:
    pass

func _handle_init() -> void:
    clock.off = true
    clock.current_value = count_from
    await get_tree().create_timer(1.0).timeout
    _phase = GamePhase.READY
    while _phase == GamePhase.READY:
        clock.off = !clock.off
        await get_tree().create_timer(0.5).timeout

func _handle_count() -> void:
    clock.off = false
    for val: int in (count_from + 1):
        clock.current_value = count_from - val
        match clock.current_value:
            40:
                clock.glitched = true
            35:
                clock.glitched = false
            21:
                clock.glitched = true
            19:
                clock.glitched = false
            15:
                clock.glitched = true
            14:
                clock.glitched = false
            8:
                clock.off = true

        await get_tree().create_timer(count_step).timeout
        if _phase == GamePhase.PLAYER_STOPPED:
            return

    _phase = GamePhase.ENDED
    clock.current_value = -1
    SignalBus.on_room_completed.emit()

func _show_clock() -> void:
    clock.off = false
    clock.glitched = false

func _stop_clock() -> void:
    clock.off = false
    clock.glitched = false
    if _phase == GamePhase.ENDED:
        return

    _phase = GamePhase.PLAYER_STOPPED
    SignalBus.on_room_completed.emit()
