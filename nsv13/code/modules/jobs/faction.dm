//I love how this actually fucking works. Untyped languages are BASED
/datum/job/New()
	. = ..()
	if(SSmapping.config.faction != "nanotrasen")
		var/newLook = text2path("[outfit]/[SSmapping.config.faction]")
		if(newLook)
			outfit = newLook

//Job outfit overrides for SolGov crew!
//Format: /path/to/job/outfit/nameOfYourFaction.
//Ok congrats, youre done.

/datum/outfit/job/fighter_pilot/solgov
	name = "Fighter Pilot (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/pilot
	accessory = /obj/item/clothing/accessory/solgov_jacket

/datum/outfit/job/bridge/solgov
	name = "Bridge Assistant (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/command
	accessory = /obj/item/clothing/accessory/solgov_jacket/command

/datum/outfit/job/air_traffic_controller/solgov
	name = "ATC (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/command
	accessory = /obj/item/clothing/accessory/solgov_jacket/command
	shoes = /obj/item/clothing/shoes/jackboots //White shoes look awful with this

/datum/outfit/job/master_at_arms/solgov
	name = "MAA (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/command
	accessory = /obj/item/clothing/accessory/solgov_jacket/command

/datum/outfit/job/munitions_tech/solgov
	name = "MT (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/engsec
	suit = null
	accessory = /obj/item/clothing/accessory/solgov_jacket/engsec

/datum/outfit/job/assistant/solgov
	name = "Assistant (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov
	suit = null
	head = null
	shoes = /obj/item/clothing/shoes/jackboots //White shoes look awful with this

/datum/outfit/job/assistant_ship/solgov
	name = "Assistant (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov
	suit = null
	head = null
	shoes = /obj/item/clothing/shoes/jackboots //White shoes look awful with this

/datum/outfit/job/atmos/solgov
	name = "Atmos Tech (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/engsec
	accessory = /obj/item/clothing/accessory/solgov_jacket/engsec

/datum/outfit/job/bartender/solgov
	name = "Bartender (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci

/datum/outfit/job/botanist/solgov
	name = "Botanist (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci

/datum/outfit/job/brig_phys/solgov
	name = "Brig Physician (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/engsec
	accessory = /obj/item/clothing/accessory/solgov_jacket/engsec

/datum/outfit/job/captain/solgov
	name = "Captain (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/command
	accessory = /obj/item/clothing/accessory/solgov_jacket/formal/captain
	suit = null
	gloves = /obj/item/clothing/gloves/color/black

/datum/outfit/job/cargo_tech/solgov
	name = "Cargo Technician (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/engsec
	accessory = /obj/item/clothing/accessory/solgov_jacket/engsec

/datum/outfit/job/chaplain/solgov
	name = "Chaplain (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci

/datum/outfit/job/chemist/solgov
	name = "Chemist (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci

/datum/outfit/job/ce/solgov
	name = "Chief Engineer (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/engsec
	accessory = /obj/item/clothing/accessory/solgov_jacket/engsec

/datum/outfit/job/cmo/solgov
	name = "Chief Medical Officer (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci
	shoes = /obj/item/clothing/shoes/jackboots //White shoes look awful with this

/datum/outfit/job/cook/solgov
	name = "Cook (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci

/datum/outfit/job/curator/solgov
	name = "Curator (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci

/datum/outfit/job/deputy/solgov
	name = "Deputy (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/engsec
	accessory = /obj/item/clothing/accessory/solgov_jacket/engsec
	shoes = /obj/item/clothing/shoes/jackboots //White shoes look awful with this

/datum/outfit/job/emt/solgov
	name = "EMT (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci

/datum/outfit/job/geneticist/solgov
	name = "Geneticist (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci

/datum/outfit/job/hop/solgov
	name = "Executive Officer (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/command
	accessory = /obj/item/clothing/accessory/solgov_jacket/formal
	suit = null
	gloves = /obj/item/clothing/gloves/color/black

/datum/outfit/job/hos/solgov
	name = "Head Of Security (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/command
	accessory = /obj/item/clothing/accessory/solgov_jacket/command
	suit = null
	gloves = /obj/item/clothing/gloves/color/black

/datum/outfit/job/janitor/solgov
	name = "Janitor (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci

/datum/outfit/job/lawyer/solgov
	name = "Lawyer (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/engsec
	accessory = /obj/item/clothing/accessory/solgov_jacket/engsec

/datum/outfit/job/doctor/solgov
	name = "Doctor (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci
	shoes = /obj/item/clothing/shoes/jackboots //White shoes look awful with this

/datum/outfit/job/qm/solgov
	name = "Quartermaster (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/engsec
	accessory = /obj/item/clothing/accessory/solgov_jacket/engsec

/datum/outfit/job/rd/solgov
	name = "Research Director (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/command
	accessory = /obj/item/clothing/accessory/solgov_jacket/command
	shoes = /obj/item/clothing/shoes/jackboots //White shoes look awful with this

/datum/outfit/job/roboticist/solgov
	name = "Roboticist (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci

/datum/outfit/job/scientist/solgov
	name = "Scientist (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci
	shoes = /obj/item/clothing/shoes/jackboots //White shoes look awful with this

/datum/outfit/job/security/solgov
	name = "Security Officer (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/engsec
	accessory = /obj/item/clothing/accessory/solgov_jacket/engsec

/datum/outfit/job/miner/solgov
	name = "Miner (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci

/datum/outfit/job/engineer/solgov
	name = "Engineer (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/engsec
	accessory = /obj/item/clothing/accessory/solgov_jacket/engsec

/datum/outfit/job/virologist/solgov
	name = "Virologist (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci

/datum/outfit/job/warden/solgov
	name = "Warden (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/engsec
	accessory = /obj/item/clothing/accessory/solgov_jacket/engsec
