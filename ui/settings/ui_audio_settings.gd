extends Control

@export var master: UISlidingValueSetting
@export var music: UISlidingValueSetting
@export var dialogue: UISlidingValueSetting
@export var effects: UISlidingValueSetting
@export var effects_alt: UISlidingValueSetting

var _syncing: bool

func _ready() -> void:
    _syncing = true

    if master:
        _set_and_connect(master, AudioHub.Bus.MASTER)
    if music:
        _set_and_connect(music, AudioHub.Bus.MUSIC)
    if dialogue:
        _set_and_connect(dialogue, AudioHub.Bus.DIALGUE)
    if effects:
        _set_and_connect(effects, AudioHub.Bus.SFX)
    if effects_alt:
        _set_and_connect(effects_alt, AudioHub.Bus.SFX_ALT)

    _syncing = false

func _set_and_connect(setting: UISlidingValueSetting, bus: AudioHub.Bus) -> void:
    var volume: float = AudioHub.get_volume(bus)
    setting.slider.value = volume * 100.0
    setting.slider.value_changed.connect(_change_volume.bind(bus))

func _change_volume(volume: float, bus: AudioHub.Bus) -> void:
    if !_syncing:
        AudioSettings.store_volume(bus, volume * 0.01)
