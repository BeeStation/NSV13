/obj/effect/temp_visual/countermeasure_cloud
	icon = 'nsv13/goonstation/icons/hugeexplosion2.dmi'
	icon_state = "explosion"
	duration = 100

/obj/effect/temp_visual/countermeasure_cloud/Crossed(obj/item/projectile/bullet/B)
	. = ..()
	if(istype(B, /obj/item/projectile/bullet/torpedo || /obj/item/projectile/bullet/missile))
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

	if(!get_part(/obj/item/fighter_component/countermeasure_dispenser)) //Check for a dispenser
		to_chat(usr, "<span class='warning'>Countermeasure Dispenser Not Detected!</span>")
		return

	if(countermeasures == 0) //check to see if we have any countermeasures
		to_chat(usr, "<span class='warning'>Countermeasures depleted!</span>")
		return

	var/obj/item/fighter_component/countermeasure_dispenser/cmd = get_part(/obj/item/fighter_component/countermeasure_dispenser)
	if(cmd.burntout) //check to see if the dispenser is damaged
		if(prob(85))
			to_chat(usr, "<span class='warning'>Error detected in Countermeasure System! Process Aborted!</span>")
			SEND_SOUND(usr, sound('sound/effects/alert.ogg', repeat = FALSE, wait = 0, volume = 100))
			return

	for(var/I = 0, I < 3, I++) //launch three chaff
		new /obj/effect/temp_visual/countermeasure_cloud (loc, 1)
		sleep(5)

	var/obj/item/ship_weapon/ammunition/countermeasure_charge/cmc = locate(/obj/item/ship_weapon/ammunition/countermeasure_charge) in contents //remove charge
	qdel(cmc)