/obj/structure/hull_plate
	name = "nanolaminate reinforced hull plating"
	desc = "A heavy piece of hull plating designed to reinforced the ship's superstructure. The Nanotrasen official starship operational manual states that any damage sustained can be patched up temporarily with a welder."
	icon = 'nsv13/icons/obj/structures/ship_structures.dmi'
	icon_state = "tgmc_outerhull"
	anchored = TRUE
	density = FALSE
	layer = LATTICE_LAYER //under pipes
	plane = FLOOR_PLANE
	obj_integrity = 200
	max_integrity = 200
	var/obj/structure/overmap/parent = null
	var/armour_scale_modifier = 4
	var/armour_broken = FALSE
	var/tries = 2 //How many times do we try and locate our parent before giving up? Here to avoid infinite recursion timers.

/obj/structure/hull_plate/end
	icon_state = "tgmc_outerhull_dir"

/obj/structure/hull_plate/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/hull_plate/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	return T.rcd_vals(user, the_rcd)

/obj/structure/hull_plate/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	var/turf/T = get_turf(src)
	if(!T)
		return FALSE
	return T.rcd_act(user, the_rcd, passed_mode)

/obj/structure/hull_plate/LateInitialize()
	try_find_parent()

/**

Method to try locate an overmap object that we should attach to. Recursively calls if we can't find one.

*/

/obj/structure/hull_plate/proc/try_find_parent()
	if(tries <= 0)
		message_admins("Hull plates in [get_area(src)] have no overmap object!")
		qdel(src) //This should be enough of a hint....
		return
	parent = get_overmap()
	if(!parent)
		tries --
		addtimer(CALLBACK(src, .proc/try_find_parent), 10 SECONDS)
		return
	parent.armour_plates ++
	parent.max_armour_plates ++
	RegisterSignal(parent, COMSIG_ATOM_DAMAGE_ACT, .proc/relay_damage, override = TRUE)

/obj/structure/hull_plate/Destroy()
	parent?.armour_plates --
	. = ..()

/datum/reagent/hull_repair_juice
	name = "Hull Repair Juice"
	description = "Repairs hull plating rapidly."
	reagent_state = LIQUID
	color = "#CC8899"
	metabolization_rate = 4
	taste_description = "metallic hull repair juice"
	process_flags = ORGANIC | SYNTHETIC

//Hull repair juice -> stabilizing agent, iron, carbon

/obj/effect/particle_effect/foam/hull_repair_juice
	name = "Hull Repair Foam"
	slippery_foam = FALSE
	color = "#CC8899"

/obj/structure/reagent_dispensers/foamtank/hull_repair_juice
	name = "hull repair juice tank"
	desc = "A tank full of hull repair foam."
	icon_state = "foam"
	reagent_id = /datum/reagent/hull_repair_juice
	tank_volume = 1500 //I NEED A LOT OF FOAM OK.

/obj/item/extinguisher/advanced/hull_repair_juice
	name = "hull damage extinguisher"
	desc = "For when the hull plates just won't STOP."
	icon = 'nsv13/icons/obj/inflatable.dmi'
	chem = /datum/reagent/hull_repair_juice
	tanktype = /obj/structure/reagent_dispensers/foamtank/hull_repair_juice

/datum/chemical_reaction/hull_repair_juice
	name = "Hull Repair Juice"
	id = /datum/reagent/hull_repair_juice
	results = list(/datum/reagent/hull_repair_juice = 10)
	required_reagents = list(/datum/reagent/stabilizing_agent = 1, /datum/reagent/iron = 1,/datum/reagent/carbon = 1)

/datum/reagent/hull_repair_juice/reaction_turf(turf/open/T, reac_volume)
	if (!istype(T))
		return

	if(reac_volume >= 1)
		var/obj/effect/particle_effect/foam/F = (locate(/obj/effect/particle_effect/foam) in T)
		if(!F)
			F = new(T)
		else if(istype(F))
			F.lifetime = initial(F.lifetime) //reduce object churn a little bit when using smoke by keeping existing foam alive a bit longer

	for(var/obj/structure/hull_plate/HP in T.contents)
		if(!istype(HP))
			continue
		HP.try_repair(HP.max_integrity)

