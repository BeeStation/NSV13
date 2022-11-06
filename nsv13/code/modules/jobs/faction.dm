/datum/job/New()
	. = ..()
	if(ispath(SSmapping.config.ship_type, /obj/structure/overmap/nanotrasen/solgov))
		var/newLook = text2path("[outfit]/solgov")
		if(newLook)
			outfit = newLook

//Job outfit overrides for SolGov crew!
//Format: /path/to/job/outfit/nameOfYourFaction.
//Ok congrats, youre done.

/datum/outfit/job/pilot/solgov
	name = JOB_NAME_PILOT + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/pilot
	accessory = /obj/item/clothing/accessory/solgov_jacket

/datum/outfit/job/bridge/solgov
	name = JOB_NAME_BRIDGESTAFF + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/command
	accessory = /obj/item/clothing/accessory/solgov_jacket/command

/datum/outfit/job/air_traffic_controller/solgov
	name = JOB_NAME_AIRTRAFFICCONTROLLER + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/command
	accessory = /obj/item/clothing/accessory/solgov_jacket/command
	shoes = /obj/item/clothing/shoes/jackboots //White shoes look awful with this

/datum/outfit/job/master_at_arms/solgov
	name = JOB_NAME_MASTERATARMS + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/command
	accessory = /obj/item/clothing/accessory/solgov_jacket/command

/datum/outfit/job/munitions_tech/solgov
	name = JOB_NAME_MUNITIONSTECHNICIAN + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/engsec
	suit = null
	accessory = /obj/item/clothing/accessory/solgov_jacket/engsec

/datum/outfit/job/assistant/solgov
	name = JOB_NAME_ASSISTANT + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov
	suit = null
	head = null
	shoes = /obj/item/clothing/shoes/jackboots //White shoes look awful with this

/datum/outfit/job/atmos/solgov
	name = JOB_NAME_ATMOSPHERICTECHNICIAN + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/engsec
	accessory = /obj/item/clothing/accessory/solgov_jacket/engsec

/datum/outfit/job/bartender/solgov
	name = JOB_NAME_BARTENDER + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci

/datum/outfit/job/botanist/solgov
	name = JOB_NAME_BOTANIST + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci

/datum/outfit/job/brig_phys/solgov
	name = JOB_NAME_BRIGPHYSICIAN + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/engsec
	accessory = /obj/item/clothing/accessory/solgov_jacket/engsec

/datum/outfit/job/captain/solgov
	name = JOB_NAME_CAPTAIN + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/command
	accessory = /obj/item/clothing/accessory/solgov_jacket/formal/captain
	suit = null
	gloves = /obj/item/clothing/gloves/color/black

/datum/outfit/job/cargo_tech/solgov
	name = JOB_NAME_CARGOTECHNICIAN + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/engsec
	accessory = /obj/item/clothing/accessory/solgov_jacket/engsec

/datum/outfit/job/chaplain/solgov
	name = JOB_NAME_CHAPLAIN + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci

/datum/outfit/job/chemist/solgov
	name = JOB_NAME_CHEMIST + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci

/datum/outfit/job/ce/solgov
	name = JOB_NAME_CHIEFENGINEER + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/engsec
	accessory = /obj/item/clothing/accessory/solgov_jacket/engsec

/datum/outfit/job/cmo/solgov
	name = JOB_NAME_CHIEFMEDICALOFFICER + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci
	shoes = /obj/item/clothing/shoes/jackboots //White shoes look awful with this

/datum/outfit/job/cook/solgov
	name = JOB_NAME_COOK + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci

/datum/outfit/job/curator/solgov
	name = JOB_NAME_CURATOR + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci

/datum/outfit/job/deputy/solgov
	name = JOB_NAME_DEPUTY + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/engsec
	accessory = /obj/item/clothing/accessory/solgov_jacket/engsec
	shoes = /obj/item/clothing/shoes/jackboots //White shoes look awful with this

/datum/outfit/job/emt/solgov
	name = JOB_NAME_PARAMEDIC + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci

/datum/outfit/job/geneticist/solgov
	name = JOB_NAME_GENETICIST + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci

/datum/outfit/job/hop/solgov
	name = JOB_NAME_HEADOFPERSONNEL + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/command
	accessory = /obj/item/clothing/accessory/solgov_jacket/formal
	suit = null
	gloves = /obj/item/clothing/gloves/color/black

/datum/outfit/job/hos/solgov
	name = JOB_NAME_HEADOFSECURITY + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/command
	accessory = /obj/item/clothing/accessory/solgov_jacket/command
	suit = null
	gloves = /obj/item/clothing/gloves/color/black

/datum/outfit/job/janitor/solgov
	name = JOB_NAME_JANITOR + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci

/datum/outfit/job/lawyer/solgov
	name = JOB_NAME_LAWYER + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/engsec
	accessory = /obj/item/clothing/accessory/solgov_jacket/engsec

/datum/outfit/job/doctor/solgov
	name = JOB_NAME_MEDICALDOCTOR + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci
	shoes = /obj/item/clothing/shoes/jackboots //White shoes look awful with this

/datum/outfit/job/qm/solgov
	name = JOB_NAME_QUARTERMASTER + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/engsec
	accessory = /obj/item/clothing/accessory/solgov_jacket/engsec

/datum/outfit/job/rd/solgov
	name = JOB_NAME_RESEARCHDIRECTOR + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/command
	accessory = /obj/item/clothing/accessory/solgov_jacket/command
	shoes = /obj/item/clothing/shoes/jackboots //White shoes look awful with this

/datum/outfit/job/roboticist/solgov
	name = JOB_NAME_ROBOTICIST + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci

/datum/outfit/job/scientist/solgov
	name = JOB_NAME_SCIENTIST + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci
	shoes = /obj/item/clothing/shoes/jackboots //White shoes look awful with this

/datum/outfit/job/security/solgov
	name = JOB_NAME_SECURITYOFFICER + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/engsec
	accessory = /obj/item/clothing/accessory/solgov_jacket/engsec

/datum/outfit/job/miner/solgov
	name = JOB_NAME_SHAFTMINER + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci

/datum/outfit/job/engineer/solgov
	name = JOB_NAME_STATIONENGINEER + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/engsec
	accessory = /obj/item/clothing/accessory/solgov_jacket/engsec

/datum/outfit/job/virologist/solgov
	name = JOB_NAME_VIROLOGIST + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/medsci
	accessory = /obj/item/clothing/accessory/solgov_jacket/medsci

/datum/outfit/job/warden/solgov
	name = JOB_NAME_WARDEN + " (SolGov)"
	uniform = /obj/item/clothing/under/ship/solgov/engsec
	accessory = /obj/item/clothing/accessory/solgov_jacket/engsec
