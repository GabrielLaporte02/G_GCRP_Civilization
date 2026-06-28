extends Node

signal world_generated
signal world_gen_requested (stone_abundance: WorldConfig.AbundanceLevel,
							wood_abundance: WorldConfig.AbundanceLevel,
							food_abundance: WorldConfig.AbundanceLevel,
							agents_config: Dictionary)
