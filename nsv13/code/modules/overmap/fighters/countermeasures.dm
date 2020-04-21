/obj/effect/temp_visual/countermeasure_cloud
	icon = 'nsv13/goonstation/icons/effects/explosions/160x160.dmi'
	icon_state = "thundercloud"
	duration = 100
	pixel_x = -80
	pixel_y = -80

/obj/effect/temp_visual/countermeasure_cloud/Crossed(obj/item/projectile/missile/B)
	. = ..()
	if(istype(B, /obj/item/projectile/missile/torpedo || /obj/item/projectile/missile/missile))
		if(prob(50))
			if(prob(50))
				B.explode() //Kaboom on the chaff
			else
				B.homing = FALSE //Confused by the chaff

/obj/structure/overmap/fighter/verb/countermeasure()
	set name = "Deploy Countermeasures"
	set category = "Ship"
	set src = usr.loc
	set waitfor = FALSE

	if(!verb_check())
		return

	fire_countermeasure()