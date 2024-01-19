/datum/disease/transformation/jungle_fever
	name = "Jungle Fever"
	cure_text = "Death."
	cures = list(/datum/reagent/medicine/adminordrazine)
	spread_text = "Monkey Bites"
	spread_flags = DISEASE_SPREAD_SPECIAL
	viable_mobtypes = list(/mob/living/carbon/monkey, /mob/living/carbon/human)
	permeability_mod = 1
	cure_chance = 1
	disease_flags = CAN_CARRY|CAN_RESIST
	desc = "Monkeys with this disease will bite humans, causing humans to mutate into a monkey."
	danger = DISEASE_BIOHAZARD
	stage_prob = 4
	visibility_flags = 0
	agent = "Kongey Vibrion M-909"
	new_form = null
	bantype = ROLE_MONKEY


	stage1	= list()
	stage2	= list()
	stage3	= list()
	stage4	= list("<span class='warning'>Your back hurts.</span>", "<span class='warning'>You breathe through your mouth.</span>",
					"<span class='warning'>You have a craving for bananas.</span>", "<span class='warning'>Your mind feels clouded.</span>")
	stage5	= list("<span class='warning'>You feel like monkeying around.</span>")

/datum/disease/transformation/jungle_fever/do_disease_transformation(mob/living/carbon/affected_mob)
	if(affected_mob.mind && !is_monkey(affected_mob.mind))
		add_monkey(affected_mob.mind)
	if(affected_mob && ishuman(affected_mob))
		if((is_monkey_leader(affected_mob.mind) || prob(4)))
			affected_mob.junglegorillize()
		else
			var/mob/living/carbon/monkey/M = affected_mob.monkeyize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPVIRUS | TR_KEEPSE)
			M.ventcrawler = VENTCRAWLER_ALWAYS
			var/datum/atom_hud/H = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
			H.add_hud_to(M)

/datum/disease/transformation/jungle_fever/stage_act()
	..()
	switch(stage)
		if(2)
			if(prob(2))
				to_chat(affected_mob, "<span class='notice'>Your [pick("back", "arm", "leg", "elbow", "head")] itches.</span>")
		if(3)
			if(prob(4))
				to_chat(affected_mob, "<span class='danger'>You feel a stabbing pain in your head.</span>")
				affected_mob.confused += 10
		if(4)
			if(prob(3))
				affected_mob.say(pick("Eeek, ook ook!", "Eee-eeek!", "Eeee!", "Ungh, ungh."), forced = "jungle fever")

/datum/disease/transformation/jungle_fever/cure()
	remove_monkey(affected_mob.mind)
	..()

/datum/disease/transformation/jungle_fever/monkeymode
	visibility_flags = HIDDEN_SCANNER|HIDDEN_PANDEMIC
	disease_flags = CAN_CARRY //no vaccines! no cure!

/datum/disease/transformation/jungle_fever/monkeymode/after_add()
	if(affected_mob && !is_monkey_leader(affected_mob.mind))
		visibility_flags = NONE
