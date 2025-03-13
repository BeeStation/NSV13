//Cursed modular override file because for some reason this wasn't written dependant on the core.

/obj/machinery/nuclearbomb/selfdestruct
	desc = "For when it all gets too much to bear. Something seems.. off.. about this one."

/obj/machinery/nuclearbomb/selfdestruct/actually_explode()
	//Unblock roundend, we're not actually exploding.
	SSticker.roundend_check_paused = FALSE
	var/turf/bomb_location = get_turf(src)
	if(!bomb_location)
		disarm()
		return
	if(is_station_level(bomb_location.z))
		var/datum/round_event_control/beer_clog/beer_event = new()
		beer_event.runEvent()
		addtimer(CALLBACK(src, PROC_REF(really_actually_explode)), 110)
	else
		visible_message("<span class='notice'>[src] fizzes ominously.</span>")
		addtimer(CALLBACK(src, PROC_REF(fizzbuzz)), 110)

/obj/machinery/nuclearbomb/selfdestruct/proc/disarm()
	detonation_timer = null
	exploding = FALSE
	exploded = TRUE
	set_security_level(previous_level)
	for(var/obj/item/pinpointer/nuke/syndicate/S in GLOB.pinpointer_list)
		S.switch_mode_to(initial(S.mode))
		S.alert = FALSE
	countdown.stop()
	update_icon()
	update_ui_mode()
	ui_update()

/obj/machinery/nuclearbomb/selfdestruct/proc/fizzbuzz()
	var/datum/reagents/R = new/datum/reagents(1000)
	R.my_atom = src
	R.add_reagent(/datum/reagent/consumable/ethanol/beer, 100)

	var/datum/effect_system/foam_spread/foam = new
	foam.set_up(200, get_turf(src), R)
	foam.start()
	disarm()

/obj/machinery/nuclearbomb/selfdestruct/really_actually_explode()
	disarm()
