extends CanvasLayer

@export var _rotate_inspected_velocity_scale: float = 0.01

@export var affirmative: Label
@export var affirmative_panel: Panel

@export var decline: Label
@export var decline_panel: Panel

@export var _drag_length_to_select: float = 1.0
@export var _drag_easing_velocity: float = 5

@export var neutral_color: Color
@export var opposite_color: Color
@export var accept_color: Color
@export var decline_color: Color
@export var neutral_offset: float = 0.1

@export var select_size: int = 32
@export var default_size: int = 16

@export var selected_style: StyleBox
@export var not_selected_style: StyleBox

@export var inspect_mat: Material

var _affirmative_callback: Variant
var _decline_callback: Variant
var _inspected_obj: Node3D
var _inspected_obj_resting_pos: Vector3
var _inspected_obj_distance: float

enum Action { NONE, AFFIRM, DECLINE }

var _action: Action = Action.NONE

func _enter_tree() -> void:
    if SignalBus.on_inspect_object.connect(_handle_inspect_object) != OK:
        push_error("Failed to connect inspect object")
    if SignalBus.on_inspect_object_ready.connect(_handle_inspect_object_ready) != OK:
        push_error("Failed to connect inspect object ready")
    if SignalBus.on_pause_game.connect(_handle_pause) != OK:
        push_error("Failed to connect pause")

func _ready() -> void:
    set_process_input(false)
    visible = false

var _resume_visible: bool

func _handle_pause(paused: bool) -> void:
    if paused:
        _resume_visible = visible
        visible = false
    else:
        visible = _resume_visible

func _handle_inspect_object(obj: Node3D, affirmative_verb: String, affirmative_callback: Variant, decline_verb: String, decline_callback: Variant) -> void:
    SignalBus.on_pointer_visible.emit(false)

    _inspected_obj = obj
    affirmative.text = "< %s" % [affirmative_verb]
    decline.text = "%s >" % [decline_verb]
    _affirmative_callback = affirmative_callback
    _decline_callback = decline_callback

    affirmative.visible = !affirmative_verb.is_empty()
    decline.visible = !decline_verb.is_empty()

func _handle_inspect_object_ready(inspected_root: Node3D, cam: Camera3D) -> void:
    _cam = cam
    _inspected_root = inspected_root

    _inspected_obj_resting_pos = inspected_root.global_position
    _inspected_obj_distance = _inspected_obj_resting_pos.distance_to(cam.global_position)

    # TODO: This should know about mouse vs controller
    Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
    visible = true

    set_process(true)
    set_process_input(true)

    _apply_inspect_mat(inspected_root)

func _end_inspection() -> void:
    _remove_inspect_mat(_inspected_root)
    SignalBus.on_complete_inspect_object.emit(_inspected_obj)
    SignalBus.on_pointer_visible.emit(true)
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    visible = false
    _inspected_obj = null
    _inspected_root = null

    set_process(false)
    set_process_input(false)

var _cam: Camera3D
var _inspected_root: Node3D
var _rotating_inspected: bool
var _dragging_inspected: bool
var _drag_velocity: Vector2
var _pointer_pos: Vector2

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        var m_evt: InputEventMouseButton = event
        if m_evt.button_index == MOUSE_BUTTON_RIGHT:
            _rotating_inspected = m_evt.is_pressed()
        if m_evt.button_index == MOUSE_BUTTON_LEFT:
            _dragging_inspected = m_evt.is_pressed()
            if _dragging_inspected && _cam:
                _pointer_pos = _cam.get_viewport().get_visible_rect().get_center()
            elif !_dragging_inspected:
                match _action:
                    Action.AFFIRM:
                        _end_inspection()
                        if _affirmative_callback is Callable:
                            (_affirmative_callback as Callable).call()
                        _affirmative_callback = null
                        _decline_callback = null
                        return
                    Action.DECLINE:
                        _end_inspection()
                        if _decline_callback is Callable:
                            (_decline_callback as Callable).call()
                        _affirmative_callback = null
                        _decline_callback = null
                        return
    if event is InputEventMouseMotion:
        var m_evt: InputEventMouseMotion  = event
        _drag_velocity = m_evt.velocity

var _uniqified: Array[Material] = []

