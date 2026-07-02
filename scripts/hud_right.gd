extends PanelContainer

@onready var operators_label: Label = %OperatorsValue
@onready var upgrades_label: Label = %UpgradesValue
@onready var upgrade_limit_label: Label = %UpgradeLimitValue

func update_phase(data: Dictionary) -> void:
	operators_label.text = str(data.get("operadores", "+ -"))
	upgrades_label.text = str(data.get("upgrades", 0))
	upgrade_limit_label.text = str(data.get("limite_upgrade", "[-4, 4]"))
