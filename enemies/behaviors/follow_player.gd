extends CharacterBody2D


#Variáveis
#----------------------------------#
#Variável que define a velocidade em px/s
@export var speed: float = 100



func _physics_process(delta: float) -> void:
	
	#--------- Movimentação do inimigo -----------------#
	
	# Define direção do inimigo:
	var player_position = Vector2(0, 0)
	var difference = player_position - position
	var input_vector = difference.normalized()
	
	# Define velocidade do inimigo:
	velocity = input_vector * speed
	
	
	
	
	move_and_slide()
