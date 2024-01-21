/obj/machinery/mineral/bluespace_miner
	name = "bluespace mining machine"
	desc = "A machine that uses the magic of Bluespace to slowly generate materials and add them to a linked ore silo."
	icon = 'aquila/icons/obj/machines/mining_machines.dmi'
	icon_state = "bs_miner"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/bluespace_miner
	layer = BELOW_OBJ_LAYER
	var/list/ore_rates = list(/datum/material/iron = 0.6, /datum/material/glass = 0.6, /datum/material/copper = 0.4, /datum/material/plasma = 0.2,  /datum/material/silver = 0.2, /datum/material/gold = 0.1, /datum/material/titanium = 0.1, /datum/material/uranium = 0.1, /datum/material/diamond = 0.1)
	var/datum/component/remote_materials/materials

/obj/machinery/mineral/bluespace_miner/Initialize(mapload)
	. = ..()
	materials = AddComponent(/datum/component/remote_materials, "bsm", mapload)
	RegisterSignal(src, COMSIG_REMOTE_MATERIALS_CHANGED, PROC_REF(on_material_change))
	update_appearance()

/obj/machinery/mineral/bluespace_miner/Destroy()
	materials = null
	return ..()

/obj/machinery/mineral/bluespace_miner/power_change()
	..()
	update_appearance()

/obj/machinery/mineral/bluespace_miner/update_icon(updates)
	. = ..()
	if(machine_stat & NOPOWER)
		icon_state = "bs_miner_off"
	else if(!materials?.silo || materials?.on_hold())
		icon_state = "bs_miner_halt"
	else
		icon_state = "bs_miner"

/obj/machinery/mineral/bluespace_miner/multitool_act(mob/living/user, obj/item/multitool/M)
	if(istype(M))
		if(!M.buffer || !istype(M.buffer, /obj/machinery/ore_silo))
			to_chat(user, "<span class='warning'>You need to multitool the ore silo first.</span>")
			return FALSE

/obj/machinery/mineral/bluespace_miner/examine(mob/user)
	. = ..()
	if(!materials?.silo)
		. += "<span class='notice'>No ore silo connected. Use a multi-tool to link an ore silo to this machine.</span>"
	else if(materials?.on_hold())
		. += "<span class='warning'>Ore silo access is on hold, please contact the quartermaster.</span>"

/obj/machinery/mineral/bluespace_miner/process()
	if(!materials?.silo || materials?.on_hold())
		update_appearance()
		return
	var/datum/component/material_container/mat_container = materials.mat_container
	if(!mat_container || panel_open || !powered())
		update_appearance()
		return
	var/datum/material/ore = pick(ore_rates)
	mat_container.insert_amount_mat((ore_rates[ore] * 1000), ore)

/obj/machinery/mineral/bluespace_miner/proc/on_material_change()
	if(materials?.silo)
		begin_processing()
	else
		end_processing()
	update_appearance()
