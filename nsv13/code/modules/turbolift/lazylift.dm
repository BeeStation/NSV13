/*

Lazy man's turbolift. A lift class which involves 0 var editing and very little hassle for mappers.

Steps:

Place turbolift on the bottom floor of your ship
Ensure there's a load of open space above it for any decks above.
Ensure that each lift is inside a unique area.
Give each lift segment on each deck a call button. Ensure it's in the same area as the lift. This should be outside the lift, as the button is what you use to call the lift to your location.
That's it.

Rules:
Lifts require doors. They must have at least one, or the system will get finnicky.
Lifts must have an even amount of floorspace on each deck. Or we'll get nightmarish bugs.
Everything above the bottom floor of the turbolift should be open space! The platform of a turbolift always starts at the bottom!
Place whatever turf type you want the "platform" to be made out of on the bottom floor.
Lifts need one or more doors to be placed. Otherwise it will forcibly make one for you in a random location. Lifts require doors to function. That's why we use indestructible turbolift airlocks as standard. However, that's not to stop you from using a regular ol' door.
Turbolifts need to be in a unique turbolift area.
Voice activation mode picks up areas based off of their in-world position. If you re-use areas over multiple decks, expect issues (You really shouldn't be doing that anyway...).
Example:

[]LIFT[]
[]	  []
[]DOOR[]

For a simple lift.

Things of note:
You're fine to place your own turbolift doors down. If the lift can't locate any, it'll place one of its own out of spite.



That's it, ok bye!

*/

//Mappers, DON'T USE ME! Use the other one.

/area/shuttle/turbolift
	ambient_buzz = 'nsv13/sound/effects/lift/elevatormusic.ogg' //Mandatory.

/obj/machinery/lazylift_button
	name = "Turbolift call button"
	desc = "A button that can call a turbolift to your location, so that you can board it. Be sure to mash it as often as physically possible."
	icon = 'icons/obj/turbolift.dmi'
	icon_state = "button"
	can_be_unanchored = FALSE
	density = FALSE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	var/obj/machinery/lazylift/lift = null //Pointer to the lift controller in our area on this deck, we then ask its master to path the lift to us, assuming it isn't busy or anything.

/obj/machinery/lazylift_button/attack_robot(mob/user)
	return attack_hand(user)

/obj/machinery/lazylift_button/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/lazylift_button/attack_hand(mob/user)
	if (stat & NOPOWER || !lift)
		to_chat(user, "<span class='warning'>Nothing happens...</span>")
		return
	if(isliving(user) && user.mouse_opacity) //Don't display things like AIs or admin ghosts clicking the button.
		visible_message("<span class='notice'>[user] [pick("calmly presses", "mashes", "pokes", "slaps", "hits")] [src] </span>", "<span class='notice'>You push [src].</span>")
	flick("button_lit", src)
	lift.master.path_to(lift.deck, lift.master.platform_location.deck)

/obj/machinery/door/airlock/ship/public/glass/turbolift
	name = "turbolift door"
	desc = "A bulkhead which opens and closes."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF //Go away greytiders

//Lifts speak a lotta languages, alien isn't one of 'em.
/datum/language_holder/synthetic/turbolift
	spoken_languages = list(/datum/language/common)
	understood_languages = list(/datum/language/common, /datum/language/machine, /datum/language/draconic, /datum/language/drone)

