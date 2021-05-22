#define AI_TRAIT_BRAWLER 1 //The "marines". These guys will attempt to stand and fight
#define AI_TRAIT_SUPPORT 2 //The "medics", civvies, etc. These lads will call for backup

GLOBAL_LIST_EMPTY(human_ais)


/datum/component/human_ai
	var/ai_trait = AI_AGGRESSIVE
	var/static/list/ai_goals = null
	var/datum/ai_goal/current_goal = null
	var/view_range = 15 //How good is this mob's "eyes"?
	var/move_delay = 2 //How quickly do the boys travel?

/mob/living/carbon/human/ai_boarder
	faction = list("Syndicate")

/mob/living/carbon/human/ai_boarder/Initialize()
	. = ..()
	AddComponent(/datum/component/human_ai)

/datum/component/human_ai/Initialize(...)
	. = ..()
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE
	if(!ai_goals)
		for(var/gtype in subtypesof(/datum/ai_goal/human))
			LAZYADD(ai_goals, new gtype)
	START_PROCESSING(SSdcs, src)
	//They're alive!
	RegisterSignal(parent, COMSIG_LIVING_REVIVE, .proc/restart)

/datum/component/human_ai/proc/pathfind_to(atom/movable/target)
	walk_to(parent, target, 1, move_delay)

//Allows the AI actor to be revived by a medic, and get straight back into the fight!
/datum/component/human_ai/proc/restart()
	START_PROCESSING(SSdcs, src)

///Pick a goal from the available goals!
/datum/component/human_ai/proc/pick_goal()
	var/best_score = 0
	var/datum/ai_goal/chosen = null
	for(var/datum/ai_goal/human/H in ai_goals)
		var/this_score = H.check_score(src)
		if(this_score > best_score)
			chosen = H
	if(chosen)
		chosen.assume(src)

//Handles actioning on the goal every tick.
/datum/component/human_ai/process()
	if(!current_goal)
		pick_goal()
		return
	var/mob/living/carbon/human/H = parent
	if(H.stat == DEAD) //Dead.
		return PROCESS_KILL
	current_goal.action(src)


/datum/ai_goal/human
	name = "Placeholder goal" //Please keep these human readable for debugging!
	score = 0
	required_trait = null //Set this if you want this task to only be achievable by certain types of ship.

//Method to get the score of a certain action. This can change the "base" score if the score of a specific action goes up, to encourage skynet to go for that one instead.
//@param OM - If you want this score to be affected by the stats of an overmap.

/datum/ai_goal/check_score(datum/component/human_ai/HA)
	if(istype(HA, /obj/structure/overmap))
		return ..()
	var/mob/living/carbon/human/H = HA.parent
	if(required_trait)
		if(islist(HA.ai_trait))
			var/found = FALSE
			for(var/X in HA.ai_trait)
				if(X == required_trait)
					found = TRUE
					break
			if(!found)
				return 0
		else
			if(HA.ai_trait != required_trait)
				return 0
	return (score > 0 && !H.client) //Children sometimes NEED this true value to run their own checks. We also cancel here if the mob has been overtaken by someone.

//Delete the AI's last orders, tell the AI ship what to do.
/datum/ai_goal/human/assume(datum/component/human_ai/HA)
	if(istype(HA, /obj/structure/overmap))
		return ..()
	message_admins("Goal [src] chosen!")
	HA.current_goal = src

///Method that gets all the potential aggressors for this target.
/datum/ai_goal/proc/get_aggressors(datum/component/human_ai/HA)
	. = list()
	var/mob/living/carbon/human/H = HA.parent
	for(var/mob/living/M in oview(HA.view_range, HA.parent))
		if(M.invisibility >= INVISIBILITY_ABSTRACT || M.alpha <= 0)
			continue
		if(!H.faction_check_mob(M))
			continue
		. += M
	//Check for nearby mechas....
	if(GLOB.mechas_list?.len)
		for(var/obj/mecha/OM in GLOB.mechas_list)
			if(OM.z != H.z)
				continue
			if(get_dist(H, OM) > HA.view_range || !can_see(H, OM, HA.view_range))
				continue
			if(OM.occupant && !H.faction_check_mob(OM.occupant))
				. += OM.occupant
	for(var/obj/structure/overmap/OM in GLOB.overmap_objects)
		if(OM.z != H.z)
			continue
		if(get_dist(H, OM) > HA.view_range || !can_see(H, OM, HA.view_range))
			continue
		if(OM.pilot && !H.faction_check_mob(OM.pilot))
			. += OM.pilot
	return .

