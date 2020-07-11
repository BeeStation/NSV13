//PUMP GOES HERE
/obj/machinery/armour_plating_nanorepair_pump
	name = "Armour Plating Nano-repair Pump"
	desc = "AP thingies that link to the Well"
	icon = 'nsv13/icons/obj/machinery/armour_pump.dmi'
	icon_state = "pump"
	pixel_x = -16
	density = TRUE
	anchored = TRUE
	idle_power_usage = 50
	active_power_usage = 50
	layer = ABOVE_MOB_LAYER
	obj_integrity = 500
	var/obj/machinery/armour_plating_nanorepair_well/apnw //parent device
	var/obj/structure/overmap/OM //parent ship
	var/armour_repair_amount = 0
	var/structure_repair_amount = 0
	var/armour_allocation = 0
	var/structure_allocation = 0
	var/online = TRUE
	var/stress_shutdown = FALSE
	var/quadrant = null
	var/apnw_id = null
	var/list/repair_records = list() //Graphs again
	var/repair_records_length = 120
	var/repair_records_interval = 10
	var/repair_records_next_interval = 0

/obj/machinery/armour_plating_nanorepair_pump/forward_port
	quadrant = "forward_port"

/obj/machinery/armour_plating_nanorepair_pump/aft_port
	quadrant = "aft_port"

/obj/machinery/armour_plating_nanorepair_pump/aft_starboard
	quadrant = "aft_starboard"

/obj/machinery/armour_plating_nanorepair_pump/forward_starboard
	quadrant = "forward_starboard"

/obj/machinery/armour_plating_nanorepair_pump/Initialize()
	.=..()
	OM = get_overmap()
	addtimer(CALLBACK(src, .proc/handle_linking), 10 SECONDS)

	repair_records["armour"] = list()
	repair_records["structure"] = list()

/obj/machinery/armour_plating_nanorepair_pump/examine(mob/user)
	.=..()
	if(quadrant)
		. += "<span class='notice'>This APNP is aligned to [quadrant]</span>"
	if(online)
		. += "<span class='notice'>It has a maintenance panel that appears to be welded shut</span>"
	if(!online)
		. += "<span class='notice'>The maintenance panel is open</span>"
	if(stress_shutdown)
		. += "<span class='warning'>The system overload lights are flashing</span>"

/obj/machinery/armour_plating_nanorepair_pump/process()
	if(online && is_operational() && !stress_shutdown)
		idle_power_usage = 0
		if(armour_allocation)
			if(OM.armour_quadrants[quadrant]["current_armour"] < OM.armour_quadrants[quadrant]["max_armour"]) //Basic Implementation
				armour_repair_amount = ((1 / (0.01 + ((NUM_E ** (-0.05 * ((OM.armour_quadrants[quadrant]["current_armour"] / OM.armour_quadrants[quadrant]["max_armour"]) * 100))) / 2))) * (apnw.repair_efficiency * (armour_allocation / 100))) / 50
				if(apnw.repair_resources >= armour_repair_amount)
					message_admins("ARA: [armour_repair_amount]")
					OM.armour_quadrants[quadrant]["current_armour"] += armour_repair_amount
					if(OM.armour_quadrants[quadrant]["current_armour"] > OM.armour_quadrants[quadrant]["max_armour"])
						OM.armour_quadrants[quadrant]["current_armour"] = OM.armour_quadrants[quadrant]["max_armour"]
					apnw.repair_resources -= armour_repair_amount
					idle_power_usage += armour_repair_amount * 100 //test case
		if(structure_allocation)
			if(OM.obj_integrity < OM.max_integrity) //Basic Implementation
				structure_repair_amount = (1 * apnw.repair_efficiency * structure_allocation) / 100 //test case
				if(apnw.repair_resources >= structure_repair_amount * 10)
					OM.obj_integrity += structure_repair_amount
					if(OM.obj_integrity > OM.max_integrity)
						OM.obj_integrity = OM.max_integrity
					apnw.repair_resources -= structure_repair_amount
					idle_power_usage += structure_repair_amount * 100 //test case
	else
		armour_repair_amount = 0
		structure_repair_amount = 0
		idle_power_usage = initial(idle_power_usage)
	update_icon() //temp

	if(world.time >= repair_records_next_interval)
		repair_records_next_interval = world.time + repair_records_interval

		var/list/armour = repair_records["armour"]
		armour += armour_repair_amount
		if(armour.len > repair_records_length)
			armour.Cut(1, 2)

		var/list/structure = repair_records["structure"]
		structure += structure_repair_amount
		if(structure.len > structure_repair_amount)
			structure.Cut(1, 2)

