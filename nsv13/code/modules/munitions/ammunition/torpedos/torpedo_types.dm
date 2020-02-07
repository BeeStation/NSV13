/obj/item/ship_weapon/ammunition/torpedo //CREDIT TO CM FOR THIS SPRITE
	name = "NTP-2 530mm torpedo"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "standard"
	desc = "A fairly standard torpedo which is designed to cause massive structural damage to a target. It is fitted with a basic homing mechanism to ensure it always hits the mark."
	anchored = TRUE
	density = TRUE
	projectile_type = /obj/item/projectile/bullet/torpedo //What torpedo type we fire
	pixel_x = -17
	var/speed = 1 //Placeholder, allows upgrading speed with better propulsion

/obj/item/ship_weapon/ammunition/torpedo/CtrlClick(mob/user)
	. = ..()
	to_chat(user,"<span class='warning'>[src] is far too cumbersome to carry, and dragging it around might set it off! Load it onto a munitions trolley.</span>")

/obj/item/ship_weapon/ammunition/torpedo/examine(mob/user)
	. = ..()
	. += "<span class='warning'>It's far too cumbersome to carry, and dragging it around might set it off!</span>"

//High damage torp. Use this when youve exhausted their flak.
/obj/item/ship_weapon/ammunition/torpedo/hull_shredder
	name = "NTP-4 'BNKR' 430mm torpedo"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "hull_shredder"
	desc = "A heavy torpedo which is packed with a high energy plasma charge, allowing it to impact a target with massive force."
	projectile_type = /obj/item/projectile/bullet/torpedo/shredder

/obj/item/projectile/bullet/torpedo/shredder
	icon_state = "torpedo_shredder"
	name = "plasma charge"
	damage = 120

//Gap closer, weaker but quick.
/obj/item/ship_weapon/ammunition/torpedo/fast
	name = "NTP-1 'SPD' 430mm high velocity torpedo"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "highvelocity"
	desc = "A small torpedo which is fitted with an advanced propulsion system, allowing it to rapidly travel long distances. Due to its smaller frame however, it packs less of a punch."
	projectile_type = /obj/item/projectile/bullet/torpedo/fast
	speed = 3

/obj/item/projectile/bullet/torpedo/fast
	icon_state = "torpedo_fast"
	name = "high velocity torpedo"
	damage = 40

//A dud missile designed to exhaust flak
/obj/item/ship_weapon/ammunition/torpedo/decoy
	name = "NTP-0x 'DCY' 530mm electronic countermeasure"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "decoy"
	desc = "A simple electronic countermeasure packed inside a standard torpedo casing. This model excels at diverting enemy PDC emplacements away from friendly ships, or even another barrage of missiles."
	projectile_type = /obj/item/projectile/bullet/torpedo/decoy
	speed = 2

/obj/item/projectile/bullet/torpedo/decoy
	icon_state = "torpedo"
	damage = 0

//The alpha torpedo
/obj/item/ship_weapon/ammunition/torpedo/nuke
	name = "NTNK 'Oncoming Storm' 700mm thermonuclear warhead"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "nuke"
	desc = "The NTX-class IV nuclear torpedo carries a radiological payload which is capable of inflicting catastrophic damage against enemy ships, stations or dense population centers. These weapons are utterly without mercy and will annihilate indiscriminately, use with EXTREME caution."
	projectile_type = /obj/item/projectile/bullet/torpedo/nuclear

/obj/item/projectile/bullet/torpedo/nuclear
	icon_state = "torpedo_shredder"
	name = "thermonuclear cruise missile"
	damage = 300
	impact_effect_type = /obj/effect/temp_visual/impact_effect/torpedo/nuke

//What you get from an incomplete torpedo.
/obj/item/projectile/bullet/torpedo/dud
	icon_state = "torpedo_dud"
	damage = 0
