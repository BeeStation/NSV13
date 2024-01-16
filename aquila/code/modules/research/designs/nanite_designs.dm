/datum/design/nanites/nutrition_synthesis
	name = "Nutrition Synthesis"
	desc = "The nanites use themself to synthesise nutriments into host's bloodstream, gradually decaying to feed the host."
	id = "nutrition_nanites"
	program_type = /datum/nanite_program/nutrition_synthesis
	category = list("Utility Nanites")

/datum/design/nanites/nanolink
	name = "Nanolink"
	desc = "The nanites gain the ability to transfer messages between other nano clusters connected to the Nanolink, using the \".z\" key."
	id = "nanolink_nanites"
	program_type = /datum/nanite_program/nanolink
	category = list("Utility Nanites")

/datum/design/nanites/cloud_change
	name = "Cloud Change"
	desc = "When triggered, changes the nanites' cloud to that specified."
	id = "cloud_change_nanites"
	program_type = /datum/nanite_program/cloud_change
	category = list("Utility Nanites")

/datum/design/nanites/nanojutsu
	name = "Nanojutsu Teaching Program"
	desc = "The nanites stimulate host's brain, giving them the ability to use the martial art of Nanojutsu."
	id = "nanojutsu_nanites"
	program_type = /datum/nanite_program/nanojutsu
	category = list("Augmentation Nanites")

/datum/design/nanites/camo
	name = "Adaptive Camouflage"
	desc = "The nanites coat host with a thin, reflective layer, rendering them almost invisible."
	id = "camo_nanites"
	program_type = /datum/nanite_program/camo
	category = list("Augmentation Nanites")

/datum/design/nanites/kunai
	name = "Kunai Form"
	desc = "When triggered, nanites gather in host's free hand, forming a Kunai knife, which disintegrates a few seconds after being thrown."
	id = "kunai_nanites"
	program_type = /datum/nanite_program/kunai
	category = list("Weaponized Nanites")

/datum/design/nanites/nanophage
	name = "Nano Swarm"
	desc = "When triggered, nanites gather in host's stomach, forming nanophages - small, pre-programmed drones, then quickly get coughed out."
	id = "nanoswarm_nanites"
	program_type = /datum/nanite_program/nanophage
	category = list("Weaponized Nanites")

/datum/design/nanites/movement
	name = "Forced Locomotion"
	desc = "The nanites force the host to walk in a pre-programmed direction when triggered."
	id = "movement_nanites"
	program_type = /datum/nanite_program/movement
	category = list("Suppression Nanites")

/datum/design/nanites/sensor_impact
	name = "Impact Sensor"
	desc = "Sends a signal when the nanites detect fluctuations in host's health."
	id = "sensor_impact_nanites"
	program_type = /datum/nanite_program/sensor/impact
	category = list("Sensor Nanites")

/datum/design/nanites/kickstart
	name = "Kickstart Protocol"
	desc = "Replication Protocol: the nanites focus on early growth, heavily boosting replication rate for a few minutes after the initial implantation."
	id = "kickstart_nanites"
	program_type = /datum/nanite_program/protocol/kickstart
	category = list("Protocols_Nanites")

/datum/design/nanites/factory
	name = "Factory Protocol"
	desc = "Replication Protocol: the nanites build a factory matrix within the host, gradually increasing replication speed over time. The factory decays if the protocol is not active."
	id = "factory_nanites"
	program_type = /datum/nanite_program/protocol/factory
	category = list("Protocols_Nanites")

/datum/design/nanites/tinker
	name = "Tinker Protocol"
	desc = "Replication Protocol: the nanites learn to use metallic material in the host's bloodstream to speed up the replication process."
	id = "tinker_nanites"
	program_type = /datum/nanite_program/protocol/tinker
	category = list("Protocols_Nanites")

/datum/design/nanites/offline
	name = "Offline Production Protocol"
	desc = "Replication Protocol: while the host is asleep or otherwise unconcious, the nanites exploit the reduced interference to replicate more quickly."
	id = "offline_nanites"
	program_type = /datum/nanite_program/protocol/offline
	category = list("Protocols_Nanites")

/datum/design/nanites/free_range
	name = "Free-Range Protocol"
	desc = "Replication Protocol: the nanites discard their default storage protocols in favour of a cheaper and more organic approach. Reduces maximum volume, but increases the replication rate."
	id = "free_range_nanites"
	program_type = /datum/nanite_program/protocol/free_range
	category = list("Protocols_Nanites")

/datum/design/nanites/zip
	name = "Zip Protocol"
	desc = "Replication Protocol: the nanites are disassembled and compacted when unused, greatly increasing the maximum volume while in a host. However, the process slows down the replication rate slightly."
	id = "zip_nanites"
	program_type = /datum/nanite_program/protocol/zip
	category = list("Protocols_Nanites")
