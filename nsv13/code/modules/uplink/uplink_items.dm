/datum/uplink_item/device_tools/tc_rod
	name = "Telecrystal Fuel Rod"
	desc = "This special fuel rod has eight material slots that can be inserted with telecrystals, \
			once the rod has been fully depleted, you will be able to harvest the extra telecrystals. \
			Please note: This Rod fissiles much faster than it's nanotrasen counterpart, it doesn't take \
			much to overload the reactor with these..."
	item = /obj/item/fuel_rod/material/telecrystal
	cost = 7

/datum/uplink_item/role_restricted/pdc_rifle
	name = "Point Defence Rifle"
	desc = "A rifle specifically designed to shoot the 30.12x82mm bullets found on ships."
	item = /obj/item/gun/ballistic/rifle/boltaction/pdc
	cost = 12
	restricted_roles = list(JOB_NAME_MUNITIONSTECHNICIAN,JOB_NAME_MASTERATARMS)
