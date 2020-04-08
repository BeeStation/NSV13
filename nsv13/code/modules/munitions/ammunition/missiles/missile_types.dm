/obj/item/ship_weapon/ammunition/missile //CREDIT TO CM FOR THIS SPRITE
	name = "Test Missile"
	icon = 'nsv13/icons/obj/munition_types.dmi'
	icon_state = "standard"
	desc = "missile."
	anchored = TRUE
	density = TRUE
	projectile_type = /obj/item/projectile/bullet/missile //What torpedo type we fire
	pixel_x = -17
//	var/speed = 1 //Placeholder, allows upgrading speed with better propulsion

/obj/item/ship_weapon/ammunition/missile/georgio
	name = "Georgio"

/obj/item/ship_weapon/ammunition/missile/CtrlClick(mob/user)
	. = ..()
	to_chat(user,"<span class='warning'>[src] is far too cumbersome to carry, and dragging it around might set it off! Load it onto a munitions trolley.</span>")

/obj/item/ship_weapon/ammunition/missile/examine(mob/user)
	. = ..()
	. += "<span class='warning'>It's far too cumbersome to carry, and dragging it around might set it off!</span>"

//What you get from an incomplete missile.
/obj/item/projectile/bullet/missile/dud
	icon_state = "torpedo_dud"
	damage = 0
