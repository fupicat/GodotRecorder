# Esse é um exemplo de script que roda a cada tick de gravação.

extends AnimationPlayer

signal im_done

export var recorder_path : NodePath = '../Recorder'
export var which_anim = 'Go'

# Crie uma referência ao node “Recorder” usando o caminho dado pelo usuário.
onready var recorder = get_node(recorder_path)

# Conexões de grupo e sinais que fazem o objeto ser atualizado a cada tick.
func _ready():
    add_to_group('RecordThis')
    var _err = recorder.connect("recording_tick", self, "recording_tick")
    _err = recorder.connect("recording_start", self, "recording_start")
    _err = connect("im_done", recorder, "check_done")

# Executado quando o Recorder emite “recording_start”.
func recording_start():
    # Mude o modo de playback para que a animação só avance quando você mandar.
    playback_process_mode = AnimationPlayer.ANIMATION_PROCESS_MANUAL
    
    # Resete para o primeiro frame da animação.
    stop(true)
    
    # Toque a animação dada pelo usuário.
    play(which_anim)

# Executado quando o Recorder emite “recording_tick”.
func recording_tick(delta):
    # Avance a animação atual por “delta segundos” e atualize os visuais.
    # Delta = 1 segundo / X frames por segundo.
    # Ex: para 60fps, delta = 0.016667.
    advance(delta)
    
    # Avise o Recorder que o seu frame está pronto.
    emit_signal("im_done")
