// CARGO
/obj/item/robot_module/cargo
	name = "Cargo"
	basic_modules = list(
		/obj/item/stamp,
		/obj/item/stamp/denied,
		/obj/item/pen/cyborg,
		/obj/item/clipboard/cyborg,
		/obj/item/stack/package_wrap/cyborg,
		/obj/item/stack/wrapping_paper/cyborg,
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/hydraulic_clamp,
		/obj/item/borg/hydraulic_clamp/mail,
		/obj/item/hand_labeler/cyborg,
		/obj/item/dest_tagger,
		/obj/item/crowbar/cyborg,
		/obj/item/extinguisher,
		/obj/item/export_scanner,
	)
	emag_modules = list(
		/obj/item/stamp/chameleon,
	)
	hat_offset = 0
	cyborg_base_icon = "cargo"
	moduleselect_icon = "cargo"
	canDispose = TRUE
	borg_skins = list(
		"Technician" = list(SKIN_ICON_STATE = "cargoborg", SKIN_ICON = CYBORG_ICON_CARGO),
		"Zoomba" = list(SKIN_ICON_STATE = "zoomba_cargo", SKIN_ICON = CYBORG_ICON_CARGO, SKIN_FEATURES = list(R_TRAIT_UNIQUEWRECK))
	)

// Munitions
/obj/item/robot_module/munition
	name = "Munitions"
	basic_modules = list(
		/obj/item/borg/apparatus/munitions,
		/obj/item/borg/fuelnozzle,
		/obj/item/lighter,
		/obj/item/borg/charger,
		/obj/item/airlock_painter/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/multitool/cyborg,
		/obj/item/stack/cable_coil/cyborg,
		/obj/item/extinguisher/mini,
	)
	hat_offset = 0
	moduleselect_icon = "standard"
	cyborg_base_icon = "engi-tread"
	borg_skins = list(
		"Loader" = list(SKIN_ICON_STATE = "loaderborg", SKIN_ICON = CYBORG_ICON_MUNITIONS, SKIN_FEATURES = list(R_TRAIT_UNIQUEWRECK)),
		"Treads" = list(SKIN_ICON_STATE = "muni-tread", SKIN_ICON = CYBORG_ICON_MUNITIONS)
	)
