/**
	Late game science researchable machine that allows you to project shields around the ship in exchange for a crapload of power.
	@author Kmc2000
*/

/obj/structure/overmap
	var/obj/machinery/shield_generator/shields

/obj/structure/shieldgen_frame
	name = "shield generator frame"
	desc = "The beginnings of a shield generator. It requires 2 cooling fans, 4 flux, 1 crystal interface, and 4 modulators."
	icon = 'nsv13/icons/obj/machinery/shieldgen.dmi'
	icon_state = "shieldgen_build1"
	pixel_x = -32
	density = TRUE
	layer = HIGH_OBJ_LAYER
	var/state = 1
	var/fanCount = 0
	var/capacitorCount = 0
	var/modulatorCount = 0
	var/hasInterface = FALSE
	var/componentsDone = FALSE


/obj/item/disk/design_disk/overmap_shields
	name = "SolGov Experimental Shielding Technology Disk"
	desc = "This disk is the property of SolGov, unlawful use of the data contained on this disk is prohibited."
	icon_state = "datadisk2"
	max_blueprints = 5

/obj/item/disk/design_disk/overmap_shields/Initialize(mapload)
	. = ..()
	var/datum/design/shield_fan/A = new
	var/datum/design/shield_capacitor/B = new
	var/datum/design/shield_modulator/C = new
	var/datum/design/shield_interface/D = new
	var/datum/design/shield_frame/E = new
	blueprints[1] = A
	blueprints[2] = B
	blueprints[3] = C
	blueprints[4] = D
	blueprints[5] = E

/obj/structure/shieldgen_frame/attackby(obj/item/I, mob/living/user, params)
	if(state != 11)
		return FALSE

	switch(I.type)
		if(/obj/item/shield_component/fan)
			if(fanCount >= 2)
				return FALSE

			to_chat(user, "<span class='notice'>You add [I] to [src].</span>")
			I.forceMove(src)
			fanCount ++
		if(/obj/item/shield_component/capacitor)
			if(capacitorCount >= 4)
				return FALSE

			to_chat(user, "<span class='notice'>You add [I] to [src].</span>");
			I.forceMove(src)
			capacitorCount ++
		if(/obj/item/shield_component/modulator)
			if(modulatorCount >= 4)
				return FALSE

			to_chat(user, "<span class='notice'>You add [I] to [src].</span>");
			I.forceMove(src)
			modulatorCount ++
		if(/obj/item/shield_component/interface)
			if(hasInterface)
				return FALSE

			to_chat(user, "<span class='notice'>You add [I] to [src].</span>")
			I.forceMove(src)
			hasInterface = TRUE
	componentsDone = check_finished()
	if(componentsDone)
		state = 12

	return FALSE

/obj/structure/shieldgen_frame/proc/check_finished()
	return (fanCount >= 2 && capacitorCount >= 4 && modulatorCount >= 4 && hasInterface)


/obj/structure/shieldgen_frame/proc/finish()
	for(var/atom/movable/AM in contents)
		qdel(AM)

	new /obj/machinery/shield_generator(get_turf(src));
	qdel(src)


/obj/structure/shieldgen_frame/wrench_act(mob/living/user, obj/item/I)
	switch(state)
		if(2)
			to_chat(user, "<span class='notice'>You start to bolt together [src].</span>");
			if(do_after(user, 5 SECONDS, target=src))
				state = 3
				update_icon()
				return FALSE
		if(4)
			to_chat(user, "<span class='notice'>You start to bolt [src]'s housings together...</span>")
			if(do_after(user, 5 SECONDS, target=src))
				state = 5
				update_icon()
				return FALSE
		if(6)
			to_chat(user, "<span class='notice'>You start to bolt [src]'s connecting struts into its frame.</span>")
			if(do_after(user, 5 SECONDS, target=src))
				state = 7
				update_icon()
				return FALSE
		if(8)
			to_chat(user, "<span class='notice'>You start to bolt [src]'s primary generator coverings...</span>")
			if(do_after(user, 5 SECONDS, target=src))
				state = 9
				update_icon()
				return FALSE
		if(10)
			to_chat(user, "<span class='notice'>You start to secure [src]'s flux generator housing...</span>")
			if(do_after(user, 5 SECONDS, target=src))
				state = 11
				update_icon()
				return FALSE
	anchored = !anchored
	I.play_tool_sound(src)
	to_chat(user, "<span class='notice'>You [anchored?"secure":"unsecure"] [src].</span>")
	return FALSE