/obj/machinery/lazylift
	name = "Turbolift interface panel"
	desc = "A control panel for elevators, simply talk into its microphone to tell it where you want to go. Brought to you by the Sirius Cybernetics Corporation."
	icon = 'nsv13/icons/obj/computers.dmi'
	icon_state = "turbolift"
	pixel_y = 26 //E.
	anchored = TRUE
	can_be_unanchored = FALSE
	movement_type = FLYING //Turbolifts can't fall for anyone - won't get fooled again like I did.
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF //Go away greytiders
	var/turf_type = null
	var/deck = 1 //For display and record-keeping purposes.
	var/obj/machinery/lazylift/master/master = null
	var/list/platform = list() //The """platform""" of the lift that's going to move up and down. This is just a list of turfs that we own.
	var/list/doors = list()
	var/static/list/moving_blacklist = list(/obj/machinery/lazylift, /obj/machinery/lazylift/master, /obj/machinery/light, /obj/structure/cable, /obj/machinery/power/apc, /obj/machinery/airalarm, /obj/machinery/firealarm, /obj/structure/grille, /obj/structure/window, /obj/machinery/camera)

	//Voice activation.
	flags_1 = HEAR_1
	initial_language_holder = /datum/language_holder/synthetic/turbolift
	var/list/addresses = list() //Voice activation! Lets you speak into the elevator to tell it where you wanna go. This stores all the departments on this floor. If youre lazy and re-use floors then uh...sucks to be you I guess!
	var/list/area_blacklist = list(/area/space, /area/shuttle/turbolift, /area/shuttle, /area/maintenance/ship_exterior) //Areas that do not show up on the address book.
	var/next_voice_activation = 0

/obj/machinery/lazylift/attack_robot(mob/user)
	return attack_hand(user)

/obj/machinery/lazylift/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/lazylift/attack_hand(mob/user)
	var/list/deckNums = list()
	for(var/obj/machinery/lazylift/LL in master.decks)
		deckNums += LL.deck
	var/theDeck = input(user, "Which deck would you like to go to?", name, null) as null|anything in deckNums
	if(!theDeck || !isnum(theDeck))
		return FALSE
	master.path_to(theDeck)

/obj/machinery/lazylift/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	set waitfor = FALSE
	. = ..()
	if(speaker == src || world.time < next_voice_activation || master.in_use || get_area(speaker) != get_area(src) || !(get_turf(speaker) in platform))
		return
	var/datum/language_holder/L = get_language_holder()
	if(!L?.has_language(message_language))
		say("[pick("I'm sorry, I didn't quite understand that!", "Please speak clearly into the microphone.", "Unable to process voice command.")]")
		return
	if(findtext(raw_message, "?")) //Don't ask questions, just clearly state your intent.
		return
	next_voice_activation = world.time + 1 SECONDS //To avoid spamming list iteration.
	for(var/obj/machinery/lazylift/LL in master.decks)
		if(findtext(raw_message, "deck") || findtext(raw_message, "floor")) //Alright they're asking for a specific deck.
			if(findtext(raw_message, num2text(LL.deck)))
				master.path_to(LL.deck)
				playsound(src.loc, 'sound/machines/chime.ogg', 100, TRUE)
				return TRUE
		for(var/area/AR in LL.addresses)
			var/department = AR.name
			if(findtext(raw_message, department))
				master.path_to(LL.deck)
				playsound(src.loc, 'sound/machines/chime.ogg', 100, TRUE)
				return TRUE

/obj/machinery/lazylift/proc/setup()
	set waitfor = FALSE //Don't wanna get hung up on creating doors do we?
	var/turf/open/door_turf = null
	for(var/turf/T in platform)
		if(istype(T, /turf/open/openspace) || T.z != z)
			continue
		door_turf = T
		var/obj/machinery/door/airlock/door = locate(/obj/machinery/door/airlock) in T
		if(door)
			doors += door
			platform -= T
	if(!door_turf)
		message_admins("Couldn't find a turbolift door turf for [src]!")
		return

/obj/machinery/lazylift/proc/check_mobs_in_lift()
	var/mobs = 0
	for(var/atom/movable/AM in get_area(src))
		if(AM.z != z)
			continue
		if(isliving(AM))
			mobs ++
	return (mobs <= 0)

