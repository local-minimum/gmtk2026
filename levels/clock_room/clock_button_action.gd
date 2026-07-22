extends InteractableAction
class_name ClockButtonAction

var _press_count: int = 0

func perform(_interactable: Interactable) -> void:
    _press_count += 1
    SignalBus.on_count_down_room_press_big_button.emit(_press_count)

func abort(_interactable: Interactable) -> void:
    pass
