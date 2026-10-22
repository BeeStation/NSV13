
/atom/movable/screen/overheat
	name = "Heat"
	icon = 'nsv13/icons/overmap/gui/overheat_gauge.dmi'
	icon_state = "gauge"
	screen_loc = "WEST:64,CENTER-1:15"
//	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/filterprogress = 50
//	var/image/progressbar
	var/obj/effect/overlay/heat_progressbar/bar
	var/obj/effect/overlay/heat_progressbar/avg/bar_average
	var/alpha_mask_filter
	var/datum/overmap_ship_weapon/weapon_datum


/atom/movable/screen/overheat/Initialize(mapload)
	transform *= 4
	if(!bar) bar = new
	vis_contents |= bar
	bar.add_filter("alpha_mask_filter", 1, alpha_mask_filter(0 , filterprogress, 'nsv13/icons/overmap/gui/mask.dmi', flags = MASK_INVERSE))
	if(!bar_average)
		bar_average = new
		vis_contents |= bar_average
		bar_average.add_filter("alpha_mask_filter", 1, alpha_mask_filter(0 , filterprogress, 'nsv13/icons/overmap/gui/mask.dmi', flags = MASK_INVERSE))
	//filters += filter(type = "alpha", y = filterprogress , flags = MASK_INVERSE , icon =  'nsv13/icons/overmap/gui/mask.dmi',  name = "progressbarmask")
//	cut_overlay()
//	progressbar = image('nsv13/icons/overmap/gui/overheat_gauge.dmi', icon_state= "7" )
//	progressbar.filters += filter(type = "alpha", y = filterprogress , flags = MASK_INVERSE , icon =  'icons/obj/doors/airlocks/mask_32x32_airlocks.dmi',  name = "progressbarmask")
	//alpha_mask_filter, alpha_mask_filter(0 , 100, 'icons/obj/doors/airlocks/mask_32x32_airlocks.dmi')
//	add_overlay(progressbar)

/atom/movable/screen/overheat/proc/set_offset(y,y2)
	bar.transition_filter("alpha_mask_filter", 0, list("y" = y), 0, 0,)
	bar_average.transition_filter("alpha_mask_filter", 0, list("y" = y2), 0, 0,)
	//filters += filter(type = "alpha", y = y , flags = MASK_INVERSE , icon =  'nsv13/icons/overmap/gui/mask.dmi',  name = "progressbarmask")

/atom/movable/screen/overheat/proc/updatehud()
	var/highest_heat = 0
	var/obj/machinery/ship_weapon/energy/hot_weapon
	var/combined_heat = 0
	for(hot_weapon in weapon_datum.weapons["loaded"])
		combined_heat += hot_weapon.heat
		if(hot_weapon.heat > highest_heat)
			highest_heat = hot_weapon.heat
	hot_weapon = pick(weapon_datum.weapons["loaded"])
	var/y = (100-(((hot_weapon.max_heat-highest_heat)/(hot_weapon.max_heat)) *100))
	var/max_combined_heat = hot_weapon.max_heat *length(weapon_datum.weapons["loaded"])
	var/y2 = (100-(((max_combined_heat-combined_heat)/(max_combined_heat)) *100))
	set_offset(y,y2)

/obj/effect/overlay/heat_progressbar
	name = "Heat"
	icon = 'nsv13/icons/overmap/gui/overheat_gauge.dmi'
	icon_state = "7"
	layer = FLOAT_LAYER

/obj/effect/overlay/heat_progressbar/avg
	name = "Average Heat"
	icon_state = "9"
	layer = FLOAT_LAYER-1

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
