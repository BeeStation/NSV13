//All credit goes to Goonstation's 2020 release for these explosion sprites, thanks goons!//

/obj/effect/temp_visual/impact_effect/torpedo
	icon = 'nsv13/goonstation/icons/effects/explosions/60x60.dmi'
	icon_state = "explosion"
	duration = 2 SECONDS

/obj/effect/temp_visual/impact_effect/torpedo/Initialize()
	var/states = list("explosion", "explosion2")
	icon_state = pick(states)
	. = ..()

/obj/effect/temp_visual/nuke_impact
	icon = 'nsv13/goonstation/icons/effects/explosions/224x224.dmi'
	icon_state = "explosion"
	duration = 5 SECONDS
	pixel_x = -96
	pixel_y = -96

/obj/effect/temp_visual/flak
	icon = 'nsv13/goonstation/icons/effects/explosions/80x80.dmi'
	icon_state = "explosion"
	duration = 2 SECONDS
	pixel_x = -32
	pixel_y = -32

/obj/effect/temp_visual/flak/Initialize()
	if(prob(50))
		icon = 'nsv13/goonstation/icons/effects/explosions/96x96.dmi'
	. = ..()