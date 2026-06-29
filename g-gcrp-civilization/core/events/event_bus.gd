extends Node

signal world_generated
signal world_gen_requested (stone_abundance: WorldConfig.AbundanceLevel,
							wood_abundance: WorldConfig.AbundanceLevel,
							food_abundance: WorldConfig.AbundanceLevel,
							agents_config: Dictionary)
signal next_turn_requested
signal turn_lock_changed(is_locked: bool)
signal loading_api_changed(is_loading: bool)
signal turn_updated(new_turn_number: int)
signal agents_updated
