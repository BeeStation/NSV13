#define UBS_CHASSIS							0
#define UBS_CHASSIS_BOLT					1
#define UBS_CHASSIS_WELD					2
#define UBS_ENGINE							3
#define UBS_ENGINE_BOLT						4
#define UBS_APU								5
#define UBS_APU_WIRE						6
#define UBS_APU_MULTI						7
#define UBS_FUEL_TANK						8
#define UBS_FUEL_TANK_BOLT					9
#define UBS_AUX_FUEL_TANK					10
#define UBS_AUX_FUEL_TANK_SCREW				11
#define UBS_AUX_FUEL_TANK_BOLT				12
#define UBS_REFUELING_SYSTEM				13
#define UBS_REFUELING_SYSTEM_BOLT			14
#define UBS_REFUELING_SYSTEM_MULTI			15
#define UBS_PASSENGER_COMPARTMENT			16
#define UBS_PASSENGER_COMPARTMENT_SCREW		17
#define UBS_PASSENGER_COMPARTMENT_BOLT		18
#define UBS_AVIONICS						19
#define UBS_AVIONICS_WIRE					20
#define UBS_ARMOUR_PLATING					21
#define UBS_ARMOUR_PLATING_BOLT				22
#define UBS_ARMOUR_PLATING_WELD				23
#define UBS_PAINT_PRIMER					24
#define UBS_PAINT_DETAILING					25

/obj/structure/fighter_component/underconstruction_fighter/utility_craft_frame
	name = "Utility Craft Frame"
	desc = "An Incomplete Utility Craft"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "smmop"
	build_state = UBS_CHASSIS
	fighter_name = null

/obj/structure/fighter_component/underconstruction_fighter/utility_craft_frame/examine(mob/user)
	. = ..()
	switch(build_state)
		if(UBS_CHASSIS)
			. += "<span class='notice'>0</span>"
		if(UBS_CHASSIS_BOLT)
			. += "<span class='notice'>1</span>"
		if(UBS_CHASSIS_WELD)
			. += "<span class='notice'>2</span>"
		if(UBS_ENGINE)
			. += "<span class='notice'>3</span>"
		if(UBS_ENGINE_BOLT)
			. += "<span class='notice'>4</span>"
		if(UBS_APU)
			. += "<span class='notice'>5</span>"
		if(UBS_APU_WIRE)
			. += "<span class='notice'>6</span>"
		if(UBS_APU_MULTI)
			. += "<span class='notice'>7</span>"
		if(UBS_FUEL_TANK)
			. += "<span class='notice'>8</span>"
		if(UBS_FUEL_TANK_BOLT)
			. += "<span class='notice'>9</span>"
		if(UBS_AUX_FUEL_TANK)
			. += "<span class='notice'>10</span>"
		if(UBS_AUX_FUEL_TANK_SCREW)
			. += "<span class='notice'>11</span>"
		if(UBS_AUX_FUEL_TANK_BOLT)
			. += "<span class='notice'>12</span>"
		if(UBS_REFUELING_SYSTEM)
			. += "<span class='notice'>13</span>"
		if(UBS_REFUELING_SYSTEM_BOLT)
			. += "<span class='notice'>14</span>"
		if(UBS_REFUELING_SYSTEM_MULTI)
			. += "<span class='notice'>15</span>"
		if(UBS_PASSENGER_COMPARTMENT)
			. += "<span class='notice'>16</span>"
		if(UBS_PASSENGER_COMPARTMENT_SCREW)
			. += "<span class='notice'>17</span>"
		if(UBS_PASSENGER_COMPARTMENT_BOLT)
			. += "<span class='notice'>18</span>"
		if(UBS_AVIONICS)
			. += "<span class='notice'>19</span>"
		if(UBS_AVIONICS_WIRE)
			. += "<span class='notice'>20</span>"
		if(UBS_ARMOUR_PLATING)
			. += "<span class='notice'>21</span>"
		if(UBS_ARMOUR_PLATING_BOLT)
			. += "<span class='notice'>22</span>"
		if(UBS_ARMOUR_PLATING_WELD)
			. += "<span class='notice'>23</span>"
		if(UBS_PAINT_PRIMER)
			. += "<span class='notice'>24</span>"
		if(UBS_PAINT_DETAILING)
			. += "<span class='notice'>25</span>"

