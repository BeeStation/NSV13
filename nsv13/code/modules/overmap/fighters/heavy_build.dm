#define HBS_CHASSIS							0
#define HBS_CHASSIS_BOLT					1
#define HBS_CHASSIS_WELD					2
#define HBS_FUEL_TANK						3
#define HBS_FUEL_TANK_BOLT					4
#define HBS_ENGINE							5
#define HBS_ENGINE_BOLT						6
#define HBS_APU								7
#define HBS_APU_WIRE						8
#define HBS_APU_SCREW						9
#define HBS_AVIONICS						10
#define HBS_AVIONICS_WIRE					11
#define HBS_AVIONICS_MULTI					12
#define HBS_TARGETING_SENSOR				13
#define HBS_TARGETING_SENSOR_SCREW			14
#define HBS_COUNTERMEASURE_DISPENSOR		15
#define HBS_COUNTERMEASURE_DISPENSOR_BOLT	16
#define HBS_CANNON							17
#define HBS_CANNON_BOLT						18
#define HBS_TORPEDO_RACK					19
#define HBS_TORPEDO_RACK_BOLT				20
#define HBS_ARMOUR_PLATING					21
#define HBS_ARMOUR_PLATING_BOLT				22
#define HBS_ARMOUR_PLATING_WELD				23
#define HBS_PAINT_PRIMER					24
#define HBS_PAINT_DETAILING					25

/obj/structure/fighter_component/underconstruction_fighter/heavy_fighter_frame
	name = "Heavy Fighter Frame"
	desc = "An Incomplete Heavy Fighter"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "advmop"
	build_state = HBS_CHASSIS
	fighter_name = null

/obj/structure/fighter_component/underconstruction_fighter/heavy_fighter_frame/examine(mob/user)
	. = ..()
	switch(build_state)
		if(HBS_CHASSIS)
			. += "<span class='notice'>0</span>"
		if(HBS_CHASSIS_BOLT)
			. += "<span class='notice'>1</span>"
		if(HBS_CHASSIS_WELD)
			. += "<span class='notice'>2</span>"
		if(HBS_FUEL_TANK)
			. += "<span class='notice'>3</span>"
		if(HBS_FUEL_TANK_BOLT)
			. += "<span class='notice'>4</span>"
		if(HBS_ENGINE)
			. += "<span class='notice'>5</span>"
		if(HBS_ENGINE_BOLT)
			. += "<span class='notice'>6</span>"
		if(HBS_APU)
			. += "<span class='notice'>7</span>"
		if(HBS_APU_WIRE)
			. += "<span class='notice'>8</span>"
		if(HBS_APU_SCREW)
			. += "<span class='notice'>9</span>"
		if(HBS_AVIONICS)
			. += "<span class='notice'>10</span>"
		if(HBS_AVIONICS_WIRE)
			. += "<span class='notice'>11</span>"
		if(HBS_AVIONICS_MULTI)
			. += "<span class='notice'>12</span>"
		if(HBS_TARGETING_SENSOR)
			. += "<span class='notice'>13</span>"
		if(HBS_TARGETING_SENSOR_SCREW)
			. += "<span class='notice'>14</span>"
		if(HBS_COUNTERMEASURE_DISPENSOR)
			. += "<span class='notice'>15</span>"
		if(HBS_COUNTERMEASURE_DISPENSOR_BOLT)
			. += "<span class='notice'>16</span>"
		if(HBS_CANNON)
			. += "<span class='notice'>17</span>"
		if(HBS_CANNON_BOLT)
			. += "<span class='notice'>18</span>"
		if(HBS_TORPEDO_RACK)
			. += "<span class='notice'>19</span>"
		if(HBS_TORPEDO_RACK_BOLT)
			. += "<span class='notice'>20</span>"
		if(HBS_ARMOUR_PLATING)
			. += "<span class='notice'>21</span>"
		if(HBS_ARMOUR_PLATING_BOLT)
			. += "<span class='notice'>22</span>"
		if(HBS_ARMOUR_PLATING_WELD)
			. += "<span class='notice'>23</span>"
		if(HBS_PAINT_PRIMER)
			. += "<span class='notice'>24</span>"
		if(HBS_PAINT_DETAILING)
			. += "<span class='notice'>25</span>"

