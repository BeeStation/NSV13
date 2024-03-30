//IT CAME....from outer space!

#define MOVESPEED_ID_BLOODLING_BIOMASS "bloodling_biomass_penalty"
#define BLOODLING_ASCENSION_MODIFIER "bloodling_ascension_penalty"

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
	speed = 0 //Rapid
	verb_say = "hisses"
	bubble_icon = "alien"
	deathsound = 'sound/voice/hiss6.ogg'
	deathmessage = "lets out a terrible screech as its life fades away..."
	attacktext = "glomps"
	attack_sound = 'sound/effects/blobattack.ogg'
	wander = FALSE
	//IT CAME...from outer space!
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	var/datum/component/bloodling/biomass = null

/mob/living/simple_animal/bloodling/update_health_hud(shown_health_amount)
	if(!client || !hud_used)
		return
	if(hud_used.healths)
		if(stat != DEAD)
			. = 1
			if(shown_health_amount == null)
				shown_health_amount = health
			if(shown_health_amount >= maxHealth)
				hud_used.healths.icon_state = "health0"
			else if(shown_health_amount > maxHealth*0.8)
				hud_used.healths.icon_state = "health1"
			else if(shown_health_amount > maxHealth*0.6)
				hud_used.healths.icon_state = "health2"
			else if(shown_health_amount > maxHealth*0.4)
				hud_used.healths.icon_state = "health3"
			else if(shown_health_amount > maxHealth*0.2)
				hud_used.healths.icon_state = "health4"
			else if(shown_health_amount > 0)
				hud_used.healths.icon_state = "health5"
			else
				hud_used.healths.icon_state = "health6"
		else
			hud_used.healths.icon_state = "health7"

/mob/living/simple_animal/bloodling/UnarmedAttack(atom/A)
	if(istype(A, /obj/structure/ladder))
		return A.attack_paw(src)
	if(istype(A, /obj/machinery/door) && mob_size > MOB_SIZE_TINY)
		return A.attack_alien(src)
	. = ..()

//Handle status updates.
/mob/living/Life(seconds, times_fired)
	. = ..()
	if(hud_used) //NSV13: Bloodling biomass storage.
		var/datum/component/bloodling/bloodling = GetComponent(/datum/component/bloodling)
		if(bloodling && hud_used)
			hud_used.lingchemdisplay.invisibility = FALSE
			hud_used.lingchemdisplay.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#dd66dd'>[round(bloodling.biomass)]</font></div>"

/mob/living/simple_animal/bloodling/Life(seconds, times_fired)
	. = ..()
	health = biomass.biomass
	maxHealth = biomass.final_form_biomass
	if(health <= 0 && stat != DEAD)
		death()

/mob/living/simple_animal/bloodling/lingcheck()
	return LINGHIVE_LING //We are the king of the lings.

/obj/effect/decal/cleanable/blood/bloodling
	name = "Otherwordly Goop"
	desc = "Just looking at it makes you feel sick."
	icon = 'nsv13/icons/mob/bloodling.dmi'
	icon_state = "tracks"

/mob/living/simple_animal/bloodling/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/waddling)
	biomass = GetComponent(/datum/component/bloodling)
	if(!biomass)
		biomass = AddComponent(/datum/component/bloodling)

/mob/living/simple_animal/bloodling/proc/on_evolve(step)
	icon_living = "evo[step]"
	icon_dead = "deadling"
	icon_state = "evo[step]"
	melee_damage = 2.5 * step
	obj_damage = 5 * step //When youre big, you need to be able to move around.
	if(step >= 4)
		environment_smash = ENVIRONMENT_SMASH_WALLS
	if(step >= 8)
		environment_smash = ENVIRONMENT_SMASH_RWALLS
/datum/component/bloodling
	var/biomass = 20 //How much biomass have we absorbed? We start off with a tiiiiny bit.
	var/final_form_biomass = 1500
	var/mob/living/ling = null
	var/evolution_step = 1 //What evolution level are we currently at?
	var/last_evolution = 1 //So we can animate the little critter when it grows up.
	var/max_evolution = 6
	var/can_blob_talk = FALSE //Allows the bloodling to intercept blob-comms. Can only be done after dominating a blob overmind.

	//Abilities.

	//Lay out the ability tiers here! Very simple, unlocks at unlockTier evo, locks at lockTier evo (if set). Code'll handle the rest. The abilities list is, you guessed it, all the abilities for that tier.
	var/list/unlock_tiers = list(
		list("unlockTier"=0, "lockAtTier"=4, "abilities"=list(/datum/action/bloodling/hide)),
		list("unlockTier"=0, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/thermalvision)),
		list("unlockTier"=0, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/absorb)),
		list("unlockTier"=0, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/call_remnant)),
		list("unlockTier"=2, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/infest)),
		list("unlockTier"=2, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/build)),
		list("unlockTier"=3, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/transfer_biomass)),
		list("unlockTier"=3, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/ground_pound)),
		list("unlockTier"=3, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/dissonant_shriek)),
		list("unlockTier"=4, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/give_life)),
		list("unlockTier"=4, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/whiplash)),
		list("unlockTier"=4, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/heal)),
		list("unlockTier"=6, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/ascend))
	)
	//Generated list of abilities, created at init.
	var/list/ability_tiers = list()

/datum/component/bloodling/Initialize()
	. = ..()
	if(!istype(parent, /mob))
		return COMPONENT_INCOMPATIBLE
	ling = parent
	for(var/list/tier in unlock_tiers)
		var/list/abilities = list()
		for(var/aType in tier["abilities"])
			abilities += new aType
		ability_tiers[++ability_tiers.len] =list("unlockTier"=tier["unlockTier"], "abilities"=abilities, "lockAtTier"=tier["lockAtTier"])
	RegisterSignal(parent, COMSIG_MOB_APPLY_DAMGE, PROC_REF(damage_react))
	update_mob()

/datum/component/bloodling/proc/damage_react(datum/source, amount)
	remove_biomass(amount)
	ling.visible_message("<span class='warning'>A chunk of [ling]'s flesh falls to the floor!</span>", "<span class='warning'>A piece of flesh weighing [amount/10] G is ripped from us!</span>")
	var/obj/effect/decal/cleanable/blood/bloodling/guts = new /obj/effect/decal/cleanable/blood/bloodling(get_turf(ling))
	guts.setDir(ling.dir)
	ling.shake_animation()
	if(prob(10))
		ling.emote("scream")

/datum/component/bloodling/Destroy(force, silent)
	. = ..()


/datum/component/bloodling/proc/add_biomass(amount)
	biomass += amount
	if(biomass >= final_form_biomass)
		biomass = final_form_biomass //Todo: Final form!
	to_chat(parent, "<span class='noticealien'>Our biomass has increased by [amount] units...</span>")
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
	var/speed = round(biomass / 50) //You move more slowly when you have more biomass...
	evolution_step = CLAMP(speed, 1, max_evolution)
	speed /= 2 //Shifting the movement slightly up so it can outrun better.
	speed = CLAMP(speed, 0.5, max_evolution)
	ling.remove_movespeed_modifier(MOVESPEED_ID_BLOODLING_BIOMASS, TRUE)
	//WORM STUCK, WORM STUCK PLEASE, I BEG OF YOU.
	if(!istype(ling, /mob/living/simple_animal/hostile/eldritch/armsy/prime/bloodling_ascended))
		ling.add_movespeed_modifier(MOVESPEED_ID_BLOODLING_BIOMASS, TRUE, 100, multiplicative_slowdown = speed, override = TRUE)
	SSticker.mode.check_win()
	if(istype(ling, /mob/living/simple_animal/bloodling))
		var/mob/living/simple_animal/bloodling/B = ling
		B.on_evolve(evolution_step) //Update baby's icon.
		B.health = biomass
		B.maxHealth = final_form_biomass
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

