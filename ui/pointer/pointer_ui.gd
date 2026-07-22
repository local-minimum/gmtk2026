extends CanvasLayer

@export var _textureRect: TextureRect
@export var _defaultTex: Texture2D
@export var _interactableTex: Texture2D
@export var _actionLabel: Label

var _current: Interactable
var _current_hint: Interactable.Hint

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
    if _textureRect:
        _textureRect.texture = _defaultTex

    if SignalBus.on_pointer_interaction_update.connect(_handle_walking_sim_crosshair) != OK:
        push_error("Failed to connect walking sim interactable")

    if SignalBus.on_pointer_visible.connect(_handle_pointer_visible) != OK:
        push_error("Failed to connect pointer visible")

    if SignalBus.on_interactable_action_change.connect(_handle_interactable_action_change) != OK:
        push_error("Failed to connect interactable action change")

    if SignalBus.on_interactable_action_name_change.connect(_handle_interactable_action_name_change) != OK:
        push_error("Failed to connect interactiable ")

    if SignalBus.on_pointer_captured.connect(_handle_pointer_captured) != OK:
        push_error("Failed to connect pointer captured")

    if SignalBus.on_pause_game.connect(_handle_pause_game) != OK:
        push_error("Failed to connect pause game")

    if SignalBus.on_update_pointer_setting.connect(_handle_update_pointer_setting) != OK:
        push_error("Failed to connect update pointer setting")

func _ready() -> void:
    set_process_input(false)
    _handle_update_pointer_setting(SignalBus.PointerSetting.SIZE, AccessibilitySettings.reticle_size)
    _handle_update_pointer_setting(SignalBus.PointerSetting.ALPHA, AccessibilitySettings.reticle_alpha)
    _handle_update_pointer_setting(SignalBus.PointerSetting.TEXT_SIZE, AccessibilitySettings.reticle_text_size)

func _handle_update_pointer_setting(setting: SignalBus.PointerSetting, value: Variant) -> void:
    match setting:
        SignalBus.PointerSetting.SIZE:
            if value is int:
                var size: int = value
                _textureRect.custom_minimum_size = Vector2.ONE * size
                _actionLabel.offset_transform_position.y = _textureRect.custom_minimum_size.y + _actionLabel.label_settings.font_size * 0.5
        SignalBus.PointerSetting.ALPHA:
            if value is float:
                var a: float = value
                _textureRect.self_modulate.a = a
        SignalBus.PointerSetting.TEXT_SIZE:
            if value is int:
                var size: int = value
                _actionLabel.offset_transform_position.y = _textureRect.custom_minimum_size.y + size * 0.5
                _actionLabel.label_settings.font_size = size

func _handle_pause_game(paused: bool) -> void:
    visible = !paused

func _handle_pointer_captured(captured: bool) -> void:
    if captured:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
        set_process_input(false)
        _textureRect.global_position = _textureRect.get_viewport_rect().get_center()
    else:
        Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
        set_process_input(true)

func _handle_interactable_action_name_change(action: InteractableAction) -> void:
    if _current && _current.action == action && _current_hint == Interactable.Hint.INTERACTABLE:
        _actionLabel.text = action.action_name

func _handle_interactable_action_change(interactable: Interactable) -> void:
    if interactable == _current:
        _handle_walking_sim_crosshair(_current_hint, interactable)

func _handle_pointer_visible(vis: bool) -> void:
    if !visible && vis:
        await get_tree().create_timer(0.1).timeout

    visible = vis

func _handle_walking_sim_crosshair(hint: Interactable.Hint, interactable: Interactable) -> void:
    _current = interactable
    _current_hint = hint

    match hint:
        Interactable.Hint.NONE:
            _textureRect.texture = _defaultTex
            _actionLabel.text = ""
        Interactable.Hint.POINTER:
            _textureRect.texture = _interactableTex
            _actionLabel.text = ""
        Interactable.Hint.INTERACTABLE:
            _textureRect.texture = _interactableTex
            _actionLabel.text = interactable.action.action_name if interactable.action else "???"

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        var mevt: InputEventMouseMotion = event
        _textureRect.global_position = mevt.position

    if event is InputEventMouseButton:
        var mevt: InputEventMouseButton = event
        if !mevt.is_pressed() || mevt.is_echo():
            return

        if mevt.button_index == MOUSE_BUTTON_LEFT && _current && _current_hint == Interactable.Hint.INTERACTABLE:
            _current.interact()
        elif mevt.button_index == MOUSE_BUTTON_RIGHT:
            SignalBus.on_abort_interaction.emit()
