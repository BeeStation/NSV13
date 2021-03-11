//IT CAME....from outer space!

#define MOVESPEED_ID_BLOODLING_BIOMASS "bloodling_biomass_penalty"

/mob/living/simple_animal/bloodling
	name = "fleshy entity"
	desc = "Just looking at this thing makes you want to puke."
	icon = 'nsv13/icons/mob/bloodling.dmi'
	icon_living = "evo1"
	icon_dead = "deadling"
	icon_state = "evo1"
	pass_flags = PASSTABLE | PASSMOB | PASSDOOR
	mob_size = MOB_SIZE_TINY
	density = FALSE
	hud_type = /datum/hud/bloodling
	health = 200
	maxHealth = 200

/mob/living/simple_animal/bloodling/Initialize()
	. = ..()
	AddComponent(/datum/component/waddling)
	AddComponent(/datum/component/bloodling)

/mob/living/simple_animal/bloodling/proc/on_evolve(step)
	icon_living = "evo[step]"
	icon_dead = "deadling"
	icon_state = "evo[step]"
	maxHealth = initial(maxHealth) * step
	health = maxHealth //Yeah fine, free heal.


/datum/component/bloodling
	var/biomass = 20 //How much biomass have we absorbed? We start off with a tiiiiny bit.
	var/final_form_biomass = 600
	var/mob/living/ling = null
	var/evolution_step = 1 //What evolution level are we currently at?
	var/last_evolution = 1 //So we can animate the little critter when it grows up.
	var/max_evolution = 6

	//Abilities.

	//Lay out the ability tiers here! Very simple, unlocks at unlockTier evo, locks at lockTier evo (if set). Code'll handle the rest. The abilities list is, you guessed it, all the abilities for that tier.
	var/list/unlock_tiers = list(
		list("unlockTier"=0, "lockAtTier"=4, "abilities"=list(/datum/action/bloodling/hide)),
		list("unlockTier"=0, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/thermalvision))
	)
	//Generated list of abilities, created at init.
	var/list/ability_tiers = list()

/datum/component/bloodling/Initialize()
	. = ..()
	if(!istype(parent, /mob/living))
		return COMPONENT_INCOMPATIBLE
	ling = parent
	for(var/list/tier in unlock_tiers)
		var/list/abilities = list()
		for(var/aType in tier["abilities"])
			abilities += new aType
		ability_tiers[++ability_tiers.len] =list("unlockTier"=tier["unlockTier"], "abilities"=abilities, "lockAtTier"=tier["lockAtTier"])
	parent.AddComponent(/datum/component/simple_teamchat/bloodling) //Give them the teamchat ability...
	update_mob()

/datum/component/bloodling/Destroy(force, silent)
	//Remove their access to the bloodling hivemind.
	var/datum/component/C = parent.GetComponent(/datum/component/simple_teamchat/bloodling)
	C.RemoveComponent()
	. = ..()


/datum/component/bloodling/proc/add_biomass(amount)
	biomass += amount
	if(biomass >= final_form_biomass)
		biomass = final_form_biomass //Todo: Final form!
	update_mob()

/datum/component/bloodling/proc/remove_biomass(amount)
	if(biomass < amount)
		return FALSE //Nope, can't use that ability :(
	biomass -= amount
	update_mob()

//Varedits need to use the wrapper method to ensure the ling's evo steps update properly.
/datum/component/bloodling/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, biomass))
		set_biomass(var_value)
		return
	. = ..()


/datum/component/bloodling/proc/set_biomass(amount)
	biomass = amount
	if(biomass >= final_form_biomass)
		biomass = final_form_biomass //Todo: Final form!
	update_mob()

/**
Method to update the bloodling's movespeed etc.
To be called whenever biomass is gained or lost.
*/
/datum/component/bloodling/proc/update_mob()
	var/speed = round(biomass / 100) //You move more slowly when you have more biomass...
	evolution_step = CLAMP(speed, 1, max_evolution)
	speed /= 2 //Shifting the movement slightly up so it can outrun better.
	speed = CLAMP(speed, 0.5, max_evolution)
	ling.remove_movespeed_modifier(MOVESPEED_ID_BLOODLING_BIOMASS, TRUE)
	ling.add_movespeed_modifier(MOVESPEED_ID_BLOODLING_BIOMASS, TRUE, 100, multiplicative_slowdown = speed, override = TRUE)
	if(istype(ling, /mob/living/simple_animal/bloodling))
		var/mob/living/simple_animal/bloodling/B = ling
		B.on_evolve(evolution_step) //Update baby's icon.
	if(evolution_step != last_evolution)
		//Cool effects time!
		new /obj/effect/gibspawner/xeno(get_turf(ling))
		//What's this? Your bloodling is evolving!
		ling.shake_animation(evolution_step)
		last_evolution = evolution_step
	//Handle abilities

	for(var/list/tier in ability_tiers)
		for(var/datum/action/bloodling/B in tier["abilities"])
			if(evolution_step >= tier["unlockTier"])
				if(tier["lockAtTier"] && evolution_step >= tier["lockAtTier"])
					B.Remove(ling)
					continue
				B.Grant(ling)
			else
				B.Remove(ling)