/obj/structure/shieldgen_frame/screwdriver_act(mob/living/user, obj/item/I)
	. = FALSE
	switch(state)
		if(7)
			to_chat(user, "<span class='notice'>You start to screw in [src]'s primary generator coverings...</span>")
			if(do_after(user, 5 SECONDS, target=src))
				state = 8
				update_icon()

			return FALSE
		if(12)
			if(!anchored)
				to_chat(user, "<span class='notice'>[src] must be anchored with a wrench before you can complete it!</span>")
				return FALSE

			to_chat(user, "<span class='notice'>You start to screw in [src]'s components...</span>");
			if(do_after(user, 5 SECONDS, target=src))
				finish()

			return FALSE

/obj/structure/shieldgen_frame/welder_act(mob/living/user, obj/item/I)
	. = FALSE
	switch(state)
		if(1)
			to_chat(user, "<span class='notice'>You start to weld the chassis together...</span>")
			if(do_after(user, 5 SECONDS, target=src))
				state = 2
				update_icon()

		if(3)
			to_chat(user, "<span class='notice'>You start to weld [src]'s connecting struts into its frame.</span>")
			if(do_after(user, 5 SECONDS, target=src))
				state = 4
				update_icon()

		if(5)
			to_chat(user, "<span class='notice'>You start to weld [src]'s housings to the frame.</span>")
			if(do_after(user, 5 SECONDS, target=src))
				state = 6
				update_icon()

		if(9)
			to_chat(user, "<span class='notice'>You start to weld [src]'s primary generator coverings...</span>")
			if(do_after(user, 5 SECONDS, target=src))
				state = 10
				update_icon()
				return FALSE



/obj/structure/shieldgen_frame/update_icon()
	icon_state = "shieldgen_build[state]"

/obj/machinery/shield_generator
	name = "shield Generator"
	desc = "A massively powerful device which is able to project energy shields around ships. This technology is highly experimental and requires a huge amount of power."
	icon = 'nsv13/icons/obj/machinery/shieldgen.dmi'
	icon_state = "shieldgen"
	idle_power_usage = IDLE_POWER_USE; //This will change to match the requirements for projecting a shield.
	pixel_x = -32
	bound_height = 128
	bound_width = 96
	density = TRUE
	layer = HIGH_OBJ_LAYER
	var/flux_rate = 0 //Flux that this shield generator is producing based on power usage.
	var/power_input = 0 //Inputted power setting. Allows you to throttle the shieldgen to not eat all of your power at once.
	var/list/shield = list("integrity"=0, "max_integrity"=0)
	var/regenPriority = 50
	var/maxHealthPriority = 50 //50/50 split
	var/max_power_input = 1.5e+7 //15 MW theoretical maximum. This much power means your shield is going to be insanely good.
	var/active = FALSE; //Are we projecting out our shields? This lets you offline the shields for a recharge period so that they become useful again. This function needs a rework as there is no penalty for shields collapsing, and recharge rate is linear.
	var/obj/structure/cable/cable = null //Connected cable
	var/mutable_appearance/c_screen


/obj/machinery/shield_generator/proc/absorb_hit(obj/item/projectile/proj)
	var/damage = proj.damage
	if(!active)
		return SHIELD_NOEFFECT //If we don't have shields raised, then we won't tank the hit. This allows you to micro the shields back to health.

	if(shield["integrity"] >= damage)
		shield["integrity"] -= damage
		return SHIELD_ABSORB

	return SHIELD_NOEFFECT