/**
Infestation! If given a human, it makes them a changeling thrall. If given any other kind of mob, it becomes a bloodling thrall.
*/
/datum/component/bloodling/proc/infest(mob/living/user)
	user.mind.enslave_mind_to_creator(ling)
	if(isovermind(user) || isAI(user) || HAS_TRAIT(user, TRAIT_MINDSHIELD))
		ling.get_overmap().relay_to_nearby('nsv13/sound/effects/bloodling_awaken.ogg', "<span class='userdanger'>Hideous images creep into your mind!</span>", FALSE)
	if(ishuman(user))
		user.mind.add_antag_datum(/datum/antagonist/changeling/bloodling_thrall) //Alright! you caught a human, THRALL TIME
	else
		user.mind.add_antag_datum(/datum/antagonist/bloodling/minion)

//Bloodling's very own mindslave!
/datum/antagonist/changeling/bloodling_thrall
	name = "Enthralled Changeling"
	roundend_category  = "Bloodling Thralls"
	antagpanel_category = "Bloodling Thralls"
	tips = "bloodling_thrall"
	//Gimped changeling powers! Notably missing major healing abilities...
	powers_override = list(
		/datum/action/changeling/absorbDNA,
		/datum/action/changeling/adrenaline,
		/datum/action/changeling/augmented_eyesight,
		/datum/action/changeling/biodegrade,
		/datum/action/changeling/refractive_chitin,
		/datum/action/changeling/digitalcamo,
		/datum/action/changeling/fleshmend,
		/datum/action/changeling/headcrab,
		/datum/action/changeling/humanform,
		/datum/action/changeling/lesserform,
		/datum/action/changeling/mimicvoice,
		/datum/action/changeling/weapon/arm_blade,
		/datum/action/changeling/weapon/tentacle,
		/datum/action/changeling/suit/organic_space_suit,
		/datum/action/changeling/suit/armor,
		/datum/action/changeling/panacea,
		/datum/action/changeling/strained_muscles,
		/datum/action/changeling/sting/transformation,
		/datum/action/changeling/sting/false_armblade,
		/datum/action/changeling/sting/extract_dna,
		/datum/action/changeling/sting/mute,
		/datum/action/changeling/sting/blind,
		/datum/action/changeling/sting/LSD,
		/datum/action/changeling/sting/cryo,
		/datum/action/changeling/transform
	)
	geneticpoints = 5 //Very gimped abilities.
	var/antag_hud_type = ANTAG_HUD_BLOODLING
	var/antag_hud_name = "bloodling_thrall"

/datum/antagonist/bloodling
	name = "Bloodling Master"
	roundend_category  = "Bloodling Thralls"
	antagpanel_category = "Bloodling Thralls"
	give_objectives = TRUE
	tips = "bloodling"
	var/antag_hud_type = ANTAG_HUD_BLOODLING
	var/antag_hud_name = "bloodling_thrall"
	var/component_type = /datum/component/bloodling
	banning_key = ROLE_BLOODLING

/datum/antagonist/bloodling/greet()
	to_chat(owner.current, "<span class='boldannounce'>We are the master!</span>")
	to_chat(owner.current, "<span class='boldannounce'>We latched onto this vessel as it was travelling through space, it can sustain us.</span>")
	to_chat(owner.current, "<span class='boldannounce'>Give the gift of life to this ship, and consume its available biomass by any means necessary...</span>")
	to_chat(owner.current, "<b>Your objectives are:</b>")
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ling_aler.ogg', 100, FALSE, pressure_affected = FALSE)
	owner.announce_objectives()

/datum/antagonist/bloodling/proc/forge_objectives()
	var/datum/objective/bloodling_ascend/ascend = new
	ascend.owner = owner
	objectives += ascend
	log_objective(owner, ascend.explanation_text)

/datum/antagonist/bloodling/minion
	name = "Bloodling Minion"
	component_type = /datum/component/bloodling/lesser
	tips = 'html/antagtips/bloodling_thrall.html'

/datum/antagonist/bloodling/minion/forge_objectives()
	var/datum/objective/bloodling_serve/serve = new
	serve.owner = owner
	objectives += serve
	log_objective(owner, serve.explanation_text)

/datum/antagonist/bloodling/minion/greet()
	to_chat(owner.current, "<span class='boldannounce'>You are a bloodling minion!</span>")
	to_chat(owner.current, "<span class='boldannounce'>Although you exist at a lower level of evolution than the other thralls, you still serve the master faithfully.</span>")
	to_chat(owner.current, "<span class='boldannounce'>Help the master ascend to its highest plane of existence by bringing it loyal subjects.</span>")
	to_chat(owner.current, "<b>Your objectives are:</b>")
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ling_aler.ogg', 100, FALSE, pressure_affected = FALSE)
	owner.announce_objectives()

/datum/antagonist/bloodling/on_gain()
	if(give_objectives)
		forge_objectives()
	owner.current.grant_all_languages(FALSE, FALSE, TRUE)	//Allows the bloodlings to communicate with _anything_ they may want to absorb ;)
	. = ..()

/datum/antagonist/bloodling/apply_innate_effects(mob/living/mob_override)
	. = ..()
	if(!owner.current.GetComponent(component_type))
		owner.current.AddComponent(component_type)
	owner.current.AddComponent(/datum/component/simple_teamchat/bloodling) //Give them the teamchat ability...
	add_antag_hud(antag_hud_type, antag_hud_name, owner.current)

/datum/antagonist/bloodling/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/datum/component/C = owner.current.GetComponent(component_type)
	if(C)
		C.RemoveComponent()
	var/datum/component/simple_teamchat/bloodling/B = owner.current.GetComponent(/datum/component/simple_teamchat/bloodling)
	if(B)
		B.RemoveComponent()
	remove_antag_hud(antag_hud_type, owner.current)

/datum/antagonist/changeling/bloodling_thrall/update_changeling_icons_added()
	var/datum/atom_hud/antag/hud = GLOB.huds[antag_hud_type]
	hud.join_hud(owner.current)
	set_antag_hud(owner.current, antag_hud_name)

/datum/antagonist/changeling/bloodling_thrall/update_changeling_icons_removed()
	var/datum/atom_hud/antag/hud = GLOB.huds[antag_hud_type]
	hud.leave_hud(owner.current)
	set_antag_hud(owner.current, null)

/datum/objective/bloodling_serve
	name = "Serve the entity"
	explanation_text = "Serve the entity at all costs. This objective overrides any others."
	completed = TRUE //This is hard to track.

/datum/objective/bloodling_ascend
	name = "Ascend"
	explanation_text = "Ascend to your final form."
	var/list/summon_spots = list() //Where can we ascend?

