extends Control

@export var _labels: Array[Label]
@export var start_time: int = 600
@export var scroll_speed: float = -1.0
@export var label_padding: float = 0.0

func _ready() -> void:
    var offset: int = -floori(_labels.size() / 2.0)
    for label: Label in _labels:
        label.text = "%s" % (start_time - offset)
        offset += 1

    _next_time = start_time - offset
    _sync_label_positions()

var _next_time: int
var _last_time_change_label: Label

func _sync_label_positions() -> void:
    if _labels.is_empty():
        return

    var half: float =  _labels.size() / 2.5
    var delta: float = (1.0 + label_padding) * _labels[0].label_settings.font_size
    var idx: int = -floori(half)
    var top: float
    var top_idx: int = -1
    for label: Label in _labels:
        var offset: float = fposmod(_progress + idx , float(_labels.size())) - half
        if offset > top || top_idx < 0:
            top = offset
            top_idx = idx + floori(half)
        label.offset_transform_position.y = offset * delta
        idx += 1

    if _labels[top_idx] != _last_time_change_label:
        _last_time_change_label = _labels[top_idx]
        _last_time_change_label.text = "%s" % _next_time
        _next_time = maxi(0, _next_time - 1)


var _progress: float = 0.0
func _process(delta: float) -> void:
    _progress += delta * scroll_speed
    _sync_label_positions()
