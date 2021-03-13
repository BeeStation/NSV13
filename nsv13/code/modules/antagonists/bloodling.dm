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
	speed = 0 //Rapid
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

/mob/living/simple_animal/bloodling/lingcheck()
	return LINGHIVE_LING //We are the king of the lings.

/obj/effect/decal/cleanable/blood/bloodling
	name = "Otherwordly Goop"
	desc = "Just looking at it makes you feel sick."
	icon = 'nsv13/icons/mob/bloodling.dmi'
	icon_state = "tracks"

/mob/living/simple_animal/bloodling/Initialize()
	. = ..()
	AddComponent(/datum/component/waddling)
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
	var/final_form_biomass = 1000
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
		list("unlockTier"=3, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/transfer_biomass)),
		list("unlockTier"=3, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/ground_pound)),
		list("unlockTier"=4, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/give_life)),
		list("unlockTier"=4, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/whiplash))
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
	RegisterSignal(parent, COMSIG_MOB_APPLY_DAMGE, .proc/damage_react)
	parent.AddComponent(/datum/component/simple_teamchat/bloodling) //Give them the teamchat ability...
	SEND_SOUND(ling, 'sound/ambience/antag/ling_aler.ogg')
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
	//Remove their access to the bloodling hivemind.
	var/datum/component/C = parent.GetComponent(/datum/component/simple_teamchat/bloodling)
	C.RemoveComponent()
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
	ling.add_movespeed_modifier(MOVESPEED_ID_BLOODLING_BIOMASS, TRUE, 100, multiplicative_slowdown = speed, override = TRUE)
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
	user.AddComponent(/datum/component/simple_teamchat/bloodling)
	if(isovermind(user))
		ling.get_overmap().relay_to_nearby('nsv13/sound/effects/bloodling_awaken.ogg', "<span class='userdanger'>Hideous images creep into your mind!</span>", FALSE)
		var/mob/camera/blob/B = user
		var/datum/objective/bloodling_serve/serve = new
		serve.owner = B.mind
		B.mind.objectives += serve
		B.mind.announce_objectives()
	if(!isliving(user) || !user.mind)
		return FALSE
	if(ishuman(user))
		user.mind.add_antag_datum(/datum/antagonist/changeling/bloodling_thrall) //Alright! you caught a human, THRALL TIME
	else
		user.AddComponent(/datum/component/bloodling/lesser) //Otherwise, turn them into a critter slave!

//Bloodling's very own mindslave!
/datum/antagonist/changeling/bloodling_thrall
	name = "Enthralled Changeling"
	roundend_category  = "changelings"
	antagpanel_category = "Bloodling Thralls"

/datum/objective/bloodling_serve
	name = "Serve the entity"
	explanation_text = "Serve the entity at all costs. This objective overrides any others."
	completed = TRUE //This is hard to track.

/datum/antagonist/changeling/bloodling_thrall/forge_objectives()
	var/datum/objective/bloodling_serve/serve = new
	serve.owner = owner
	objectives += serve
	log_objective(owner, serve.explanation_text)
	. = ..()

/datum/antagonist/changeling/bloodling_thrall/greet()
	//For admin spawned thralls...
	if(!owner.current.GetComponent(/datum/component/simple_teamchat/bloodling))
		owner.current.AddComponent(/datum/component/simple_teamchat/bloodling) //Give them the teamchat ability...
	to_chat(owner.current, "<span class='boldannounce'>You are reborn as [changelingID]! We remade you in our image.</span>")
	to_chat(owner.current, "<span class='boldannounce'>You can communicate with other ascended changelings with \"[MODE_TOKEN_CHANGELING]\". Our greater hivemind can be heard by all of the master's servants.</span>")
	to_chat(owner.current, "<span class='boldannounce'>You must serve the master above all else, failure to do so may lead to our generous gift to you being revoked, along with your life...</span>")
	to_chat(owner.current, "<b>Carry out the master's will above else. Your objectives are:</b>")
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/ling_aler.ogg', 100, FALSE, pressure_affected = FALSE)
	owner.announce_objectives()


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

	lingchemdisplay = new /obj/screen/ling/chems()
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
	addtimer(CALLBACK(src, .proc/remove_cooldown), time)

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
	name = "Thermal Vision"
	desc = "We can alter our vision to see heat signatures."
	button_icon_state = "augmented_eyesight"

