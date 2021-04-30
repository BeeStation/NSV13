/obj/item/circuitboard/computer/squad_manager
	name = "circuit board (squad management computer)"
	build_path = /obj/machinery/computer/squad_manager

/obj/machinery/computer/squad_manager
	name = "Squad Management Computer"
	desc = "A console which allows you to manage the ship's squads and assign people to different squads."
	icon_screen = "squadconsole"
	req_one_access = ACCESS_HEADS
	circuit = /obj/item/circuitboard/computer/squad_manager
	var/next_major_action = 0 //To stop the infinite BOOOP spam.

/obj/machinery/computer/squad_manager/attackby(obj/item/W, mob/user, params)
	if(istype(W , /obj/item/clothing/suit/ship/squad))
		W.forceMove(src)
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 100, 0)
		return FALSE
	if(istype(W, /obj/item/squad_pager))
		W.forceMove(src)
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 100, 0)
		return FALSE
	if(istype(W, /obj/item/clothing/neck/squad))
		W.forceMove(src)
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 100, 0)
		return FALSE
	. = ..()

/obj/machinery/computer/squad_manager/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SquadManager")
		ui.open()
/obj/machinery/squad_vendor
	name = "Squad Vendor"
	desc = "A machine which can dispense equipment to squads. <i>Kits taken from this machine must be returned before you can get a new one.</i>"
	icon = 'nsv13/icons/obj/computers.dmi'
	icon_state = "squadvend"
	anchored = TRUE
	density = TRUE
	obj_integrity = 500
	max_integrity = 500 //Tough nut to crack, due to how it'll spit out a crap load of squad gear like a goddamned pinata.
	resistance_flags = ACID_PROOF | FIRE_PROOF
	req_one_access = list(ACCESS_HOP, ACCESS_HOS)
	var/list/loaned = list() //List of mobs who have taken a kit without returning it. To get a new kit, you have to return the old one.