//Mappers, use me! The other one is generated by this thing.
/obj/machinery/lazylift/master
	name = "Elevator control panel"
	var/list/decks = list() //Lifts that are slaved to this 'un. This abuses pointers to tell a lift object to point to a given deck.
	var/obj/machinery/lazylift/platform_location = null //Where is the lift platform at?
	var/in_use = FALSE
	var/turbolift_loop_sound = 'nsv13/sound/effects/lift/elevator_loop.ogg'
	var/turbolift_start_sound = 'nsv13/sound/effects/lift/elevator_start.ogg'
	var/turbolift_end_sound = 'nsv13/sound/effects/lift/elevator_end.ogg'
	var/start_delay = 1 SECONDS
	var/end_delay = 0.5 SECONDS
	var/turbolift_delay = 4 SECONDS //How long should the turbolift stay on each deck? Don't make this delay higher than a few seconds, or BYOND will start to complain.
	var/wait_time = 5 SECONDS //Brief cooldown after the lift reaches its destination, to allow people from that floor to board it.
	var/play_voice_lines = TRUE //Do you want your elevator to sarcastically tell you that it's going up or down? Thanks to Corsaka / Skullmagic for the VA!
	var/open_doors_on_arrival = FALSE

/obj/machinery/lazylift/master/aircraft_elevator
	open_doors_on_arrival = TRUE

/obj/machinery/lazylift/master/advanced //Fancy elevators for fancy crews.
	name = "Turbolift control panel"
	icon_state = "turbolift_solgov"
	start_delay = 1.4 SECONDS
	end_delay = 2 SECONDS
	turbolift_delay = 2 SECONDS
	pixel_y = 32
	turbolift_loop_sound = 'nsv13/sound/effects/lift/lift_loop.ogg'
	turbolift_start_sound = 'nsv13/sound/effects/lift/lift_start.ogg'
	turbolift_end_sound = 'nsv13/sound/effects/lift/lift_end.ogg'
	play_voice_lines = FALSE //Fancy, silent lift.

/obj/machinery/lazylift/Initialize()
	. = ..()
	for(var/turf/T in get_area(src))
		if(T.z != z)
			continue
		if(!istype(T, /turf/open))
			var/obj/machinery/lazylift_button/BB = locate(/obj/machinery/lazylift_button) in T
			if(BB)
				BB.lift = src
			continue
		else
			platform += T
	addtimer(CALLBACK(src, .proc/acquire_destinations), 10 SECONDS)
	setup()

/obj/machinery/lazylift/proc/acquire_destinations()
	for(var/x in SSmapping.areas_in_z["[z]"])
		var/area/AR = x
		if(AR.type in area_blacklist)
			continue
		addresses += AR

/obj/machinery/lazylift/master/Initialize()
	. = ..()
	master = src
	var/turf/T = get_turf(src)
	turf_type = T.type
	//Time to set up the wacky turbolift network!
	platform_location = src //IMPORTANT! Platform starts at the bottom lift.
	var/turf/last = get_turf(src)
	decks += src //Ew. But necessary.
	for(var/I = 0; I <= world.maxz; I++)
	{
		var/turf/next = SSmapping.get_turf_above(last)
		if(!istype(next, /turf/open/openspace))
			break //That means we've hit the end of the line, stop here.
		var/obj/machinery/lazylift/slave = new /obj/machinery/lazylift(next)
		slave.master = src
		slave.icon_state = icon_state
		//For consistency
		slave.pixel_x = pixel_x
		slave.pixel_y = pixel_y
		slave.dir = dir
		last = next
		decks += slave
	}
	//We use the Star Trek naming convention for decks. Deck 1 is actually at the top, so we count from the top.
	var/count = decks.len
	for(var/obj/machinery/lazylift/LL in decks){
		LL.deck = count
		count --
	}
	close_all_doors() //Start off by closing all the doors.
	platform_location.unbolt_doors(open_doors_on_arrival) //But ensure that you can board the lift at some point.
	set_music()
	for(var/blacklist in moving_blacklist)
		moving_blacklist += typecacheof(blacklist)

//Lets you set the elevator music for this turbolift. Used by emags to make the music ~~horrible~~ amazing

/obj/machinery/lazylift/master/proc/set_music(what)
	if(!what)
		what = pick('sound/effects/turbolift/elevatormusic.ogg','nsv13/sound/effects/lift/elevatormusic.ogg', 'nsv13/sound/effects/lift/GeorgeForse-rick.ogg', 'nsv13/sound/effects/lift/tchaikovsky.ogg')
	var/area/ours = get_area(src)
	for(var/area/affected in GLOB.sortedAreas)
		if(istype(affected, ours.type))
			affected.ambient_buzz = what