//What happens when this action is selected? You'll override this and check_score mostly.
/datum/ai_goal/human/action(datum/component/human_ai/HA)
	if(istype(HA, /obj/structure/overmap))
		return ..()
	var/mob/living/carbon/human/H = HA.parent
	if(H.incapacitated() || H.client) //An admin overtook this mob or something, ignore.
		return FALSE

/datum/ai_goal/human/proc/can_action(datum/component/human_ai/HA)
	var/mob/living/carbon/human/H = HA.parent
	return (!H.incapacitated() && !H.client) //An admin overtook this mob or something, ignore.
/*

Goal #1, get a weapon!
If we don't have a weapon, we really ought to grab one...
This is to account for sec Ju-Jitsuing boarding commandos.

*/

/datum/ai_goal/human/acquire_weapon
	name = "Acquire Weapon" //Please keep these human readable for debugging!
	score = AI_SCORE_PRIORITY //Fighting takes priority
	required_trait = null //Set this if you want this task to only be achievable by certain types of ship.

/datum/ai_goal/human/acquire_weapon/check_score(datum/component/human_ai/HA)
	if(!..())
		return 0
	var/mob/living/carbon/human/H = HA.parent
	var/obj/A = H.get_active_held_item()
	//We already have a gun
	if(istype(A, /obj/item/gun))
		return 0
	return score

/datum/ai_goal/human/acquire_weapon/action(datum/component/human_ai/HA)
	message_admins("Running [name]... action() ...")
	if(!can_action(HA))
		return
	var/mob/living/carbon/human/H = HA.parent
	var/obj/item/storage/S = H.back
	var/obj/item/gun/target_item = null
	message_admins("Checking storage....")
	//Okay first off, is the gun already on our person?
	if(S)
		target_item = locate(/obj/item/gun) in S.contents

		if(H.can_equip(target_item, ITEM_SLOT_HANDS))
			H.visible_message("<span class='notice'>[H] rummages around in their backpack...</span>")
			H.temporarilyRemoveItemFromInventory(target_item)
			H.put_in_hands(target_item)
			return TRUE //We're done!
	message_admins("Checking floor....")
	//Now we run the more expensive check to find a gun laying on the ground.
	var/best_distance = world.maxx
	for(var/obj/O in oview(HA.view_range, H))
		var/dist = get_dist(O, H)
		if(istype(O, /obj/structure/closet) && dist <= best_distance)
			var/obj/structure/closet/C = O
			target_item = locate(/obj/item/gun) in C.contents
			if(target_item)
				best_distance = dist
		if(istype(O, /obj/item/gun) && dist <= best_distance)
			target_item = O
			best_distance = dist
	if(target_item)
		message_admins("Found [target_item]....")
		var/dist = get_dist(H, target_item)
		if(dist > 1)
			HA.pathfind_to(get_turf(target_item))
		else
			if(istype(target_item.loc, /obj/structure/closet))
				var/obj/structure/closet/C = target_item.loc
				if(C.open())
					H.visible_message("<span class='notice'>[H] pops open [C]...</span>")
			else
				H.visible_message("<span class='warning'>[H] grabs [target_item]!</span>")
				H.put_in_hands(target_item)

/datum/ai_goal/human/engage_targets
	name = "Engage targets"
	score = AI_SCORE_HIGH_PRIORITY //If we find a target, we want to engage!
	required_trait = null //Set this if you want this task to only be achievable by certain types of ship.

/*
//Calling for backup is a relatively high priority task if we're not healing or anything.
/datum/ai_goal/human/call_backup
	name = "Call for backup"
	score = 0
	required_trait = list(AI_TRAIT_SUPPORT)
	var/backup_range = 15 //Should be a reasonable enough range for AI eyes.

/datum/ai_goal/human/call_backup/check_score(datum/component/human_ai/HA)
	if(!..())
		return 0




/datum/ai_goal/human/call_backup/action(datum/component/human_ai/HA)
	if(!..())
		return
	HA.parent.do_alert_animation(HA.parent)
	playsound(HA.parent, 'sound/machines/chime.ogg', 50, 1, -1)
	HA.say(pick("GUARDS!", "HELP!!", "I NEED BACKUP!", "INTRUDERS!!!"))
	//Firstly! Call for the simplemobs..
	for(var/mob/living/simple_animal/hostile/M in oview(backup_range, HA.parent))
		if(HA.parent.faction_check_mob(HA.parent, TRUE))
			if(M.AIStatus == AI_OFF)
				return
			else
				M.Goto(HA.parent,M.move_to_delay,M.minimum_distance)
	//Secondly! Call for other intelligent AIs
	for(var/datum/component/human_ai/H in GLOB.human_ais)
		if(get_dist(H.parent, HA.parent) > backup_range))
			continue
		//TODO! call the pathfindingey thing
*/
