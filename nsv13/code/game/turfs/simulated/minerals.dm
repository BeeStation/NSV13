/**********************Mineral deposits**************************/

/turf/closed/mineral //wall piece
	name = "rock"
	icon = 'icons/turf/mining.dmi'
	icon_state = "rock"
	var/smooth_icon = 'icons/turf/smoothrocks.dmi'
	smooth = SMOOTH_MORE|SMOOTH_BORDER
	canSmoothWith = null
	baseturfs = /turf/open/floor/plating/asteroid/airless
	initial_gas_mix = AIRLESS_ATMOS
	opacity = 1
	density = TRUE
	layer = EDGED_TURF_LAYER
	temperature = TCMB
	material_flags = MATERIAL_NO_DESC | MATERIAL_NO_COLOR
	var/environment_type = "asteroid"
	var/hardness = ROCK_HARDNESS_WEAK
	var/last_act = 0
	var/turf/open/floor/plating/turf_type = /turf/open/floor/plating/asteroid/airless
	var/defer_change = FALSE

/turf/closed/mineral/Initialize()
	if (!canSmoothWith)
		canSmoothWith = list(/turf/closed/mineral, /turf/closed/indestructible)
	var/matrix/M = new
	M.Translate(-4, -4)
	transform = M
	icon = smooth_icon
	. = ..()

/turf/closed/mineral/attackby(obj/item/I, mob/user, params)
	if (!user.IsAdvancedToolUser())
		to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return

	if(I.tool_behaviour == TOOL_MINING)
		var/turf/T = user.loc
		if (!isturf(T))
			return

		if(!istype(I, /obj/item/pickaxe))
			return //go away non pickaxies

		var/obj/item/pickaxe/P = I

		if(last_act + (40 * P.toolspeed) > world.time)//prevents message spam
			return
		last_act = world.time
		to_chat(user, "<span class='notice'>You start picking...</span>")

		var/destructive = P.tunnel_mining
		var/tunnel_mining_modifier = destructive ? 0.33 : 1 //If tunnel mining, mine 66% faster
		var/delay_modifier = hardness == ROCK_HARDNESS_NORMAL ? 3 * tunnel_mining_modifier : 1

		if(P.use_tool(src, user, 40 * delay_modifier, volume=50))
			if(ismineralturf(src))
				to_chat(user, "<span class='notice'>You finish cutting into the rock.</span>")
				gets_drilled(user, FALSE, 1, destructive)
				SSblackbox.record_feedback("tally", "pick_used_mining", 1, I.type)
	else
		return attack_hand(user)

/turf/closed/mineral/proc/gets_drilled(mob/user, triggered_by_explosion = 0, var/efficiency = 1)
	var/flags = NONE
	if(defer_change) // TODO: make the defer change var a var for any changeturf flag
		flags = CHANGETURF_DEFER_CHANGE
	ScrapeAway(null, flags)
	addtimer(CALLBACK(src, .proc/AfterChange), 1, TIMER_UNIQUE)
	playsound(src, 'sound/effects/break_stone.ogg', 50, 1) //beautiful destruction

/turf/closed/mineral/attack_animal(mob/living/simple_animal/user)
	if((user.environment_smash & ENVIRONMENT_SMASH_WALLS) || (user.environment_smash & ENVIRONMENT_SMASH_RWALLS))
		gets_drilled()
	..()

/turf/closed/mineral/attack_alien(mob/living/carbon/alien/M)
	to_chat(M, "<span class='notice'>You start digging into the rock...</span>")
	playsound(src, 'sound/effects/break_stone.ogg', 50, 1)
	if(do_after(M, 40, target = src))
		to_chat(M, "<span class='notice'>You tunnel into the rock.</span>")
		gets_drilled(M)


/// Specific handling for when you bump into this turf with the correcty tools equipped.
/turf/closed/mineral/Bumped(atom/movable/AM)
	..()
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		var/obj/item/I = H.is_holding_tool_quality(TOOL_MINING)
		if(I)
			attackby(I, H)
		return
	else if(iscyborg(AM))
		var/mob/living/silicon/robot/R = AM
		if(R.module_active && (R.module_active.tool_behaviour == TOOL_MINING))
			attackby(R.module_active, R)
			return
	else
		return

/turf/closed/mineral/acid_melt()
	if(hardness == ROCK_HARDNESS_WEAK)
		ScrapeAway()

/turf/closed/mineral/ex_act(severity, target)
	..()
	switch(severity)
		if(3)
			if (prob(75))
				gets_drilled(null, 1)
		if(2)
			if (prob(90))
				gets_drilled(null, 1)
		if(1)
			gets_drilled(null, 1)
	return