/obj/item/shield_component
	name = "shield component"
	icon = 'nsv13/icons/obj/shield_components.dmi'

/obj/item/shield_component/fan
	name = "shield generator cooling fan"
	desc = "A small fan which aids in cooling down a shield generator."
	icon_state = "cooling_fan"

/obj/item/shield_component/capacitor
	name = "Flux Capacitor"
	desc = "A small capacitor which can generate shield flux."
	icon_state = "capacitor"

/obj/item/shield_component/modulator
	name = "Shield Modulator"
	desc = "A control circuit for shield systems to allow them to project energy screens around the ship."
	icon_state = "modulator"

/obj/item/shield_component/interface
	name = "Bluespace Crystal Interface"
	desc = "A housing to hold a bluespace crystal which extends the generated shield around an entire ship via subspace."
	icon_state = "crystal_interface"


//Constructor of objects of class shield_generator. No params
/obj/machinery/shield_generator/Initialize(mapload)
	. = ..()
	var/obj/structure/overmap/ours = get_overmap()
	ours?.shields = src
	c_screen = mutable_appearance(src.icon, "screen_on")
	add_overlay(c_screen)
	if(!ours)
		addtimer(CALLBACK(src, PROC_REF(try_find_overmap)), 20 SECONDS)

/obj/machinery/shield_generator/Destroy()
	cut_overlay(c_screen)
	QDEL_NULL(c_screen)
	return ..()

/obj/machinery/shield_generator/proc/try_find_overmap()
	var/obj/structure/overmap/ours = get_overmap()
	ours?.shields = src
	if(!ours)
		message_admins("WARNING: Shield generator in [get_area(src)] does not have a linked overmap!");
		log_game("WARNING: Shield generator in [get_area(src)] does not have a linked overmap!");



/obj/machinery/shield_generator/proc/depower_shield()
	c_screen.alpha = 0
	shield["integrity"] = 0
	shield["max_integrity"] = 0


/obj/machinery/shield_generator/proc/try_use_power(amount) // Although the machine may physically be powered, it may not have enough power to sustain a shield.
	var/turf/T = get_turf(src)
	cable = T.get_cable_node()
	if(cable?.surplus() > amount)
		cable.powernet.load += amount
		return TRUE
	return FALSE

//Every tick, the shield generator updates its stats based on the amount of power it's being allowed to chug.
/obj/machinery/shield_generator/process()
	if(!powered() || power_input <= 0 || !try_use_power(power_input))
		if(shield["integrity"] > 0) //If we lose power, the shield integrity steadily drains
			shield["integrity"] -= 2
			active = FALSE

		if(shield["integrity"] <= 0) //Reset if no juice remaining
			depower_shield()

		return FALSE
	c_screen.alpha = 255
	var/megawatts = power_input / 1e+6 //I'm lazy.
	flux_rate = round(megawatts*2.5) //Round down them megawatts. Multiplier'd this to make shields actually useful

	//Firstly, set the max health of the shield based off of the available input power, and the priority that the user set for generating a shield.
	var/projectRate = max(((maxHealthPriority / 100) * flux_rate), 0)
	flux_rate -= projectRate
	shield["max_integrity"] = projectRate * 100 //1 flux/s => 100max HP for this tick.

	//Now we handle whatever's left of the power allocation for regenerating the shield

	var/regenRate = max(((regenPriority / 100) * flux_rate),0) //Times also works as of. Soo we're going, for example, 50% of flux_rate
	flux_rate -= regenRate
	shield["integrity"] += regenRate
	if(shield["integrity"] > shield["max_integrity"])
		shield["integrity"] = shield["max_integrity"]