/datum/objective/bloodling_ascend/check_completion()
	. = ..()
	if(owner)
		return (owner.current && owner.current.health > 0 && istype(owner.current, /mob/living/simple_animal/hostile/eldritch/armsy/prime/bloodling_ascended))

/datum/objective/bloodling_ascend/New()
	..()
	var/sanity = 0
	while(summon_spots.len < SUMMON_POSSIBILITIES && sanity < 100)
		var/area/summon = pick(GLOB.sortedAreas - summon_spots)
		if(summon && is_station_level(summon.z) && (summon & VALID_TERRITORY))
			summon_spots += summon
		sanity++
	update_explanation_text()

/datum/objective/bloodling_ascend/update_explanation_text()
	explanation_text = "Ascend to your final form. <b>We can only ascend in [english_list(summon_spots)] - where the consciousness grid is naturally susceptible to our influence.</b>"

/datum/antagonist/changeling/bloodling_thrall/forge_objectives()
	var/datum/objective/bloodling_serve/serve = new
	serve.owner = owner
	objectives += serve
	log_objective(owner, serve.explanation_text)
	. = ..()

/datum/antagonist/changeling/bloodling_thrall/greet()
	to_chat(owner.current, "<span class='boldannounce'>You are reborn as [changelingID]! We remade you in our image.</span>")
	to_chat(owner.current, "<span class='boldannounce'>You must serve the master above all else, failure to do so may lead to our generous gift to you being revoked, along with your life...</span>")
	to_chat(owner.current, "<b>Carry out the master's will above else. Your objectives are:</b>")
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ling_aler.ogg', 100, FALSE, pressure_affected = FALSE)
	owner.announce_objectives()

/datum/antagonist/changeling/bloodling_thrall/apply_innate_effects()
	. = ..()
	//For admin spawned thralls...
	if(!owner.current.GetComponent(/datum/component/simple_teamchat/bloodling))
		owner.current.AddComponent(/datum/component/simple_teamchat/bloodling) //Give them the teamchat ability...

/datum/antagonist/changeling/bloodling_thrall/remove_innate_effects(mob/living/mob_override)
	. = ..()
	//For admin spawned thralls etc...
	var/datum/component/simple_teamchat/bloodling/B = owner.current.GetComponent(/datum/component/simple_teamchat/bloodling)
	if(B)
		B.RemoveComponent()

//Very similar to larva, for now.
/datum/hud/bloodling
	ui_style = 'icons/mob/screen_alien.dmi'

/datum/hud/bloodling/New(mob/owner)
	..()
	var/atom/movable/screen/using

	healths = new /atom/movable/screen/healths/alien()
	healths.hud = src
	infodisplay += healths

	pull_icon = new /atom/movable/screen/pull()
	pull_icon.icon = 'icons/mob/screen_alien.dmi'
	pull_icon.update_icon()
	pull_icon.screen_loc = ui_above_movement
	pull_icon.hud = src
	hotkeybuttons += pull_icon

	using = new/atom/movable/screen/language_menu
	using.screen_loc = ui_alien_language_menu
	using.hud = src
	static_inventory += using

	lingchemdisplay = new /atom/movable/screen/ling/chems()
	lingchemdisplay.hud = src
	infodisplay += lingchemdisplay

//Abilities.

/datum/action/bloodling
	name = "Nothing"
	background_icon_state = "bg_changeling"
	icon_icon = 'nsv13/icons/mob/actions/actions_bloodling.dmi'
	var/biomass_cost = 0
	var/active = FALSE
	var/timer_icon = 'icons/effects/cooldown.dmi'
	var/timer_icon_state_active = "second"
	var/mutable_appearance/timer_overlay

/datum/action/bloodling/proc/add_cooldown(time)
	if(!button || has_cooldown_timer)
		return
	has_cooldown_timer = TRUE
	timer_overlay = mutable_appearance(timer_icon, timer_icon_state_active)
	timer_overlay.alpha = 180
	button.add_overlay(timer_overlay)
	addtimer(CALLBACK(src, PROC_REF(remove_cooldown)), time)

/datum/action/bloodling/proc/remove_cooldown()
	has_cooldown_timer = FALSE
	button.cut_overlay(timer_overlay)
	button.update_icon()

/datum/action/bloodling/proc/can_use(mob/living/user)
	if(!user || !user.mind || user.stat != CONSCIOUS || has_cooldown_timer)
		to_chat(user, "<span class='warning'>You are unable to do that right now.</span>")
		return FALSE
	var/datum/component/bloodling/B = user.GetComponent(/datum/component/bloodling)
	if(B && B.biomass >= biomass_cost)
		B.remove_biomass(biomass_cost)
		return TRUE
	to_chat(user, "<span class='warning'>You don't have the requisite biomass to do that. </span>")
	return FALSE

/datum/action/bloodling/proc/refund_biomass(mob/living/user, amount)
	var/datum/component/bloodling/B = user.GetComponent(/datum/component/bloodling)
	to_chat(user, "<span class='aliennotice'>We have regained [amount] biomass.</span>")
	B.add_biomass(amount)

/datum/action/bloodling/Trigger()
	var/mob/user = owner
	action(user)

/datum/action/bloodling/proc/action(mob/living/user)
	if(!can_use(user))
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
	M.mob_size = MOB_SIZE_HUMAN
	M.density = TRUE
	M.pass_flags = null //Now you're big.
	M.ventcrawler = FALSE
	. = ..()

/datum/action/bloodling/thermalvision
	name = "Enhanced Vision"
	desc = "We can alter our vision to see heat signatures."
	button_icon_state = "augmented_eyesight"

/datum/action/bloodling/thermalvision/action(mob/living/user)
	if(!..() || istype(user, /mob/living/silicon)) //Okay no this was TOO BASED to let AIs use
		return FALSE

	if(!active)
		user.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		user.update_sight()
		user.sight |= SEE_MOBS | SEE_OBJS | SEE_TURFS //Add sight flags to the user's eyes
		to_chat(user, "We adjust our eyes to see beyond the darkness.")
		active = TRUE
		return
	user.lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
	user.update_sight()
	user.sight ^= SEE_MOBS | SEE_OBJS | SEE_TURFS //Remove sight flags from the user's eyes
	active = FALSE
	to_chat(user, "We adjust our eyes to see as our prey do.")

/datum/action/bloodling/thermalvision/Remove(mob/M)
	M.sight ^= SEE_MOBS | SEE_OBJS | SEE_TURFS //Remove sight flags from the user's eyes
	active = FALSE
	M.lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
	M.update_sight()
	. = ..()

//Remnant

/obj/effect/temp_visual/bloodling_remnant
	name = "fleshy remnants"
	icon = 'nsv13/icons/mob/bloodling.dmi'
	icon_state = "remnant"
	duration = 2 MINUTES //Remnants persist for a while, but boi needs to hoover them.
	var/biomass_amount = 50

/obj/effect/temp_visual/bloodling_remnant/Initialize(mapload, biomass_amount)
	. = ..()
	if(biomass_amount)
		src.biomass_amount = biomass_amount

/datum/action/bloodling/call_remnant
	name = "Call Forth Remnant"
	desc = "We call forth nearby remnant, causing it to fly to us."
	button_icon_state = "remnant"
	biomass_cost = 5 //Best be sure you found one...
	var/base_range = 5

