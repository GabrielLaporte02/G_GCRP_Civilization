class_name WorldConfig

enum AbundanceLevel {
	ABUNDANT,
	NORMAL,
	SCARCE
}

# Dicionário de tradução para a UI
const ABUNDANCE_NAMES: Dictionary = {
	AbundanceLevel.ABUNDANT: "Abundante",
	AbundanceLevel.NORMAL: "Normal",
	AbundanceLevel.SCARCE: "Escasso"
}

const TURN_OPTIONS : Array[int] = [10, 15, 20]

const ABUNDANCE_THRESHOLDS: Dictionary = {
	AbundanceLevel.SCARCE: 0.75,
	AbundanceLevel.NORMAL: 0.65,
	AbundanceLevel.ABUNDANT: 0.55
}
