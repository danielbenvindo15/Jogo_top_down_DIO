extends Node2D

@export var creatures: Array[PackedScene]
@export var mobs_per_minute: float = 60.0

@onready var path_follow_2d: PathFollow2D = %PathFollow2D #Importa o PathFollow2D
var cooldown: float = 0.0


##-------------------- Função para criar inimigos -----------------------##
func _process(delta: float) -> void:
	##Temporizador (cooldown):
	cooldown -= delta
	if cooldown > 0: return
	
	##Frequência:
	var interval = 60.0 / mobs_per_minute
	cooldown = interval
	
	##Checar se o ponto é válido:
	# Atribui a criatura a posição de spawn
	var point = get_point() 
	
	#Traz as informações do mundo 2D
	var world_state = get_world_2d().direct_space_state
	
	
	var parameters = PhysicsPointQueryParameters2D.new() #Cria um objeto de parametros no script e armazena as informações desse objeto
	parameters.position = point
	
	var result: Array = world_state.intersect_point(parameters, 1)
	
	if not result.is_empty():
		return
	
	
	##Instanciar criatura aleatória
	# Pegar criatura aleatória
	var index = randi_range(0, creatures.size() - 1)
	var creature_scene = creatures[index]
	
	# Instanciar cena
	var creature = creature_scene.instantiate()
	
	# Spawnar criatura
	creature.global_position = point  
	
	# Define o parent/parentesco da criatura (de quem ela é um child node)
	get_parent().add_child(creature)
	pass


#---------------------- Define posição de spawn aleatória ------------------#
func get_point() -> Vector2:
	path_follow_2d.progress_ratio = randf()  # Dá um número aleatório entre 0 e 1 para a propriedade "progress_ratio" da variável path_follow_2d
	return path_follow_2d.global_position # Retorna as cordenadas do progress ratio
