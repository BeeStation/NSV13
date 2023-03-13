/obj/item/clothing/suit/space/hardsuit/dominion
	name = "Dominion hardsuit"
	desc = "A Dominion hardsuit, with room for antennae and neck fluff!"
	icon = 'nsv13/icons/obj/clothing/suits.dmi'
	icon_state = "hardsuit-dominion"
	item_state = "hardsuit-dominion"
	worn_icon = 'nsv13/icons/mob/suit.dmi'
	lefthand_file = 'nsv13/icons/mob/inhands/nsvclothing_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/nsvclothing_righthand.dmi'
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/dominion
	armor = list("melee" = 15, "bullet" = 0, "laser" = 20, "energy" = 20, "bomb" = 0, "bio" = 100, "rad" = 60, "fire" = 50, "acid" = 50, "stamina" = 5)
	resistance_flags = FIRE_PROOF
	flash_protect = 2

/obj/item/clothing/head/helmet/space/hardsuit/dominion
	name = "Dominion hardsuit helmet"
	desc = "The helmet to a Dominion hardsuit with flash resistance glass and room for antennae and neck fluff."
	icon = 'nsv13/icons/obj/clothing/hats.dmi'
	worn_icon = 'nsv13/icons/mob/head.dmi'
	icon_state = "hardsuit0-dominion"
	item_state = "hardsuit0-dominion"
	hardsuit_type = "dominion"

/obj/item/clothing/suit/space/hardsuit/dominion/engi
	name = "Dominion Engineering hardsuit"
	desc = "A Dominion engineering hardsuit, built to last!"
	icon = 'nsv13/icons/obj/clothing/suits.dmi'
	icon_state = "hardsuit-dominion-engi"
	item_state = "hardsuit-dominion-engi"
	worn_icon = 'nsv13/icons/mob/suit.dmi'
	lefthand_file = 'nsv13/icons/mob/inhands/nsvclothing_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/nsvclothing_righthand.dmi'
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/dominion/engi
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 12, "bomb" = 10, "bio" = 100, "rad" = 75, "fire" = 100, "acid" = 75, "stamina" = 20)
	resistance_flags = FIRE_PROOF
	flash_protect = 2

/obj/item/clothing/head/helmet/space/hardsuit/dominion/engi
	name = "Dominion engineering helmet"
	desc = "The helmet to a Dominion engineering hardsuit."
	icon = 'nsv13/icons/obj/clothing/hats.dmi'
	worn_icon = 'nsv13/icons/mob/head.dmi'
	icon_state = "hardsuit0-dominion-engi"
	item_state = "hardsuit0-dominion-engi"
	hardsuit_type = "dominion-engi"

/obj/item/clothing/suit/space/hardsuit/dominion/atmo
	name = "Dominion Atmospherics hardsuit"
	desc = "A Dominion atmospherics hardsuit, built to last!"
	icon = 'nsv13/icons/obj/clothing/suits.dmi'
	icon_state = "hardsuit-dominion-atmo"
	item_state = "hardsuit-dominion-atmo"
	worn_icon = 'nsv13/icons/mob/suit.dmi'
	lefthand_file = 'nsv13/icons/mob/inhands/nsvclothing_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/nsvclothing_righthand.dmi'
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/dominion/atmo
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 10, "bio" = 100, "rad" = 25, "fire" = 100, "acid" = 75, "stamina" = 20)
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/head/helmet/space/hardsuit/dominion/atmo
	name = "Dominion atmospherics helmet"
	desc = "The helmet to a Dominion atmospherics hardsuit."
	icon = 'nsv13/icons/obj/clothing/hats.dmi'
	worn_icon = 'nsv13/icons/mob/head.dmi'
	icon_state = "hardsuit0-dominion-atmo"
	item_state = "hardsuit0-dominion-atmo"
	hardsuit_type = "dominion-atmo"


/obj/item/clothing/suit/space/hardsuit/dominion/mining
	icon_state = "hardsuit-dominion-mining"
	name = "Dominion mining hardsuit"
	icon = 'nsv13/icons/obj/clothing/suits.dmi'
	desc = "A special hardsuit designed for mining asteroids."
	item_state = "dominion-mining"
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 20, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 75, "stamina" = 40)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/storage/bag/ore, /obj/item/pickaxe)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/dominion/mining
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	high_pressure_multiplier = 0.6

/obj/item/clothing/suit/space/hardsuit/dominion/mining/Initialize()
	. = ..()
	AddComponent(/datum/component/armor_plate)

/obj/item/clothing/head/helmet/space/hardsuit/dominion/mining
	name = "Dominion mining hardsuit helmet"
	desc = "A specially designed helmet for the Dominion mining hardsuit."
	icon_state = "hardsuit0-dominion-mining"
	item_state = "hardsuit0-dominion-mining"
	hardsuit_type = "dominion-mining"
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF
	heat_protection = HEAD
	armor = list("melee" = 30, "bullet" = 5, "laser" = 10, "energy" = 15, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 50, "acid" = 75, "stamina" = 40)
	light_range = 7
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/resonator, /obj/item/mining_scanner, /obj/item/t_scanner/adv_mining_scanner, /obj/item/gun/energy/kinetic_accelerator)
	high_pressure_multiplier = 0.6

/obj/item/clothing/head/helmet/space/hardsuit/dominion/mining/Initialize()
	. = ..()
	AddComponent(/datum/component/armor_plate)
