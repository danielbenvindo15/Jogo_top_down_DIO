extends Node2D

#--------------- Variáveis ------------------#

#Variavel que define o quanto de vida o item vai regenerar:
@export var regenteration_amount: int = 10



func _ready() -> void:
	$Area2D.body_entered.connect(on_body_entered) #Importa as informações obtidas no Area2D

#--------------------------- Sistema de Cura -------------------------------#
func on_body_entered(body: Node2D) -> void:
	#Estrutura de decisão que detecta se é um player:
	if body.is_in_group("player"):
		var player: Player = body #Variável que importa as propriedades do player para o script.
		player.heal(regenteration_amount) #Invoca a função de curar do Player
		queue_free() #Destrói o objeto
	
	
	pass
