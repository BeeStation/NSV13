/obj/item/borg/apparatus/munitions
	name = "integrated mechanical clamp"
	desc = "A mechanical clamp designed for carrying highly volatile equipment without causing violent reactions."
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_clamp"
	storable = list(
		/obj/item/powder_bag,
		/obj/item/ship_weapon/ammunition,
		/obj/item/ship_weapon/parts,
		/obj/item/ammo_box/magazine/nsv,
	)

/obj/item/borg/apparatus/munitions/update_icon()
	cut_overlays()
	if(stored)
		COMPILE_OVERLAYS(stored)
		stored.pixel_x = 0
		stored.pixel_y = 0
		var/image/img = image("icon"=stored, "layer"=FLOAT_LAYER)
		img.plane = FLOAT_PLANE
		add_overlay(img)

/obj/item/borg/apparatus/munitions/examine()
	. = ..()
	if(stored)
		. += "The clamps are currently holding [stored]"
		. += "<span class='notice'<i>Alt-click</i> will drop the currently stored [stored].</span>"

/obj/item/borg/apparatus/munitions/AltClick(mob/living/silicon/robot/user)
	if(!stored)
		return ..()
	stored.pixel_x = initial(stored.pixel_x)
	stored.pixel_y = initial(stored.pixel_y)
	stored.forceMove(get_turf(user))

/obj/item/airlock_painter/cyborg
	name = "integrated airlock painter"
	desc = "An integrated device intended to be used to paint fighter crafts."
	initial_ink_type = /obj/item/toner/extreme

/obj/item/borg/fuelnozzle
	name = "integrated cryofuel delivery hose"
	desc = "An integrated cryofuel delivery hose, this integrated version is equipped with an internal fuel synthesizer."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "atmos_nozzle"
	item_flags = NOBLUDGEON
	var/max_volume_to_recharge = 3500
	/// Cell cost for recharging the integrated fuel tank
	var/charge_cost = 300
	/// Counts up to the next time we charge
	var/charge_timer = 0
	/// Time it takes for fuel to recharge each cycle (in seconds)
	var/recharge_time = 10
	/// Amount of fuel units to transfer per second
	var/units_per_second = 50
	/// The target to refuel
	var/obj/structure/overmap/small_craft/fuel_target
	var/max_range = 2
	var/datum/looping_sound/refuel/soundloop
	var/datum/reagents/internal_tank
	var/datum/reagent/fuel = /datum/reagent/cryogenic_fuel
	var/allow_recharge = FALSE

/obj/item/borg/fuelnozzle/Initialize(mapload)
	. = ..()
	internal_tank = new(new_flags = NO_REACT)
	internal_tank.maximum_volume = max_volume_to_recharge + 1
	internal_tank.add_reagent(fuel, (max_volume_to_recharge + 1), reagtemp = 40, no_react = TRUE)
	soundloop = new(src)
	START_PROCESSING(SSobj, src)

/obj/item/borg/fuelnozzle/examine(mob/user)
	. = ..()
	for(var/datum/reagent/cryogenic_fuel/reagent in internal_tank.reagent_list)
		if(reagent)
			. += "Currently has [round(reagent.volume, 0.01) - 1] units of fuel."

/obj/item/borg/fuelnozzle/proc/start_fuelling(target, mob/user)
	if(!target)
		return
	ui_interact(user)
	soundloop?.start()
	fuel_target = target

/obj/item/borg/fuelnozzle/proc/recharge_reagent(datum/reagent/reagent_to_recharge)
	if(iscyborg(src.loc))
		var/mob/living/silicon/robot/cyborg = src.loc
		if(cyborg?.cell)
			if(!internal_tank.has_reagent(reagent_to_recharge, max_volume_to_recharge))
				cyborg.cell.use(charge_cost)
				internal_tank.add_reagent(reagent_to_recharge, 150, no_react = TRUE, reagtemp = 40)

