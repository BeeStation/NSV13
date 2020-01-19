/obj/machinery/ship_weapon/pdc_mount
	name = "PDC loading rack"
	icon = 'nsv13/icons/obj/munitions.dmi'
	icon_state = "pdc"
	desc = "Seegson's all-in-one PDC targeting computer, ammunition loader, and human interface has proven extremely popular in recent times. It's rare to see a ship without one of these."
	anchored = TRUE
	density = FALSE
	pixel_y = 26

	auto_load = TRUE
	semi_auto = TRUE
	maintainable = FALSE
	magazine_type = /obj/item/ammo_box/magazine/pdc
	max_ammo = 100
	burst_size = 3
	range_mod = 0
	fire_mode = 1

	// We're fully automatic, so just the loading sound is enough
	feeding_sound = null
	fed_sound = null
	chamber_sound = null

	load_delay = 50
	unload_delay = 50

	// No added delay between shots or for feeding rounds
	feed_delay = 0
	chamber_delay_rapid = 0
	chamber_delay = 0

// Update the icon to reflect how far our magazine is depleted
/obj/machinery/ship_weapon/pdc_mount/update_icon()
	if(!magazine)
		icon_state = "[initial(icon_state)]_0"
		return
	var/progress = magazine.ammo_count() //How damaged is this shield? We examine the position of index "I" in the for loop to check which directional we want to check
	var/goal = magazine.max_ammo //How much is the max hp of the shield? This is constant through all of them
	progress = CLAMP(progress, 0, goal)
	progress = round(((progress / goal) * 100), 20)//Round it down to 20%. We now apply visual damage
	icon_state = "[initial(icon_state)]_[progress]"


// Update the icon after things that affect how much ammo we have

/obj/machinery/ship_weapon/pdc_mount/load_magazine()
	..()
	update_icon()

/obj/machinery/ship_weapon/pdc_mount/unload_magazine()
	..()
	update_icon()

/obj/machinery/ship_weapon/pdc_mount/after_fire()
	..()
	update_icon()

// Don't animate us on fire, the above takes care of all the icon updates we need
/obj/machinery/ship_weapon/pdc_mount/do_animation()
	return

/obj/machinery/ship_weapon/pdc_mount/notify_select(obj/structure/overmap/OM, mob/user)
	to_chat(user, "<span class='notice'>Defensive flak screens: <b>OFFLINE</b>. Activating manual point defense cannon control.</span>")
	OM.relay('nsv13/sound/effects/ship/pdc_start.ogg')