/obj/structure/fighter_component/utility_chassis_crate/attack_hand(mob/user)
	.=..()
	if(alert(user, "Begin constructing an somethingsomething Utility Craft?",, "Yes", "No")!="Yes")
		return
	to_chat(user, "<span class='notice'>You begin constructing the chassis of a utility craft.</span>")
	if(!do_after(user, 10 SECONDS, target=src))
		return
	to_chat(user, "<span class='notice'>You construct the chassis of a utility craft.</span>")
	new/obj/structure/fighter_component/underconstruction_fighter/utility_craft_frame (loc, 1)
	qdel(src)

/obj/structure/fighter_component/underconstruction_fighter/light_fighter_frame/update_icon()
	cut_overlays()
	switch(build_state)
		if(UBS_CHASSIS)
			icon_state = "smmop"
		if(UBS_CHASSIS_BOLT)
			icon_state = "smmop"
		if(UBS_CHASSIS_WELD)
			icon_state = "smmop"
		if(UBS_ENGINE)
			icon_state = "smmop"
		if(UBS_ENGINE_BOLT)
			icon_state = "smmop"
		if(UBS_APU)
			icon_state = "smmop"
		if(UBS_APU_WIRE)
			icon_state = "smmop"
		if(UBS_APU_MULTI)
			icon_state = "smmop"
		if(UBS_FUEL_TANK)
			icon_state = "smmop"
		if(UBS_FUEL_TANK_BOLT)
			icon_state = "smmop"
		if(UBS_AUX_FUEL_TANK)
			icon_state = "smmop"
		if(UBS_AUX_FUEL_TANK_SCREW)
			icon_state = "smmop"
		if(UBS_AUX_FUEL_TANK_BOLT)
			icon_state = "smmop"
		if(UBS_REFUELING_SYSTEM)
			icon_state = "smmop"
		if(UBS_REFUELING_SYSTEM_BOLT)
			icon_state = "smmop"
		if(UBS_REFUELING_SYSTEM_MULTI)
			icon_state = "smmop"
		if(UBS_PASSENGER_COMPARTMENT)
			icon_state = "smmop"
		if(UBS_PASSENGER_COMPARTMENT_SCREW)
			icon_state = "smmop"
		if(UBS_PASSENGER_COMPARTMENT_BOLT)
			icon_state = "smmop"
		if(UBS_AVIONICS)
			icon_state = "smmop"
		if(UBS_AVIONICS_WIRE)
			icon_state = "smmop"
		if(UBS_ARMOUR_PLATING)
			icon_state = "smmop"
		if(UBS_ARMOUR_PLATING_BOLT)
			icon_state = "smmop"
		if(UBS_ARMOUR_PLATING_WELD)
			icon_state = "smmop"
		if(UBS_PAINT_PRIMER)
			icon_state = "smmop"
		if(UBS_PAINT_DETAILING)
			icon_state = "smmop"

#undef UBS_CHASSIS
#undef UBS_CHASSIS_BOLT
#undef UBS_CHASSIS_WELD
#undef UBS_ENGINE
#undef UBS_ENGINE_BOLT
#undef UBS_APU
#undef UBS_APU_WIRE
#undef UBS_APU_MULTI
#undef UBS_FUEL_TANK
#undef UBS_FUEL_TANK_BOLT
#undef UBS_AUX_FUEL_TANK
#undef UBS_AUX_FUEL_TANK_SCREW
#undef UBS_AUX_FUEL_TANK_BOLT
#undef UBS_REFUELING_SYSTEM
#undef UBS_REFUELING_SYSTEM_BOLT
#undef UBS_REFUELING_SYSTEM_MULTI
#undef UBS_PASSENGER_COMPARTMENT
#undef UBS_PASSENGER_COMPARTMENT_SCREW
#undef UBS_PASSENGER_COMPARTMENT_BOLT
#undef UBS_AVIONICS
#undef UBS_AVIONICS_WIRE
#undef UBS_ARMOUR_PLATING
#undef UBS_ARMOUR_PLATING_BOLT
#undef UBS_ARMOUR_PLATING_WELD
#undef UBS_PAINT_PRIMER
#undef UBS_PAINT_DETAILING