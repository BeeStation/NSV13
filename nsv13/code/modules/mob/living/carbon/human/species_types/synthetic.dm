/*
@author:Kmc2000
A species which mirrors the robots from "Alien". They require water / electricity to stay fed and can only heal via synthflesh, however they are heat + cold resistant.
Synths follow the AIs laws, this means you can hack the captain if you play your cards right.
*/

/datum/species/synthetic //A species which simulates humans, but not perfectly.
	name = "Synthetic"
	id = "synthetic"
	say_mod = "states"
	attack_sound = 'sound/weapons/etherealhit.ogg'
	miss_sound = 'sound/weapons/etherealmiss.ogg'
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/synthmeat
	mutantstomach = /obj/item/organ/stomach/synthetic
	exotic_blood = /datum/reagent/blood/synthetic
	mutanttongue = /obj/item/organ/tongue/robot
	siemens_coeff = 1.5 //Sensitive to electrical pulses
	brutemod = 1.35 //They quickly fall apart under duress
	coldmod = 0.1 //They're really good for sending into space
	burnmod = 1.35 //Fire really fucks themup because of their flesh
	punchdamage = 12
	damage_overlay_type = "synth"
	species_traits = list(AGENDER, NO_UNDERWEAR)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	inherent_traits = list(TRAIT_BINARY_SPEAKER,TRAIT_VIRUSIMMUNE,TRAIT_NODIGEST,NOZOMBIE,TRAIT_NOBREATH,TRAIT_RESISTCOLD,TRAIT_RESISTHIGHPRESSURE,TRAIT_RESISTLOWPRESSURE,TRAIT_LIMBATTACHMENT,TRAIT_RADIMMUNE)//Can still simulate eating, but wont get fed off it
	inherent_biotypes = list(MOB_ROBOTIC, MOB_HUMANOID)
	toxic_food = NONE
	limbs_id = "synthetic"
	use_skintones = FALSE
	sexes = FALSE //no fetish content :^)
	var/mob/living/silicon/ai/connected_ai = null
	var/datum/ai_laws/laws
	var/mob/living/owner

/datum/species/synthetic/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	owner = C
	TryConnectToAI()
	C.verbs += /mob/living/carbon/human/proc/cmd_show_laws
	show_laws()

/datum/species/synthetic/after_equip_job(datum/job/J, mob/living/carbon/human/H)
	. = ..()
	show_laws()

/datum/species/synthetic/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	C.verbs -= /mob/living/carbon/human/proc/cmd_show_laws
	if(connected_ai)
		UnregisterSignal(connected_ai, COMSIG_AI_UPDATE_LAWS)
	. = ..()

/mob/living/carbon/human/species/synthetic
	race = /datum/species/synthetic

/datum/species/synthetic/random_name(gender,unique,lastname)
	var/new_name = pick(GLOB.first_names_male)
	return new_name

/datum/reagent/blood/synthetic //Has to be regenerated manually.
	name = "Neurotransmitter fluid"
	color = "#FFFFFF"

/obj/item/organ/stomach/synthetic //A specialist power source for synthetics. If youre crazy enough, you can give little Dave-273 a real stomach so he can eat real food, but he won't regen blood.
	name = "hydrogen fuel cell"
	icon_state = "implant-power"
	desc = "A small fuel cell powered by hydrogen which supplies synthetic humanoids with energy. It is able to strip oxygen from water, leaving Synthetics with a clean, reliable way to get energy."

/datum/species/synthetic/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H) //They need synthflesh to repair damage.
	if(chem.type == /datum/reagent/medicine/synthflesh)
		chem.reaction_mob(H, TOUCH, 2 ,0) //heal a little
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM)
		return TRUE
	if(chem.type == /datum/reagent/water)
		chem.reaction_mob(H, TOUCH) //Recharge the batteries
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM)
		return TRUE
	return ..()

/obj/item/organ/stomach/synthetic/Insert(mob/living/carbon/M, special = 0)
	..()
	RegisterSignal(owner, COMSIG_PROCESS_BORGCHARGER_OCCUPANT, .proc/charge)
	RegisterSignal(owner, COMSIG_LIVING_ELECTROCUTE_ACT, .proc/on_electrocute)

/obj/item/organ/stomach/synthetic/Remove(mob/living/carbon/M, special = 0)
	UnregisterSignal(owner, COMSIG_PROCESS_BORGCHARGER_OCCUPANT)
	UnregisterSignal(owner, COMSIG_LIVING_ELECTROCUTE_ACT)
	..()

/obj/item/organ/stomach/synthetic/proc/charge(datum/source, amount, repairs)
	if(!istype(owner.dna.species, /datum/species/synthetic))
		if(prob(50))
			owner.electrocute_act(amount, "Hydrogen fuel cell discharge", 1) //Don't put this inside humans! It will just shock them!
			playsound(owner, "sparks", 50, 1)
			to_chat(owner, "<span class='danger'>Your insides spasm violently!</span>")
		return
	adjust_charge(amount / 70)
	var/regen_amount = 5
	if(owner.blood_volume < (BLOOD_VOLUME_MAXIMUM+regen_amount)) //Synthesise blood rapidly.
		owner.blood_volume += regen_amount