/datum/action/bloodling/thermalvision/action(mob/living/user)
	if(!..())
		return FALSE

	if(!active)
		user.sight |= SEE_MOBS | SEE_OBJS | SEE_TURFS //Add sight flags to the user's eyes
		user.see_in_dark = 8
		to_chat(user, "We adjust our eyes to sense prey through walls.")
		active = TRUE
		return
	user.sight ^= SEE_MOBS | SEE_OBJS | SEE_TURFS //Remove sight flags from the user's eyes
	user.see_in_dark = 2
	active = FALSE
	to_chat(user, "We adjust our eyes to see as our prey do.")

/datum/action/bloodling/thermalvision/Remove(mob/M)
	M.sight ^= SEE_MOBS | SEE_OBJS | SEE_TURFS //Remove sight flags from the user's eyes
	active = FALSE
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
	soundloop = new(list(M), FALSE)
	soundloop.stop(M)

/datum/action/bloodling/absorb/Remove(mob/M)
	soundloop.stop(M)
	. = ..()

/datum/action/bloodling/absorb/action(mob/living/user)
	. = ..()
	var/list/mobs = list()
	for(var/mob/living/M in view(user, 5))
		if(M == user || !isliving(M) || M.invisibility > 0 || !M.alpha || M.GetComponent(/datum/component/bloodling) || M.mind?.has_antag_datum(/datum/antagonist/changeling/bloodling_thrall))
			continue
		mobs += M
	var/mob/living/M = input(user, "Who shall we absorb?", "[src]", null) as null|anything in mobs
	if(!M)
		return FALSE
	var/datum/component/bloodling/B = user.GetComponent(/datum/component/bloodling)
	var/absorb_cooldown = 20 SECONDS - B.last_evolution SECONDS //Bigger boys absorb better
	add_cooldown(absorb_cooldown)
	soundloop.start(user)
	var/datum/beam/current_beam = new(user,M,time=absorb_time,beam_icon_state="tentacle",btype=/obj/effect/ebeam/blood)
	INVOKE_ASYNC(current_beam, /datum/beam.proc/Start)
	M.visible_message("<span class='warning'>[user] plunges a tendril deep into [M]'s carotid artery!</span>", "<span class='userdanger'>You feel a stabbing pain in your carotid artery!</span>")
	M.take_overall_damage(0, 0, 50) //OUCH!
	M.emote("scream")
	if(do_after(user, absorb_time, target=M))
		M.visible_message("<span class='warning'>[user] retracts their tendril!</span>", "<span class='userdanger'>YOU FEEL SLIGHTLY UNWELL.</span>")
		var/gains = M.mob_size*50
		gains = CLAMP(gains, 1, gains)
		new /obj/effect/temp_visual/bloodling_remnant(get_turf(M), gains)
		M.gib() //Sorry man :(
	else
		M.visible_message("<span class='warning'>[user] quickly retracts their tendril!</span>", "<span class='userdanger'>You feel something slip out of your neck!</span>")
		qdel(current_beam)
	soundloop.stop(user)

/datum/action/bloodling/infest
	name = "Infest Creature"
	desc = "We infest a creature with our consciousness, forcing its servitude and upgrading its physical form with some of our biomass."
	button_icon_state = "infest"
	biomass_cost = 35
	var/absorb_time = 10 SECONDS//30 SECONDS //This is a lengthy process, and will require assistance to complete.
	var/datum/looping_sound/bloodling_absorb/soundloop = null

/datum/component/bloodling/lesser
	//Enthralled creatures get a lesser arsenal, but a powerful one still.
	unlock_tiers = list(
		list("unlockTier"=0, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/thermalvision)),
		list("unlockTier"=0, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/absorb)),
		list("unlockTier"=0, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/call_remnant)),
		list("unlockTier"=0, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/transfer_biomass)),
		list("unlockTier"=0, "lockAtTier"=0, "abilities"=list(/datum/action/bloodling/whiplash))
	)
	final_form_biomass = 200 //An inferior lifeform, but still able to gather biomass.