//Very similar to larva, for now.
/datum/hud/bloodling
	ui_style = 'icons/mob/screen_alien.dmi'

/datum/hud/bloodling/New(mob/owner)
	..()
	var/obj/screen/using

	healths = new /obj/screen/healths/alien()
	healths.hud = src
	infodisplay += healths

	pull_icon = new /obj/screen/pull()
	pull_icon.icon = 'icons/mob/screen_alien.dmi'
	pull_icon.update_icon()
	pull_icon.screen_loc = ui_above_movement
	pull_icon.hud = src
	hotkeybuttons += pull_icon

	using = new/obj/screen/language_menu
	using.screen_loc = ui_alien_language_menu
	using.hud = src
	static_inventory += using

//Abilities.

/datum/action/bloodling
	name = "Nothing"
	background_icon_state = "bg_changeling"
	icon_icon = 'nsv13/icons/mob/actions/actions_bloodling.dmi'
	var/biomass_cost = 0
	var/active = FALSE

/datum/action/bloodling/proc/can_use(mob/living/user)
	if(!user || !user.mind || user.stat != CONSCIOUS)
		return
	var/datum/component/bloodling/B = user.GetComponent(/datum/component/bloodling)
	if(B && B.biomass >= biomass_cost)
		B.remove_biomass(biomass_cost)
		return TRUE
	return FALSE

/datum/action/bloodling/Trigger()
	var/mob/user = owner
	action(user)

/datum/action/bloodling/proc/action(mob/living/user)
	if(!can_use(user))
		to_chat(user, "<span class='warning'>You don't have the requisite biomass to do that. </span>")
		return FALSE
	return TRUE

/datum/action/bloodling/hide
	name = "Hide"
	desc = "We can become harder to spot by shifting our chromatic resonance."
	button_icon_state = "hide"

/datum/action/bloodling/hide/Grant(mob/living/M)
	. = ..()
	M.pass_flags = PASSTABLE | PASSMOB | PASSDOOR //Tiny boi!
	M.mob_size = MOB_SIZE_TINY
	M.ventcrawler = TRUE

/datum/action/bloodling/hide/action(mob/living/user)
	if(!..())
		return

	if (user.layer != ABOVE_NORMAL_TURF_LAYER)
		user.layer = ABOVE_NORMAL_TURF_LAYER
		animate(user, alpha = 50, time = 2 SECONDS)
		user.visible_message("<span class='name'>[user] scurries to the ground!</span>", \
						"<span class='noticealien'>You are now hiding.</span>")
	else
		user.layer = MOB_LAYER
		animate(user, alpha = 255, time = 2 SECONDS)
		user.visible_message("[user] slowly peeks up from the ground...", \
					"<span class='noticealien'>You stop hiding.</span>")
	return 1

/datum/action/bloodling/hide/Remove(mob/living/M)
	M.layer = MOB_LAYER
	animate(M, alpha = 255, time = 2 SECONDS)
	M.visible_message("[M] slowly peeks up from the ground...", \
				"<span class='noticealien'>You stop hiding.</span>")
	M.mob_size = MOB_SIZE_HUMAN
	M.density = TRUE
	M.pass_flags = null //Now you're big.
	M.ventcrawler = FALSE
	. = ..()


/datum/action/bloodling/thermalvision
	name = "Thermal Vision"
	desc = "We can alter our vision to see heat signatures."
	button_icon_state = "augmented_eyesight"

/datum/action/bloodling/thermalvision/action(mob/living/user)
	if(!..())
		return FALSE

	if(!active)
		user.sight |= SEE_MOBS | SEE_OBJS | SEE_TURFS //Add sight flags to the user's eyes
		to_chat(user, "We adjust our eyes to sense prey through walls.")
		active = TRUE
		return
	user.sight ^= SEE_MOBS | SEE_OBJS | SEE_TURFS //Remove sight flags from the user's eyes
	active = FALSE
	to_chat(user, "We adjust our eyes to see as our prey do.")

/datum/action/bloodling/thermalvision/Remove(mob/M)
	M.sight ^= SEE_MOBS | SEE_OBJS | SEE_TURFS //Remove sight flags from the user's eyes
	active = FALSE
	. = ..()