/datum/action/bloodling/call_remnant/action(mob/living/user)
	if(!..())
		return FALSE
	var/datum/component/bloodling/B = user.GetComponent(/datum/component/bloodling)
	var/range = base_range * B.last_evolution //Bigger boys suck better
	var/foundRemnant = FALSE //Refund them if they find no remnant.
	for(var/obj/effect/temp_visual/bloodling_remnant/BR in view(user, range))
		if(istype(BR))
			var/required_pixel_x = (user.x - BR.x) * 32
			var/required_pixel_y = (user.y - BR.y) * 32
			BR.shake_animation()
			BR.visible_message("<span class='warning'>[BR] starts to fly off to the [dir2text(get_dir(BR, user))]!</span>")
			animate(BR, pixel_x = required_pixel_x, time = 3 SECONDS)
			animate(BR, pixel_y = required_pixel_y, time = 3 SECONDS)
			//animate(BR, alpha = 0, time = 3 SECONDS)
			QDEL_IN(BR, 3 SECONDS)
			B.add_biomass(BR.biomass_amount)
			playsound(get_turf(BR), 'sound/magic/enter_blood.ogg', 100, 1, -1)
			foundRemnant = TRUE


	if(!foundRemnant)
		to_chat(user, "<span class='notice'>We could not find any remnant to call forth.</span>")
	else
		add_cooldown(5 SECONDS)
//Succ
/datum/looping_sound/bloodling_absorb
	mid_sounds = list('nsv13/sound/effects/bloodling_absorb.ogg')
	mid_length = 2.85 SECONDS
	volume = 100

/datum/action/bloodling/absorb
	name = "Absorb Creature"
	desc = "We absorb a creature using our tendrils, claiming its biomass for ourselves."
	button_icon_state = "absorb"
	biomass_cost = 0
	var/absorb_time = 10 SECONDS //You have to pin them down for a while to get them...
	var/datum/looping_sound/bloodling_absorb/soundloop = null

/datum/action/bloodling/absorb/Grant(mob/M)
	. = ..()
	soundloop?.stop(M)
	soundloop = new(M, FALSE)
	soundloop.stop(M)

/datum/action/bloodling/absorb/Remove(mob/M)
	soundloop.stop(M)
	. = ..()

/datum/action/bloodling/absorb/action(mob/living/user)
	if(!..())
		return
	var/list/mobs = list()
	for(var/mob/living/M in view(user, 1))
		if(M == user || issilicon(M) || !isliving(M) || M.invisibility > 0 || !M.alpha || is_bloodling(M))
			continue
		mobs += M
	var/mob/living/M = input(user, "Who shall we absorb?", "[src]", null) as null|anything in mobs
	if(!M)
		return FALSE
	var/datum/component/bloodling/B = user.GetComponent(/datum/component/bloodling)
	var/absorb_cooldown = 40 SECONDS - B.last_evolution SECONDS //Bigger boys absorb better
	add_cooldown(absorb_cooldown)
	soundloop.start(user)

	//You lose your cloak..
	var/datum/action/bloodling/hide/cloak = (locate(/datum/action/bloodling/hide) in user.actions)
	if(cloak)
		cloak.add_cooldown(10 SECONDS)
	user.layer = MOB_LAYER
	animate(user, alpha = 255, time = 2 SECONDS)

	var/datum/beam/current_beam = new(user,M,time=absorb_time,beam_icon_state="tentacle",btype=/obj/effect/ebeam/blood)
	INVOKE_ASYNC(current_beam, TYPE_PROC_REF(/datum/beam, Start))
	M.visible_message("<span class='warning'>[user] plunges a tendril deep into [M]'s carotid artery!</span>", "<span class='userdanger'>You feel a stabbing pain in your carotid artery!</span>")
	M.take_overall_damage(0, 0, 50) //OUCH!
	M.emote("scream")
	playsound(M, 'nsv13/sound/effects/bloodling_squelch.ogg', 70, FALSE)
	if(do_after(user, absorb_time, target=M))
		M.visible_message("<span class='warning'>[user] retracts their tendril!</span>", "<span class='userdanger'>YOU FEEL SLIGHTLY UNWELL.</span>")
		var/gains = M.mob_size*50
		gains = CLAMP(gains, 1, gains)
		new /obj/effect/temp_visual/bloodling_remnant(get_turf(M), gains)
		M.gib() //Sorry man :(
		soundloop.stop(user)
		return TRUE
	else
		M.visible_message("<span class='warning'>[user] quickly retracts their tendril!</span>", "<span class='userdanger'>You feel something slip out of your neck!</span>")
		qdel(current_beam)
		soundloop.stop(user)

/datum/action/bloodling/infest
	name = "Infest Creature"
	desc = "We infest a creature with our consciousness, forcing its servitude and upgrading its physical form with some of our biomass."
	button_icon_state = "infest"
	biomass_cost = 75
	var/absorb_time = 10 SECONDS//30 SECONDS //This is a lengthy process, and will require assistance to complete.
	var/datum/looping_sound/bloodling_absorb/soundloop = null

/datum/component/bloodling/lesser
	//Enthralled creatures get a lesser arsenal, but a powerful one still.
	unlock_tiers = list(
		list("unlockTier"=0, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/thermalvision)),
		list("unlockTier"=0, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/absorb)),
		list("unlockTier"=0, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/call_remnant)),
		list("unlockTier"=0, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/transfer_biomass)),
		list("unlockTier"=0, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/whiplash)),
		list("unlockTier"=0, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/ground_pound)),
	)
	final_form_biomass = 200 //An inferior lifeform, but still able to gather biomass.

/datum/action/bloodling/infest/Grant(mob/M)
	. = ..()
	soundloop = new(M, FALSE)
	soundloop.stop(M)

/datum/action/bloodling/infest/Remove(mob/M)
	soundloop?.stop(M)
	. = ..()

