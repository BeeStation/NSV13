
// mission_cargos.dm has a bunch of signal code that I'm not going to touch at 3 in the morning, 
// delivery_types.dm contains redundant checks that allow repackaging anyway, 
// and overmap gamemodes are currently in a state that don't exactly encourage "bonus points" for untampered transfers. 
// I literally just need a box right now. 
// TODO Refactor mission_cargos.dm to handle cargo objective descriptions 

/obj/structure/closet/crate/large/cargo_objective/
	desc = "A hefty wooden crate. This crate is fitted with an anti-tamper seal. If you really want to open it you'll need a crowbar to get it open."
	icon = 'nsv13/icons/obj/custom_crates.dmi'
	icon_state = "large_cargo_crate"
	var/datum/overmap_objective/cargo/overmap_objective = null
	var/datum/cargo_item_type/cargo_item_type = null

/obj/structure/closet/crate/large/cargo_objective/attackby(obj/item/W, mob/user, params)  
	if(W.tool_behaviour == TOOL_CROWBAR)
		var/choice = input("WARNING: The client requests that the cargo must not be tampered with. Opening this crate will reduce mission payout. Are you sure you wish to open it?", "WARNING!", "No") in list("Yes", "No")
		if(choice != "Yes") 
			return
		if(get_dist(user, src) > 1) //Check they are still in range
			return
		for ( var/mob/living/simple_animal/M in GetAllContents( contents ) )
			message_admins( M )
			message_admins( "reminder to reset probability" )
			// if ( rand( 1, 20 ) == 20 ) // Random sentient mob event!
			if ( rand( 1, 2 ) == 2 ) 
				message_admins(" success")
				var/list/candidates = pollCandidatesForMob("Do you want to play as [M]?", ROLE_SENTIENCE, null, ROLE_SENTIENCE, 50, M, POLL_IGNORE_SENTIENCE_POTION)
				M.AIStatus = AI_ON
				if(LAZYLEN(candidates))
					var/mob/dead/observer/C = pick(candidates)
					M.key = C.key
					M.sentience_act()
					log_game("[key_name(M)] took control of [M].")
		..()

/obj/structure/closet/crate/large/cargo_objective/examine( mob/user )
	. = ..()
	var/text = "<span class='warning'>"
	text += "This item is tagged as cargo. "
	if ( cargo_item_type.item )
		text += "It contains [cargo_item_type.item]"
		if ( overmap_objective?.destination )
			var/obj/structure/overmap/S = overmap_objective.destination
			text += ", and needs to be delivered to [S] in system [S.current_system]. "
		else 
			text += ". "
	else if ( overmap_objective?.destination ) 
		var/obj/structure/overmap/S = overmap_objective.destination
		text += "It needs to be delivered to [S] in system [S.current_system]. "
	
	// text += "<B>Opening this crate will reduce payout!</B>" // No it doesn't 
	text += "</span>\n"

	. += text
