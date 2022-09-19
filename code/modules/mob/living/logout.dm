/mob/living/Logout()
	update_z(null)
	//I still need their clients in tact to do this stuff.
	if(istype(loc, /obj/machinery/ship_weapon/gauss_gun))
		var/obj/machinery/ship_weapon/gauss_gun/GG = loc
		GG.remove_gunner()
	if(src.overmap_ship)
		overmap_ship.stop_piloting(src)
	..()
	if(!key && mind)	//key and mind have become separated.
		mind.active = 0	//This is to stop say, a mind.transfer_to call on a corpse causing a ghost to re-enter its body.
