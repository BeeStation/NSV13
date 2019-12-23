/obj/structure/ship_weapon/laser_cannon
	name = "MODEL_HERE Ship mounted laser"
	desc = "A ship-to-ship weapon which fires a destructive energy burst. This particular model has an effective range of 20,000KM."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"

	var/fire_sound = 'sound/weapons/lasercannonfire.ogg'
	var/load_sound = null
	var/speed = 1 //Placeholder, allows upgrading speed with better propulsion
	var/power_draw // How much power does it cost to fire this?

/obj/structure/ship_weapon/laser_cannon/attackby(obj/item/I, mob/user)
	if(!linked)
		var/area/AR = get_area(src)
		if(AR.linked_overmap)
			linked = AR.linked_overmap
			linked?.ship_lasers += src
	else
		. = ..()

/obj/structure/ship_weapon/laser_cannon/proc/can_fire(powernet_power) // Do we have enough power?
	if(powernet_power > power_draw)
		return TRUE
	else
		return FALSE