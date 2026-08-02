extends CanvasLayer

@onready var timer_label: Label = %TimerLabel
@onready var meat_label: Label = %MeatLabel


func _process(delta: float) -> void:
	timer_label.text = GameManager.time_elapsed_string
	meat_label.text = str(GameManager.meat_counter) # Já determina a relação do teto do meatlabel com a variavel meat_counter já ao carregar o jogo.