/obj/item/borg/fuelnozzle/process(delta_time)
	charge_timer += delta_time
	if(charge_timer >= recharge_time && allow_recharge)
		if(!internal_tank.has_reagent(fuel, max_volume_to_recharge))
			recharge_reagent(fuel)
		charge_timer = 0
	if(fuel_target)
		if(!fuel_target)
			soundloop?.stop()
			return TRUE
		if(get_dist(src, fuel_target) > max_range)
			soundloop?.stop()
			to_chat(usr, "<span class='warning'>[icon2html(src)] [fuel_target] is out of range!</span>")
			playsound(src, 'sound/machines/buzz-two.ogg', 100)
			fuel_target = null
			return TRUE
		var/obj/item/fighter_component/fuel_tank/sft = fuel_target.loadout.get_slot(HARDPOINT_SLOT_FUEL)
		if(!sft)
			soundloop?.stop()
			to_chat(usr, "<span class='warning'>[icon2html(src)] [fuel_target] does not have a fuel tank installed!</span>")
			return TRUE
		var/transfer_amount = min(min(units_per_second * delta_time, internal_tank.total_volume), fuel_target.get_max_fuel() - fuel_target.get_fuel()) // Transfer as much as possible
		if(fuel_target.get_max_fuel() <= fuel_target.get_fuel())
			soundloop?.stop()
			to_chat(usr, "<span class='warning'>[icon2html(src)] refuelling complete.</span>")
			playsound(src, 'sound/machines/ping.ogg', 100)
			fuel_target = null
			return TRUE
		else if (transfer_amount <= 0)
			soundloop?.stop()
			to_chat(usr, "<span class='warning'>[icon2html(src)] insufficient fuel.</span>")
			playsound(src, 'sound/machines/buzz-two.ogg', 100)
			fuel_target = null
			return TRUE
		internal_tank.trans_to(sft, transfer_amount)

/obj/item/borg/fuelnozzle/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(istype(target, /obj/structure/overmap/small_craft))
		var/obj/structure/overmap/small_craft/voidcraft = target
		var/obj/item/fighter_component/fuel_tank/sft = voidcraft.loadout.get_slot(HARDPOINT_SLOT_FUEL)
		if(!sft)
			to_chat(user, "<span class='warning'>[icon2html(src)] [voidcraft] does not have a fuel tank installed!</span>")
			return
		if(voidcraft.engines_active())
			to_chat(user, "<span class='notice'>[voidcraft]'s engine is still running! Refuelling it now would be dangerous.</span>")
			playsound(src, 'sound/machines/buzz-two.ogg', 100)
			return
		if(voidcraft.get_fuel() < voidcraft.get_max_fuel())
			start_fuelling(voidcraft, user)
			to_chat(user, "<span class='notice'>You slot [src] into [voidcraft]'s refuelling hatch.</span>")
			playsound(user, 'sound/machines/click.ogg', 60, 1)
			return
		else
			to_chat(user, "<span class='notice'>[voidcraft]'s fuel tank is already full.</span>")

/obj/item/borg/fuelnozzle/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CryogenicFuel")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/item/borg/fuelnozzle/ui_data(mob/user)
	var/list/data = list()
	if(!fuel_target)
		data["targetfuel"] = 0
		data["targetmaxfuel"] = 1000
	else
		data["targetfuel"] = fuel_target.get_fuel()
		data["targetmaxfuel"] = fuel_target.get_max_fuel()
	data["transfer_mode"] = allow_recharge
	data["fuel"] = internal_tank.total_volume
	data["maxfuel"] = internal_tank.maximum_volume
	return data

/obj/item/borg/fuelnozzle/ui_act(action, params, datum/tgui/ui)
	if(..())
		return
	if(action == "stopfuel" && fuel_target)
		soundloop?.stop()
		visible_message("<span class='warning'>[icon2html(src)] refuelling cancelled.</span>")
		playsound(src, 'sound/machines/buzz-two.ogg', 100)
		fuel_target = null
	if(action == "transfer_mode")
		if(!allow_recharge)
			to_chat(usr, "<span class='notice'>You activate [src]'s internal fuel synthesizer</span>")
			allow_recharge = TRUE
		else
			to_chat(usr, "<span class='notice'>You deactivate [src]'s internal fuel synthesizer</span>")
			allow_recharge = FALSE
