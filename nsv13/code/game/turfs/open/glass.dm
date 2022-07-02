/turf/open/floor/glass
	name = "Glass floor"
	desc = "While it at first appears to be a dangerous glass floor over space, closer inspection reveals it to simply be a screen behind a layer of glass."
	icon = 'nsv13/icons/turf/floors/glass.dmi'
	icon_state = "glass-0"
	baseturfs = /turf/open/floor/plating
	floor_tile = /obj/item/stack/tile/glass
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/turf/open/floor/glass,/turf/open/floor/glass/reinforced)
	footstep = FOOTSTEP_PLATING
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY

/turf/open/floor/glass/Initialize(mapload, inherited_virtual_z)
	icon_state = "" //Prevent the normal icon from appearing behind the smooth overlays
	..()
	return INITIALIZE_HINT_LATELOAD

/turf/open/floor/glass/LateInitialize()
	. = ..()
	AddElement(/datum/element/turf_z_transparency, TRUE)

/turf/open/floor/glass/reinforced
	name = "Reinforced glass floor"
	desc = "While it at first appears to be a dangerous glass floor over space, closer inspection reveals it to simply be a screen behind a reinforced protective layer of glass."
	icon = 'nsv13/icons/turf/floors/reinf_glass.dmi'
	icon_state = "reinf_glass-0"
	floor_tile = /obj/item/stack/tile/glass/reinforced
