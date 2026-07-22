extends UISettingsBase
class_name UIBindingSettings

signal on_change_binding(input_method: BindingSettings.InputMethod, action: String, idx: int, event: InputEvent)

@export var input_method: BindingSettings.InputMethod = BindingSettings.InputMethod.KEYBOARD_AND_MOUSE
@export var bindings: Array[Button]
@export var action: String
@export_group("Bad Binding")
@export var binding_unset: String
@export var binding_incompatible: String = "err"
@export var binding_unknown: String = "???"

var _monitor_input: bool:
    set(value):
        _monitor_input = value
        set_process_input(value)
        set_process_unhandled_input(value)

func _enter_tree() -> void:
    super._enter_tree()

    for button: Button in bindings:
        if button.focus_entered.connect(_focus.bind(button, true)) != OK:
            push_error("Failed to connect focus enter")
        if button.focus_exited.connect(_handle_defocus.bind(button)) != OK:
            push_error("Failed to connect focus exit")
        if button.mouse_entered.connect(_hover.bind(button, true)) != OK:
            push_error("Failed to connect mouse entered")
        if button.mouse_exited.connect(_hover.bind(button, false)) != OK:
            push_error("Failed to connect mouse exited")
        if button.button_down.connect(_press.bind(button, true)) != OK:
            push_error("Failed to connect button down")
        if button.button_up.connect(_press.bind(button, false)) != OK:
            push_error("Failed to connect button up")
        if button.pressed.connect(_handle_rebind.bind(button)) != OK:
            push_error("Failed to connect handle rebind")
        if button.gui_input.connect(_handle_gui_input.bind(button)) != OK:
            push_error("Failed to connect handle gui input")

func _handle_gui_input(evt: InputEvent, btn: Button) -> void:
    if evt.is_action_pressed(&"ui_clear_setting"):
        btn.text = "\u200e"
        _update_binding(btn, bindings.find(btn), null)

func _handle_defocus(button: Button) -> void:
    if button.button_pressed:
        button.button_pressed = false
        _monitor_input = false

    _focus(button, false)

func _ready() -> void:
    for button: Button in bindings:
        button.disabled = disabled
        button.button_pressed = false
    _update_style()
    _monitor_input = false
    sync()

func _set_disabled(value: bool) -> void:
    super._set_disabled(value)

    for btn: Button in bindings:
        btn.disabled = value

    _update_style()

func _handle_clicked() -> void:
    if bindings.is_empty():
        return

    var btn: Button = bindings[0]
    btn.button_pressed = true
    btn.grab_focus()

func _handle_rebind(btn: Button) -> void:
    if !btn.button_pressed:
        return

    if action.is_empty():
        push_warning("Inmput re-mapper %s lacks binding key" % [self])
        return

    if !InputMap.has_action(action):
        push_warning("Input re-mapper %s's binding '%s' does not exists in settings" % [self, action])
        return

    _monitor_input = true

func _valid_action_event(evt: InputEvent) -> bool:
    return BindingSettings.is_valid_action_event(evt, input_method)

