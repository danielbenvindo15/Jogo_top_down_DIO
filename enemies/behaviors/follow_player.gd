extends CharacterBody2D


#Variáveis
#----------------------------------#
#Variável que define a velocidade em px/s
@export var speed: float = 120
#Variável que relaciona o script do pawn com o sprite dele
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	
	#--------- Movimentação do inimigo -----------------#
	
	# Define direção do inimigo:
	var player_position = GameManager.player_position
	var difference = player_position - position
	var input_vector = difference.normalized()
	
	# Define velocidade do inimigo:
	velocity = input_vector * speed
	
	#------ Sistema de rotação e espelhamento de Sprite ------#
	
	if difference.x > 0 :
		#Desmarcar flip_h do Sprite2D
		sprite.flip_h = false
		pass
	elif difference.x < 0 :
		#Marcar o flip_h do Sprite2D
		sprite.flip_h = true
		pass
	
	
	move_and_slide()