//Handler to allow the bloodling to absorb other antags.
//This code could likely be improved, though I'm going to leave it for now.
/datum/action/bloodling/infest/proc/ask_special_absorb(mob/living/user, atom/movable/special_target)
	//WARNING: EXTREMELY BASED
	var/atom/physical_target = null
	var/mob/absorb_mob = null
	var/datum/component/bloodling/B = user.GetComponent(/datum/component/bloodling)
	if(!B)
		return FALSE
	var/can_absorb_normally = TRUE //Have we found a use case where this thing could be absorbed normally?
	var/new_absorb_time = absorb_time * 3
	//Handle your pre-req checks here, then set the targets accordingly.
	if(isAI(special_target))
		var/mob/living/silicon/ai/ai = special_target
		if(!ai.mind)
			to_chat(user, "<span class='warning'>We can sense the remnants of a powerful entity here, but its mind is no longer here.</span>")
			return FALSE
		if(B.last_evolution < 4) //You have to be STRONG to do this.
			to_chat(user, "<span class='warning'>We can sense the essence of a powerful entity inhabiting [special_target], but we are not yet strong enough to infest it.</span>")
			return FALSE
		absorb_mob = ai
		physical_target = ai

	if(istype(special_target, /obj/structure/blob)) //I'm probably gonna fucking regret this.
		var/obj/structure/blob/blob = special_target
		if(!blob.overmind)
			to_chat(user, "<span class='warning'>We can sense the remnants of a powerful entity here, but its mind is no longer here.</span>")
			return FALSE
		if(B.last_evolution < 4) //You have to be STRONG to do this.
			to_chat(user, "<span class='warning'>We can sense the essence of a powerful entity inhabiting [special_target], but we are not yet strong enough to infest it.</span>")
			return FALSE
		absorb_mob = blob.overmind
		physical_target = blob

	if(HAS_TRAIT(special_target, TRAIT_MINDSHIELD))
		to_chat(user, "<span class='warning'>This one tries to resist our influence with mental walls... But it cannot resist forever.</span>")
		physical_target = special_target
		absorb_mob = special_target

	if(absorb_mob && physical_target)
		to_chat(user, "<span class='userdanger'>WE HAVE DETECTED A POWERFUL ENTITY'S PRESENCE HERE...</span>")
		can_absorb_normally = FALSE
		if(alert(user, "Absorb the powerful entity (LOUD)?",name,"Yes","No") == "Yes")
			to_chat(absorb_mob, "<span class='userdanger'>A strange consciousness starts to intertwine with yours...</span>")
			var/absorb_cooldown = 1 MINUTES - B.last_evolution SECONDS //It'll take everything you have to pull this off...
			soundloop.start(user)
			var/datum/beam/current_beam = new(user,physical_target,time=new_absorb_time,beam_icon_state="tentacle",btype=/obj/effect/ebeam/blood)
			INVOKE_ASYNC(current_beam, TYPE_PROC_REF(/datum/beam, Start))
			add_cooldown(absorb_cooldown*2)
			user.emote("scream")
			if(do_after(user, new_absorb_time, target=physical_target))
				user.visible_message("<span class='warning'>[user] retracts their tendril!</span>", "<span class='userdanger'>That consciousness was strong, but not strong enough.</span>")
				to_chat(user, "<span class='aliennotice'>We have infested the creature. If they do not do our bidding, we may absorb them for biomass.</span>")
				to_chat(absorb_mob, "<span class='userdanger'>Your mind has been overtaken by [user]! You must serve them at all costs...</span>")
				B.infest(absorb_mob)
			else
				user.visible_message("<span class='warning'>[user] quickly retracts their tendril!</span>", "<span class='userdanger'>Our domination of the entity was interrupted!</span>")
				qdel(current_beam)
				refund_biomass(user, biomass_cost/1.5) //You get most of your biomass back if interrupted, but not _all_
			soundloop.stop(user)
			return TRUE
	return !(can_absorb_normally) //So you can't bypass this check..

/datum/action/bloodling/infest/action(mob/living/user)
	if(!..())
		return

	var/list/mobs = list()
	for(var/atom/movable/M in view(user, 2))
		if(ask_special_absorb(user, M))
			return TRUE //Oh god, he's doing it.
		if(M == user || !isliving(M) || M.invisibility > 0 || !M.alpha || is_bloodling(M))
			continue
		mobs += M
	var/mob/living/M = input(user, "Who shall we infest?", "[src]", null) as null|anything in mobs
	if(!M || !M.mind || is_bloodling(M))
		to_chat(user, "<span class='warning'>That creature lacks intelligence, we should absorb it instead. </span>")
		refund_biomass(user, biomass_cost)
		return FALSE
	var/datum/component/bloodling/B = user.GetComponent(/datum/component/bloodling)
	var/absorb_cooldown = 20 SECONDS - B.last_evolution SECONDS //Bigger boys absorb better
	soundloop.start(user)
	var/datum/beam/current_beam = new(user,M,time=absorb_time,beam_icon_state="tentacle",btype=/obj/effect/ebeam/blood)
	INVOKE_ASYNC(current_beam, TYPE_PROC_REF(/datum/beam, Start))
	M.visible_message("<span class='warning'>[user] plunges a tendril deep into [M]'s carotid artery!</span>", "<span class='userdanger'>You feel a stabbing pain in your carotid artery!</span>")
	add_cooldown(absorb_cooldown)
	M.emote("scream")
	playsound(M, 'nsv13/sound/effects/bloodling_squelch.ogg', 70, FALSE)
	if(do_after(user, absorb_time, target=M))
		M.visible_message("<span class='warning'>[user] retracts their tendril!</span>", "<span class='userdanger'>YOU FEEL SLIGHTLY UNWELL.</span>")
		to_chat(user, "<span class='aliennotice'>We have infested the creature. If they do not do our bidding, we may absorb them for biomass.</span>")
		B.infest(M)
	else
		M.visible_message("<span class='warning'>[user] quickly retracts their tendril!</span>", "<span class='userdanger'>You feel something slip out of your neck!</span>")
		qdel(current_beam)
		refund_biomass(user, biomass_cost/1.5) //You get most of your biomass back if interrupted, but not _all_
	soundloop.stop(user)

/*
Allows the bloodling to give intelligence to lower lifeforms, and enthrall them as lesser bloodlings.
Depending on what creature the entity gives life to, this can be EXTREMELY strong, or practically useless. If it somehow manages to enthrall a blob..god fucking help you.
*/
/datum/action/bloodling/give_life
	name = "Give Life"
	desc = "We use some of our essence to bestow the greatest gift of all, lesser creatures will become our slaves. When used on mindless humans, it will also enthrall them."
	button_icon_state = "give_life"
	biomass_cost = 75

/datum/action/bloodling/give_life/action(mob/living/user)
	if(!..())
		return

	var/list/mobs = list()
	for(var/atom/movable/M in view(user, 2))
		if(M == user || !isliving(M) || M.invisibility > 0 || !M.alpha)
			continue
		mobs += M
	var/mob/living/M = input(user, "What creature shall we bestow life upon?", "[src]", null) as null|anything in mobs
	if(!M || M.mind)
		to_chat(user, "<span class='warning'>That creature already has an intelligence, we should infest it instead...</span>")
		refund_biomass(user, biomass_cost)
		return FALSE

	var/list/candidates = pollCandidatesForMob("Do you want to play as a bloodling minion?", ROLE_SENTIENCE, null, ROLE_SENTIENCE, 50, M) // see poll_ignore.dm
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		var/datum/component/bloodling/B = user.GetComponent(/datum/component/bloodling)
		M.key = C.key
		if(istype(M, /mob/living/simple_animal))
			var/mob/living/simple_animal/SM = M
			SM.sentience_act()
		to_chat(M, "<span class='warning'>All at once it makes sense: you know what you are and who you are! Self awareness is yours!</span>")
		to_chat(M, "<span class='userdanger'>You are grateful to be self aware and owe [user.real_name] a great debt. Serve [user.real_name], and assist [user.p_them()] in completing [user.p_their()] goals at any cost.</span>")
		if(M.flags_1 & HOLOGRAM_1) //Check to see if it's a holodeck creature
			to_chat(M, "<span class='userdanger'>You also become depressingly aware that you are not a real creature, but instead a holoform. Your existence is limited to the parameters of the holodeck.</span>")
		M.copy_languages(user)
		B.infest(M) //Free infest!
	else
		to_chat(user, "<span class='notice'>[M] looks interested for a moment, but then looks back down. Maybe you should try again later.</span>")
		refund_biomass(user, biomass_cost) //Rip, it didn't work
		return FALSE

