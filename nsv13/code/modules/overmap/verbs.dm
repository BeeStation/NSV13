//Holds all the overmap ship panel verbs

/obj/structure/overmap/proc/verb_check(mob/user, require_pilot = TRUE)
	if(!user)
		user = usr
	if(user != pilot)
		to_chat(user, "<span class='notice'>You can't reach the controls from here</span>")
		return FALSE
	return !user.incapacitated() && isliving(user)

//Control Scheme Verbs
/obj/structure/overmap/verb/toggle_brakes()
	set name = "Toggle Handbrake"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check() || !can_brake())
		return
	brakes = !brakes
	to_chat(usr, "<span class='notice'>You toggle the brakes [brakes ? "on" : "off"].</span>")

/obj/structure/overmap/verb/toggle_inertia()
	set name = "Toggle IAS"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check() || !can_brake())
		return
	if(!toggle_dampeners(user = usr))
		return
	to_chat(usr, "<span class='notice'>Inertial assistance system [inertial_dampeners ? "ONLINE" : "OFFLINE"].</span>")

/obj/structure/overmap/verb/toggle_move_mode()
	set name = "Change movement mode"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check())
		return
	move_by_mouse = !move_by_mouse
	to_chat(usr, "<span class='notice'>You [move_by_mouse ? "activate" : "deactivate"] [src]'s laser guided movement system.</span>")

//General Overmap Verbs
/obj/structure/overmap/verb/show_dradis()
	set name = "Show DRADIS"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check() || !dradis)
		return
	dradis.attack_hand(usr)

/obj/structure/overmap/verb/cycle_firemode()
	set name = "Switch firemode"
	set category = "Ship"
	set src = usr.loc
	if(usr != gunner)
		return

	var/stop = fire_mode
	fire_mode = WRAP_AROUND_VALUE(fire_mode + 1, 1, weapon_types.len + 1)

	for(fire_mode; fire_mode != stop; fire_mode = WRAP_AROUND_VALUE(fire_mode + 1, 1, weapon_types.len + 1))
		if(swap_to(fire_mode))
			return TRUE

	// No other weapons available, go with whatever we had before
	fire_mode = stop

//Small Craft Specific Verbs
/obj/structure/overmap/small_craft/verb/show_control_panel()
	set name = "Show control panel"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check())
		return
	ui_interact(usr)

/obj/structure/overmap/small_craft/verb/change_name()
	set name = "Change name"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check())
		return
	var/new_name = stripped_input(usr, message="What do you want to name \
		your fighter? Keep in mind that particularly terrible names may be \
		rejected by your employers.", max_length=MAX_CHARTER_LEN)
	if(!new_name || length(new_name) <= 0)
		return
	message_admins("[key_name_admin(usr)] renamed a fighter to [new_name] [ADMIN_LOOKUPFLW(src)].")
	name = new_name

/obj/structure/overmap/verb/toggle_safety()
	set name = "Toggle Gun Safeties"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check() || !can_change_safeties())
		return
	weapon_safety = !weapon_safety
	to_chat(usr, "<span class='notice'>You toggle [src]'s weapon safeties [weapon_safety ? "on" : "off"].</span>")

/obj/structure/overmap/small_craft/verb/countermeasure()
	set name = "Deploy Countermeasures"
	set category = "Ship"
	set src = usr.loc
	set waitfor = FALSE

	if(!verb_check())
		return

	fire_countermeasure()

//Large Craft Specifc Verbs
/obj/structure/overmap/verb/show_tactical()
	set name = "Show Tactical"
	set category = "Ship"
	set src = usr.loc

	if(!verb_check() || !tactical)
		return

	tactical.attack_hand(usr)
