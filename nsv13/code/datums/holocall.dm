/obj/item/disk/holodisk/hammerhead_cryo
	name = "Engineering Audit Log HH-593"
	desc = "A holodisk containing a recording of a work order being carried out during servicing."
	preset_image_type = /datum/preset_holoimage/engineer/rig
	preset_record_text = {"
	NAME Almayer Gervais
	DELAY 10
	SAY So tell me, why are we dumping a load of stasis beds in the dormitories?
	DELAY 20
	PRESET /datum/preset_holoimage/engineer/ce/rig
	NAME Oscar Leonidas
	SAY Why does NT do anything strange, they've probably hit some kinda delay in a project.
	DELAY 10
	SAY And instead of admitting they made a mistake, they ship something. Even if it's wildly off spec.
	DELAY 20
	NAME Almayer Gervais
	PRESET /datum/preset_holoimage/engineer/rig
	SAY Sounds pretty scummy.
	DELAY 5
	SAY Oh well, work orders are work orders, we got them all hooked up?
	PRESET /datum/preset_holoimage/engineer/ce/rig
	NAME Oscar Leonidas
	SAY Yeah they're all set, Next up's uh... Something about a transit tube?
	DELAY 15
	SAY Ah who cares, Let's get moving
	DELAY 20
	PRESET /datum/preset_holoimage/corgi
	NAME Burst Data
	LANGUAGE /datum/language/eal
	SAY START NTINTEL METADATA
	SAY RECORDED 12-17-0000
	SAY SECURITY CLASS UNCLASSIFIED
	SAY END NTINTEL METADATA
"}