/obj/machinery/shield_generator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui);
	if(!ui)
		ui = new(user, src, "ShieldGenerator")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/shield_generator/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/shield_generator/ui_data(mob/user)
	. = ..()
	var/list/data = list()
	data["maxHealthPriority"] = maxHealthPriority
	data["regenPriority"] = regenPriority
	data["progress"] = shield["integrity"]
	data["goal"] = shield["max_integrity"]
	data["powerAlloc"] = power_input/1e+6
	data["maxPower"] = max_power_input/1e+6
	data["active"] = active
	data["available_power"] = 0
	var/turf/T = get_turf(src)
	cable = T.get_cable_node()
	if(cable?.powernet)
		data["available_power"] = cable.surplus()
	return data


/obj/effect/temp_visual/overmap_shield_hit
	name = "Shield hit"
	icon = 'nsv13/icons/overmap/shieldhit.dmi';
	icon_state = "shieldhit"
	duration = 0.75 SECONDS
	layer = ABOVE_MOB_LAYER+0.1
	animate_movement = NO_STEPS // Override the inbuilt movement engine to avoid bouncing
	appearance_flags = TILE_BOUND | PIXEL_SCALE
	var/obj/structure/overmap/overmap

/obj/effect/temp_visual/overmap_shield_hit/Initialize(mapload, obj/structure/overmap/OM)
	. = ..()
	//Scale up the shield hit icon to roughly fit the overmap ship that owns us.
	if(!OM)
		return INITIALIZE_HINT_QDEL
	overmap = OM
	var/matrix/desired = new()
	var/icon/I = icon(overmap.icon)
	var/resize_x = I.Width()/96
	var/resize_y = I.Height()/96
	desired.Scale(resize_x,resize_y)
	desired.Turn(overmap.angle)
	transform = desired
	overmap.vis_contents += src

/obj/effect/temp_visual/overmap_shield_hit/Destroy()
	overmap?.vis_contents -= src
	overmap = null
	return ..()

/obj/machinery/shield_generator/ui_act(action, params)
	if(..())
		return

	var/value = text2num(params["input"])
	switch(action)
		if("maxHealth")
			maxHealthPriority = value
			regenPriority = 100-maxHealthPriority

		if("regen")
			regenPriority = value
			maxHealthPriority = 100-regenPriority

		if("power")
			power_input = value*1e+6
		if("activeToggle")
			active = !active
	return


/**
Component that allows AI ships to model shields. Will continuously recharge over time.
*/
/datum/component/overmap_shields
	var/list/shield = list(
		"integrity" = 0,
		"max_integrity" = 100
	)
	//How good are these shields anyway?
	var/max_integrity = 500
	var/recharge_rate = 20
	var/active = TRUE //This is really for adminbuse, or if we ever add EMP damage....

/datum/component/overmap_shields/New(datum/P, start_integrity=0, max_integrity=100, recharge_rate=20)
	. = ..()
	if(!isovermap(parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/structure/overmap/OM = parent
	//That ship's already got shields simulated. Nope.
	if(!QDELETED(OM.shields))
		return COMPONENT_INCOMPATIBLE
	//Alright! Link up. We'll now protect that ship.
	OM.shields = src
	set_stats(start_integrity, max_integrity)
	START_PROCESSING(SSdcs, src)

/datum/component/overmap_shields/process()
	shield["integrity"] += recharge_rate
	if(shield["integrity"] > max_integrity)
		shield["integrity"] = max_integrity

/datum/component/overmap_shields/proc/set_stats(integrity=0, max_integrity=100, recharge_rate=20)
	src.max_integrity = max_integrity
	src.recharge_rate = recharge_rate
	shield["integrity"] = integrity
	shield["max_integrity"] = max_integrity

/datum/component/overmap_shields/proc/absorb_hit(obj/item/projectile/proj)
	var/damage = proj.damage
	if(!active)
		return SHIELD_NOEFFECT //If we don't have shields raised, then we won't tank the hit. This allows you to micro the shields back to health.
	if(shield["integrity"] >= damage)
		shield["integrity"] -= damage
		return SHIELD_ABSORB
	return SHIELD_NOEFFECT