/datum/action/bloodling/infest/Grant(mob/M)
	. = ..()
	soundloop = new(list(M), FALSE)
	soundloop.stop(M)

/datum/action/bloodling/infest/Remove(mob/M)
	soundloop?.stop(M)
	. = ..()

//Handler to allow the bloodling to absorb other antags. Just blob for now.
/datum/action/bloodling/infest/proc/ask_special_absorb(mob/living/user, atom/movable/special_target)
	if(istype(special_target, /obj/structure/blob)) //I'm probably gonna fucking regret this.
		var/obj/structure/blob/blob = special_target
		var/datum/component/bloodling/B = user.GetComponent(/datum/component/bloodling)
		if(!blob.overmind)
			return FALSE
		if(B.last_evolution < 4) //You have to be STRONG to do this.
			to_chat(user, "<span class='warning'>We can sense the essence of a powerful entity inhabiting [special_target], but we are not yet strong enough to absorb it.</span>")
			return FALSE
		to_chat(user, "<span class='userdanger'>WE HAVE DETECTED A POWERFUL ENTITY'S PRESENCE IN THIS STRUCTURE...</span>")
		if(alert(user, "Absorb the powerful entity?",name,"Yes","No") == "Yes")
			to_chat(blob.overmind, "<span class='userdanger'>A strange consciousness starts to intertwine with yours...</span>")
			var/absorb_cooldown = 1 MINUTES - B.last_evolution SECONDS //It'll take everything you have to pull this off...
			soundloop.start(user)
			var/datum/beam/current_beam = new(user,blob,time=absorb_time,beam_icon_state="tentacle",btype=/obj/effect/ebeam/blood)
			INVOKE_ASYNC(current_beam, /datum/beam.proc/Start)
			add_cooldown(absorb_cooldown*2)
			user.emote("scream")
			if(do_after(user, absorb_time, target=blob))
				user.visible_message("<span class='warning'>[user] retracts their tendril!</span>", "<span class='userdanger'>That consciousness was strong, but not strong enough.</span>")
				to_chat(user, "<span class='aliennotice'>We have infested the creature. If they do not do our bidding, we may absorb them for biomass.</span>")
				to_chat(blob.overmind, "<span class='userdanger'>Your mind has been overtaken by [user]!</span>")
				B.infest(blob.overmind)
				B.can_blob_talk = TRUE
				return TRUE
			else
				user.visible_message("<span class='warning'>[user] quickly retracts their tendril!</span>", "<span class='userdanger'>Our domination of the entity was interrupted!</span>")
				qdel(current_beam)
				refund_biomass(user, biomass_cost/1.5) //You get most of your biomass back if interrupted, but not _all_
			soundloop.stop(user)
			return TRUE

		else
			return FALSE
	else
		return FALSE

/datum/action/bloodling/infest/action(mob/living/user)
	. = ..()
	var/list/mobs = list()
	for(var/atom/movable/M in view(user, 2))
		if(ask_special_absorb(user, M))
			return TRUE //Oh god, he's doing it.
		if(M == user || !isliving(M) || M.invisibility > 0 || !M.alpha || M.GetComponent(/datum/component/bloodling))
			continue
		mobs += M
	var/mob/living/M = input(user, "Who shall we infest?", "[src]", null) as null|anything in mobs
	if(!M || !M.mind || M.mind?.has_antag_datum(/datum/antagonist/changeling/bloodling_thrall))
		to_chat(user, "<span class='warning'>That creature lacks intelligence, we should absorb it instead. </span>")
		refund_biomass(user, biomass_cost)
		return FALSE
	var/datum/component/bloodling/B = user.GetComponent(/datum/component/bloodling)
	var/absorb_cooldown = 20 SECONDS - B.last_evolution SECONDS //Bigger boys absorb better
	soundloop.start(user)
	var/datum/beam/current_beam = new(user,M,time=absorb_time,beam_icon_state="tentacle",btype=/obj/effect/ebeam/blood)
	INVOKE_ASYNC(current_beam, /datum/beam.proc/Start)
	M.visible_message("<span class='warning'>[user] plunges a tendril deep into [M]'s carotid artery!</span>", "<span class='userdanger'>You feel a stabbing pain in your carotid artery!</span>")
	add_cooldown(absorb_cooldown)
	M.emote("scream")
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
	. = ..()
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

	var/list/candidates = pollCandidatesForMob("Do you want to play as [user.name]?", ROLE_SENTIENCE, null, ROLE_SENTIENCE, 50, M, POLL_IGNORE_SENTIENCE_POTION) // see poll_ignore.dm
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
	. = ..()
	var/list/mobs = list()
	for(var/atom/movable/M in view(user, 2))
		if(M == user || !isliving(M) || M.invisibility > 0 || !M.alpha | !M.GetComponent(/datum/component/bloodling))
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

	amount = CLAMP(amount, 0, ours.biomass) //Can't transfer what you don't own...

	ours.remove_biomass(amount)
	theirs.add_biomass(amount)

