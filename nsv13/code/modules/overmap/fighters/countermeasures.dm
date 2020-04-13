/obj/effect/temp_visual/countermeasure_cloud
	icon = 'nsv13/goonstation/icons/hugeexplosion2.dmi'
	icon_state = "explosion"
	duration = 100

/obj/effect/temp_visual/countermeasure_cloud/Crossed(obj/item/projectile/bullet/B)
	. = ..()
	if(istype(B, /obj/item/projectile/missile/torpedo || /obj/item/projectile/missile/missile))
		if(prob(50))
			if(prob(50))
				B.process_hit() //Kaboom on the chaff
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