//Emag the lift to let it crush people. Otherwise, its built in safeties will kick in.
/obj/machinery/lazylift/emag_act(mob/user)
	return master.emag_act(user)

/obj/machinery/lazylift/master/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	set_music('nsv13/sound/effects/lift/emagged.ogg') //Wonderful music, manifique, c'est encroyable.
	req_access = list()
	obj_flags |= EMAGGED
	turbolift_delay = 1 SECONDS //NYOOOOOM
	to_chat(user, "<span class='notice'>You fry [src]'s safety overrides, de-limiting its speed control circuits, button control priviledges and disabling its ability to avoid crushing people at the bottom of the shaft.</span>")

//Method to generate a path to a specific deck. If we're on deck 1, and want to reach deck 3, we have to go via deck 2 first.
/obj/machinery/lazylift/master/proc/path_to(target_deck, startDeck=platform_location.deck)
	if(in_use)
		return FALSE
	if(startDeck == target_deck)
		platform_location.unbolt_doors()
		in_use = FALSE //in use more like in PUCE am I right gamers???
		return FALSE
	var/safety = (obj_flags & EMAGGED) ? FALSE : TRUE
	if(safety) //Emag the master turbolift controller to wreak havoc with the lift system and allow it to gib people.
		for(var/obj/machinery/lazylift/LL in decks)
			if(LL.deck != startDeck) //Check elevator decks other than ourselves for mobs before we start.
				if(!LL.check_mobs_in_lift())
					return FALSE
	in_use = TRUE
	close_all_doors() //Just in case. Let's make sure those doors are all bolted, except for the entry point.
	var/list/path = list()
	if(target_deck > startDeck)
		if(play_voice_lines)
			playsound(platform_location, 'nsv13/sound/effects/lift/goingdown.ogg', 100, FALSE)
			platform_location.say("Elevator going down.")
		for(var/I = ++startDeck; I <= target_deck; I++){
			path += I
		}
	else
		if(play_voice_lines)
			playsound(platform_location, 'nsv13/sound/effects/lift/goingup.ogg', 100, FALSE)
			platform_location.say("Elevator going up.")
		for(var/I = --startDeck; I >= target_deck; I--){
			path += I
		}
	if(!path.len)
		message_admins("Uhh..turbolift didn't have a path..that's not good.")
		platform_location.unbolt_doors()
		in_use = FALSE //in use more like in PUCE am I right gamers???
		return FALSE //FUCK
	playsound(platform_location.loc, 'sound/effects/turbolift/turbolift-close.ogg', 100, FALSE)
	sound_effect(start=TRUE)
	for(var/_deck in path)
		sleep(turbolift_delay)
		if(_deck == target_deck)
			sound_effect(start=FALSE)
		move_platform(_deck)
	platform_location.unbolt_doors(open_doors_on_arrival)
	addtimer(VARSET_CALLBACK(src, in_use, FALSE), wait_time)

