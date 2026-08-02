class_name Player  #Dá um rótulo para o nosso Script, nesse caso o rótulo é "Player".
extends CharacterBody2D


@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer #O @onready faz com que a variável dita na linha seja inicializada apenas após o carregamento do node.
@onready var sword_area: Area2D = $SwordArea
@onready var hitbox_area: Area2D = $HitboxArea
@onready var hitbox_cooldown: float = 0.0
@onready var health_bar: ProgressBar = $HealthBar

#Variáveis booleanas
var attackAnimation1: bool = true  #Variável responsável pelo switch das animações 1 e 2 de ataque
var isRunning: bool = false  #Variável para ver se o personagem está correndo
var wasRunning = isRunning #Variável pra tranzição de animação do isRunning
var isAttacking: bool = false  #Variável responsável por ver se o personagem está na animação de ataque

#Variáveis float
var attackCoolDown: float = 0.0  #Variável responsável por resetar o isAttacking
var ritual_cooldown = 0.0
#Variáveis Vector2
var direction: Vector2 = Vector2(0, 0)

#----------------- Variáveis Exportadas -----------------#

#Variável de velocidade (em px/s)
@export_category("Speed")
@export var speed = 300


#Variável para dano de ataque
@export_category("Sword")
@export var sword_damage: int = 2

#Parte responsável por cuidar das configurações do ritual
@export_category("Ritual")
@export var ritual_damage: int = 1
@export var ritual_interval: float = 30.0
@export var ritual_scene : PackedScene

#Variável para definir o nível de vida do player
@export_category("Health")
@export var health: int = 25
@export var max_health: int = 25 #Variável para definir a vida máxima do player

#Variável responsável por definir a animação de morte
@export_category("Death Animation")
@export var death_prefab: PackedScene


signal  meat_collected(value:int)


func _ready() -> void:
	GameManager.player = self # Determina o valor da variavel player do script game_manager.
	meat_collected.connect(func(value: int): GameManager.meat_counter += 1)


func _process(delta: float) -> void:
	GameManager.player_position = position

	# Ritual
	update_ritual(delta)
	
	
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
		
	
	#Espelha o personagem de acordo com a posição:
	if not isAttacking:  #Garante que não haverá o bug de virar enquanto ataca
		if direction.x > 0 :
			#Desmarcar flip_h do Sprite2D
			sprite.flip_h = false
			pass
		elif direction.x < 0 :
			#Marcar o flip_h do Sprite2D
			sprite.flip_h = true
			pass
	
	# Processar dano:
	update_hitbox_detection(delta)
	
	# Atualiza barra de vida:
	health_bar.max_value = max_health
	health_bar.value = health


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


func update_hitbox_detection(delta: float) -> void:
	#Frame de invencibilidade:
	hitbox_cooldown -= delta
	if hitbox_cooldown > 0 : return
	
	#Define o tempo do frame de invencibilidade:
	hitbox_cooldown = 0.5
	
	#Pega todos os corpos da cena:
	var bodies = hitbox_area.get_overlapping_bodies() 
	
	#Laço de repetição para atribuir dano ao encostar no inimigo
	for body in bodies: 
		if body.is_in_group("enemies"): #Essa linha serve para diferenciar inimigos de demais corpos coletados na variável bodies
			var enemy: Enemy = body
			var damage_amount = 1
			damage(damage_amount) #Chama a função de receber dano
	
	pass

func update_ritual(delta: float) -> void:
	#Atualiza temporizador
	ritual_cooldown -= delta
	if ritual_cooldown > 0: return
	ritual_cooldown = ritual_interval #Reseta o temporizador
	
	#Cria ritual
	var ritual = ritual_scene.instantiate()
	ritual.damage_amount = ritual_damage
	add_child(ritual)


func damage(amount: int) -> void:
	#Verifica se está vivo
	if health <= 0 : return
	#Checa dano
	health -= amount
	print("dano recebido Player: ", amount, " vida total: ", health)
	
	#------------ Efeito de dano --------------#
	modulate = Color("#9D2228")
	#Cria um efeito de "transição no inimigo"
	var tween = create_tween()
	#Diz o tipo de tranzição
	tween.set_ease(Tween.EASE_IN)
	#Define a animação da tranzição
	tween.set_trans(Tween.TRANS_QUINT)
	#Define as propriedades da transição criada acima
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	#Processar morte
	if health <= 0: 
		die()


func die() -> void :
	GameManager.end_game()
	
	if death_prefab:
		var death_object = death_prefab.instantiate()
		death_object.position = position
		get_parent().add_child(death_object)
	
	print("Game Over!")
	queue_free()


func heal(amount: int) -> int:
	health += amount
	if health > max_health:
		health = max_health
	return health
