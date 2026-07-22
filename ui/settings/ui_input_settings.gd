extends Control

@export var input_method: BindingSettings.InputMethod
@export var reset_btn: BaseButton
var bindings: Array[UIBindingSettings]

func _enter_tree() -> void:
    for binding: UIBindingSettings in find_children("", "UIBindingSettings"):
        bindings.append(binding)
        if binding.input_method != input_method:
            binding.input_method = input_method
            binding.sync()
        if binding.on_change_binding.connect(BindingSettings.store_changed_binding) != OK:
            push_error("Failed to connect change binding")

    if reset_btn.pressed.connect(_handle_reset) != OK:
        push_error("Failed to connect reset bindings")

func _ready() -> void:
    for bind: UIBindingSettings in bindings:
        for btn: Button in bind.bindings:
            btn.grab_focus()
            return

func _handle_reset() -> void:
    BindingSettings.reset_input_method(input_method)
    for binding: UIBindingSettings in bindings:
        binding.sync()
