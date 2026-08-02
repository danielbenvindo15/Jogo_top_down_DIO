class_name GameOverUI
extends CanvasLayer

@onready var time_label: Label = %TimeLabel
@onready var monsterLabel: Label = %MonsterCounter

@export var restart_delay: float = 5.0
var restart_cooldown: float


func _ready() -> void:
	time_label.text = GameManager.time_elapsed_string
	monsterLabel.text = str(GameManager.monsters_defeated_counter)
	restart_cooldown = restart_delay


func _process(delta: float) -> void:
	restart_cooldown -= delta
	
	if restart_cooldown <= 0: 
		restart_game()


func restart_game() -> void:
	GameManager.reset()
	get_tree().reload_current_scene()
	pass
