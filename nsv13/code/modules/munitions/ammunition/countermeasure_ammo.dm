/obj/item/ship_weapon/ammunition/countermeasure_charge //A single use of the countermeasure system
	name = "three shot countermeasure tri-charge"
	desc = "Three tri-charges of countermeasure chaff for a fighter"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "iff" //temp
	var/restock_amount = 3
	w_class = 3

/obj/item/ship_weapon/ammunition/countermeasure_charge/five
	name = "five shot countermeasure tri-charge"
	desc = "Five tri-charges of countermeasure chaff for an upgraded countermeasure system"
	icon_state = "iff" //temp :)
	restock_amount = 5

//Man I sure do love the amount of //temp labels this file had :) -Bokkie
//Code below this point stolen from before fighters 3.0 and modded to work with current things:

/obj/effect/temp_visual/countermeasure_cloud
	icon = 'nsv13/goonstation/icons/effects/explosions/countermeasures.dmi'
	icon_state = "thundercloud"
	duration = 10 SECONDS
	pixel_x = -80
	pixel_y = -80

/obj/effect/temp_visual/countermeasure_cloud/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/temp_visual/countermeasure_cloud/proc/on_entered(datum/source, obj/item/projectile/guided_munition/B)
	SIGNAL_HANDLER

	if(istype(B, /obj/item/projectile/guided_munition/torpedo) || istype(B, /obj/item/projectile/guided_munition/missile))
		if(prob(50))
			B.explode() //Kaboom on the chaff
		else
			B.homing = FALSE //Confused by the chaff

/obj/structure/overmap/small_craft/proc/fire_countermeasure()
	var/obj/item/fighter_component/countermeasure_dispenser/CD = loadout.get_slot(HARDPOINT_SLOT_COUNTERMEASURE)
	if(!CD) //Check for a dispenser
		to_chat(usr, "<span class='warning'>Failed to detect countermeasure dispenser!</span>")
		return
	if(!CD.charges) //check to see if we have any countermeasures
		to_chat(usr, "<span class='warning'>Countermeasures depleted!</span>")
		return
	if(CD.obj_integrity <= 0) //check to see if the dispenser is broken
		if(prob(85))
			to_chat(usr, "<span class='warning'>Error detected in Countermeasure System! Process Aborted!</span>")
			SEND_SOUND(usr, sound('sound/effects/alert.ogg', repeat = FALSE, wait = 0, volume = 100))
			return
	CD.charges -= 1
	for(var/I = 0, I < 3, I++) //launch three chaff
		new /obj/effect/temp_visual/countermeasure_cloud(get_turf(src))
		sleep(5)