/// Dense rock, can only be mined by specific tools like drills and jackhammers and drops boulders instead of ore.
/turf/closed/mineral/dense
	environment_type = "basalt"
	hardness = ROCK_HARDNESS_NORMAL
	turf_type = /turf/open/floor/plating/asteroid
	baseturfs = /turf/open/floor/plating/asteroid
	defer_change = 1
	var/list/composition = list()
	var/can_become_vein = TRUE

/turf/closed/mineral/dense/Initialize(mapload)
	. = ..()
	generate_random_composition()

/turf/closed/mineral/dense/proc/set_materials(var/list/minerals)
	composition = minerals

/// Cant destoy dense easily with explosions
/turf/closed/mineral/dense/ex_act(severity, target)
	..()
	if(severity == 1)
		gets_drilled(null, 1)
	return


/// If not destructive, spawn a boulder, otherwise a rock. Then set their custom materials
/turf/closed/mineral/dense/gets_drilled(mob/user, triggered_by_explosion = 0, var/efficiency = 1, destructive = TRUE)
	if(!destructive) //If its not destructive, spawn a boulder
		var/temp_mat_list = list()
		for(var/i in composition)
			temp_mat_list[i] = composition[i] * efficiency
		var/obj/structure/boulder/B = new(src)
		B.set_custom_materials(temp_mat_list) //Adds ore to the boulder

	else //Else spawn a rock
		var/temp_mat_list = list()
		for(var/i in composition)
			temp_mat_list[i] = composition[i] * efficiency / ROCK_COUNT_BOULDER
		var/obj/item/rock/R = new(src)
		R.set_custom_materials(temp_mat_list) //Adds ore to the rock
	. = ..()

/// Generates a list a map of /datum/material references || percentage coming out at 100% in total
/turf/closed/mineral/dense/proc/generate_random_composition()
	var/list/temp_composition = list()
	var/total_amount = MINERAL_TURF_AMOUNT

	var/basalt_amount = total_amount * (rand(65, 95) / 100) //How much sand will this rock consist of

	temp_composition[getmaterialref(/datum/material/sand)] = basalt_amount //sediment amount
	total_amount -= basalt_amount

	var/other_material_count = rand(1, 5)

	for(var/i in 1 to other_material_count)
		var/material = getmaterialref(pickweight(MINERAL_RARITY_LIST)) //Pick the material to use and get the ref
		var/mat_amount = total_amount / other_material_count // Replace this to make the distribution look more smooth later
		temp_composition[material] += mat_amount
	composition = temp_composition

/turf/closed/mineral/dense/vein
	name = "Vein Rock"
	var/list/core_minerals = list(/datum/material/plasma = 25, /datum/material/titanium = 3) //Default
	var/base_spread = 0.7 //50% chance at first spread.
	var/base_spread_loss = 2 //Division per spread
	can_become_vein = FALSE

/turf/closed/mineral/dense/vein/Initialize(mapload)
	. = ..()
	var/activated_overlay = mutable_appearance('icons/turf/smoothrocks.dmi', "vein_overlay", ON_EDGED_TURF_LAYER)
	add_overlay(activated_overlay)

/turf/closed/mineral/dense/vein/generate_random_composition() //We're not as random as other rocks.
	return FALSE

/turf/closed/mineral/dense/vein/proc/setup_composition(var/list/core_composition)
	if(core_composition)
		core_minerals = core_composition

	var/list/temp_composition = list()
	var/total_amount = MINERAL_TURF_AMOUNT

	var/basalt_amount = total_amount * (rand(10, 25) / 100) //How much sand will this rock consist of
	temp_composition[getmaterialref(/datum/material/sand)] = basalt_amount //sediment amount

	total_amount -= basalt_amount

	var/core_material_count = rand(1, 15)

	for(var/i in 1 to core_material_count)
		var/material = getmaterialref(pickweight(core_minerals)) //Pick the material to use and get the ref
		var/mat_amount = total_amount / core_material_count // Replace this to make the distribution look more smooth later
		temp_composition[material] += mat_amount

	composition = temp_composition

/turf/closed/mineral/dense/vein/proc/create_vein() //Create vein, which encircles the turf selected with veins and then slowly creeps out
	for(var/dir in GLOB.cardinals)
		var/turf/T = get_step(src, dir)
		if(!istype(T, /turf/closed/mineral/dense))
			continue
		var/turf/closed/mineral/dense/D = T
		if(!D.can_become_vein)
			continue
		var/turf/closed/mineral/dense/vein/V = D.ChangeTurf(type)
		V.setup_composition(core_minerals)
		V.spread_vein(base_spread)