/obj/machinery/lazylift/master/proc/move_platform(targetDeck)
	var/obj/machinery/lazylift/target = null
	for(var/obj/machinery/lazylift/L in decks) //First pass: Find the target
		if(L.deck == targetDeck)
			target = L
			if(target == src)
				for(var/turf/T in platform)
					for(var/atom/movable/AM in T)
						if(isturf(AM))
							continue
						if(isliving(AM))
							var/mob/living/karmics_victim = AM //SQUISH
							karmics_victim.gib() //Elevator suicides are...a thing I guess!
						else
							AM.ex_act(4) //Crush
			break
	if(!target)
		message_admins("Turbolift couldnt find a target..this is bad...")
		return FALSE

	//First, move the platform.
	for(var/turf/T in platform_location.platform)
		var/turf/newT = locate(T.x,T.y,target.z)
		newT.ChangeTurf(T.type, list(/turf/open/openspace, /turf/open/floor/plating), CHANGETURF_INHERIT_AIR)
		for(var/atom/movable/AM in T.contents)
			if(AM.type in moving_blacklist) //To stop the lift moving itself and its components
				if(AM.anchored)
					continue
			AM.forceMove(newT)
		if(platform_location != src)
			T.ScrapeAway(2)
		else
			T.ScrapeAway()
	//Then, clear up everything else
	for(var/obj/machinery/lazylift/next in decks)
		if(next == platform_location || next == target)
			continue //Already done these ones in that other loop.
		for(var/turf/T in next.platform)
			var/obj/machinery/door/airlock/turbolift_door = locate(/obj/machinery/door/airlock) in T
			if(turbolift_door) //Don't scrape away the doors.
				if(turbolift_door in next.doors) //I mean, fuck whatever doors the players decide to build I guess.
					continue
			else
				T.ScrapeAway(2)
	platform_location = target
	//Finally, ensure that the bottom floor is always plating.
	for(var/turf/T in platform)
		if(src != target)
			T.ChangeTurf(/turf/open/floor/plasteel/elevatorshaft, list(/turf/open/openspace, /turf/open/floor/plating), CHANGETURF_INHERIT_AIR)

//Special FX and stuff.

/obj/machinery/lazylift/master/proc/sound_effect(start)
	if(start)
		for(var/mob/M in get_area(src))
			SEND_SOUND(M, turbolift_start_sound)
			shake_camera(M, 2, 1)
			if(!isliving(M))
				continue
			if(obj_flags & EMAGGED)
				var/mob/living/karmics_victim = M
				karmics_victim.Knockdown(5 SECONDS)
				shake_camera(karmics_victim, 10, 1)
				to_chat(karmics_victim, "<span class='warning'>You're pressed into the floor as the lift rapidly accelerates!</span>")
				if(prob(50)) //Unlucky fucker
					to_chat(karmics_victim, "<span class='warning'>You hit your head as you're thrown about wildly!</span>")
					karmics_victim.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)
					playsound(karmics_victim.loc, 'nsv13/sound/effects/lift/bonk.ogg', 100)
				if(HAS_TRAIT(karmics_victim, TRAIT_SEASICK)) //oh my god you poor soul
					to_chat(karmics_victim, "<span class='warning'>You can feel your head start to swim...</span>")
					karmics_victim.adjust_disgust(100)
		sleep(start_delay) //Sound time!
		for(var/mob/M in get_area(src))
			SEND_SOUND(M, sound(turbolift_loop_sound, repeat = TRUE, wait = 0, volume = 100, channel = CHANNEL_AMBIENT_EFFECTS))
		return
	else
		if(play_voice_lines)
			playsound(platform_location, 'nsv13/sound/effects/lift/mindthegap.ogg', 100, FALSE)
			platform_location.say("Please mind the gap.")
		for(var/mob/M in get_area(src))
			SEND_SOUND(M, sound(turbolift_end_sound, repeat = FALSE, wait = 0, volume = 100, channel = CHANNEL_AMBIENT_EFFECTS))
		sleep(end_delay)
		return

/obj/machinery/lazylift/proc/close_doors()
	for(var/obj/machinery/door/airlock/theDoor in doors)
		theDoor.unbolt()
		if(!theDoor.close()) //Close and bolt this badboy.
			if(!theDoor.locked) //Failed to close, and is not bolted. So something went wrong. Abort.
				return FALSE
		theDoor.bolt()
	return TRUE

/obj/machinery/lazylift/proc/unbolt_doors(openThemToo)
	for(var/obj/machinery/door/airlock/theDoor in doors)
		theDoor.unbolt()
		if(openThemToo)
			theDoor.open()
			theDoor.bolt()

/obj/machinery/lazylift/master/proc/close_all_doors()
	for(var/obj/machinery/lazylift/target in decks)
		if(!target.close_doors())
			return FALSE
	return TRUE

/obj/machinery/lazylift/master/proc/unbolt_all_doors()
	set waitfor = FALSE
	for(var/obj/machinery/lazylift/target in decks)
		target.unbolt_doors()
	return TRUE
