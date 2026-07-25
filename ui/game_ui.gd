extends CanvasLayer

@onready var timer_label: Label = %TimerLabel
@onready var meat_label: Label = %MeatLabel

var time_elapsed: float = 0.0
var meat_counter: int = 0

func _ready() -> void:
	GameManager.player.meat_collected.connect(on_meat_collected)
	meat_label.text = str(meat_counter) # Já determina a relação do teto do meatlabel com a variavel meat_counter já ao carregar o jogo.

func _process(delta: float) -> void:
	# Update Timer
	time_elapsed += delta
	var time_elapsed_in_seconds: int = floori(time_elapsed) #O floori() arredonda o valor colocado nele pra baixo e em um valor inteiro. Isso é usado no tempo pois por exemplo 2:35 não chegou a 3 minutos ainda, sendo necessário arredondar para 2 minutos.
	var seconds: int = time_elapsed_in_seconds % 60
	var minutes: int = time_elapsed_in_seconds / 60
	
	
	timer_label.text = "%02d:%02d" % [minutes , seconds] #Vá para o minuto 08:57 do video "Programando o timer do nosso jogo" no curso de ui do bootcamp de godot


func on_meat_collected(regeneration_value: int) -> void:
	meat_counter += 1
	meat_label.text = str(meat_counter)
