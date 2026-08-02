extends Node


#Variáveis
#----------------------------------#
#Variável que define a velocidade em px/s
@export var speed: float = 120
#Variável que liga o Script de seguir o jogador ao script enemy.gd
var enemy: Enemy
#Variável que relaciona o script do pawn com o sprite dele
var sprite: AnimatedSprite2D




func _ready():
	enemy = get_parent()
	sprite = enemy.get_node("AnimatedSprite2D")
	enemy.health
	pass

func _physics_process(delta: float) -> void:
	# Para o código se o Player morreu:
	if GameManager.is_game_over: return
	
	#--------- Movimentação do inimigo -----------------#
	
	# Define direção do inimigo:
	var player_position = GameManager.player_position
	var difference = player_position - enemy.position
	var input_vector = difference.normalized()
	
	# Define velocidade do inimigo:
	enemy.velocity = input_vector * speed
	
	#------ Sistema de rotação e espelhamento de Sprite ------#
	
	if difference.x > 0 :
		#Desmarcar flip_h do Sprite2D
		sprite.flip_h = false
		pass
	elif difference.x < 0 :
		#Marcar o flip_h do Sprite2D
		sprite.flip_h = true
		pass
	
	
	enemy.move_and_slide()
