extends PanelContainer

@onready var operators_label: Label = %OperatorsValue
@onready var upgrades_label: Label = %UpgradesValue
@onready var upgrade_limit_label: Label = %UpgradeLimitValue
@onready var phase_progress_bar: ProgressBar = %PhaseProgressBar
@onready var debug_distance_label: Label = %DebugDistanceValue

func update_phase(data: Dictionary) -> void:
	operators_label.text = str(data.get("operadores", "+ -"))
	var txtupgrades = ", ".join(range(1, data.get("upgrades", 1) + 1))
	upgrades_label.text = txtupgrades #str(data.get("upgrades", 0))
	upgrade_limit_label.text = str(data.get("limite_upgrade", "[-4, 4]"))

## percent: 0.0 a 100.0, percentual já percorrido da distância total da fase.
func update_phase_progress(percent: float) -> void:
	phase_progress_bar.value = clamp(percent, 0.0, 100.0)

func update_debug_distance(distance_traveled: float, travel_distance: float) -> void:
	debug_distance_label.text = "%d / %d" % [distance_traveled, travel_distance]