/turf/closed/mineral/dense/vein/proc/spread_vein(spread_chance)
	for(var/dir in GLOB.cardinals)
		var/turf/T = get_step(src, dir)
		if(!istype(T, /turf/closed/mineral/dense))
			continue
		var/turf/closed/mineral/dense/D = T
		if(!D.can_become_vein)
			continue
		if(!prob(spread_chance))
			continue
		var/turf/closed/mineral/dense/vein/V = T.ChangeTurf(type)
		V.setup_composition(core_minerals)
		V.spread_vein(spread_chance / base_spread_loss) //Less efficient than creation

/turf/closed/mineral/random/volcanic/Initialize()
	. = ..()
	if(prob(0.5)) //1 in 200 to spawn tunnel
		ChangeTurf(/turf/open/floor/plating/asteroid/airless/cave/volcanic,null,CHANGETURF_IGNORE_AIR)

/turf/closed/mineral/random/high_chance
	icon_state = "rock_highchance"

/turf/closed/mineral/random/high_chance/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/random/low_chance
	icon_state = "rock_lowchance"

/turf/closed/mineral/random/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/random/labormineral

/turf/closed/mineral/random/labormineral/volcanic
	environment_type = "basalt"

/turf/closed/mineral/iron

/turf/closed/mineral/iron/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/iron/ice
	environment_type = "snow_cavern"
	icon_state = "icerock_iron"
	smooth_icon = 'icons/turf/walls/icerock_wall.dmi'
	turf_type = /turf/open/floor/plating/asteroid/snow/ice
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice
	initial_gas_mix = FROZEN_ATMOS
	defer_change = TRUE

/turf/closed/mineral/uranium

/turf/closed/mineral/uranium/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = 1


/turf/closed/mineral/diamond

/turf/closed/mineral/diamond/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/diamond/ice
	environment_type = "snow_cavern"
	icon_state = "icerock_diamond"
	smooth_icon = 'icons/turf/walls/icerock_wall.dmi'
	turf_type = /turf/open/floor/plating/asteroid/snow/ice
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice
	initial_gas_mix = FROZEN_ATMOS
	defer_change = TRUE


/turf/closed/mineral/gold


/turf/closed/mineral/gold/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/silver

/turf/closed/mineral/silver/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/titanium

/turf/closed/mineral/titanium/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/plasma

/turf/closed/mineral/plasma/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = 1

/turf/closed/mineral/plasma/ice
	environment_type = "snow_cavern"
	icon_state = "icerock_plasma"
	smooth_icon = 'icons/turf/walls/icerock_wall.dmi'
	turf_type = /turf/open/floor/plating/asteroid/snow/ice
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice
	initial_gas_mix = FROZEN_ATMOS
	defer_change = TRUE

/turf/closed/mineral/bananium

/turf/closed/mineral/bscrystal

/turf/closed/mineral/bscrystal/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = TRUE

/turf/closed/mineral/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt
	baseturfs = /turf/open/floor/plating/asteroid/basalt
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/closed/mineral/volcanic/lava_land_surface
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	defer_change = TRUE

/turf/closed/mineral/ash_rock //wall piece
	name = "rock"
	icon = 'icons/turf/mining.dmi'
	smooth_icon = 'icons/turf/walls/rock_wall.dmi'
	icon_state = "rock2"
	smooth = SMOOTH_MORE|SMOOTH_BORDER
	canSmoothWith = list (/turf/closed)
	baseturfs = /turf/open/floor/plating/ashplanet/wateryrock
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	environment_type = "waste"
	turf_type = /turf/open/floor/plating/ashplanet/rocky
	defer_change = TRUE

/turf/closed/mineral/snowmountain
	name = "snowy mountainside"
	icon = 'icons/turf/mining.dmi'
	smooth_icon = 'icons/turf/walls/mountain_wall.dmi'
	icon_state = "mountainrock"
	smooth = SMOOTH_MORE|SMOOTH_BORDER
	canSmoothWith = list (/turf/closed)
	baseturfs = /turf/open/floor/plating/asteroid/snow
	initial_gas_mix = FROZEN_ATMOS
	environment_type = "snow"
	turf_type = /turf/open/floor/plating/asteroid/snow
	defer_change = TRUE

/turf/closed/mineral/snowmountain/cavern
	name = "ice cavern rock"
	icon = 'icons/turf/mining.dmi'
	smooth_icon = 'icons/turf/walls/icerock_wall.dmi'
	icon_state = "icerock"
	smooth = SMOOTH_MORE|SMOOTH_BORDER
	canSmoothWith = list (/turf/closed)
	baseturfs = /turf/open/floor/plating/asteroid/snow/ice
	environment_type = "snow_cavern"
	turf_type = /turf/open/floor/plating/asteroid/snow/ice

