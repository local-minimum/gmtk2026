extends RayCast3D

func _physics_process(_delta: float) -> void:
    if !is_colliding():
        _handle_no_interaction()
        return

    var interactable = Interactable.find_interactable_in_tree(get_collider(), true)
    if !interactable:
        _handle_no_interaction()
        return

    var dist: float = (get_collision_point() - global_position).length()
    var hint: Interactable.Hint = interactable.get_hint(dist)
    if hint == Interactable.Hint.NONE:
        _handle_no_interaction()
        return

    _handle_hinting(interactable, hint)

var _interactable: Interactable
var _hint: Interactable.Hint

func _handle_no_interaction() -> void:
    if _hint == Interactable.Hint.NONE:
        return

    _hint = Interactable.Hint.NONE
    _interactable = null

    SignalBus.on_pointer_interaction_update.emit(Interactable.Hint.NONE, null)

func _handle_hinting(interactable: Interactable, hint: Interactable.Hint) -> void:
    if _interactable == interactable && _hint == hint:
        return

    _hint = hint
    _interactable = interactable

    SignalBus.on_pointer_interaction_update.emit(hint, interactable)
