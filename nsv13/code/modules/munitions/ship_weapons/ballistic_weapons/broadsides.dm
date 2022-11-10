/obj/machinery/ship_weapon/broadside
	name = "\improper SN 'Sucker Punch' Broadside Cannon"
	icon = 'nsv13/icons/obj/broadside.dmi'
	icon_state = "broadside"
	desc = "Line 'em up, knock 'em down." //Temp
	anchored = TRUE
	density = TRUE
	safety = FALSE

	bound_width = 64
	bound_height = 128
	ammo_type = /obj/item/ship_weapon/ammunition/broadside_shell
	circuit = /obj/item/circuitboard/machine/broadside

	fire_mode = FIRE_MODE_BROADSIDE

	auto_load = TRUE
	semi_auto = TRUE
	maintainable = FALSE
	max_ammo = 5

	feeding_sound = 'nsv13/sound/effects/ship/mac_load.ogg'
	fed_sound = null
	chamber_sound = null

	load_delay = 20
	unload_delay = 20

	feed_delay = 0
	chamber_delay_rapid = 0
	chamber_delay = 0
	bang = TRUE
	bang_range = 5
	var/next_sound = 0

/obj/item/circuitboard/machine/broadside
	name = "circuit board (broadside)"
	desc = "Man the cannons!"
	req_components = list(
		/obj/item/stack/sheet/mineral/titanium = 20,
		/obj/item/stack/sheet/iron = 50,
		/obj/item/stock_parts/manipulator = 2,
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/matter_bin = 6,
		/obj/item/ship_weapon/parts/firing_electronics = 1
	)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	build_path = /obj/machinery/ship_weapon/broadside

/obj/item/circuitboard/machine/broadside/Destroy(force=FALSE)
	if(!force)
		return QDEL_HINT_LETMELIVE
	return ..()

/datum/ship_weapon/broadside
	name = "SNBC"
	burst_size = 5
	fire_delay = 5 SECONDS
	range_modifier = 10
	default_projectile_type = /obj/item/projectile/bullet/broadside
	select_alert = "<span class='notice'>Locking Broadside Cannons...</span>"
	failure_alert = "<span class='warning'>DANGER: No Shells Loaded In Broadside Cannons!</span>"
	overmap_firing_sounds = list('nsv13/sound/effects/ship/broadside.ogg')
	overmap_select_sound = 'nsv13/sound/effects/ship/mac_charge.ogg'
	weapon_class = WEAPON_CLASS_HEAVY
	miss_chance = 10
	max_miss_distance = 6
	ai_fire_delay = 10 SECONDS
	allowed_roles = OVERMAP_USER_ROLE_GUNNER
	screen_shake = 10

/obj/machinery/ship_weapon/broadside/animate_projectile(atom/target, lateral=TRUE)
	var/obj/item/ship_weapon/ammunition/broadside_shell/T = chambered
	if(T)
		linked.fire_projectile(T.projectile_type, target, FALSE, null, null, TRUE, null, 5, 5, TRUE)

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

/obj/machinery/ship_weapon/broadside/overmap_fire(atom/target)
	if(world.time >= next_sound) //Prevents ear destruction from soundspam
		overmap_sound()
		next_sound = world.time + 1 SECONDS
	if(overlay)
		overlay.do_animation()
	animate_projectile(target)

/obj/item/ship_weapon/ammunition/broadside_shell
	name = "\improper SNBC Type 1 Shell"
	desc = "A large packed shell, complete with powder and projectile, ready to be loaded and fired."
	icon_state = "broadside"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_righthand.dmi'
	icon = 'nsv13/icons/obj/munitions.dmi'
	w_class = 4
	projectile_type = /obj/item/projectile/bullet/broadside

/obj/item/ship_weapon/ammunition/broadside_shell/plasma
	name = "\improper SNBC Type P Shell"
	desc = "A large packed shell, complete with plasma and projectile, ready to be loaded and fired."
	icon_state = "broadside_plasma"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_righthand.dmi'
	icon = 'nsv13/icons/obj/munitions.dmi'
	w_class = 4
	projectile_type = /obj/item/projectile/bullet/broadside/plasma

/obj/item/projectile/bullet/broadside
	name = "broadside shell"
	icon = 'nsv13/icons/obj/projectiles_nsv.dmi'
	icon_state = "broadside"
	damage = 120
	obj_integrity = 500
	flag = "overmap_medium"
	spread = 25
	speed = 1

/obj/item/projectile/bullet/broadside/plasma
	name = "plasma-packed broadside shell"
	icon = 'nsv13/icons/obj/projectiles_nsv.dmi'
	icon_state = "broadside_plasma"
	damage = 150
	armour_penetration = 10
	speed = 0.4

//Temp Disable incase a better system is found
/*obj/item/ship_weapon/ammunition/broadside_shell/casing
	name = "\improper SNBC Shell Casing"
	desc = "An empty shell meant for a Broadside Cannon Shell"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "broadside-casing"
	projectile_type = /obj/item/projectile/bullet/broadisde/dud

/obj/item/projectile/bullet/broadisde/dud
	icon_state = "broadside-dud"
	damage = 0
	speed = 100
*/

/obj/item/ship_weapon/parts/broadside_shell
	name = "broadside shell casing"
	desc = "An empty shell casing for the Broadside Cannon. Load it into the Shell Packer!"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "broadside_casing"

/obj/item/ship_weapon/parts/broadside_load
	name = "broadisde shell load"
	desc = "A loose load meant for a Broadside shell. Load it into the Shell Packer!"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "broadside_load"
