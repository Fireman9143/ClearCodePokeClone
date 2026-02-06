extends Control

@onready var label = $PanelContainer/MarginContainer/VBoxContainer/Label
@onready var bar = $PanelContainer/MarginContainer/VBoxContainer/ProgressBar
signal dead

func setup(monster: Global.Monster):
	var monster_data = Global.monster_data[monster]
	label.text = monster_data['name']
	bar.max_value = monster_data['max health']
	bar.value = monster_data['max health']
	
func update(data: Dictionary):
	bar.value -= data['amount']
	if bar.value <= 0:
		dead.emit()
