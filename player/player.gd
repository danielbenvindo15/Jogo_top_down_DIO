extends CharacterBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer #O @onready faz com que a variável dita na linha seja inicializada apenas após o carregamento do node.
@onready var sword_area: Area2D = $SwordArea

#Variáveis booleanas
var attackAnimation1: bool = true  #Variável responsável pelo switch das animações 1 e 2 de ataque
var isRunning: bool = false  #Variável para ver se o personagem está correndo
var wasRunning = isRunning #Variável pra tranzição de animação do isRunning
var isAttacking: bool = false  #Variável responsável por ver se o personagem está na animação de ataque
var attackCoolDown: float = 0.0  #Variável responsável por resetar o isAttacking

#Variáveis Vector2
var direction: Vector2 = Vector2(0, 0)

#----------------- Variáveis Exportadas -----------------#

#Variável de velocidade
@export var speed = 300
#Variável para dano de ataque
@export var sword_damage: int = 2


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
	if not isAttacking:  #Garante que não haverá o bug de virar enquanto ataca
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
	
	#------------------ Toca Animação ----------------------#
	
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

	#Player_AttackUp
	elif direction.y < 0 :
		
		if attackAnimation1 :#Player_AttackUp1
			animation_player.play("Player_AttackUp1")
			attackAnimation1 = false
			pass
		else : #Player_AttackUp2
			animation_player.play("Player_AttackUp2")
			attackAnimation1 = true
			pass

	#Player_AttackDown
	else :
		
		if attackAnimation1 :#Player_AttackDown1
			animation_player.play("Player_AttackDown1")
			attackAnimation1 = false
			pass
		else : #Player_AttackDown2
			animation_player.play("Player_AttackDown2")
			attackAnimation1 = true
			pass
	
	
	#------------ Configurar temporizador --------------#
	#Define o cooldown do ataque
	attackCoolDown = 0.6
	
	#--------- Marcar Ataque -------------#
	isAttacking = true
	
	#------------- Aplicar dano nos inimigos ------------#
	
	pass
	

func deal_damage_to_enemies() -> void :
	
	#-------------- Acessar todos os inimigos ----------------#
	#Pega todos os inimigos que estão dentro da área de alcance da espada
	var bodies = sword_area.get_overlapping_bodies()
	
	#Variável que importa as características de vida do inimigo 
 
	
	#-------- Chamar a função "damage" (COM sword_damage como 1º parametro) -----------------#
	for body in bodies:
		if body.is_in_group("enemies"): #Essa seção vasculha todos os objetos presentes na cena e pega todos os que pertencem ao grupo "enemies"
			var enemy: Enemy = body
			
			var direction_to_enemy = (enemy.position - position).normalized()
			var attack_direction: Vector2
			
		#------------------------- Verifica direção de ataque ------------------#
			if direction.y < 0:   #Ataque para cima
				attack_direction = Vector2.UP
			elif direction.y > 0 :  #Ataque para baixo
				attack_direction = Vector2.DOWN
			elif sprite.flip_h: #Ataque para a esquerda
				attack_direction = Vector2.LEFT
			else :  #Ataque para a direita
				attack_direction = Vector2.RIGHT
			
		#----------------------- Faz a comparação de vetores da posição do inimigo com a direção do ataque do Player --------------------------#
			var dot_product = direction_to_enemy.dot(attack_direction)
			
		#----------------------- Chama a função que dá dano no inimigo ----------------#
			#Processamento que verifica se o inimigo está na área de ataque da espada
			if dot_product >= 0.3 :
				enemy.damage(sword_damage)
		pass
