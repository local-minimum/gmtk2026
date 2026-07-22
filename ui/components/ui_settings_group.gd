extends PanelContainer
class_name UISettingsGroup

enum VisibleCondition { PRESSED, NOT_PRESSED }
@export var required_setting: UIToggleSetting
@export var visible_condition: VisibleCondition = VisibleCondition.PRESSED

func _ready() -> void:
    if required_setting && required_setting.button:
        _handle_required_setting_toggled(required_setting.button.button_pressed)

func _enter_tree() -> void:
    if required_setting && required_setting.button:
        if required_setting.button.toggled.connect(_handle_required_setting_toggled) != OK:
            push_error("Failed to connect require setting toggled")


func _handle_required_setting_toggled(toggled: bool) -> void:
    if toggled:
        visible = visible_condition == VisibleCondition.PRESSED
    else:
        visible = visible_condition == VisibleCondition.NOT_PRESSED
