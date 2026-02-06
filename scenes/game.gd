extends Control

@export var animation_index: int
@export var animation: int

func _ready() -> void:
	player_setup()	
	enemy_setup()
	$AttackSprite.hide()

func _process(_delta: float) -> void:
	var atlas = $Monsters/Enemy.texture as AtlasTexture
	atlas.region = Rect2i(Vector2i((96 * animation_index), (96 * animation)), Vector2i(96, 96))
	
func _on_input_menu_selected(state: int, type: Variant) -> void:
	$InputMenu.hide()
	$TurnTimer.start()
	
	match state:
		Global.State.ATTACK:
			var target = $Monsters/Enemy if Global.attack_data[type]['target'] else $Monsters/Player
			attack(target, type)
		Global.State.SWAP:
			Global.monsters.append(Global.current_monster)
			$Monsters/Player.texture = load(Global.monster_data[type]['back texture'])
			Global.current_monster = type
			Global.monsters.erase(type)
			$Stats/PlayerMonsterStats.setup(Global.current_monster)
		Global.State.DEFEND:
			pass
		Global.State.ITEM:
			var target = $Stats/PlayerMonsterStats if Global.item_data[type]['target'] == 0 else $Stats/EnemyMonsterStats
			target.update(Global.item_data[type])
			
func attack(target: TextureRect, attack_type: Global.Attack):
	$AttackSprite.show()
	$AttackSprite.frame = 0
	$AttackSprite.texture = load(Global.attack_data[attack_type]['animation'])
	var tween = create_tween()
	tween.tween_property($AttackSprite, 'frame', 3, 0.6).from(0)
	tween.tween_property($AttackSprite, 'visible', false, 0)
	$AttackSprite.position = target.get_rect().position + target.get_rect().size/2
	
	if target == $Monsters/Player:
		$Stats/PlayerMonsterStats.update(Global.attack_data[attack_type])
	else:
		$Stats/EnemyMonsterStats.update(Global.attack_data[attack_type])
		
func player_setup():
	Global.current_monster = Global.monsters.pop_at(0)
	$Monsters/Player.texture = load(Global.monster_data[Global.current_monster]['back texture'])
	$Stats/PlayerMonsterStats.setup(Global.current_monster)
	
func enemy_setup():
	Global.current_enemy = Global.Monster.values().pick_random()
	var new_atlas: AtlasTexture = AtlasTexture.new()
	new_atlas.atlas = load(Global.monster_data[Global.current_enemy]['front texture'])
	$Monsters/Enemy.texture = new_atlas
	new_atlas.region = Rect2i(Vector2i.ZERO, Vector2i(96, 96))
	$Stats/EnemyMonsterStats.setup(Global.current_enemy)

func _on_player_monster_stats_dead() -> void:
	player_setup()


func _on_enemy_monster_stats_dead() -> void:
	enemy_setup()


func _on_turn_timer_timeout() -> void:
	$AnimationPlayer.play("Attack")
	var attack_type = Global.monster_data[Global.current_enemy]['attacks'].pick_random()
	var target = $Monsters/Player if Global.attack_data[attack_type]['target'] else $Monsters/Enemy
	attack(target, attack_type)
	$InputMenu.show()
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("Idle")
