
/obj/machinery/processor
	name = "food processor"
	desc = "An industrial grinder used to process meat and other foods. Keep hands clear of intake area while operating."
	icon = 'nsv13/icons/obj/kitchen.dmi' //NSV13
	icon_state = "processor1"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 50
	circuit = /obj/item/circuitboard/machine/processor
	var/broken = FALSE
	var/processing = FALSE
	var/rating_speed = 1
	var/rating_amount = 1
	processing_flags = NONE

/obj/machinery/processor/RefreshParts()
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		rating_amount = B.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		rating_speed = M.rating

/obj/machinery/processor/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Outputting <b>[rating_amount]</b> item(s) at <b>[rating_speed*100]%</b> speed.</span>"

/obj/machinery/processor/proc/process_food(datum/food_processor_process/recipe, atom/movable/what)
	if (recipe.output && loc && !QDELETED(src))
		for(var/i = 0, i < rating_amount, i++)
			new recipe.output(drop_location())
	if (ismob(what))
		var/mob/themob = what
		themob.gib(TRUE,TRUE,TRUE)
	else
		qdel(what)

/obj/machinery/processor/proc/select_recipe(X)
	for (var/type in subtypesof(/datum/food_processor_process) - /datum/food_processor_process/mob)
		var/datum/food_processor_process/recipe = new type()
		if (!istype(X, recipe.input) || !istype(src, recipe.required_machine))
			continue
		return recipe

/obj/machinery/processor/attackby(obj/item/O, mob/user, params)
	if(processing)
		to_chat(user, "<span class='warning'>[src] is in the process of processing!</span>")
		return TRUE
	if(default_deconstruction_screwdriver(user, "processor", "processor1", O))
		return

	if(default_pry_open(O))
		return

	if(default_unfasten_wrench(user, O))
		return

	if(default_deconstruction_crowbar(O))
		return

	if(istype(O, /obj/item/storage/bag/tray))
		var/obj/item/storage/T = O
		var/loaded = 0
		for(var/obj/item/reagent_containers/food/snacks/S in T.contents)
			var/datum/food_processor_process/P = select_recipe(S)
			if(P)
				if(SEND_SIGNAL(T, COMSIG_TRY_STORAGE_TAKE, S, src))
					loaded++

		if(loaded)
			to_chat(user, "<span class='notice'>You insert [loaded] items into [src].</span>")
		return

	var/datum/food_processor_process/P = select_recipe(O)
	if(P)
		user.visible_message("[user] put [O] into [src].", \
			"You put [O] into [src].")
		user.transferItemToLoc(O, src, TRUE)
		return 1
	else
		if(user.a_intent != INTENT_HARM)
			to_chat(user, "<span class='warning'>That probably won't blend!</span>")
			return 1
		else
			return ..()

/obj/machinery/processor/interact(mob/user)
	if(processing)
		to_chat(user, "<span class='warning'>[src] is in the process of processing!</span>")
		return TRUE
	if(user.a_intent == INTENT_GRAB && ismob(user.pulling) && select_recipe(user.pulling))
		if(user.grab_state < GRAB_AGGRESSIVE)
			to_chat(user, "<span class='warning'>You need a better grip to do that!</span>")
			return
		var/mob/living/pushed_mob = user.pulling
		visible_message("<span class='warner'>[user] stuffs [pushed_mob] into [src]!</span>")
		pushed_mob.forceMove(src)
		user.stop_pulling()
		return
	if(contents.len == 0)
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return TRUE
	processing = TRUE
	update_icon() //NSV13
	user.visible_message("[user] turns on [src].", \
		"<span class='notice'>You turn on [src].</span>", \
		"<span class='italics'>You hear a food processor.</span>")
	playsound(src.loc, 'sound/machines/blender.ogg', 50, 1)
	use_power(500)
	var/total_time = 0
	for(var/O in src.contents)
		var/datum/food_processor_process/P = select_recipe(O)
		if (!P)
			log_admin("DEBUG: [O] in processor doesn't have a suitable recipe. How did it get in there? Please report it immediately!!!")
			continue
		total_time += P.time
	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = (total_time / rating_speed)*5) //start shaking
	sleep(total_time / rating_speed)
	for(var/atom/movable/O in src.contents)
		var/datum/food_processor_process/P = select_recipe(O)
		if (!P)
			log_admin("DEBUG: [O] in processor doesn't have a suitable recipe. How do you put it in?")
			continue
		process_food(P, O)
	pixel_x = base_pixel_x //return to its spot after shaking
	processing = FALSE
	update_icon() //NSV13
	visible_message("\The [src] finishes processing.")

