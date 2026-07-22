@abstract
extends Control
class_name UISettingsBase

@export var disabled: bool:
    get = _get_disabled,
    set = _set_disabled
@export var background_panel: Panel
@export var labels: Array[Label] = []
@export var modulations: Array[Control] = []
@export_group("Modulation Colors")
@export var mod_default: Color = Color.WHITE
@export var mod_hover: Color = Color.WHITE
@export var mod_pressed: Color = Color.WHITE
@export var mod_focus: Color = Color.WHITE
@export var mod_disabled: Color = Color.GRAY


const _COMPONENT_THEME = "Setting"

var _disabled: bool
var _focused: Control
var _hovered: Control
var _pressed: Control

@abstract func _handle_clicked() -> void

func _enter_tree() -> void:
    if gui_input.connect(_handle_input) != OK:
        push_error("Failed to connect gui input")
    if focus_entered.connect(_focus.bind(self, true)) != OK:
        push_error("Failed to connect focus enter")
    if focus_exited.connect(_focus.bind(self, false)) != OK:
        push_error("Failed to connect focus exit")
    if mouse_entered.connect(_hover.bind(self, true)) != OK:
        push_error("Failed to connect mouse entered")
    if mouse_exited.connect(_hover.bind(self, false)) != OK:
        push_error("Failed to connect mouse exited")


func _ready() -> void:
    _update_style()

func _handle_input(event: InputEvent) -> void:
    if disabled:
        return

    if event is InputEventMouseButton:
        var mbtn: InputEventMouseButton = event
        if mbtn.button_index == MOUSE_BUTTON_LEFT:
            if mbtn.is_pressed():
                _pressed = self
            else:
                if _pressed:
                    if _hovered:
                        _handle_clicked()
                    _pressed = null
            _update_style()

func _update_style() -> void:
    if background_panel:
        _style_child(background_panel, "Panel", _COMPONENT_THEME)
    for label: Label in labels:
        _style_child(label, "Label", _COMPONENT_THEME)
    for modder: Control in modulations:
        _modulate_child(modder)

func _get_disabled() -> bool:
    return _disabled

func _set_disabled(value: bool) -> void:
    _disabled = value
    if value:
        _focused = null
        _hovered = null
        _pressed = null

func _press(what: Control, btn_pressed: bool) -> void:
    if disabled:
        return

    if btn_pressed:
        _pressed = what
    elif _pressed == what:
        _pressed = null

    _update_style()

func _hover(what: Control, btn_hovered: bool) -> void:
    if disabled:
        return

    if btn_hovered:
        _hovered = what
    elif _hovered == what:
        _hovered = null
    _update_style()

func _focus(what: Control, btn_focused: bool) -> void:
    if disabled:
        return

    if btn_focused:
        _focused = what
    elif _focused == what:
        _focused = null
    _update_style()

func _modulate_child(child: Control) -> void:
    if disabled:
        child.modulate = mod_disabled
    elif _pressed:
        child.modulate = mod_pressed
    elif _hovered:
        child.modulate = mod_hover
    elif _focused:
        child.modulate = mod_focus
    else:
        child.modulate = mod_default

func _style_child(child: Control, base: String, component: String) -> void:
    var t: Theme = find_theme(child)
    if !t:
        push_warning("%s of %s lacks custom theming so cannot be managed" % [child, self])
        return

    if disabled && t.is_type_variation("%s%sDisabled" % [component, base], base):
        child.theme_type_variation = "%s%sDisabled" % [component, base]
    elif _pressed && t.is_type_variation("%s%sPressed" % [component, base], base):
        child.theme_type_variation = "%s%sPressed" % [component, base]
    elif _hovered && t.is_type_variation("%s%sHover" % [component, base], base):
        child.theme_type_variation = "%s%sHover" % [component, base]
    elif _focused && t.is_type_variation("%s%sFocus" % [component, base], base):
        child.theme_type_variation = "%s%sFocus" % [component, base]
    elif t.is_type_variation("%s%sNormal" % [component, base], base):
        child.theme_type_variation = "%s%sNormal" % [component, base]
    else:
        child.theme_type_variation = ""


static func find_theme(node: Node) -> Theme:
    while node:
        if node is Control:
            var control: Control = node
            if control.theme:
               return control.theme
        node = node.get_parent()
    return null