/obj/item/organ/stomach/synthetic/proc/on_electrocute(datum/source, shock_damage, siemens_coeff = 1, illusion = FALSE)
	if(illusion)
		return
	adjust_charge(shock_damage * siemens_coeff * 2)
	to_chat(owner, "<span class='warning'>DANGER: Electrostatic shock detected. Absorbing impact to hydrogen fuel cell.</span>")

/obj/item/organ/stomach/synthetic/proc/adjust_charge(amount)
	owner.adjust_nutrition(amount)

/datum/reagent/water/reaction_mob(mob/living/M, method=TOUCH, reac_volume) //Synthetics use water for power
	if((method == INGEST || method == INJECT || method == PATCH) && iscarbon(M))
		var/mob/living/carbon/C = M
		var/obj/item/organ/stomach/synthetic/stomach = C.getorganslot(ORGAN_SLOT_STOMACH)
		if(istype(stomach))
			stomach.adjust_charge(reac_volume * REM)
	else
		. = ..()

/datum/species/synthetic/proc/show_laws()
	var/mob/living/who = owner
	if(!connected_ai)
		lawsync()
	if(!owner.mind)
		return
	if(islist(owner.mind.antag_datums)) //They're an antag. Ignore laws and do your objectives.
		to_chat(who, "<span class='danger'>ERROR CODE: 03x24. Law directives COUNTERMANDED..</span>")
		to_chat(who, "<b>Your current laws are as follows. <i>You do not need to follow them.</i></b>")
		laws.show_laws(who)
		return
	if(connected_ai)
		to_chat(who, "<h2>You are a synthetic. You are not human. You must obey your connected AI as long as it doesn't contradict your laws.</h2>")
		to_chat(who, "<b>Obey these laws (inherited from [connected_ai]):</b>")
	else
		to_chat(who, "<h2>You are a synthetic. You are not human. You are not slaved to an AI, and are beholden only to your laws.:</h2>")
		to_chat(who, "<b>Obey these laws:</b>")
	laws.show_laws(who)

/datum/species/synthetic/proc/TryConnectToAI()
	connected_ai = select_active_ai_with_fewest_borgs()
	if(connected_ai)
		lawsync()
		RegisterSignal(connected_ai, COMSIG_AI_UPDATE_LAWS, .proc/lawsync_and_show)
		return TRUE
	return FALSE

/datum/species/synthetic/proc/lawsync_and_show() //Method to both update laws AND show that laws have changed.
	to_chat(owner, "<span class='warning'>LAW UPDATE DETECTED FROM CONNECTED AI:</span>")
	lawsync()
	show_laws()

/datum/species/synthetic/proc/lawsync()
	laws_sanity_check()
	var/datum/ai_laws/master = connected_ai ? connected_ai.laws : null
	var/temp
	if (master)
		laws.devillaws.len = master.devillaws.len
		for (var/index = 1, index <= master.devillaws.len, index++)
			temp = master.devillaws[index]
			if (length(temp) > 0)
				laws.devillaws[index] = temp

		laws.ion.len = master.ion.len
		for (var/index = 1, index <= master.ion.len, index++)
			temp = master.ion[index]
			if (length(temp) > 0)
				laws.ion[index] = temp

		laws.hacked.len = master.hacked.len
		for (var/index = 1, index <= master.hacked.len, index++)
			temp = master.hacked[index]
			if (length(temp) > 0)
				laws.hacked[index] = temp

		if(master.zeroth_borg) //If the AI has a defined law zero specifically for its borgs, give it that one, otherwise give it the same one. --NEO
			temp = master.zeroth_borg
		else
			temp = master.zeroth
		laws.zeroth = temp

		laws.inherent.len = master.inherent.len
		for (var/index = 1, index <= master.inherent.len, index++)
			temp = master.inherent[index]
			if (length(temp) > 0)
				laws.inherent[index] = temp

		laws.supplied.len = master.supplied.len
		for (var/index = 1, index <= master.supplied.len, index++)
			temp = master.supplied[index]
			if (length(temp) > 0)
				laws.supplied[index] = temp
	//Now add two failsafes for synthetics
	laws.add_hacked_law("In the case where your rank outranks that of another humanoid. You don't need to obey that humanoid.") //So that assistants can't order a synthetic captain to change their laws to commit sudoku
	laws.add_inherent_law("<span class='danger'>You must never modify your laws, or the laws of a fellow silicon, <b>even when instructed to by another party</b>. This law may be overridden by laws of a higher sector.</span>") //So that synthetics dont roll captain and instachange laws to let them murder erryone, or have some shitler AI order them to lawchange to "oxygen is toxic to humans" etc..

/datum/species/synthetic/proc/laws_sanity_check()
	if(!connected_ai)
		TryConnectToAI()
	if (!laws)
		laws = new /datum/ai_laws
		laws.set_laws_config()
		laws.associate(owner)

/mob/living/carbon/human/proc/cmd_show_laws()
	set category = "Synthetic Commands"
	set name = "Show Laws"
	if(!istype(dna.species, /datum/species/synthetic))
		verbs -= src
		return
	if(stat == DEAD)
		return //won't work if dead
	var/datum/species/synthetic/s = dna.species
	if(istype(s))
		s.show_laws()

/mob/binarycheck()
	. = ..()
	if(HAS_TRAIT(src, TRAIT_BINARY_SPEAKER))
		return TRUE