/datum/action/bloodling/transfer_biomass
	name = "Transfer Biomass"
	desc = "We can transfer some of our biomass to a minion."
	button_icon_state = "transfer"
	biomass_cost = 0

/datum/action/bloodling/transfer_biomass/action(mob/living/user)
	if(!..())
		return

	var/list/mobs = list()
	for(var/atom/movable/M in view(user, 2))
		if(M == user || !isliving(M) || M.invisibility > 0 || !M.alpha || !is_bloodling(M))
			continue
		mobs += M
	var/mob/living/M = input(user, "To whom shall we transfer biomass?", "[src]", null) as null|anything in mobs
	if(!M || !M.mind)
		to_chat(user, "<span class='warning'>That creature lacks intelligence, we should reconsider transfering biomass.</span>")
		return FALSE
	var/amount = input(user, "How much biomass do you want to transfer?.","Biomass") as num|null
	if(amount == null)
		return FALSE

	var/datum/component/bloodling/ours = user.GetComponent(/datum/component/bloodling)
	var/datum/component/bloodling/theirs = M.GetComponent(/datum/component/bloodling)

	amount = CLAMP(amount, 0, ours.biomass - 10) //Can't transfer what you don't own...
	if(amount <= 0)
		to_chat(user, "<span class='warning'>We do not have enough biomass to transfer!</span>")
		return
	ours.remove_biomass(amount)
	theirs.add_biomass(amount)

//Ability: ground pound. Simple AOE stun, low biomass, long cooldown.
/datum/action/bloodling/ground_pound
	name = "Ground Slam"
	desc = "We jump into the air and slam into the ground at high velocity, stunning nearby victims."
	button_icon_state = "ground_pound"
	biomass_cost = 0
	var/base_stun_time = 3.5 SECONDS
	var/cooldown = 50 SECONDS

/obj/effect/temp_visual/bloodling_target
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "sniper_zoom"
	layer = BELOW_MOB_LAYER
	light_range = 2
	duration = 1 SECONDS

/datum/action/bloodling/ground_pound/action(mob/living/user)
	if(!..())
		return
	add_cooldown(cooldown)
	user.visible_message("<span class='warning'>[user] leaps up high into the air!</span>")
	user.Paralyze(1 SECONDS)
	animate(user, pixel_y = 100, 1 SECONDS)
	sleep(1 SECONDS)
	animate(user, pixel_y = 0, 1 SECONDS)
	user.shake_animation()
	user.visible_message("<span class='warning'>[user] slams into the ground!</span>")
	playsound(user, 'sound/effects/gravhit.ogg', 100, TRUE)
	var/datum/component/bloodling/B = user.GetComponent(/datum/component/bloodling)
	var/stun_time = base_stun_time + max(B.last_evolution / 2, 0) SECONDS //Bigger bloodling = hit harder
	for(var/atom/movable/AM in view(user, 3))
		if(AM == src)
			continue
		AM.shake_animation(10)
		if(isstructure(AM))
			var/obj/structure/XXX = AM
			XXX.take_damage(2.5 * B.last_evolution) //Big boys slam harder
		else if(isliving(AM))
			var/mob/living/L = AM
			L.Paralyze(stun_time)

//The COOLER stun
/datum/action/bloodling/whiplash
	name = "Tentacle Whip"
	desc = "We lash out our tentacles to stun nearby enemies."
	button_icon_state = "tailsweep"
	biomass_cost = 25
	var/base_stun_time = 1.5 SECONDS
	var/cooldown = 40 SECONDS

/datum/action/bloodling/whiplash/action(mob/living/user)
	if(!..())
		return

	user.visible_message("<span class='warning'>[user] lashes out with a legion of tentacles!</span>")
	user.shake_animation()
	playsound(user, 'sound/magic/tail_swing.ogg', 100, TRUE)
	INVOKE_ASYNC(src, PROC_REF(summon_tentacles), user)
	add_cooldown(cooldown)

/datum/action/bloodling/whiplash/proc/summon_tentacles(mob/living/user)
	var/datum/component/bloodling/B = user.GetComponent(/datum/component/bloodling)
	var/stun_time = base_stun_time + max(B.last_evolution / 2, 0) SECONDS //Bigger bloodling = hit harder
	for(var/mob/living/M in view(user, 5))
		if(M == user)
			continue
		var/datum/beam/current_beam = new(user,M,time=0.75 SECONDS,beam_icon_state="tentacle",btype=/obj/effect/ebeam/blood)
		INVOKE_ASYNC(current_beam, TYPE_PROC_REF(/datum/beam, Start))
		animate(M, pixel_y = 70, 0.25 SECONDS)
		playsound(M, 'nsv13/sound/effects/bloodling_squelch.ogg', 70, FALSE)
		M.visible_message("<span class='warning'>A tentacle grabs hold of [M]!</span>", "<span class='userdanger'>A tentacle sweeps you high into the air!</span>")
		sleep(2.5)
		animate(M, pixel_y = 0, 5)
		M.visible_message("<span class='warning'>[M] is slammed down into the floor!</span>", "<span class='userdanger'>[user] slams you into the floor!</span>")
		playsound(user, 'sound/effects/gravhit.ogg', 100, TRUE)
		var/turf/throwtarget = get_edge_target_turf(user, get_dir(user, get_step_away(M, user)))
		var/distfromcaster = get_dist(user, M)
		M.Paralyze(stun_time)
		M.adjustBruteLoss(stun_time / 10)
		M.safe_throw_at(throwtarget, ((CLAMP((5 - (CLAMP(distfromcaster - 2, 0, distfromcaster))), 3, 5))), 1,user, force = MOVE_FORCE_EXTREMELY_STRONG)//So stuff gets tossed around at the same time.

/mob/living/simple_animal/bloodling_minion
	name = "necrotic harvester"
	desc = "A fleshy creature with jagged arms."
	icon = 'nsv13/icons/mob/bloodling.dmi'
	icon_living = "harvester"
	icon_dead = "harvester_dead"
	icon_state = "harvester"
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_HUMAN
	density = FALSE
	hud_type = /datum/hud/bloodling
	health = 100
	maxHealth = 100
	speed = 0 //Rapid
	melee_damage = 8
	obj_damage = 15
	attacktext = "glomps"
	attack_sound = 'sound/effects/blobattack.ogg'
	wander = FALSE
	verb_say = "hisses"
	bubble_icon = "alien"
	deathsound = 'sound/voice/hiss6.ogg'
	deathmessage = "lets out a terrible screech as its life fades away..."
	attacktext = "glomps"
	//IT CAME...from outer space!
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	ventcrawler = TRUE

/mob/living/simple_animal/bloodling_minion/Initialize(mapload)
	. = ..()
	name = "[name] ([rand(0,1000)])"

/mob/living/simple_animal/bloodling_minion/UnarmedAttack(atom/A)
	if(istype(A, /obj/structure/ladder))
		return A.attack_paw(src)
	if(istype(A, /obj/machinery/door) && mob_size > MOB_SIZE_TINY)
		return A.attack_alien(src)
	return ..()

