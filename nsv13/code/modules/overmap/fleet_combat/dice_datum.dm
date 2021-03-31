/*
A datum assigned to a overmap ship, dictating its dice rolls in fights between NPC-fleets in nonloaded systems.
Different ships have different combat dice, some have the same as eachother.
*/

/datum/combat_dice
	var/name = "Combat dice basetype"	//No actual ship should have these.

	var/evade_dice = 1		//How many evade dice?
	var/evade_roll = 4		//How many sides? Result 1 to X.
	var/evade_bonus = 0		//Bonus that gets added to the evade roll total.

	var/target_dice = 1		//How many target dice?
	var/target_roll = 6		//How many sides? Result 1 to X.
	var/target_bonus = 0	//Bonus that gets added to the target roll total.

	var/armor_dice = 1		//How many armor dice?
	var/armor_roll = 4		//How many sides? Result 1 to X.
	var/armor_bonus = 0		//Bonus that gets added to the armor roll total.

	var/damage_dice = 1		//How many damage dice?
	var/damage_roll = 6		//How many sides? Result 1 to X.
	var/damage_bonus = 0	//Bonus that gets added to the damage roll total.

	var/affinity = 0		//Affinity: All dice end values are increased by 50% (rounded down) if the target AI type contains the affinity type.

/datum/combat_dice/civilian
	name = "Civilian combat dice"

	evade_roll = 3

	target_roll = 4

	armor_roll = 2

	damage_roll = 2

/datum/combat_dice/fighter
	name = "Fighter combat dice"

	evade_dice = 2
	evade_roll = 5

	armor_roll = 3
	armor_bonus = -1

	damage_roll = 3

	affinity = AI_TRAIT_SWARMER	//Great at shooting other fighters.

/datum/combat_dice/bomber
	name = "Bomber combat dice"

	evade_roll = 3

	target_dice = 2
	target_roll = 4
	target_bonus = 2

	armor_roll = 3
	armor_bonus = -1

	damage_dice = 2
	damage_roll = 5
	damage_bonus = 3

	affinity = AI_TRAIT_BATTLESHIP	//Loves taking out capital ships.


/datum/combat_dice/carrier
	name = "Carrier combat dice"

	evade_roll = 2

	target_roll = 4
	target_bonus = 1

	armor_roll = 4
	armor_bonus = -2

	damage_dice = 2
	damage_roll = 2

/datum/combat_dice/frigate
	name = "Frigate combat dice"

	evade_roll = 6
	evade_bonus = 1

	target_roll = 5
	target_bonus = 1

	armor_roll = 4

	damage_dice = 2
	damage_roll = 3
	damage_bonus = 1

	affinity = AI_TRAIT_SWARMER

/datum/combat_dice/destroyer
	name = "Destroyer combat dice"

	evade_roll = 3

	target_dice = 2
	target_roll = 4

	armor_roll = 4
	armor_bonus = 2

	damage_roll = 4
	damage_bonus = 2

	affinity = AI_TRAIT_SUPPLY

/datum/combat_dice/destroyer/flycatcher
	name = "Anti-Air Destroyer combat dice"

	target_dice = 4

	damage_dice = 2
	damage_bonus = 0

	affinity = AI_TRAIT_SWARMER

/datum/combat_dice/destroyer/nuclear
	name = "Nuclear Destroyer combat dice"

	target_bonus = 2

	armor_bonus = 0

	damage_dice = 4

	affinity = AI_TRAIT_BATTLESHIP

/datum/combat_dice/cruiser
	name = "Cruiser combat dice"

	evade_roll = 2

	target_dice = 2
	target_roll = 5
	target_bonus = 1

	armor_dice = 2
	armor_roll = 3
	armor_bonus = 1

	damage_dice = 2
	damage_roll = 4
	damage_bonus = 2

	affinity = AI_TRAIT_SUPPLY

/datum/combat_dice/battleship
	name = "Battleship combat dice"

	evade_roll = 3
	evade_bonus = -1

	target_dice = 4
	target_roll = 4
	target_bonus = 2

	armor_dice = 4
	armor_roll = 3

	damage_dice = 4
	damage_roll = 3
	damage_bonus = 2

	affinity = AI_TRAIT_DESTROYER

/datum/combat_dice/flagship
	name = "Flagship combat dice"

	evade_roll = 4
	evade_bonus = -2

	target_dice = 6
	target_roll = 3
	target_bonus = 4

	armor_dice = 6
	armor_roll = 2
	armor_bonus = 3

	damage_dice = 6
	damage_roll = 4
	damage_bonus = 5

	affinity = AI_TRAIT_BATTLESHIP