func sync() -> void:
    for idx: int in bindings.size():
        var btn: Button = bindings[idx]
        var inp: InputEvent = BindingSettings.get_binding(input_method, action, idx)
        if inp == null:
            btn.text = "\u200e"
            continue

        if inp is InputEventKey:
            if input_method != BindingSettings.InputMethod.KEYBOARD_AND_MOUSE:
                push_warning("Input re-mapper %s's binding '%s' #%s binding not joypad compatible event: %s" % [self, action, idx, inp])
                btn.text = binding_incompatible
                continue

            btn.text = BindingSettings.key_event_to_text(inp as InputEventKey)
            continue

        if inp is InputEventMouseButton:
            if input_method != BindingSettings.InputMethod.KEYBOARD_AND_MOUSE:
                push_warning("Input re-mapper %s's binding '%s' #%s binding is not joypad compatible event: %s" % [self, action, idx, inp])
                btn.text = binding_incompatible
                continue

            btn.text = BindingSettings.mouse_event_to_text(inp as InputEventMouseButton)
            continue

        if inp is InputEventJoypadButton:
            if input_method != BindingSettings.InputMethod.JOYPAD:
                push_warning("Input re-mapper %s's binding '%s' #%s binding is not keyboard and mouse compatible event: %s" % [self, action, idx, inp])
                btn.text = binding_incompatible
                continue

            btn.text = BindingSettings.joy_btn_event_to_text(inp as InputEventJoypadButton)
            continue

        if inp is InputEventJoypadMotion:
            if input_method != BindingSettings.InputMethod.JOYPAD:
                push_warning("Input re-mapper %s's binding '%s' #%s binding is not keyboard and mouse compatible event: %s" % [self, action, idx, inp])
                btn.text = binding_incompatible
                continue

            btn.text = BindingSettings.joy_axis_event_to_text(inp as InputEventJoypadMotion)
            continue

        push_warning("Input re-mapper %s's binding '%s' #%s is of unhandled type: %s" % [self, action, idx, inp])
        btn.text = binding_unknown

func _input(event: InputEvent) -> void:
    _unhandled_input(event)

func _unhandled_input(event: InputEvent) -> void:
    if !InputMap.has_action(action):
        push_error("Input map lacks %s's key '%s'" % [self, action])
        _monitor_input = false
        for btn: Button in bindings:
            btn.button_pressed = false
        return

    for idx: int in bindings.size():
        var btn: Button = bindings[idx]
        if !btn.button_pressed:
            continue

        if event is InputEventKey:
            var kevt: InputEventKey = event
            if !kevt.is_pressed() || kevt.is_echo():
                return

            if kevt.keycode == KEY_ESCAPE:
                btn.button_pressed = false
                _monitor_input = false
                return

            if input_method == BindingSettings.InputMethod.KEYBOARD_AND_MOUSE:
                _update_binding(btn, idx, kevt)
                return

        if event is InputEventMouseButton:
            var mevt: InputEventMouseButton = event
            if !mevt.is_pressed() || mevt.is_echo():
                return

            if input_method == BindingSettings.InputMethod.KEYBOARD_AND_MOUSE:
                _update_binding(btn, idx, mevt)
                return

        if event is InputEventJoypadButton:
            var jevt: InputEventJoypadButton = event
            if !jevt.is_pressed() || jevt.is_echo():
                return

            if jevt.button_index == JoyButton.JOY_BUTTON_BACK:
                btn.button_pressed = false
                _monitor_input = false
                return

            if input_method == BindingSettings.InputMethod.JOYPAD:
                _update_binding(btn, idx, jevt)

        if event is InputEventJoypadMotion:
            var jevt: InputEventJoypadMotion = event
            if !jevt.is_pressed() || jevt.is_echo() || jevt.axis_value == 0:
                return

            if input_method == BindingSettings.InputMethod.JOYPAD:
                jevt.axis_value = -1.0 if jevt.axis_value < 0.0 else 1.0
                _update_binding(btn, idx, jevt)

    get_viewport().set_input_as_handled()

func _update_binding(btn: Button, idx: int, evt: InputEvent) -> void:
    var all_events: Array[InputEvent] = InputMap.action_get_events(action)
    var events: Array[InputEvent] = []
    events.append_array(all_events.filter(_valid_action_event))

    if evt == null:
        if events.size() > idx:
            var evt_idx: int = all_events.find(events[idx])
            all_events.remove_at(evt_idx)
            InputMap.action_erase_events(action)
            for e: InputEvent in all_events:
                InputMap.action_add_event(action, e)
    elif events.size() > idx:
        var evt_idx: int = all_events.find(events[idx])
        all_events[evt_idx] = evt
        InputMap.action_erase_events(action)
        for e: InputEvent in all_events:
            InputMap.action_add_event(action, e)
    else:
        InputMap.action_add_event(action, evt)

    on_change_binding.emit(input_method, action, idx, evt)
    btn.button_pressed = false
    _monitor_input = false
    sync()
