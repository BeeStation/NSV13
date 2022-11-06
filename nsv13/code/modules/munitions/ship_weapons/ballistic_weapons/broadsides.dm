
/obj/machinery/ship_weapon/broadside
	name = "\improper Space Naval Broadside Cannon"
	icon = 'nsv13/icons/obj/railgun.dmi' //Temp
	icon_state = "OBC" //Temp
	desc = "Line 'em up, knock 'em down." //Temp
	anchored = TRUE
	density = TRUE
	safety = FALSE //Temp

	bound_width = 128
	bound_height = 64
	pixel_y = -64
	ammo_type = /obj/item/ship_weapon/ammunition/gauss
	circuit = /obj/item/circuitboard/machine/pdc_mount //Temp

	fire_mode = FIRE_MODE_BROADSIDE
	firing_sound = 'nsv13/sound/effects/ship/mac_fire.ogg'

	auto_load = TRUE
	semi_auto = TRUE
	maintainable = TRUE
	max_ammo = 3

	// We're fully automatic, so just the loading sound is enough
	feeding_sound = 'nsv13/sound/effects/ship/mac_load.ogg'

	load_delay = 20
	unload_delay = 20

	// No added delay between shots or for feeding rounds
	feed_delay = 0
	chamber_delay_rapid = 0
	chamber_delay = 0
	bang = TRUE
	bang_range = 5

/datum/ship_weapon/broadside
	name = "SNBC"
	default_projectile_type = /obj/item/projectile/bullet/broadside
	burst_size = 3
	fire_delay = 3 SECONDS
	range_modifier = 10
	select_alert = "<span class='notice'>Locking Broadside Cannons...</span>"
	failure_alert = "<span class='warning'>DANGER: No Shells In Loaded In Broadside Cannons!</span>"
	overmap_firing_sounds = 'nsv13/sound/effects/ship/mac_fire.ogg'
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_charge.ogg'
	weapon_class = WEAPON_CLASS_HEAVY
	miss_chance = 10
	max_miss_distance = 6
	ai_fire_delay = 10 SECONDS
	allowed_roles = OVERMAP_USER_ROLE_GUNNER
	broadside = TRUE

// Don't animate us on fire, the above takes care of all the icon updates we need
/obj/machinery/ship_weapon/broadside/do_animation()
	return

/obj/machinery/ship_weapon/broadside/animate_projectile(atom/target, lateral=TRUE)
	. = ..()

/obj/machinery/ship_weapon/broadside/examine()
	. = ..()
	if(panel_open)
		. += "The maintenance panel is <b>unscrewed</b> and the machinery could be <i>pried out</i>."

/obj/machinery/ship_weapon/broadside/screwdriver_act(mob/user, obj/item/tool)
	var/icon_state_open = initial(icon_state)
	var/icon_state_closed
	if(!panel_open)
		icon_state_closed = icon_state
	return default_deconstruction_screwdriver(user, icon_state_open, icon_state_closed, tool)

/obj/machinery/ship_weapon/broadside/crowbar_act(mob/user, obj/item/tool)
	if(panel_open)
		tool.play_tool_sound(src, 50)
		deconstruct(TRUE)
		return TRUE
	return default_deconstruction_crowbar(user, tool)

/obj/machinery/ship_weapon/broadside/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, .proc/RefreshParts), world.tick_lag)

/obj/item/projectile/bullet/broadside
	icon_state = "broadside"
	name = "broadside shell"
	icon = 'nsv13/icons/obj/projectiles_nsv.dmi'
	damage = 150
	obj_integrity = 500
	flag = "overmap_medium"
