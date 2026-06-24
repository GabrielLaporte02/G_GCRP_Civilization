class_name WorldConfig

enum AbundanceLevel {
	SCARCE,
	NORMAL,
	ABUNDANT
}

const ABUNDANCE_THRESHOLDS: Dictionary = {
	AbundanceLevel.SCARCE: 0.75,
	AbundanceLevel.NORMAL: 0.65,
	AbundanceLevel.ABUNDANT: 0.55
}
