/obj/effect/temp_visual/countermeasure_cloud
	icon = 'nsv13/goonstation/icons/effects/explosions/countermeasures.dmi'
	icon_state = "thundercloud"
	duration = 10 SECONDS
	pixel_x = -80
	pixel_y = -80

/obj/effect/temp_visual/countermeasure_cloud/Crossed(obj/item/projectile/guided_munition/B)
	. = ..()
	if(istype(B, /obj/item/projectile/guided_munition/torpedo || /obj/item/projectile/guided_munition/missile))
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

/obj/structure/overmap/fighter/proc/fire_countermeasure()
	if(!get_part(/obj/item/fighter_component/countermeasure_dispenser)) //Check for a dispenser
		to_chat(usr, "<span class='warning'>Countermeasure Dispenser Not Detected!</span>")
		return
	if(!mun_countermeasures.len) //check to see if we have any countermeasures
		to_chat(usr, "<span class='warning'>Countermeasures depleted!</span>")
		return
	var/obj/item/fighter_component/countermeasure_dispenser/cmd = get_part(/obj/item/fighter_component/countermeasure_dispenser)
	if(cmd.burntout) //check to see if the dispenser is damaged
		if(prob(85))
			to_chat(usr, "<span class='warning'>Error detected in Countermeasure System! Process Aborted!</span>")
			SEND_SOUND(usr, sound('sound/effects/alert.ogg', repeat = FALSE, wait = 0, volume = 100))
			return
	var/obj/item/ship_weapon/ammunition/countermeasure_charge/cmc = pick_n_take(mun_countermeasures) //select charge
	qdel(cmc)
	countermeasures = mun_countermeasures.len
	for(var/I = 0, I < 3, I++) //launch three chaff
		new /obj/effect/temp_visual/countermeasure_cloud(get_turf(src))
		sleep(5)