extends Node

signal recording_tick
signal recording_start
signal frame_done
signal start_done

export var record_for_secs = 1.0
export var fps = 60

var recordthis = 0
var done = 0
var recording = false
var frame = 0
var frames = []

func _ready():
    recordthis = 0
    for node in get_tree().get_nodes_in_group('RecordThis'):
        recordthis += 1

func _input(event):
    if event.is_action_pressed("ui_home"):
        stop_recording(true)
        start_recording()
    if event.is_action_pressed("ui_end"):
        stop_recording(true)

func _process(_delta):
    if not recording:
        return
    done = 0
    var delta = 1.0 / fps
    emit_signal("recording_tick", delta)
    yield(self, "frame_done")
    frames.append(take_screenshot())
    frame += 1
    if frame >= record_for_secs * 60:
        stop_recording()

func check_done():
    done += 1
    if done >= recordthis:
        emit_signal("frame_done")

func stop_recording(abort = false):
    if not recording:
        return
    recording = false
    if abort:
        print('Aborted!')
        return
    save_all()

func start_recording():
    var dir = Directory.new()
    if dir.open('user://') == OK:
        dir.list_dir_begin(true)
        var file_name = dir.get_next()
        while file_name != "":
            dir.remove(file_name)
            file_name = dir.get_next()
    else:
        print("User directory missing! This shouldn't be possible.")
    frame = 0
    frames = []
    done = 0
    emit_signal("recording_start")
    yield(self, "frame_done")
    recording = true

func take_screenshot():
    var screenshot = get_viewport().get_texture().get_data()
    screenshot.flip_y()
    return screenshot

func get_frame_name(framen):
    var how_many_zeros = len(str(frame)) - len(str(framen))
    assert(how_many_zeros >= 0)
    var numstr = ''
    for _i in range(how_many_zeros):
        numstr += '0'
    numstr += str(framen)
    return numstr

func save_all():
    print('Saving frames... DO NOT quit program!')
    yield(get_tree(), "idle_frame")
    yield(get_tree(), "idle_frame")
    var i = 0
    for frm in frames:
        print('Saving frame ' + get_frame_name(i) + '...')
        yield(get_tree(), "idle_frame")
        yield(get_tree(), "idle_frame")
        if Input.is_action_pressed("ui_end"):
            print('Saving aborted!')
            return
        frm.save_png('user://Frame' + get_frame_name(i) + '.png')
        i += 1
    frames = []
    frame = 0
    print('Finished! Files saved at ' + OS.get_user_data_dir())
