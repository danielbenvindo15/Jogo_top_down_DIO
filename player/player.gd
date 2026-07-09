extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer #O @onready faz com que a variável dita na linha seja inicializada apenas após o carregamento do node.

#Variáveis booleanas
var attackAnimation1: bool = true  #Variável responsável pelo switch das animações 1 e 2 de ataque
var isRunning: bool = false  #Variável para ver se o personagem está correndo
var wasRunning = isRunning #Variável pra tranzição de animação do isRunning
var isAttacking: bool = false  #Variável responsável por ver se o personagem está na animação de ataque
var attackCoolDown: float = 0.0  #Variável responsável por resetar o isAttacking

#Variáveis Vector2
var direction: Vector2 = Vector2(0, 0)

@export var speed = 300


func _process(delta: float) -> void:
	GameManager.player_position = position

#Voltar player pro padrão após a animação de ataque
	#Atualizar temporizador do ataque
	if isAttacking :
		attackCoolDown -= delta
		#Volta o player para as condições padrão
		if attackCoolDown < 0.0:
			isAttacking = false
			isRunning = false
			animation_player.play("Player_Idle")
	pass
	
	#Toca a Animação
	if not isAttacking:
		if wasRunning != isRunning :
			if isRunning:
				animation_player.play("Player_Run")
			else :
				animation_player.play("Player_Idle")
		
	
	#Espelha o personagem de acordo com a posição
	if direction.x > 0 :
		#Desmarcar flip_h do Sprite2D
		sprite.flip_h = false
		pass
	elif direction.x < 0 :
		#Marcar o flip_h do Sprite2D
		sprite.flip_h = true
		pass
	


func _physics_process(delta: float) -> void: #Essa função é executada em uma frequência fixa na qual se mantem a mesma independente do fps, sendo essa função recomendada para executar a física do jogo.
	#Chama a função que lê os inputs
	read_input()
	
	#Modifica a velocidade e movimentação
	var target_velocity = direction * speed #Velocidade alvo
	
	#Define velocidade durante o ataque
	if isAttacking:
		target_velocity *= 0.3
	
	#Velocidade Atual
	velocity = lerp(velocity, target_velocity, 0.15)
	move_and_slide()#função que move o personagem
	
	#Chama Ataque
	if Input.is_action_just_pressed("action_button"):
		attack()
	

func read_input() -> void:
	#Definir direção
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	#Limpa deadzone da variável direction
	const deadzone = 0.15
	if abs(direction.x) < deadzone :
		direction.x = 0.0
	if abs(direction.y) < deadzone :
		direction.y = 0.0
	
	#Atualizar o isRunning
	wasRunning = isRunning
	isRunning = not direction.is_zero_approx() #Define a variável isRunning como true apenas se o personagem está andando

#Função de Sistema de ataque
func attack() -> void:
	#Player_AttackSide1
	if isAttacking:
		return
	
	#Toca Animação
	#Player_AttackSide
	if direction.y == 0: 
		if attackAnimation1 : #Player_AttackSide1
			animation_player.play("Player_AttackSide1")
			attackAnimation1 = false
			pass
		else : #Player_AttackSide2
			animation_player.play("Player_AttackSide2")
			attackAnimation1 = true
			pass
		
	elif direction.y < 0 : #Player_AttackUp
		
		if attackAnimation1 :#Player_AttackUp1
			animation_player.play("Player_AttackUp1")
			attackAnimation1 = false
			pass
		else : #Player_AttackUp2
			animation_player.play("Player_AttackUp2")
			attackAnimation1 = true
			pass
		
	else : #Player_AttackDown
		
		if attackAnimation1 :#Player_AttackDown1
			animation_player.play("Player_AttackDown1")
			attackAnimation1 = false
			pass
		else : #Player_AttackDown2
			animation_player.play("Player_AttackDown2")
			attackAnimation1 = true
			pass
	
	
	#Configurar temporizador
	attackCoolDown = 0.6
	
	#Marcar Ataque
	isAttacking = true
	
	pass