/obj/structure/hull_plate/proc/relay_damage(datum/source, amount)
	if(!amount)
		return //No 0 damage
	if(prob(amount/5)) //magic number woo!
		take_damage(amount)

/obj/structure/hull_plate/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = FALSE)
	if(damage_amount >= 15)
		shake_animation(3)
	if(obj_integrity <= damage_amount)
		obj_integrity = 1
		if(!armour_broken)
			parent?.armour_plates --
			armour_broken = TRUE
		update_icon()
		return FALSE
	. = ..()
	update_icon()

/obj/structure/hull_plate/proc/try_repair(amount, mob/user)
	obj_integrity = (obj_integrity + amount < max_integrity) ? obj_integrity + amount : max_integrity
	update_icon()
	if(obj_integrity <= max_integrity)
		if(user)
			to_chat(user, "<span class='warning'>You have fully repaired [src].</span>")
		obj_integrity = max_integrity
		update_icon()
		if(armour_broken)
			parent?.armour_plates ++
			armour_broken = FALSE
		return

/obj/structure/hull_plate/update_icon()
	var/progress = obj_integrity
	var/goal = max_integrity
	progress = CLAMP(progress, 0, goal)
	progress = round(((progress / goal) * 100), 25)//Round it down to 25%. We now apply visual damage
	icon_state = "[initial(icon_state)][progress]"

/obj/structure/overmap/proc/check_armour() //Get the "max" armour plates value when all the armour plates have been initialized.
	if(!length(occupying_levels))
		return
	if(armour_plates <= 0)
		addtimer(CALLBACK(src, .proc/check_armour), 20 SECONDS) //Recursively call the function until we've generated the armour plates value to account for lag / late initializations.
		return
	max_armour_plates = armour_plates

/obj/structure/overmap/slowprocess()
	. = ..()
	if(istype(src, /obj/structure/overmap/asteroid)) //Shouldn't be repairing over time
		return
	if(mass > MASS_TINY) //Prevents fighters regenerating
		if(use_armour_quadrants && role == MAIN_OVERMAP)
			var/to_repair = get_repair_efficiency() / 2000
			if(to_repair < 0) //catch any underflows
				return FALSE
			repair_all_quadrants(to_repair) //regenerate our armour quadrants if our plates are shiny
		if(!use_armour_quadrants) //Checking to see if we are using the armour quad system
			try_repair(get_repair_efficiency() / 25) //Scale the value. If you have 80% of your armour plates repaired, the ship takes about 7.5 minutes to fully repair. If you only have 25% of your plates operational, it will take half an hour to fully repair the ship.

/obj/structure/hull_plate/attackby(obj/item/W, mob/user)
	if(W.tool_behaviour == TOOL_WELDER)
		var/obj/item/weldingtool/WT = W
		if(obj_integrity >= max_integrity)
			if(user)
				to_chat(user, "<span class='warning'>[src] is not in need of repair.</span>")
			return FALSE
		var/fuel_required = 1
		var/list/plates = list()
		plates += src
		for(var/obj/structure/hull_plate/S in orange(1, src))
			if(S.obj_integrity < S.max_integrity)
				plates += S
				fuel_required ++
		if(!W.tool_start_check(user, amount=fuel_required))
			to_chat(user, "<span class='notice'>You need [fuel_required-WT.get_fuel()] more units of welding fuel to repair this hull segment.</span>")
			return ..()
		to_chat(user, "<span class='notice'>You begin fixing some of the dents in [src] and the surrounding hull segment...</span>")
		if(do_after(user, 4 SECONDS, target = src))
			if(W.use_tool(src, user, 0, volume=100, amount=fuel_required))
				to_chat(user, "<span class='notice'>You fix some of the dents in [src] and the surrounding hull segment.</span>")
				for(var/obj/structure/hull_plate/S in plates)
					S.try_repair(100, user)
		return FALSE
	. = ..()

/obj/structure/overmap/proc/get_repair_efficiency()
	if(max_armour_plates <= 0)
		return 10 //Very slow heal for AIs, considering they can stop off at a supply post to heal back up.
	return (max_armour_plates > 0) ? 100*(armour_plates/max_armour_plates) : 100
