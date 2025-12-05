//Fluff objects that don't really fit into any other file.

/obj/machinery/smartfridge/drinks/pretender_stormdrive
	name = "Ruined stormdrive"
	desc = "Abandoned for ages. Could probably be used to store your beer."
	icon = 'nsv13/goonstation/icons/reactor.dmi'
	icon_state = "broken"
	use_power = NO_POWER_USE

/obj/machinery/smartfridge/drinks/pretender_stormdrive/update_icon()
	return

/obj/machinery/smartfridge/drinks/pretender_stormdrive/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/I)
	return

/obj/machinery/smartfridge/drinks/pretender_stormdrive/default_unfasten_wrench(mob/user, obj/item/I, time)
	return

/obj/machinery/smartfridge/drinks/pretender_stormdrive/default_deconstruction_crowbar(obj/item/I, ignore_panel)
	return

/obj/machinery/smartfridge/drinks/pretender_stormdrive/default_pry_open(obj/item/I)
	return
