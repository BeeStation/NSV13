/obj/item/stack/sheet
	name = "sheet"
	lefthand_file = 'nsv13/icons/mob/inhands/misc/sheets_lefthand.dmi' //NSV13
	righthand_file = 'nsv13/icons/mob/inhands/misc/sheets_righthand.dmi' //NSV13

	full_w_class = WEIGHT_CLASS_NORMAL
	force = 5
	throwforce = 5
	max_amount = 50
	throw_speed = 1
	throw_range = 3
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "smashed")
	novariants = FALSE
	var/perunit = MINERAL_MATERIAL_AMOUNT
	var/sheettype = null //this is used for girders in the creation of walls/false walls
	var/point_value = 0 //turn-in value for the gulag stacker - loosely relative to its rarity.
	var/turf_type = null //nsv13 - Wall stuff