func _apply_inspect_mat(node: Node3D) -> void:
    if !inspect_mat:
        return

    var m_nodes: Array[MeshInstance3D] = []
    if node is MeshInstance3D:
        m_nodes.append(node as MeshInstance3D)
    m_nodes.append_array(node.find_children("", "MeshInstance3D"))

    for m_node: MeshInstance3D in m_nodes:
        for i: int in m_node.get_surface_override_material_count():
            var mat: Material = m_node.get_active_material(i)
            if mat == null:
                break
            var parent_mat: Material = null
            while mat.next_pass && mat.next_pass != inspect_mat:
                parent_mat = mat
                mat = mat.next_pass

            if !_uniqified.has(mat):
                mat = mat.duplicate()
                _uniqified.append(mat)

            if parent_mat:
                parent_mat.next_pass = mat
            else:
                m_node.set_surface_override_material(i, mat)

            mat.next_pass = inspect_mat
            print_debug("%s's %s got next pass %s (%s)" % [m_node, mat, inspect_mat, mat.next_pass])

func _remove_inspect_mat(node: Node3D) -> void:
    if !inspect_mat:
        return

    var m_nodes: Array[MeshInstance3D] = []
    if node is MeshInstance3D:
        m_nodes.append(node as MeshInstance3D)
    m_nodes.append_array(node.find_children("", "MeshInstance3D"))

    for m_node: MeshInstance3D in m_nodes:
        for i: int in m_node.get_surface_override_material_count():
            var mat: Material = m_node.get_active_material(i)
            if mat == null:
                break
            while mat.next_pass && mat.next_pass != inspect_mat:
                mat = mat.next_pass

            if mat.next_pass == inspect_mat:
                mat.next_pass = null

func _rotate_inspected(delta: float) -> void:
    var v: Vector2 = delta * _drag_velocity * _rotate_inspected_velocity_scale
    _inspected_root.global_rotate(_cam.global_basis.y, v.x)
    _inspected_root.global_rotate(_cam.global_basis.x, v.y)

func _process(delta: float) -> void:
    if !_inspected_root:
        return
    if _rotating_inspected && _cam:
        _rotate_inspected(delta)

    _pointer_pos += _drag_velocity * delta
    var rsize: Vector2 =  _cam.get_viewport().get_visible_rect().size
    var mid_height: float = rsize.y * 0.5
    var raw_drag: float = clamp(_pointer_pos.x / rsize.x * 2.0 - 1.0, -_drag_length_to_select, _drag_length_to_select)

    if _dragging_inspected:
        if _cam:
            _inspected_root.global_position = _inspected_root.global_position.lerp(
                _cam.project_position(
                    Vector2((raw_drag + 1) * 0.5 * rsize.x, mid_height),
                    _inspected_obj_distance,
                ),
                delta * _drag_easing_velocity
            )
    else:
        _inspected_root.global_position = _inspected_root.global_position.lerp(_inspected_obj_resting_pos, delta * _drag_easing_velocity)

    var obj_pos: float = _cam.unproject_position(_inspected_root.global_position).x / rsize.x * 2.0 - 1.0
    var select_progress: float = clamp(obj_pos / _drag_length_to_select, -1.0, 1.0)

    _set_option_labels(select_progress)

func _set_option_labels(progress: float) -> void:
    if progress == 0:
        affirmative.modulate = neutral_color.lerp(accept_color, neutral_offset)
        decline.modulate = neutral_color.lerp(decline_color, neutral_offset)
        affirmative.add_theme_font_size_override("font_size", default_size)
        decline.add_theme_font_size_override("font_size", default_size)

    elif progress < 0:
        affirmative.modulate = neutral_color.lerp(accept_color, neutral_offset).lerp(accept_color, -progress)
        decline.modulate = neutral_color.lerp(decline_color, neutral_offset).lerp(opposite_color, -progress)
        affirmative.add_theme_font_size_override("font_size", roundi(lerpf(default_size, select_size, -progress)))
        decline.add_theme_font_size_override("font_size", default_size)

        if progress < -0.95:
            _action = Action.AFFIRM
            affirmative_panel.add_theme_stylebox_override("panel", selected_style)
        else:
            if _action == Action.AFFIRM:
                _action = Action.NONE
            affirmative_panel.add_theme_stylebox_override("panel", not_selected_style)

    elif progress > 0:
        affirmative.modulate = neutral_color.lerp(accept_color, neutral_offset).lerp(opposite_color, progress)
        decline.modulate = neutral_color.lerp(decline_color, neutral_offset).lerp(decline_color, progress)
        decline.add_theme_font_size_override("font_size", roundi(lerpf(default_size, select_size, progress)))
        affirmative.add_theme_font_size_override("font_size", default_size)

        if progress > 0.95:
            _action = Action.DECLINE
            decline_panel.add_theme_stylebox_override("panel", selected_style)
        else:
            if _action == Action.DECLINE:
                _action = Action.NONE
            decline_panel.add_theme_stylebox_override("panel", not_selected_style)
