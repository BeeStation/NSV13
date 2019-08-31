/obj/item/material_scanner
	name = "material scanner"
	desc = "A scanner that can be tuned to find specific materials, it has to learn about them first though."
	icon = 'icons/obj/device.dmi'
	icon_state = "mining1"
	item_state = "analyzer"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	var/list/known_materials
	var/scan_range
	var/cooldown = 5
	var/current_cooldown = 0

/obj/item/material_scanner/Initialize(mapload)
	. = ..()
	known_materials = list(getmaterialref(/datum/material/sand), getmaterialref(/datum/material/iron))

/// On attacking an atom, scan it.
/obj/item/material_scanner/pre_attack(atom/A, mob/living/user, params)
	scan(user, A)
	. = ..()

/// Allows ores to be scanned by the material scanner to add them to its registry
obj/item/material_scanner/attackby(obj/item/I, mob/user, params)
	if(!istype(I, /obj/item/stack/ore))
		return ..()
	var/obj/item/stack/ore/O = I
	for(var/i in O.materials)
		if(i in known_materials)
			to_chat(user, "<span class='notice'>You have already registered [O].</span>")
			continue
		known_materials += i
		to_chat(user, "<span class='notice'>You register [O] to [src].</span>")



///Scan an atom to find out what its made out of
/obj/item/material_scanner/proc/scan(mob/living/user, atom/A)
	var/list/scanned_materials

	if(current_cooldown > world.time)
		to_chat(user, "<span class='notice'>Sensors recharging. Please wait.</span>")
		return
	current_cooldown = world.time + cooldown
	if(istype(A, /turf/closed/mineral/dense))
		var/turf/closed/mineral/dense/T = A
		scanned_materials = T.composition
	else
		scanned_materials = A.custom_materials
	if(scanned_materials?.len)
		send_scan_message(user, A, scanned_materials)
	else
		to_chat(user, "<span class='notice'>No distinct materfial traces detected.</span>")

///Send a message to the player showing the makeup of the thing they're scanning
/obj/item/material_scanner/proc/send_scan_message(mob/living/user, atom/A, var/list/scanned_materials)
	var/message
	message += "<span class='notice'>You scan [A]'s materials:</span><br>"

	var/total_amount
	var/unknown_percentage

	for(var/i in scanned_materials)
		total_amount += scanned_materials[i]
	message += "<span class='notice'>[total_amount] units of material in total</span><br>"

	for(var/i in scanned_materials)
		var/datum/material/M = i
		var/percentage = scanned_materials[M] / total_amount * 100
		if(M in known_materials)
			message += "<span class='notice'>[M.name] - [round(percentage, 0.01)]% </span><br>"
		else
			unknown_percentage += percentage
		if(unknown_percentage)
			message += "<span class='notice'> ?????? - [round(unknown_percentage, 0.01)]% </span><br>"

	to_chat(user, "[message]")