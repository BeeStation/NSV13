/datum/reagent/consumable/ethanol/ftliver
	name = "Faster-Than-Liver"
	description = "A beverage born among the stars, it's said drinking too much feels just like FTL transit."
	color = "#0D0D0D" // rgb: 13, 13, 13
	boozepwr = 52
	taste_description = "empty space"
	glass_icon_state = "ftliver"
	glass_name = "glass of Faster-Than-Liver"
	glass_desc = "My god, it's full of stars!"
	var/HasTraveled = 0

/datum/reagent/consumable/ethanol/ftliver/on_mob_life(mob/living/carbon/M)
	if(!HasTraveled && prob(volume))
		HasTraveled = 1
		M.AdjustKnockdown(15)
		M.become_nearsighted("ftliver")
		shake_camera(M,15)
		M.playsound_local(M.loc,"sound/effects/hyperspace_end.ogg",50)
		addtimer(CALLBACK(src, .proc/Recover, M), 55)
	return ..()

/datum/reagent/consumable/ethanol/ftliver/proc/Recover(mob/living/M)
	M.cure_nearsighted("ftliver")