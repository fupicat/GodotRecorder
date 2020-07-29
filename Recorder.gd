# Esse é o script que realiza a gravação e avisa os objetos quando eles podem
# passar para o próximo frame. Você não precisa mexer aqui.

# Para adicionar isso a uma cena, clique no botão de “link”, so lado do botão
# de adicionar, na sua aba “Scene”, e selecione a cena “Recorder.tscn”.
extends Node

signal recording_tick
signal recording_start
signal frame_done

export var record_for_secs = 1.0
export var fps = 60

var recordthis = 0
var done = 0
var recording = false
var frame = 0
var frames = []

# Conte o número de objetos que mudam a cada tick.
func _ready():
    recordthis = 0
    for node in get_tree().get_nodes_in_group('RecordThis'):
        recordthis += 1

# Aperte HOME para começar a gravar. Aperte END para parar.
func _input(event):
    if event.is_action_pressed("ui_home"):
        stop_recording(true)
        start_recording()
    if event.is_action_pressed("ui_end"):
        stop_recording(true)

func _process(_delta):
    
    # Apenas faça um tick se estiver gravando.
    if not recording:
        return
    
    # Calcule quantos segundos por frame.
    var delta = 1.0 / fps
    
    # Faça um tick de gravação e espere até que todos os script de objetos
    # sendo gravados tenham terminado sua execução.
    emit_signal("recording_tick", delta)
    yield(self, "frame_done")
    
    # Tire uma print, adicione-a à lista de frames e aumente o frame atual.
    frames.append(take_screenshot())
    frame += 1
    
    # Se a gravação tiver chegado ao limite de segundos dado pelo usuário,
    # pare de gravar.
    if frame >= record_for_secs * 60:
        stop_recording()

# Executado por sinais em outros objetos. Se o número de objetos que
# terminaram execução for maior ou igual ao número total de objetos que
# executam algo todo tick, emita “frame_done”.
func check_done():
    done += 1
    if done >= recordthis:
        done = 0
        emit_signal("frame_done")

# Pare a gravação e salve todos os prints. Se abort == true, não salve nada.
func stop_recording(abort = false):
    if not recording:
        return
    recording = false
    if abort:
        print('Aborted!')
        
        # Recarrega a cena para tudo voltar ao seu lugar.
        var _err = get_tree().reload_current_scene()
        return
    save_all()

# Começa a gravar.
func start_recording():
    
    # Delete tudo da pasta de usuário.
    var dir = Directory.new()
    if dir.open('user://') == OK:
        dir.list_dir_begin(true)
        var file_name = dir.get_next()
        while file_name != "":
            dir.remove(file_name)
            file_name = dir.get_next()
    else:
        print("Não há pasta de usuário! Isso é impossível.")
    
    # Resete o frame atual, a lista de frames e quantos objetos terminaram
    # execução.
    frame = 0
    frames = []
    done = 0
    
    # Emita isso para inicializar o primeiro frame, comece a gravar.
    emit_signal("recording_start")
    recording = true

# Reporte uma imagem do viewport principal.
func take_screenshot():
    var screenshot = get_viewport().get_texture().get_data()
    screenshot.flip_y()
    return screenshot

# Reporte o número do frame com o número apropriado de zeros antes dele.
func get_frame_name(framen):
    var how_many_zeros = len(str(frame)) - len(str(framen))
    assert(how_many_zeros >= 0)
    var numstr = ''
    for _i in range(how_many_zeros):
        numstr += '0'
    numstr += str(framen)
    return numstr

# Salva todos os frames.
func save_all():
    print('Fim da gravação! Salvando frames...')
    
    # Espere por um frame só para que a mensagem apareça.
    yield(get_tree(), "idle_frame")
    yield(get_tree(), "idle_frame")
    
    # Salve todos os frames.
    var i = 0
    for frm in frames:
        print('Saving frame ' + get_frame_name(i) + '...')
        yield(get_tree(), "idle_frame")
        yield(get_tree(), "idle_frame")
        
        # Segure END para abortar o processo de salvamento.
        if Input.is_action_pressed("ui_end"):
            print('Saving aborted!')
            get_tree().reload_current_scene()
            return
        frm.save_png('user://Frame' + get_frame_name(i) + '.png')
        i += 1
    print('Finished! Files saved at ' + OS.get_user_data_dir())
    get_tree().reload_current_scene()
