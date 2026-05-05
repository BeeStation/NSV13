
/atom/movable/screen/overheat
	name = "Heat"
	icon = 'nsv13/icons/overmap/gui/overheat_gauge.dmi'
	icon_state = "gauge"
	screen_loc = "WEST:64,CENTER-1:15"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/heat = 0


/atom/movable/screen/overheat/Initialize(mapload)
	src.transform *= 4
	cut_overlays()
	add_overlay("8")


//	/atom/movable/screen/alien/plasma_display

/datum/hud/overheat


/*
/datum/hud/revenant/New(mob/owner)
	..()

	healths = new /atom/movable/screen/healths/revenant()
	healths.hud = src
	infodisplay += healths



	alien_plasma_display = new /atom/movable/screen/alien/plasma_display()
	alien_plasma_display.hud = src
	infodisplay += alien_plasma_display


/mob/living/carbon/alien/proc/updatePlasmaDisplay()
	if(!hud_used) //clientless aliens
		return
	hud_used.alien_plasma_display.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='magenta'>[round(getPlasma())]</font></div>")
*/
