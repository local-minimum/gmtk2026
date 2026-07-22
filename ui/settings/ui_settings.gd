extends HBoxContainer

@export var sections: Array[Button]
@export var tab_container: TabContainer

func _enter_tree() -> void:
    var idx: int = 0
    for btn: Button in sections:
        btn.pressed.connect(func () -> void: tab_container.current_tab = idx)
        idx += 1


func _ready() -> void:
    var idx: int = 0
    for btn: Button in sections:
        if idx == tab_container.current_tab:
            btn.button_pressed = true
            btn.grab_focus()
        idx += 1