//Ability: ground pound. Simple AOE stun, low biomass, long cooldown.
/datum/action/bloodling/ground_pound
	name = "Ground Slam"
	desc = "We jump into the air and slam into the ground at high velocity, stunning nearby victims."
	button_icon_state = "ground_pound"
	biomass_cost = 0
	var/base_stun_time = 2 SECONDS

/obj/effect/temp_visual/bloodling_target
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "sniper_zoom"
	layer = BELOW_MOB_LAYER
	light_range = 2
	duration = 1 SECONDS

/datum/action/bloodling/ground_pound/action(mob/living/user)
	. = ..()
	user.visible_message("<span class='warning'>[user] leaps up high into the air!</span>")
	user.Paralyze(1 SECONDS)
	animate(user, pixel_y = 100, 1 SECONDS)
	sleep(1 SECONDS)
	animate(user, pixel_y = 0, 1 SECONDS)
	user.shake_animation()
	user.visible_message("<span class='warning'>[user] slams into the ground!</span>")
	playsound(user, 'sound/effects/gravhit.ogg', 100, TRUE)
	var/datum/component/bloodling/B = user.GetComponent(/datum/component/bloodling)
	var/stun_time = base_stun_time + B.last_evolution SECONDS //Bigger boys absorb better
	for(var/atom/X in view(user, 3))
		if(X == src)
			continue
		X.shake_animation(10)
		if(isstructure(X) || ismachinery(X))
			var/obj/structure/XXX = X
			XXX.take_damage(2.5 * B.last_evolution) //Big boys slam harder
		if(isliving(X))
			var/mob/living/L = X
			L.Paralyze(stun_time)
	add_cooldown(30 SECONDS)

//The COOLER stun
/datum/action/bloodling/whiplash
	name = "Tentacle Whip"
	desc = "We lash out our tentacles to stun nearby enemies."
	button_icon_state = "tailsweep"
	biomass_cost = 20
	var/base_stun_time = 5 SECONDS

/datum/action/bloodling/whiplash/action(mob/living/user)
	. = ..()
	user.visible_message("<span class='warning'>[user] lashes out with a legion of tentacles!</span>")
	user.shake_animation()
	playsound(user, 'sound/magic/tail_swing.ogg', 100, TRUE)
	var/datum/component/bloodling/B = user.GetComponent(/datum/component/bloodling)
	var/stun_time = base_stun_time + B.last_evolution SECONDS //Bigger boys absorb better
	for(var/mob/living/M in view(user, 5))
		if(M == user)
			continue
		var/datum/beam/current_beam = new(user,M,time=0.5 SECONDS,beam_icon_state="tentacle",btype=/obj/effect/ebeam/blood)
		INVOKE_ASYNC(current_beam, /datum/beam.proc/Start)
		var/turf/throwtarget = get_edge_target_turf(user, get_dir(user, get_step_away(M, user)))
		var/distfromcaster = get_dist(user, M)
		M.Paralyze(stun_time)
		M.adjustBruteLoss(5)
		to_chat(M, "<span class='userdanger'>You're slammed into the floor by [user]!</span>")
		M.safe_throw_at(throwtarget, ((CLAMP((5 - (CLAMP(distfromcaster - 2, 0, distfromcaster))), 3, 5))), 1,user, force = MOVE_FORCE_EXTREMELY_STRONG)//So stuff gets tossed around at the same time.
	add_cooldown(45 SECONDS)
