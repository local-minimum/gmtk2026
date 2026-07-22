extends UISettingsBase
class_name UISlidingValueSetting

@export var value_suffix: String
@export var slider: Slider
@export var value_label: Label
@export var value_rounding: String = "%.1f%s"

func _ready() -> void:
    super._ready()
    if slider:
        slider.editable = !disabled
        value_label.text = ("%.0f%s" if slider.rounded else "%.1f%s") % [slider.value, value_suffix]
    else:
        value_label.text = ""

func _enter_tree() -> void:
    super._enter_tree()

    if slider:
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

func _handle_value_changed(value: float) -> void:
    if !value_label:
        return
    value_label.text = ("%.0f%s" if slider.rounded else value_rounding) % [value, value_suffix]

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