/mob/living/simple_animal/bloodling_minion/tank
	name = "wall of flesh"
	desc = "A massive hulk of flesh."
	icon = 'nsv13/icons/mob/bloodling.dmi'
	icon_living = "tank"
	icon_dead = "tank_dead"
	icon_state = "tank"
	pass_flags = null
	mob_size = MOB_SIZE_LARGE
	density = TRUE
	health = 200
	maxHealth = 200
	speed = 2 //bloody 'ell what an absolute unit mate
	ventcrawler = FALSE
	melee_damage = 12
	obj_damage = 15

/mob/living/simple_animal/bloodling_minion/Life(seconds, times_fired)
	. = ..()
	var/datum/component/bloodling/biomass = GetComponent(/datum/component/bloodling)
	health = biomass.biomass
	maxHealth = biomass.final_form_biomass
	if(health <= 0 && stat != DEAD)
		death()

/obj/structure/ratwarren
	name = "Rat Warren"
	desc = "A festering rat's nest, crawling with life."
	icon = 'nsv13/icons/mob/bloodling.dmi'
	icon_state = "ratwarren"
	obj_integrity = 100
	max_integrity = 100
	density = FALSE
	anchored = TRUE
	layer = CATWALK_LAYER
	var/rat_spawn_delay = 2 MINUTES
	var/next_rat_spawn = 0

/obj/structure/ratwarren/Initialize(mapload)
	. = ..()
	next_rat_spawn = world.time + rat_spawn_delay/2 //First one's quicker.
	START_PROCESSING(SSobj, src)

/obj/structure/ratwarren/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()

/obj/structure/ratwarren/process()
	if(world.time >= next_rat_spawn)
		next_rat_spawn = world.time + rat_spawn_delay
		new /mob/living/simple_animal/mouse(get_turf(src))

/datum/action/bloodling/build
	name = "Build"
	desc = "We use some of our essence to construct other entities."
	button_icon_state = "build"
	biomass_cost = 0

/datum/action/bloodling/build/action(mob/living/user)
	if(!..())
		return

	var/list/options = list()
	for(var/option in list("ratwarren", "harvester", "tank"))
		options[option] = image(icon = 'nsv13/icons/mob/bloodling.dmi', icon_state = option)
	var/choice = show_radial_menu(user, user, options)
	var/cost = 0
	var/buildPath = null
	switch(choice)
		if("ratwarren")
			cost = 40
			buildPath = /obj/structure/ratwarren
		if("harvester")
			cost = 20
			buildPath = /mob/living/simple_animal/bloodling_minion
		if("tank")
			cost = 30
			buildPath = /mob/living/simple_animal/bloodling_minion/tank

	var/datum/component/bloodling/B = user.GetComponent(/datum/component/bloodling)
	if(!B || !buildPath)
		return
	if(alert(user, "Build [choice]? This will cost [cost] biomass.",name,"Yes","No") == "Yes")
		if(B.biomass <= cost)
			to_chat(user, "<span class='warning'>We need [cost - B.biomass] more biomass to build [choice]!</span>")
			return
		add_cooldown(10 SECONDS)
		user.shake_animation()
		B.remove_biomass(cost)
		to_chat(user, "<span class='warning'>We have created a new shell... It will need life.</span>")
		new buildPath(get_turf(user))

/datum/action/bloodling/dissonant_shriek
	name = "Dissonant Shriek"
	desc = "We cry out, disabling nearby electronics."
	button_icon_state = "dissonant_shriek"
	biomass_cost = 30

/datum/action/bloodling/dissonant_shriek/action(mob/living/user)
	if(!..())
		return
	playsound(user, 'sound/effects/screech.ogg', 100, 1)
	for(var/obj/machinery/light/L in range(5, user))
		L.on = 1
		L.break_light_tube()
	empulse(get_turf(user), 2, 5, 1)
	add_cooldown(1 MINUTES)

/datum/action/bloodling/heal
	name = "Heal"
	desc = "We use some of our biomass to restore a changeling thrall, restoring their limbs and purging toxins. To heal lesser slaves, transfer them some biomass."
	button_icon_state = "heal"
	biomass_cost = 50

/datum/action/bloodling/heal/action(mob/living/user)
	if(!..())
		return
	var/list/mobs = list()
	for(var/mob/living/M in view(user, 3))
		if(M == user || !is_bloodling(M) || !iscarbon(M))
			continue
		mobs += M
	var/mob/living/M = input(user, "Which servant shall we heal?", "[src]", null) as null|anything in mobs
	if(!M)
		return FALSE
	add_cooldown(1 MINUTES)
	user.emote("scream")
	var/heal_time = 20 SECONDS
	var/datum/beam/current_beam = new(user,M,time=heal_time,beam_icon_state="tentacle",btype=/obj/effect/ebeam/blood)
	INVOKE_ASYNC(current_beam, TYPE_PROC_REF(/datum/beam, Start))
	M.visible_message("<span class='warning'>[user] plunges a tendril deep into [M]'s neck!</span>", "<span class='userdanger'>You feel a stabbing pain in your neck as your wounds knit back together...</span>")
	M.emote("scream")
	playsound(M, 'nsv13/sound/effects/bloodling_squelch.ogg', 70, FALSE)
	if(do_after(user, heal_time, target=M))
		M.visible_message("<span class='warning'>[user] retracts their tendril!</span>", "<span class='userdanger'>Your wounds have been healed!</span>")
		var/mob/living/carbon/C = M
		var/list/missing = C.get_missing_limbs()
		if(missing.len)
			playsound(C, 'sound/magic/demon_consume.ogg', 50, 1)
			C.visible_message("<span class='warning'>[C]'s missing limbs \
					reform, making a loud, grotesque sound!</span>",
					"<span class='userdanger'>Your limbs regrow, making a \
					loud, crunchy sound and giving you great pain!</span>",
					"<span class='italics'>You hear organic matter ripping \
					and tearing!</span>")
			C.emote("scream")
			C.regenerate_limbs(1)

		C.revive(full_heal = TRUE)
		C.regenerate_organs()
		return TRUE

/datum/action/bloodling/ascend
	name = "Ascend"
	desc = "We shed our mortal coil and ascend into a greater being. This will consume 500 biomass..."
	button_icon_state = "ascend"
	biomass_cost = 500

/obj/structure/fluff/bloodling_tendril
	name = "bloody tendril"
	desc = "A vile tendril of corruption, channeling power from the mighty spaceship below."
	icon = 'icons/mob/nest.dmi'
	icon_state = "tendril"

