extends PanelContainer

@onready var operators_label: Label = %OperatorsValue
@onready var upgrades_label: Label = %UpgradesValue
@onready var upgrade_limit_label: Label = %UpgradeLimitValue
@onready var phase_progress_bar: ProgressBar = %PhaseProgressBar

func update_phase(data: Dictionary) -> void:
	operators_label.text = str(data.get("operadores", "+ -"))
	var txtupgrades = ", ".join(range(1, data.get("upgrades", 1) + 1))
	upgrades_label.text = txtupgrades
	upgrade_limit_label.text = str(data.get("limite_upgrade", "[-4, 4]"))

## percent: 0.0 a 100.0, percentual já percorrido da distância total da fase.
func update_phase_progress(percent: float) -> void:
	phase_progress_bar.value = clamp(percent, 0.0, 100.0)
