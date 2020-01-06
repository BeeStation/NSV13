/obj/structure/munition //CREDIT TO CM FOR THIS SPRITE
	name = "NTP-2 530mm torpedo"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "standard"
	desc = "A fairly standard torpedo which is designed to cause massive structural damage to a target. It is fitted with a basic homing mechanism to ensure it always hits the mark."
	anchored = TRUE
	density = TRUE
	var/torpedo_type = /obj/item/projectile/bullet/torpedo //What torpedo type we fire
	pixel_x = -17
	var/speed = 1 //Placeholder, allows upgrading speed with better propulsion

/obj/structure/munition/hull_shredder //High damage torp. Use this when youve exhausted their flak.
	name = "NTP-4 'BNKR' 430mm torpedo"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "hull_shredder"
	desc = "A heavy torpedo which is packed with a high energy plasma charge, allowing it to impact a target with massive force."
	torpedo_type = /obj/item/projectile/bullet/torpedo/shredder

/obj/structure/munition/fast //Gap closer, weaker but quick.
	name = "NTP-1 'SPD' 430mm high velocity torpedo"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "highvelocity"
	desc = "A small torpedo which is fitted with an advanced propulsion system, allowing it to rapidly travel long distances. Due to its smaller frame however, it packs less of a punch."
	torpedo_type = /obj/item/projectile/bullet/torpedo/fast
	speed = 3

/obj/structure/munition/decoy //A dud missile designed to exhaust flak
	name = "NTP-0x 'DCY' 530mm electronic countermeasure"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "decoy"
	desc = "A simple electronic countermeasure packed inside a standard torpedo casing. This model excels at diverting enemy PDC emplacements away from friendly ships, or even another barrage of missiles."
	torpedo_type = /obj/item/projectile/bullet/torpedo/decoy
	speed = 2

/obj/structure/munition/nuke //The alpha torpedo
	name = "NTNK 'Oncoming Storm' 700mm thermonuclear warhead"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "nuke"
	desc = "The NTX-class IV nuclear torpedo carries a radiological payload which is capable of inflicting catastrophic damage against enemy ships, stations or dense population centers. These weapons are utterly without mercy and will annihilate indiscriminately, use with EXTREME caution."
	torpedo_type = /obj/item/projectile/bullet/torpedo/nuclear

/obj/item/projectile/bullet/torpedo/shredder
	icon_state = "torpedo_shredder"
	name = "plasma charge"
	damage = 120

/obj/item/projectile/bullet/torpedo/nuclear
	icon_state = "torpedo_shredder"
	name = "thermonuclear cruise missile"
	damage = 300
	impact_effect_type = /obj/effect/temp_visual/impact_effect/torpedo/nuke

/obj/item/projectile/bullet/torpedo/fast
	icon_state = "torpedo_fast"
	name = "high velocity torpedo"
	damage = 40

/obj/item/projectile/bullet/torpedo/decoy
	icon_state = "torpedo"
	damage = 0

/obj/item/projectile/bullet/torpedo/dud //What you get from an incomplete torpedo.
	icon_state = "torpedo_dud"
	damage = 0