/obj/machinery/processor/update_icon() //NSV13
	if(processing)
		icon_state = "processor1_animated"
	else
		icon_state = "processor1"

/obj/machinery/processor/verb/eject()
	set category = "Object"
	set name = "Eject Contents"
	set src in oview(1)
	if(usr.stat || usr.restrained())
		return
	if(isliving(usr))
		var/mob/living/L = usr
		if(!(L.mobility_flags & MOBILITY_UI))
			return
	empty()
	add_fingerprint(usr)

/obj/machinery/processor/container_resist(mob/living/user)
	user.forceMove(drop_location())
	user.visible_message("<span class='notice'>[user] crawls free of the processor!</span>")

/obj/machinery/processor/proc/empty()
	for (var/obj/O in src)
		O.forceMove(drop_location())
	for (var/mob/M in src)
		M.forceMove(drop_location())

/obj/machinery/processor/slime
	name = "slime processor"
	desc = "An industrial grinder with a sticker saying appropriated for science department. Keep hands clear of intake area while operating."
	var/sbacklogged = FALSE

/obj/machinery/processor/slime/Initialize(mapload)
	. = ..()
	var/obj/item/circuitboard/machine/B = new /obj/item/circuitboard/machine/processor/slime(null)
	B.apply_default_parts(src)
	proximity_monitor = new(src, 1)

/obj/machinery/processor/slime/adjust_item_drop_location(atom/movable/AM)
	var/static/list/slimecores = subtypesof(/obj/item/slime_extract)
	var/i = 0
	if(!(i = slimecores.Find(AM.type))) // If the item is not found
		return
	if (i <= 16) // If in the first 12 slots
		AM.pixel_x = AM.base_pixel_x - 12 + ((i%4)*8)
		AM.pixel_y = AM.base_pixel_y - 12 + (round(i/4)*8)
		return i
	var/ii = i - 16
	AM.pixel_x = AM.base_pixel_x - 8 + ((ii%3)*8)
	AM.pixel_y = AM.base_pixel_y - 8 + (round(ii/3)*8)
	return i

/obj/machinery/processor/slime/interact(mob/user)
	. = ..()
	if(sbacklogged)
		for(var/mob/living/simple_animal/slime/AM in ohearers(1,src)) //fallback in case slimes got placed while processor was active triggers only after processing!!!!
			if(AM.stat == DEAD)
				visible_message("[AM] is sucked into [src].")
				AM.forceMove(src)
		sbacklogged = FALSE

/obj/machinery/processor/slime/HasProximity(mob/AM)
	if(!sbacklogged && istype(AM, /mob/living/simple_animal/slime) && AM.stat == DEAD)
		if(processing)
			sbacklogged = TRUE
		else
			visible_message("[AM] is sucked into [src].")
			AM.forceMove(src)

/obj/machinery/processor/slime/process_food(datum/food_processor_process/recipe, atom/movable/what)
	var/mob/living/simple_animal/slime/S = what
	if (istype(S))
		var/C = S.cores
		for(var/i in 1 to (C+rating_amount-1))
			var/obj/item/slime_extract/item = new S.coretype(drop_location())
			if(S.transformeffects & SLIME_EFFECT_GOLD)
				item.sparkly = TRUE
			adjust_item_drop_location(item)
			SSblackbox.record_feedback("tally", "slime_core_harvested", 1, S.colour)
	..()