//GIBTONITE

/turf/closed/mineral/gibtonite
	var/det_time = 8 //Countdown till explosion, but also rewards the player for how close you were to detonation when you defuse it
	var/stage = GIBTONITE_UNSTRUCK //How far into the lifecycle of gibtonite we are
	var/activated_ckey = null //These are to track who triggered the gibtonite deposit for logging purposes
	var/activated_name = null
	var/mutable_appearance/activated_overlay

/turf/closed/mineral/gibtonite/Initialize()
	det_time = rand(8,10) //So you don't know exactly when the hot potato will explode
	. = ..()

/turf/closed/mineral/gibtonite/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_MULTITOOL)
		user.visible_message("<span class='notice'>[user] holds [I] to [src]...</span>", "<span class='notice'>You use [I] to locate where to cut off the chain reaction and attempt to stop it...</span>")
		defuse()
	..()

/turf/closed/mineral/gibtonite/proc/explosive_reaction(mob/user = null, triggered_by_explosion = 0)
	if(stage == GIBTONITE_UNSTRUCK)
		activated_overlay = mutable_appearance('icons/turf/smoothrocks.dmi', "rock_Gibtonite_active", ON_EDGED_TURF_LAYER)
		add_overlay(activated_overlay)
		name = "gibtonite deposit"
		desc = "An active gibtonite reserve. Run!"
		stage = GIBTONITE_ACTIVE
		visible_message("<span class='danger'>There was gibtonite inside! It's going to explode!</span>")

		var/notify_admins = 0
		if(z != 5)
			notify_admins = TRUE

		if(!triggered_by_explosion)
			log_bomber(user, "has trigged a gibtonite deposit reaction via", src, null, notify_admins)
		else
			log_bomber(null, "An explosion has triggered a gibtonite deposit reaction via", src, null, notify_admins)

		countdown(notify_admins)

/turf/closed/mineral/gibtonite/proc/countdown(notify_admins = 0)
	set waitfor = 0
	while(istype(src, /turf/closed/mineral/gibtonite) && stage == GIBTONITE_ACTIVE && det_time > 0)
		det_time--
		sleep(5)
	if(istype(src, /turf/closed/mineral/gibtonite))
		if(stage == GIBTONITE_ACTIVE && det_time <= 0)
			var/turf/bombturf = get_turf(src)
			stage = GIBTONITE_DETONATE
			explosion(bombturf,1,3,5, adminlog = notify_admins)

/turf/closed/mineral/gibtonite/proc/defuse()
	if(stage == GIBTONITE_ACTIVE)
		cut_overlay(activated_overlay)
		activated_overlay.icon_state = "rock_Gibtonite_inactive"
		add_overlay(activated_overlay)
		desc = "An inactive gibtonite reserve. The ore can be extracted."
		stage = GIBTONITE_STABLE
		if(det_time < 0)
			det_time = 0
		visible_message("<span class='notice'>The chain reaction was stopped! The gibtonite had [det_time] reactions left till the explosion!</span>")

/turf/closed/mineral/gibtonite/gets_drilled(mob/user, triggered_by_explosion = 0, var/efficiency = 1)
	if(stage == GIBTONITE_UNSTRUCK) //Gibtonite deposit is activated
		playsound(src,'sound/effects/hit_on_shattered_glass.ogg',50,1)
		explosive_reaction(user, triggered_by_explosion)
		return
	if(stage == GIBTONITE_ACTIVE) //Gibtonite deposit goes kaboom
		var/turf/bombturf = get_turf(src)
		stage = GIBTONITE_DETONATE
		explosion(bombturf,1,2,5, adminlog = 0)
	if(stage == GIBTONITE_STABLE) //Gibtonite deposit is now benign and extractable. Depending on how close you were to it blowing up before defusing, you get better quality ore.
		var/obj/item/twohanded/required/gibtonite/G = new (src)
		if(det_time <= 0)
			G.quality = 3
			G.icon_state = "Gibtonite ore 3"
		if(det_time >= 1 && det_time <= 2)
			G.quality = 2
			G.icon_state = "Gibtonite ore 2"

	var/flags = NONE
	if(defer_change)
		flags = CHANGETURF_DEFER_CHANGE
	ScrapeAway(null, flags)
	addtimer(CALLBACK(src, .proc/AfterChange), 1, TIMER_UNIQUE)


/turf/closed/mineral/gibtonite/volcanic
	environment_type = "basalt"
	turf_type = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	baseturfs = /turf/open/floor/plating/asteroid/basalt/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	defer_change = 1