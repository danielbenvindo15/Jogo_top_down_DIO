class_name Enemy
extends Node2D

@export_category("Life")
@export var health: int = 10
@export var death_prefab: PackedScene
var damage_digit_prefab: PackedScene

@export_category("Drops")
@export var drop_chance: float = 0.1
@export var drop_items: Array[PackedScene]
@export var drop_chances: Array[float]

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
	##Invoca caveira
	if death_prefab:   # Verifica se o death prefab está na cena
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)

	##Drop
	if randf() <= drop_chance:
		drop_item()
	##Deletar Node
	queue_free()

func drop_item() -> void:
	var drop = get_random_drop_item().instantiate()
	drop.position = position
	get_parent().add_child(drop)


##------------- Função para drop de items ------------------#
func get_random_drop_item() -> PackedScene:
	
	if drop_items.size() == 1: # Sistema para evitar erro caso a lista de drops tiver apenas 1 drop nela
		return drop_items[0]
	
	##Calcular chance máxima (A soma de todas as chances de todos os drops)
	var max_chance: float = 0.0
	for drop_chance in drop_chances: 
		max_chance += drop_chance
	
	##Essa variável é como se jogasse um "dado" em um lugar aleatório da nossa lista
	var random_value = randf() * max_chance
	
	##Estrutura de repetição que verifica em qual item o random_value parou
	var needle: float = 0.0
	
	 # - Passa uma "agulha" por todos os itens da variavel drop_items pra encontrar em qual lugar o "dado" foi jogado
	for i in drop_items.size():
		var drop_item = drop_items[i]
		var drop_chance = drop_chances[i] if i < drop_chances.size() else 1 # Vê se o "dado" passou por esse lugar
		
		#Finaliza a estrutura de repetição
		if random_value <= drop_chance + needle:
			return drop_item
		needle += drop_chance
	
	return drop_items[0]