/obj/structure/fighter_component/heavy_chassis_crate/attack_hand(mob/user)
	.=..()
	if(alert(user, "Begin constructing an Su-395 Chelyabinsk Heavy Fighter?",, "Yes", "No")!="Yes")
		return
	to_chat(user, "<span class='notice'>You begin constructing the chassis of a new fighter.</span>")
	if(!do_after(user, 10 SECONDS, target=src))
		return
	to_chat(user, "<span class='notice'>You construct the chassis of a new fighter.</span>")
	new/obj/structure/fighter_component/underconstruction_fighter/heavy_fighter_frame (loc, 1)
	qdel(src)

/obj/structure/fighter_component/underconstruction_fighter/heavy_fighter_frame/update_icon()
	cut_overlays()
	switch(build_state)
		if(HBS_CHASSIS)
			icon_state = "advmop"
		if(HBS_CHASSIS_BOLT)
			icon_state = "advmop"
		if(HBS_CHASSIS_WELD)
			icon_state = "advmop"
		if(HBS_FUEL_TANK)
			icon_state = "advmop"
		if(HBS_FUEL_TANK_BOLT)
			icon_state = "advmop"
		if(HBS_ENGINE)
			icon_state = "advmop"
		if(HBS_ENGINE_BOLT)
			icon_state = "advmop"
		if(HBS_APU)
			icon_state = "advmop"
		if(HBS_APU_WIRE)
			icon_state = "advmop"
		if(HBS_APU_SCREW)
			icon_state = "advmop"
		if(HBS_AVIONICS)
			icon_state = "advmop"
		if(HBS_AVIONICS_WIRE)
			icon_state = "advmop"
		if(HBS_AVIONICS_MULTI)
			icon_state = "advmop"
		if(HBS_TARGETING_SENSOR)
			icon_state = "advmop"
		if(HBS_TARGETING_SENSOR_SCREW)
			icon_state = "advmop"
		if(HBS_COUNTERMEASURE_DISPENSOR)
			icon_state = "advmop"
		if(HBS_COUNTERMEASURE_DISPENSOR_BOLT)
			icon_state = "advmop"
		if(HBS_CANNON)
			icon_state = "advmop"
		if(HBS_CANNON_BOLT)
			icon_state = "advmop"
		if(HBS_TORPEDO_RACK)
			icon_state = "advmop"
		if(HBS_TORPEDO_RACK_BOLT)
			icon_state = "advmop"
		if(HBS_ARMOUR_PLATING)
			icon_state = "advmop"
		if(HBS_ARMOUR_PLATING_BOLT)
			icon_state = "advmop"
		if(HBS_ARMOUR_PLATING_WELD)
			icon_state = "advmop"
		if(HBS_PAINT_PRIMER)
			icon_state = "advmop"
		if(HBS_PAINT_DETAILING)
			icon_state = "advmop"

#undef HBS_CHASSIS
#undef HBS_CHASSIS_BOLT
#undef HBS_CHASSIS_WELD
#undef HBS_FUEL_TANK
#undef HBS_FUEL_TANK_BOLT
#undef HBS_ENGINE
#undef HBS_ENGINE_BOLT
#undef HBS_APU
#undef HBS_APU_WIRE
#undef HBS_APU_SCREW
#undef HBS_AVIONICS
#undef HBS_AVIONICS_WIRE
#undef HBS_AVIONICS_MULTI
#undef HBS_TARGETING_SENSOR
#undef HBS_TARGETING_SENSOR_SCREW
#undef HBS_COUNTERMEASURE_DISPENSOR
#undef HBS_COUNTERMEASURE_DISPENSOR_BOLT
#undef HBS_CANNON
#undef HBS_CANNON_BOLT
#undef HBS_TORPEDO_RACK
#undef HBS_TORPEDO_RACK_BOLT
#undef HBS_ARMOUR_PLATING
#undef HBS_ARMOUR_PLATING_BOLT
#undef HBS_ARMOUR_PLATING_WELD
#undef HBS_PAINT_PRIMER
#undef HBS_PAINT_DETAILING
