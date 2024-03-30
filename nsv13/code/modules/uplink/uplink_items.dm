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

/datum/uplink_item/badass/maid
	name = "Emergency Maid Kit"
	desc = "A kit containing everything you need to become a proper syndicate maid. \
			Contains a maid outfit, a mop, a bucket and a bar of soap. \
			Because you never know when you might need to clean up a mess."
	item = /obj/item/storage/box/syndie_kit/maid
	cost = 20
	cant_discount = TRUE
	surplus = 0

/datum/uplink_item/explosives/fighterplushie
	name = "Plushie Bomb Kit"
	desc = "A kit with all of the tools and items required to assemble your very own plushie bomb! \
			Take out the clueless Nanotrasen scum with a gift they'll never expect. \
			Contains a Syndicate light fighter plush, syndicate minibomb, screwdriver and a survival knife."
	item = /obj/item/storage/box/syndie_kit/plushie
	cost = 8

/datum/uplink_item/race_restricted/robotic_firstaid
	name = "Robotic First-Aid Kit"
	desc = "A first-aid kit with all of the tools required to repair a positronic chassis.\
			Also comes with a radioactive disinfectant bottle and system cleaner medipens."
	item = /obj/item/storage/firstaid/robot
	restricted_species = list(SPECIES_IPC)
	cost = 3
