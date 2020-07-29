## Sobre

Esse é um projeto do Godot que contém um script chamado “Recorder.gd”. Esse script pode ser usado para gravar o viewport do Godot em qualquer resolução e quantos fps você quiser.

## Como usar

O passo a passo a seguir te fala como fazer uma cena simples usando um AnimationPlayer com uma única animação e um script pré-feito:

- Baixe ou clone esse repositório e importe o project.godot na sua instalação da Godot Engine.
- Crie uma nova cena onde você fará sua animação.
- Salve a cena em qualquer lugar do projeto (de preferência crie uma pasta só para a sua animação onde ficarão a sua cena e os seus scripts).
- Na sua árvore da cena onde tem os seus nodes, clique no ícone de link (instanciamento) e instancie a cena chamada “Recorder.tscn“.
  - De preferência deixe a cena Recorder como filha da sua cena raiz.
- Crie um node “AnimationPlayer”, outros nodes que você quer para a sua animação, e faça a sua animação.
- Dê ao seu AnimationPlayer o script “AnimAdvance.gd”.
- Uma nova aba chamada “Script Variables” aparecerá no inspetor quando o AnimationPlayer estiver selecionado. Configure aqueles parâmetros da seguinte forma:
  - Recorder Path: Se no campo estiver escrito “Assign...”, clique nele e selecione o seu node “Recorder”. Se no campo estiver escrito “Recorder”, o script já encontrou o Recorder automaticamente, você não precisa fazer nada.
  - Which Anim: Escreva nesse campo o nome da animação que você quer rodar quando a gravação começar.
- Agora vá para o seu Recorder e configure os Script Variables dele:
  - Record For Secs: Escreva nesse campo quantos segundos a sua gravação deve durar depois de renderizada.
  - Fps: Escreva nesse campo quantos quadros por segundo terá a sua animação depois de renderizada.
- Hora de gravar! Rode a cena apertando F6, ou clicando no ícone de claquete com botão de play no canto superior direito do editor do Godot.
- Quando a janela aparecer, aperte **duas vezes** no seu teclado o botão HOME para começar a gravação.
  - Se quiser abortar a gravação ou a renderização a qualquer momento, **segure** o botão END no seu teclado.
  - A gravação começará e terminará automaticamente, e os frames serão salvos como uma sequência de imagens na pasta do projeto.
  - Recomendo redimensionar a janela enquanto estiver gravando para ver o output no editor do Godot, e saber quantos frames já foram salvos e em que pasta eles estão.
- Você verá no output da engine quando a renderização for concluída.
- Para juntar todos os frames renderizados, vá para a pasta escrita no output da engine e copie todos os frames. Cole em outra pasta à qual você tenha acesso.
- Abra um editor de vídeo como o [Kdenlive](https://kdenlive.org/en/) e importe todos os frames como uma sequência de imagens.
- Renderize o seu vídeo!

## Scripting

Você pode fazer muito mais que usar apenas AnimationPlayers com uma animação cada um. Para criar o seu próprio script que rodará a cada frame da animação, você precisa saber um pouco de GDscript.

O template básico para um script que você pode usar em gravações é assim:

```GDScript
extends * # Troque esse asterisco pela classe que esse script herda. AnimationPlayer, Sprite, Node2D, etc.

signal im_done

# Export para você poder selecionar o node Recorder no editor.
# Se o Recorder for filho do pai deste node, ele é encontrado automaticamente.
export var recorder_path : NodePath = '../Recorder'

onready var recorder = get_node(recorder_path)

func _ready():
    # O grupo “RecordThis” contém todas as coisas que o Recorder grava.
    add_to_group('RecordThis')
    
    # Conecta os sinais que controlam o que acontece a cada frame, no início da gravação, e no final de cada frame.
    var _err = recorder.connect("recording_tick", self, "recording_tick")
    _err = recorder.connect("recording_start", self, "recording_start")
    _err = connect("im_done", recorder, "check_done")


func recording_start():
    # Programe aqui o que acontece antes da gravação começar.
    
    # Esse emit_signal no final é obrigatório. Assim o Recorder sabe quando ele pode passar para o próximo frame.
    emit_signal("im_done")

func recording_tick(delta): # Delta é igual a 1 / fps, ou seja, quantos segundos entre cada frame da gravação.
    # Programe aqui o que acontece a cada frame.
    
    # Esse emit_signal também é obrigatório.
    emit_signal("im_done")
```

Apenas copie esse template, cole em um novo script e atache esse script a um node. Alguns nodes que rodam todo frame por padrão, como os RigidBodies e os nodes de partículas, podem ser um pouco mais difíceis de capturar, pois eles não podem ser controlados diretamente, e o Recorder propositalmente grava a tela mais devagar do que o FPS da engine e tem um valor certo de delta para garantir que não haja slowdown. Se você conseguir criar um script que pode ser usado por outras pessoas como pré-feito, por favor me contate para eu adicionar ao repositório!

## Futuro

Esse projeto está muito no início ainda e eu não sei o que é possível e impossível de gravar com ele. Se encontrar qualquer bug no projeto, me avise! Mand um email para fupicat arroba gmail ponto com.

As próximas atualizações desse programa terão novos script pré-feitos.

## Licença

[CC0](https://creativecommons.org/publicdomain/zero/1.0/) Eu n ligo