/obj/machinery/armour_plating_nanorepair_pump/proc/handle_linking()
	if(apnw_id) //If mappers set an ID)
		for(var/obj/machinery/armour_plating_nanorepair_well/W in GLOB.machines)
			if(W.apnw_id == apnw_id)
				apnw = W

/obj/machinery/armour_plating_nanorepair_pump/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_MULTITOOL)
		if(!multitool_check_buffer(user, I))
			return
		var/obj/item/multitool/M = I
		apnw = M.buffer
		M.buffer = null
		quadrant = input(user, "Direct nano-repair pump to which quadrant?", "[name]") as null|anything in list("forward_port", "forward_starboard", "aft_port", "aft_starboard")
		playsound(src, 'sound/items/flashlight_on.ogg', 100, TRUE)
		to_chat(user, "<span class='notice'>Buffer transfered</span>")

/obj/machinery/armour_plating_nanorepair_pump/welder_act(mob/user, obj/item/tool)
	. = FALSE
	if(online)
		to_chat(user, "<span class='notice'>You start to unseal the maintenance panel cover...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You unseal and remove the maintenance panel cover</span>")
			online = FALSE
			update_icon()
			return TRUE
	if(!online)
		to_chat(user, "<span class='notice'>You start to replace and seal the maintenance panel cover...</span>")
		if(tool.use_tool(src, user, 40, volume=100))
			to_chat(user, "<span class='notice'>You replace the maintenance panel cover and seal it</span>")
			online = TRUE
			update_icon()
			return TRUE

/obj/machinery/armour_plating_nanorepair_pump/wrench_act(mob/user, obj/item/tool)
	. = FALSE
	if(!online && stress_shutdown)
		to_chat(user, "<span class='notice'>You start to purge and restart the pump...</span>")
		if(tool.use_tool(src, user, 100, volume=100))
			to_chat(user, "<span class='notice'>You restart the pump</span>")
			stress_shutdown = FALSE
			update_icon()
			return TRUE

/obj/machinery/armour_plating_nanorepair_pump/update_icon()
	cut_overlays()
	if(!online)
		icon_state = "pump_maint"
		set_light(0)
	if(stress_shutdown)
		add_overlay("stressed")
		light_color = LIGHT_COLOR_RED
		set_light(1)
	if(online)
		icon_state = "pump"
		var/repair_total = armour_repair_amount + structure_repair_amount
		if(repair_total > 0)
			add_overlay("active")
			light_color = LIGHT_COLOR_CYAN
			set_light(1)

/obj/machinery/armour_plating_nanorepair_pump/attack_hand(mob/living/carbon/user)
	.=..()
	if(!apnw)
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Unable to detect linked well</span>")
		return
	ui_interact(user)

/obj/machinery/armour_plating_nanorepair_pump/attack_ai(mob/user)
	.=..()
	if(!apnw)
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Unable to detect linked well</span>")
		return
	ui_interact(user)

/obj/machinery/armour_plating_nanorepair_pump/attack_robot(mob/user)
	.=..()
	if(!apnw)
		var/sound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
		playsound(src, sound, 100, 1)
		to_chat(user, "<span class='warning'>Unable to detect linked well</span>")
		return
	ui_interact(user)

/obj/machinery/armour_plating_nanorepair_pump/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state) // Remember to use the appropriate state.
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ArmourPlatingNanorepairPump", name, 560, 300, master_ui, state)
		ui.open()

/obj/machinery/armour_plating_nanorepair_pump/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	if(!in_range(src, usr))
		return
	var/adjust = text2num(params["adjust"])
	if(action == "armour_allocation")
		if(adjust && isnum(adjust))
			armour_allocation = adjust
			if(armour_allocation > 100 - structure_allocation)
				armour_allocation = 100 - structure_allocation
				return
			if(armour_allocation <= 0)
				armour_allocation = 0
				return
	if(action == "structure_allocation")
		if(adjust && isnum(adjust))
			structure_allocation = adjust
			if(structure_allocation > 100 - armour_allocation)
				structure_allocation = 100 - armour_allocation
				return
			if(structure_allocation <= 0)
				structure_allocation = 0
				return

/obj/machinery/armour_plating_nanorepair_pump/ui_data(mob/user)
	var/list/data = list()
	data["armour_allocation"] = armour_allocation
	data["structure_allocation"] = structure_allocation
	data["armour_repair_amount"] = armour_repair_amount
	data["structure_repair_amount"] = structure_repair_amount
	data["repair_records"] = repair_records
	return data

/obj/item/circuitboard/machine/armour_plating_nanorepair_pump
	name = "Armour Plating Nano-repair Pump (Machine Board)"
	build_path = /obj/machinery/armour_plating_nanorepair_pump
	req_components = list(
		/obj/item/stock_parts/manipulator = 10,
		/obj/item/stock_parts/scanning_module = 5,
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/micro_laser = 6)