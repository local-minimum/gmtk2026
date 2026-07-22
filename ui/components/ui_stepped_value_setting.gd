extends UISettingsBase
class_name UISteppedValueSetting

signal on_change_value(value: int)

@export var slider: Slider
@export var value_label: Label
@export var _steps: Dictionary[int, String]

func _ready() -> void:
    super._ready()
    if slider:
        slider.editable = !disabled
        _handle_value_changed(slider.value)
    else:
        value_label.text = ""

func _enter_tree() -> void:
    super._enter_tree()

    if slider:
        _conf_slider()

        if slider.focus_entered.connect(_focus.bind(slider, true)) != OK:
            push_error("Failed to connect focus enter")
        if slider.focus_exited.connect(_focus.bind(slider, false)) != OK:
            push_error("Failed to connect focus exit")
        if slider.mouse_entered.connect(_hover.bind(slider, true)) != OK:
            push_error("Failed to connect mouse entered")
        if slider.mouse_exited.connect(_hover.bind(slider, false)) != OK:
            push_error("Failed to connect mouse exited")
        if slider.drag_started.connect(_press.bind(slider, true)) != OK:
            push_error("Failed to connect drag started")
        if slider.drag_ended.connect(_handle_drag_ended) != OK:
            push_error("Failed to connect drag ended")
        if slider.value_changed.connect(_handle_value_changed) != OK:
            push_error("Failed to connect value changed")

func _conf_slider() -> void:
    if !slider:
        return

    slider.min_value = 0.0
    slider.max_value = _steps.size() - 1
    slider.tick_count = _steps.size()
    slider.step = 1.0
    slider.rounded = true

func set_steps(steps: Dictionary[int, String], selected: int) -> void:
    _steps = steps
    _conf_slider()
    slider.value = selected
    _update_label(selected)

func _handle_value_changed(value: float) -> void:
    if !value_label || _steps.is_empty():
        return

    var i: int = roundi(value)
    var step_value: int = _update_label(i)
    on_change_value.emit(step_value)

func _update_label(i: int) -> int:
    var keys: Array[int] = _steps.keys()
    keys.sort()
    var step_value: int = keys[mini(i, keys.size() - 1)]
    value_label.text = _steps[step_value]
    return step_value

func _handle_drag_ended(_value_changed: bool) -> void:
    _press(slider, false)

func _set_disabled(value: bool) -> void:
    super._set_disabled(value)

    if slider:
        slider.editable = !value

    _update_style()

func _handle_clicked() -> void:
    if slider:
        slider.grab_focus()
