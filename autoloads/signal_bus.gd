extends Node
class_name _SignalBus

@warning_ignore_start("unused_signal")
signal on_pause_game(paused: bool)

# Input
signal on_change_input_method(input_method: BindingSettings.InputMethod)

# Cursor
signal on_pointer_visible(visible: bool)
signal on_pointer_captured(captured: bool)
signal on_pointer_interaction_update(hint: Interactable.Hint, interactable: Interactable)
signal on_interactable_action_change(interactable: Interactable)
signal on_interactable_action_name_change(action: InteractableAction)
enum PointerSetting { SIZE, ALPHA, TEXT_SIZE }
signal on_update_pointer_setting(setting: PointerSetting, value: Variant)
signal on_abort_interaction()

# Settings
#signal on_update_input_mode(method: BindingHints.InputMode)
signal on_update_handedness(handedness: AccessibilitySettings.Handedness)
signal on_update_mouse_y_inverted(inverted: bool)
signal on_update_mouse_sensitivity(sensistivity: float)
signal on_update_joy_y_inverted(inverted: bool)
signal on_update_joy_sensitivity(sensistivity: float)
signal on_update_motion_sickness(motion_sickness: AccessibilitySettings.MotionSickness)
signal on_update_fov(fov: float)

# A11Y systems
signal on_subtitle(data: SubData)
signal on_clear_queued_subtitles(subs: Array[SubData])
signal on_clear_all_queued_subtitles()
signal on_toggle_subtitles(enabled: bool)
signal on_change_subtitles_size(size: int)
signal on_change_whisper_muting(mute_priority: int)

# FPS actions
signal on_inspect_object(obj: Node3D, affirmative_verb: String, affirmative_callback: Variant, decline_verb: String, decline_callback: Variant)
signal on_inspect_object_ready(obj: Node3D, cam: Camera3D)
signal on_complete_inspect_object(obj: Node3D)
enum CinematicMode { INITIAL, DYNAMIC_TARGET, DYNAMIC_OFFSET }
signal on_look_at_object(obj: Node3D, offset: Vector3, cinematic_follow: CinematicMode, ease_time: float, callback: Variant)
signal on_unlook_at_object(obj: Node3D, ease_time: float, callback: Variant)


# Rooms
signal on_room_completed()

# Clock Room
signal on_count_down_room_press_big_button(press_count: int)

# Sports Counting
signal on_check_score()
signal on_show_score_card(show: bool)
