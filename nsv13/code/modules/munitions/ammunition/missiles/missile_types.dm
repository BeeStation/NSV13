/obj/item/ship_weapon/ammunition/missile //CREDIT TO CM FOR THIS SPRITE
	name = "\improper NTM 44-A 230mm missile"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "highvelocity"
	desc = "A standard pattern Nanotrasen anti-fighter missile."
	density = TRUE
	climbable = TRUE //No shenanigans
	climb_time = 20
	climb_stun = 0
	w_class = WEIGHT_CLASS_GIGANTIC
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	projectile_type = /obj/item/projectile/guided_munition/missile //What torpedo type we fire
	pixel_x = -17
	volatility = 3 //Very volatile.
	explode_when_hit = TRUE //Yeah, this can't ever end well for you.

/obj/item/ship_weapon/ammunition/missile/examine(mob/user)
	. = ..()
	. += "<span class='warning'>It's far too cumbersome to carry, and dragging it around might set it off!</span>"

/obj/item/ship_weapon/ammunition/missile/attack_hand(mob/user)
	return FALSE

//What you get from an incomplete missile.
/obj/item/projectile/guided_munition/missile/dud
	icon_state = "torpedo_dud"
	damage = 0
	can_home = FALSE

/obj/item/projectile/guided_munition/missile/dud/homing
	can_home = TRUE

/obj/item/ship_weapon/ammunition/missile/georgio
	name = "\improper Georgio"

/obj/item/ship_weapon/ammunition/missile/georgio/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This is Georgio, Antonio's little brother.</span>"