/datum/action/bloodling/ascend/action(mob/living/user)
	if(!..() || istype(user, /mob/living/simple_animal/hostile/eldritch/armsy/prime/bloodling_ascended)) //Hard cockblock to prevent re-ascension.
		return
	var/datum/antagonist/bloodling/user_antag = user.mind.has_antag_datum(/datum/antagonist/bloodling)
	if(!user_antag)
		refund_biomass(user, biomass_cost)
		return
	var/area/A = get_area(user)
	var/datum/objective/bloodling_ascend/ascend_objective = locate() in user_antag.objectives
	if(!(A in ascend_objective.summon_spots))
		to_chat(user, "<span class='cultlarge'>The consciousness grid here is not receptive to our presence, we may however try to ascend in [english_list(ascend_objective.summon_spots)]!</span>")
		refund_biomass(user, biomass_cost)
		return

	if(alert(user, "Are you sure you wish to attempt an ascension? You will be left vulnerable, and lesser beings will be made aware of your location...",name,"Yes","No") == "Yes")
		user.get_overmap().relay_to_nearby('nsv13/sound/effects/bloodling_awaken.ogg', "<span class='userdanger'>Hideous images creep into your mind!</span>", FALSE)
		add_cooldown(15 MINUTES)
		//Wall the master in
		new /obj/structure/fluff/bloodling_tendril(get_turf(user))
		for(var/cdir in GLOB.alldirs)
			new /obj/structure/alien/resin/wall(get_turf(get_step(user, cdir)))

		to_chat(user, "<span class='userdanger'>We start to channel our mental energy... We will be unable to move while we attempt our ascension.</span>")
		//No moving for you.
		//user.add_movespeed_modifier(BLOODLING_ASCENSION_MODIFIER, TRUE, 100, multiplicative_slowdown = INFINITY, override = TRUE)

		user.get_overmap().relay_to_nearby('nsv13/sound/effects/bloodling_awaken.ogg', "<span class='userdanger'>You can feel your consciousness being drawn to something terrible...</span>", FALSE)
		sleep(5 SECONDS)
		var/datum/component/bloodling/B = user.GetComponent(/datum/component/bloodling)
		priority_announce("Attention all hands, possible Patmos-Omega 'end-of-the-world' class event detected. An extra-dimensional consciousness grid is forming in: [get_area(user)]. All forces must attempt to contain the event.","Central Command Higher Dimensional Affairs", 'sound/misc/airraid.ogg')
		B.begin_the_beginning_of_the_end()

	else
		//They backed out.
		refund_biomass(user, biomass_cost)

/datum/component/bloodling/proc/begin_the_beginning_of_the_end(mob/living/user)
	user = parent
	if(!user || QDELETED(user) || user.health <= 0)
		SSticker.mode.check_win()
		return FALSE //Well! he dead...
	priority_announce("Simulations indicate that a christ-consciousness grid will be formed in [get_area(user)] in T-5 minutes.","Central Command Higher Dimensional Affairs")
	set_security_level("delta")
	sleep(5 SECONDS)
	//No escape
	SSshuttle.registerHostileEnvironment(user)
	SSshuttle.lockdown = TRUE
	addtimer(CALLBACK(src, PROC_REF(begin_the_end)), 5 MINUTES)

/datum/component/bloodling/proc/begin_the_end(mob/living/user)
	user = parent
	if(!user || QDELETED(user) || user.health <= 0)
		SSticker.mode.check_win()
		return FALSE //Well! he dead...
	user.get_overmap().relay_to_nearby('nsv13/sound/effects/bloodling_awaken.ogg', "<span class='userdanger'>Something horrible has awoken!</span>", FALSE)
	//Give them a chance to resolve it.
	priority_announce("WARNING: AN EXTRA-DIMENSIONAL CONSCIOUSNESS GRID HAS BEEN ESTABLISHED ABOARD [station_name()]... Eliminate the focal entity at all costs. Reports estimate total reality failure in T-10 minutes.","Central Command Higher Dimensional Affairs")

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(bloodling_win)), 10 MINUTES)

	var/mob/last_user = user
	var/mob/living/simple_animal/hostile/eldritch/armsy/prime/bloodling_ascended/theMaster = new(user.loc)
	//last_user.remove_movespeed_modifier(BLOODLING_ASCENSION_MODIFIER, TRUE)
	user.mind.transfer_to(theMaster)
	//theMaster.mind.add_antag_datum(/datum/antagonist/bloodling)
	if(istype(SSticker.mode, /datum/game_mode/bloodling))
		var/datum/game_mode/bloodling/GM = SSticker.mode
		GM.master = theMaster

	QDEL_IN(last_user, 1 SECONDS)


/proc/bloodling_win(mob/living/user)
	if(istype(SSticker.mode, /datum/game_mode/bloodling))
		var/datum/game_mode/bloodling/GM = SSticker.mode
		user = GM.master
		if(!user || QDELETED(user) || user.health <= 0)
			SSticker.mode.check_win()
			return FALSE //Well! he dead..
	sound_to_playing_players('sound/machines/alarm.ogg')
	Cinematic(CINEMATIC_CULT,world,CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(ending_helper)))

/mob/living/simple_animal/hostile/eldritch/armsy/prime/bloodling_ascended
	name = "Fleshy Entity"
	real_name = "The Master"
	desc = "Your mind screams as it tries to comprehend what stands before you..."
	icon = 'nsv13/icons/mob/bloodling.dmi'
	health = 3000
	maxHealth = 3000
	hud_type = /datum/hud/bloodling
	obj_damage = 100
	var/datum/component/bloodling/biomass = null

//Join his cause.
/mob/living/simple_animal/hostile/eldritch/armsy/prime/bloodling_ascended/attack_ghost(mob/dead/observer/user as mob)
	var/mob/living/simple_animal/bloodling_minion/habibi
	habibi = (prob(50)) ? new /mob/living/simple_animal/bloodling_minion/tank(src.loc) : new /mob/living/simple_animal/bloodling_minion(src.loc)
	habibi.ckey = user.ckey
	sleep(1)
	habibi.mind.enslave_mind_to_creator(src)
	habibi.mind.add_antag_datum(/datum/antagonist/bloodling/minion)

/mob/living/simple_animal/hostile/eldritch/armsy/prime/bloodling_ascended/Initialize(mapload, spawn_more, len)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(update_biomass)), 1 SECONDS)
	var/area/A = get_area(src)
	if(A)
		var/mutable_appearance/alert_overlay = mutable_appearance('nsv13/icons/mob/actions/actions_bloodling.dmi', "ascend")
		notify_ghosts("The master calls to you. Reach out to him to be given life.", source = src, alert_overlay = alert_overlay, action=NOTIFY_ATTACK)

/mob/living/simple_animal/hostile/eldritch/armsy/prime/bloodling_ascended/proc/update_biomass()
	biomass = GetComponent(/datum/component/bloodling)
	biomass?.final_form_biomass = INFINITY
	biomass?.set_biomass(INFINITY)

/mob/living/simple_animal/hostile/eldritch/armsy/prime/bloodling_ascended/update_health_hud(shown_health_amount)
	if(!client || !hud_used)
		return
	if(hud_used.healths)
		if(stat != DEAD)
			. = 1
			if(shown_health_amount == null)
				shown_health_amount = health
			if(shown_health_amount >= maxHealth)
				hud_used.healths.icon_state = "health0"
			else if(shown_health_amount > maxHealth*0.8)
				hud_used.healths.icon_state = "health1"
			else if(shown_health_amount > maxHealth*0.6)
				hud_used.healths.icon_state = "health2"
			else if(shown_health_amount > maxHealth*0.4)
				hud_used.healths.icon_state = "health3"
			else if(shown_health_amount > maxHealth*0.2)
				hud_used.healths.icon_state = "health4"
			else if(shown_health_amount > 0)
				hud_used.healths.icon_state = "health5"
			else
				hud_used.healths.icon_state = "health6"
		else
			hud_used.healths.icon_state = "health7"
