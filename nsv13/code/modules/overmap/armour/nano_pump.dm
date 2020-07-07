//PUMP GOES HERE
/obj/machinery/armour_plating_nanorepair_pump
	name = "Armour Plating Nano-repair Pump"
	desc = "AP thingies that link to the Well"
	icon = 'nsv13/icons/obj/machinery/armour_pump.dmi'
	icon_state = "pump"
	density = TRUE
	anchored = TRUE
	idle_power_usage = 50
	active_power_usage = 50
	var/obj/machinery/armour_plating_nanorepair_well/apnw //parent device
	var/obj/structure/overmap/OM //parent ship
	var/armour_repair_amount = 0
	var/structure_repair_amount = 0
	var/armour_allocation = 0
	var/structure_allocation = 0
	var/online = 0 //Binary online/offline
	var/quadrant = null
	var/apnw_id = null
	var/list/repair_records = list() //Graphs again
	var/repair_records_length = 120
	var/repair_records_interval = 10
	var/repair_records_next_interval = 0

/obj/machinery/armour_plating_nanorepair_pump/forward_port
	quadrant = "foward_port"

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

/*
/obj/machinery/armour_plating_nanorepair_pump/examine(mob/user)
	.=..()
	. += "<span class='notice'>This APNP is aligned to [quadrant.designation]</span>"
*/

/obj/machinery/armour_plating_nanorepair_pump/process()
	if(online)
		if(armour_allocation)
			if(OM.armour_quadrants[quadrant]["current_armour"] <= OM.armour_quadrants[quadrant]["max_armour"]) //Basic Implementation
				armour_repair_amount = min(((1 / 0.01 + (NUM_E ** (((OM.armour_quadrants[quadrant]["current_armour"]/OM.armour_quadrants[quadrant]["max_armour"]) * -100) / 2))) * apnw.repair_efficiency * armour_allocation), OM.armour_quadrants[quadrant]["max_armour"] - OM.armour_quadrants[quadrant]["current_armour"]) //Math time
				if(apnw.repair_resources >= armour_repair_amount)
					OM.armour_quadrants[quadrant]["current_armour"] += armour_repair_amount
					apnw.repair_resources -= armour_repair_amount
					active_power_usage = armour_repair_amount * 100 //test case
		if(structure_allocation)
			if(OM.obj_integrity <= OM.max_integrity) //Basic Implementation
				structure_repair_amount = min(1 * apnw.repair_efficiency * armour_allocation, OM.max_integrity - OM.obj_integrity) //test case
				if(apnw.repair_resources >= structure_repair_amount * 10)
					OM.obj_integrity += structure_repair_amount
					apnw.repair_resources -= structure_repair_amount
					active_power_usage = structure_repair_amount * 100 //test case
	else
		armour_repair_amount = 0
		structure_repair_amount = 0
		active_power_usage = initial(active_power_usage)

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

/obj/machinery/armour_plating_nanorepair_pump/update_icon()
	cut_overlays()
	if(!online)
		icon_state = "pump_maint"
	if(online)
		icon_state = "pump"
		add_overlay("active")
		var/total_allocation = armour_allocation + structure_allocation
		switch(total_allocation)
			if(0 to 25)
				icon_state = "pump_0"
			if(25 to 50)
				icon_state = "pump_25"
			if(50 to 75)
				icon_state = "pump_50"
			if(75 to 100)
				icon_state = "pump_75"
			if(100 to INFINITY)
				icon_state = "pump_100"

/obj/machinery/armour_plating_nanorepair_pump/attack_hand(mob/living/carbon/user)
	.=..()
	ui_interact(user)

/obj/machinery/armour_plating_nanorepair_pump/attack_ai(mob/user)
	.=..()
	ui_interact(user)

/obj/machinery/armour_plating_nanorepair_pump/attack_robot(mob/user)
	.=..()
	ui_interact(user)

/obj/machinery/armour_plating_nanorepair_pump/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state) // Remember to use the appropriate state.
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "ArmourPlatingNanorepairPump", name, 560, 600, master_ui, state)
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
			if(armour_allocation < 0)
				armour_allocation = 0
				return
	if(action == "structure_allocation")
		if(adjust && isnum(adjust))
			structure_allocation = adjust
			if(structure_allocation > 100 - armour_allocation)
				structure_allocation = 100 - armour_allocation
				return
			if(structure_allocation < 0)
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