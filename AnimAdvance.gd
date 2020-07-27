extends AnimationPlayer

signal im_done

export var recorder_path : NodePath = '../Recorder'
export var which_anim = 'Go'

onready var recorder = get_node(recorder_path)

func _ready():
    add_to_group('RecordThis')
    var _err = recorder.connect("recording_tick", self, "recording_tick")
    _err = recorder.connect("recording_start", self, "recording_start")
    _err = connect("im_done", recorder, "check_done")

func recording_start():
    playback_process_mode = AnimationPlayer.ANIMATION_PROCESS_MANUAL
    stop(true)
    play(which_anim)
    emit_signal("im_done")

func recording_tick(delta):
    advance(delta)
    emit_signal("im_done")
