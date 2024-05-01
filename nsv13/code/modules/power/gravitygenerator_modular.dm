///This is the modular NSV file for gravity generators, to keep the base file more clear of conflicts.

//Modular proc attachment
/obj/machinery/gravity_generator/main/attackby(obj/item/I, mob/user, params)
	if(!(obj_flags & EMAGGED))
		return ..()
	if(I?.tool_behaviour != TOOL_MULTITOOL)
		return ..()
	if(on || charge_count > 0 || charging_state == POWER_UP)
		to_chat(user, "<span class='warning'>You should not mess with [src]'s circuitry while it is active!</span>")
		return TRUE
	if(machine_stat & BROKEN)
		to_chat(user, "<span class='notice'>Fix [src]'s chassis first.</span>")
		return TRUE
	to_chat(user, "<span class='notice'>You start resetting [src]'s control circuits and safety protocols.</span>")
	if(!do_after(user, 10 SECONDS, target = src, extra_checks = CALLBACK(src, PROC_REF(can_reset_generator))))
		return TRUE
	to_chat(user, "<span class='notice'>You reset [src]'s control circuits to default.</span>")
	obj_flags &= (~EMAGGED)
	change_setting(1)
	ui_update()
	if(ishuman(user))
		add_fibers(user) //..Fixing this thing is ALSO close and personal work.
	investigate_log("was reset while emagged and will now generate 1G", INVESTIGATE_GRAVITY)
	return TRUE

///Is this gravity generator in need of a reset right now, and is this a valid state for it to be reset in?
/obj/machinery/gravity_generator/main/proc/can_reset_generator()
	if(on || charge_count > 0 || charging_state == POWER_UP || !(obj_flags & EMAGGED) || (machine_stat & BROKEN))
		return FALSE
	return TRUE

///Can this gravity generator be emagged right now?
/obj/machinery/gravity_generator/main/proc/can_emag_generator()
	if((obj_flags & EMAGGED) || !on)
		return FALSE
	return TRUE

/obj/machinery/gravity_generator/main/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return FALSE
	if(!on)
		to_chat(user, "<span class='notice'>[src] must be active to override its controls.</span>")
		return FALSE
	to_chat(user, "<span class='notice'>You start messing with [src]'s internals. This will take a moment to get done just right..</span>")
	if(!do_after(user, 5 SECONDS, target = src, extra_checks = CALLBACK(src, PROC_REF(can_emag_generator))))
		return FALSE
	to_chat(user, "<span class='warning'>You override [src]'s safeties and crosswire it to double its target gravity.</span>")
	charge_count = 0
	set_state(0)
	radiation_pulse(src, 1800) //You SHOULD wear protection when messing with this thing this badly.
	obj_flags |= EMAGGED
	change_setting(2) // :)
	set_power(POWER_UP)
	ui_update()
	if(ishuman(user))
		add_fibers(user) //Emagging this thing is close and personal work.
	investigate_log("was emagged and will now generate 2G", INVESTIGATE_GRAVITY)
	message_admins("The gravity generator was emagged by [user] (real name: [user?.real_name])! [ADMIN_VERBOSEJMP(src)]")
	return TRUE

//Modular proc attachment
/obj/machinery/gravity_generator/main/ui_data(mob/user)
	. = ..()
	.["emagged"] = (obj_flags & EMAGGED) ? TRUE : FALSE //Trinary for safety because bitfield checks do not return just a pure TRUE / FALSE.
	.["theme"] = (obj_flags & EMAGGED) ? "syndicate " : "ntos"

///Modular proc OVERRIDE
/obj/machinery/gravity_generator/main/change_setting(value)
	if(value != setting)
		setting = value
		if(on) //No reason to shake if grav is off.
			shake_everyone()
