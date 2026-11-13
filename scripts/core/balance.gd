class_name Balance
extends RefCounted


const TILE: = 64
const MAP_W: = 54
const MAP_H: = 42

const HP_PER_LEVEL: = 9.0
const MP_PER_LEVEL: = 4.0
const ENERGY_PER_LEVEL: = 2.0
const DAMAGE_PER_LEVEL: = 1.6
const DEFENSE_PER_LEVEL: = 0.9
const CRIT_PER_LEVEL: = 0.002

const ENERGY_REGEN: = 16.0
const MANA_REGEN: = 3.2
const HP_REGEN_OUT_OF_COMBAT: = 1.4

const SPRINT_COST: = 9.0
const DODGE_COST: = 18.0
const DASH_COST: = 22.0
const BLOCK_COST_PER_HIT: = 14.0

const SPRINT_MULT: = 1.42
const DODGE_TIME: = 0.3
const DODGE_SPEED: = 560.0
const DASH_TIME: = 0.18
const DASH_SPEED: = 760.0
const EXHAUSTION_TIME: = 2.0

const BACKSTAB_DAMAGE: = 0.25
const BACKSTAB_CRIT: = 0.2
const BACKSTAB_ARC: = 1.6208
const BLOCK_ARC: = 1.7453
const BLOCK_REDUCTION: = 0.65
const PERFECT_BLOCK_WINDOW: = 0.28
const CRIT_MULT: = 1.75

const DAY_LENGTH: = 300.0
const NIGHT_FROM: = 0.62
const NIGHT_TO: = 0.1

const DEATH_XP_LOSS: = 0.1
const DEATH_DURABILITY_LOSS: = 22.0
const FARM_DURABILITY_LOSS: = 0.35
const DUNGEON_FAME_LOSS_EASY: = 1.0
const HOSTILITY_PER_ERRANTE: = 6.0
const HOSTILITY_PRICE_FACTOR: = 0.5

const FAME_CAP_DEFAULT: = 80.0
const FAME_CAP_S: = 100.0

const WEIGHT_BASE: = 34.0
const WEIGHT_PER_STRENGTH: = 2.6

const RESPAWN_INVULNERABILITY: = 1.5
const AUTOSAVE_INTERVAL: = 60.0


static func xp_multiplier_for(monster_tier: int) -> float:
	return 1.0 + 0.15 * float(maxi(0, monster_tier))
