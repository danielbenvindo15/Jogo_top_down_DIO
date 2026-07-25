class_name Enemy
extends Node2D


@export var health: int = 10
@export var death_prefab: PackedScene
var damage_digit_prefab: PackedScene
@onready var damage_digit_marker = $DamageDigitMarker

func _ready() -> void:
	# Esse preload importa determinado arquivo para dentro do script
	damage_digit_prefab = preload("res://misc/damage_digit.tscn")


func damage(amount: int) -> void:
	##Checa dano:
	health -= amount
	print("dano recebido: ", amount, " vida total: ", health)
	
	##------------ Efeito de dano --------------##
	
	modulate = Color("#9D2228")
	
	# - Cria um efeito de "transição no inimigo"
	var tween = create_tween()
	
	# - Diz o tipo de tranzição
	tween.set_ease(Tween.EASE_IN)
	
	# - Define a animação da tranzição
	tween.set_trans(Tween.TRANS_QUINT)
	
	# - Define as propriedades da transição criada acima
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	# - Processar morte
	if health <= 0: 
		die()
	
	## Criar DamageDigit
	var damage_digit = damage_digit_prefab.instantiate() #Cria o damage digit na cena
	damage_digit.value = amount
	if damage_digit_marker:
		damage_digit.global_position = damage_digit_marker.global_position
	else:
		damage_digit.global_position = global_position
	get_parent().add_child(damage_digit)


func die() -> void :
	if death_prefab:   # Verifica se o death prefab está na cena
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)

	queue_free()
