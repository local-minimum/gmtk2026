extends UISettingsBase
class_name UIDropDownSetting

@export var option: OptionButton

func set_options(options: Array[String], on_item_selected_callback: Callable, selected: int = 0, update_disabled: bool = true) -> void:
    if option:
        option.clear()
        for opt: String in options:
            option.add_item(opt)

        if !option.item_selected.is_connected(on_item_selected_callback):
            option.item_selected.connect(on_item_selected_callback)

        if selected >= 0:
            option.selected = selected

        if update_disabled:
            disabled = options.size() < 2

func _enter_tree() -> void:
    super._enter_tree()

    if option:
        if option.focus_entered.connect(_focus.bind(option, true)) != OK:
            push_error("Failed to connect focus enter")
        if option.focus_exited.connect(_focus.bind(option, false)) != OK:
            push_error("Failed to connect focus exit")
        if option.mouse_entered.connect(_hover.bind(option, true)) != OK:
            push_error("Failed to connect mouse entered")
        if option.mouse_exited.connect(_hover.bind(option, false)) != OK:
            push_error("Failed to connect mouse exited")
        if option.button_down.connect(_press.bind(option, true)) != OK:
            push_error("Failed to connect button down")
        if option.button_up.connect(_press.bind(option, false)) != OK:
            push_error("Failed to connect button up")

        if option.item_count < 2:
            disabled = false

func _set_disabled(value: bool) -> void:
    super._set_disabled(value)

    if option:
        option.disabled = value

    _update_style()


func _handle_clicked() -> void:
    if option:
        option.grab_focus()
