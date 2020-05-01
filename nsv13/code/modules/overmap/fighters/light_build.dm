#define LBS_CHASSIS 						0
#define LBS_CHASSIS_BOLT					1
#define LBS_CHASSIS_WELD					2
#define LBS_ENGINE							3
#define LBS_ENGINE_BOLT						4
#define LBS_APU								5
#define LBS_APU_WIRE						6
#define LBS_APU_SCREW						7
#define LBS_FUEL_TANK						8
#define LBS_FUEL_TANK_BOLT					9
#define LBS_AVIONICS						10
#define LBS_AVIONICS_WIRE					11
#define LBS_AVIONICS_SCREW					12
#define LBS_TARGETING_SENSOR				13
#define LBS_TARGETING_SENSOR_SCREW			14
#define LBS_COUNTERMEASURE_DISPENSER		15
#define LBS_COUNTERMEASURE_DISPENSER_BOLT	16
#define LBS_ARMOUR_PLATING					17
#define LBS_ARMOUR_PLATING_BOLT				18
#define LBS_ARMOUR_PLATING_WELD				19
#define LBS_PRIMARY							20
#define LBS_PRIMARY_BOLT					21
#define LBS_SECONDARY						22
#define LBS_SECONDARY_BOLT					23
#define LBS_PAINT_PRIMER					24
#define LBS_PAINT_DETAILING					25

/obj/structure/fighter_component/underconstruction_fighter/light_fighter_frame
	name = "Light Fighter Frame"
	desc = "An Incomplete Su-818 Rapier Light Fighter"
	icon = 'nsv13/icons/overmap/nanotrasen/fighter_construction.dmi'
	icon_state = "fighter"
	build_state = LBS_CHASSIS
	fighter_name = null
	pixel_x = -32
	pixel_y = -12

/obj/structure/fighter_component/underconstruction_fighter/light_fighter_frame/examine(mob/user)
	. = ..()
	switch(build_state)
		if(LBS_CHASSIS)
			. += "<span class='notice'>Secure the chassis with bolts.</span>"
		if(LBS_CHASSIS_BOLT)
			. += "<span class='notice'>Reinforce the chassis joints with a welder.</span>"
		if(LBS_CHASSIS_WELD)
			. += "<span class='notice'>Install the engine into slot B.</span>"
		if(LBS_ENGINE)
			. += "<span class='notice'>Secure the engine to the chassis with bolts.</span>"
		if(LBS_ENGINE_BOLT)
			. += "<span class='notice'>Install the auxiliary power unit into slot S.</span>"
		if(LBS_APU)
			. += "<span class='notice'>Follow the wiring diagram to connect the auxiliary power unit to the engine.</span>"
		if(LBS_APU_WIRE)
			. += "<span class='notice'>Secure the auxiliary power unit connections with screws.</span>"
		if(LBS_APU_SCREW)
			. += "<span class='notice'>Install the fuel tank into slot G.</span>"
		if(LBS_FUEL_TANK)
			. += "<span class='notice'>Secure the fuel tank to the chassis with bolts.</span>"
		if(LBS_FUEL_TANK_BOLT)
			. += "<span class='notice'>Install the avionics into slot _S</span>"
		if(LBS_AVIONICS)
			. += "<span class='notice'>Follow the wiring diagram to connect the avionics to the flight controls and thrusters.</span>"
		if(LBS_AVIONICS_WIRE)
			. += "<span class='notice'>Secure the avionics connections with screws.</span>"
		if(LBS_AVIONICS_SCREW)
			. += "<span class='notice'>Install the targeting sensor into slot U.</span>"
		if(LBS_TARGETING_SENSOR)
			. += "<span class='notice'>Secure the targeting sensor to the chassis with screws.</span>"
		if(LBS_TARGETING_SENSOR_SCREW)
			. += "<span class='notice'>Install the countermeasure dispenser into slot X</span>"
		if(LBS_COUNTERMEASURE_DISPENSER)
			. += "<span class='notice'>Secure the countermeasure dispenser to the chassis with bolts.</span>"
		if(LBS_COUNTERMEASURE_DISPENSER_BOLT)
			. += "<span class='notice'>Install the armour plating in all indicated places on the diagram.</span>"
		if(LBS_ARMOUR_PLATING)
			. += "<span class='notice'>Secure the armour plating to chassis with bolts.</span>"
		if(LBS_ARMOUR_PLATING_BOLT)
			. += "<span class='notice'>Reinforce the armour plating bonds with the chassis with a welder.</span>"
		if(LBS_ARMOUR_PLATING_WELD)
			. += "<span class='notice'>Install the primary weapon module into the forward weapon mount.</span>"
		if(LBS_PRIMARY)
			. += "<span class='notice'>Secure the primary weapon module to the forward weapon mount with bolts.</span>"
		if(LBS_PRIMARY_BOLT)
			. += "<span class='notice'>Install the secondary weapon module into the belly weapon mount.</span>"
		if(LBS_SECONDARY)
			. += "<span class='notice'>Secure the secondary weapon module to the belly weapon mount with bolts.</span>"
		if(LBS_SECONDARY_BOLT)
			. += "<span class='notice'>Paint the surface of the [src] with primer.</span>"
		if(LBS_PAINT_PRIMER)
			. += "<span class='notice'>Paint the surface of [src] and apply approved detailing as the diagrams.</span>"
		if(LBS_PAINT_DETAILING)
			. += "<span class='notice'>Choose a name for the new Su-818 Rapier.</span>"

/obj/structure/fighter_component/light_chassis_crate/attack_hand(mob/user)
	.=..()
	if(alert(user, "Begin constructing an Su-818 Rapier Light Fighter?",, "Yes", "No")!="Yes")
		return
	to_chat(user, "<span class='notice'>You begin constructing the chassis of a new fighter.</span>")
	if(!do_after(user, 10 SECONDS, target=src))
		return
	to_chat(user, "<span class='notice'>You construct the chassis of a new fighter.</span>")
	new/obj/structure/fighter_component/underconstruction_fighter/light_fighter_frame (loc, 1)
	qdel(src)

/obj/structure/fighter_component/underconstruction_fighter/light_fighter_frame/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(building)
		to_chat(user, "<span class='notice'>You're already installing something into [src]!.</span>")
		return
	if(istype(W, /obj/item/fighter_component/fuel_tank))
		if(build_state == LBS_APU_SCREW)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>You add [W] to [src].</span>")
			build_state = LBS_FUEL_TANK
			update_icon()
			W.forceMove(src)
			building = FALSE
	else if(istype(W, /obj/item/fighter_component/avionics))
		if(build_state == LBS_FUEL_TANK_BOLT)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>You add [W] to [src].</span>")
			build_state = LBS_AVIONICS
			update_icon()
			W.forceMove(src)
			building = FALSE
	else if(istype(W, /obj/item/fighter_component/apu))
		if(build_state == LBS_ENGINE_BOLT)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>You add [W] to [src].</span>")
			build_state = LBS_APU
			update_icon()
			W.forceMove(src)
			building = FALSE
	else if(istype(W, /obj/item/fighter_component/armour_plating/light))
		if(build_state == LBS_COUNTERMEASURE_DISPENSER_BOLT)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>You add [W] to [src].</span>")
			build_state = LBS_ARMOUR_PLATING
			update_icon()
			W.forceMove(src)
			building = FALSE
	else if(istype(W, /obj/item/fighter_component/targeting_sensor/light))
		if(build_state == LBS_AVIONICS_SCREW)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>You add [W] to [src].</span>")
			build_state = LBS_TARGETING_SENSOR
			update_icon()
			W.forceMove(src)
			building = FALSE
	else if(istype(W, /obj/item/fighter_component/engine/light))
		if(build_state == LBS_CHASSIS_WELD)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>You add [W] to [src].</span>")
			build_state = LBS_ENGINE
			update_icon()
			W.forceMove(src)
			building = FALSE
	else if(istype(W, /obj/item/fighter_component/countermeasure_dispenser))
		if(build_state == LBS_TARGETING_SENSOR_SCREW)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>You add [W] to [src].</span>")
			build_state = LBS_COUNTERMEASURE_DISPENSER
			update_icon()
			W.forceMove(src)
			building = FALSE
	else if(istype(W, /obj/item/fighter_component/secondary/light))
		if(build_state == LBS_PRIMARY_BOLT)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>You add [W] to [src].</span>")
			build_state = LBS_SECONDARY
			update_icon()
			W.forceMove(src)
			building = FALSE
	else if(istype(W, /obj/item/fighter_component/primary/light))
		if(build_state == LBS_ARMOUR_PLATING_WELD)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>You add [W] to [src].</span>")
			build_state = LBS_PRIMARY
			update_icon()
			W.forceMove(src)
			building = FALSE
	else if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if(build_state == LBS_AVIONICS)
			if(C.get_amount() <5)
				to_chat(user, "<span class='notice'>You need at least five cable pieces to wire [src]!</span>")
				return
			to_chat(user, "<span class='notice'>You start wiring [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			W.use(5)
			to_chat(user, "<spawn class='notice'>You wire [src].</span>")
			build_state = LBS_AVIONICS_WIRE
			update_icon()
			building = FALSE
		if(build_state == LBS_APU)
			if(C.get_amount() <5)
				to_chat(user, "<span class='notice'>You need at least five cable pieces to wire [src]!</span>")
				return
			to_chat(user, "<span class='notice'>You start wiring [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			W.use(5)
			to_chat(user, "<spawn class='notice'>You wire [src].</span>")
			build_state = LBS_APU_WIRE
			update_icon()
			building = FALSE
	else if(istype(W, /obj/item/airlock_painter)) //replace with an aircraft painter
		if(build_state == LBS_SECONDARY_BOLT) //check mode later
			to_chat(user, "<span class='notice'>You start painting primer on [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>You prime [src].</span>")
			playsound(src, 'sound/effects/spray.ogg', 100, 1)
			build_state = LBS_PAINT_PRIMER
			update_icon()
			building = FALSE
		else if(build_state == LBS_PAINT_PRIMER) //check mode later
			to_chat(user, "<span class='notice'>You start painting details on [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>You finish painting [src].</span>")
			playsound(src, 'sound/effects/spray.ogg', 100, 1)
			build_state = LBS_PAINT_DETAILING
			update_icon()
			building = FALSE

/obj/structure/fighter_component/underconstruction_fighter/light_fighter_frame/wrench_act(mob/user, obj/item/tool)
	. = FALSE
	switch(build_state)
		if(LBS_CHASSIS)
			to_chat(user, "<span class='notice'>You start to bolt the chassis together...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You bolt the chassis together.</span>")
				build_state = LBS_CHASSIS_BOLT
				update_icon()
				return TRUE
		if(LBS_CHASSIS_BOLT)
			to_chat(user, "<span class='notice'>You start to unbolt the chassis.</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unbolt the chassis.</span>")
				build_state = LBS_CHASSIS
				update_icon()
				return TRUE
		if(LBS_ENGINE)
			to_chat(user, "<span class='notice'>You start to bolt the engine to the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You bolt the engine to the chassis.</span>")
				build_state = LBS_ENGINE_BOLT
				update_icon()
				return TRUE
		if(LBS_ENGINE_BOLT)
			to_chat(user, "<span class='notice'>You start to unbolt the engine from the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unbolt the engine from the chassis.</span>")
				build_state = LBS_ENGINE
				update_icon()
				return TRUE
		if(LBS_FUEL_TANK)
			to_chat(user, "<span class='notice'>You start to bolt the fuel tank to the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You bolt the fuel tank to the chassis.</span>")
				build_state = LBS_FUEL_TANK_BOLT
				update_icon()
				return TRUE
		if(LBS_FUEL_TANK_BOLT)
			to_chat(user, "<span class='notice'>You start to unbolt the fuel tank from the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unbolt the fuel tank from the chassis.</span>")
				build_state = LBS_FUEL_TANK
				update_icon()
				return TRUE
		if(LBS_COUNTERMEASURE_DISPENSER)
			to_chat(user, "<span class='notice'>You start to bolt the countermeasure dispenser to the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You bolt the countermeasure dispenser to the chassis.</span>")
				build_state = LBS_COUNTERMEASURE_DISPENSER_BOLT
				update_icon()
				return TRUE
		if(LBS_COUNTERMEASURE_DISPENSER_BOLT)
			to_chat(user, "<span class='notice'>You start to unbolt the countermeasure dispenser from the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unbolt the countermeasure dispenser from the chassis.</span>")
				build_state = LBS_COUNTERMEASURE_DISPENSER
				update_icon()
				return TRUE
		if(LBS_ARMOUR_PLATING)
			to_chat(user, "<span class='notice'>You start to bolt the armour plating to the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You bolt the armour plating to the chassis.</span>")
				build_state = LBS_ARMOUR_PLATING_BOLT
				update_icon()
				return TRUE
		if(LBS_ARMOUR_PLATING_BOLT)
			to_chat(user, "<span class='notice'>You start to bolt the armour plating to the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You bolt the armour plating to the chassis.</span>")
				build_state = LBS_ARMOUR_PLATING_BOLT
				update_icon()
				return TRUE
		if(LBS_PRIMARY)
			to_chat(user, "<span class='notice'>You start to bolt the light cannon to the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You bolt the light cannon to the chassis.</span>")
				build_state = LBS_PRIMARY_BOLT
				update_icon()
				return TRUE
		if(LBS_PRIMARY_BOLT)
			to_chat(user, "<span class='notice'>You start to unbolt the light cannon from the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unbolt the light cannon from the chassis.</span>")
				build_state = LBS_PRIMARY
				update_icon()
				return TRUE
		if(LBS_SECONDARY)
			to_chat(user, "<span class='notice'>You start to bolt the missle rack to the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You bolt the missile rack to the chassis.</span>")
				build_state = LBS_SECONDARY_BOLT
				update_icon()
				return TRUE
		if(LBS_SECONDARY_BOLT)
			to_chat(user, "<span class='notice'>You start to unbolt the missle rack from the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unbolt the missile rack from the chassis.</span>")
				build_state = LBS_SECONDARY
				update_icon()
				return TRUE

/obj/structure/fighter_component/underconstruction_fighter/light_fighter_frame/screwdriver_act(mob/user, obj/item/tool)
	. = FALSE
	switch(build_state)
		if(LBS_APU_WIRE)
			to_chat(user, "<span class='notice'>You start to screw the APU to the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You screw the APU to the chassis.</span>")
				build_state = LBS_APU_SCREW
				update_icon()
				return TRUE
		if(LBS_APU_SCREW)
			to_chat(user, "<span class='notice'>You start to unscrew the APU from the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unscrew the APU from the chassis.</span>")
				build_state = LBS_APU_WIRE
				update_icon()
				return TRUE
		if(LBS_AVIONICS_WIRE)
			to_chat(user, "<span class='notice'>You start to screw the avionics to the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You screw the avionics to the chassis.</span>")
				build_state = LBS_AVIONICS_SCREW
				update_icon()
				return TRUE
		if(LBS_AVIONICS_SCREW)
			to_chat(user, "<span class='notice'>You start to unscrew the avionics from the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unscrew the avionics from the chassis.</span>")
				build_state = LBS_AVIONICS_WIRE
				update_icon()
				return TRUE
		if(LBS_TARGETING_SENSOR)
			to_chat(user, "<span class='notice'>You start to screw the targeting sensor to the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You screw the targeting to the chassis.</span>")
				build_state = LBS_TARGETING_SENSOR_SCREW
				update_icon()
				return TRUE
		if(LBS_TARGETING_SENSOR_SCREW)
			to_chat(user, "<span class='notice'>You start to unscrew the targeting sensor to the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unscrew the targeting sensor to the chassis.</span>")
				build_state = LBS_TARGETING_SENSOR
				update_icon()
				return TRUE

/obj/structure/fighter_component/underconstruction_fighter/light_fighter_frame/welder_act(mob/user, obj/item/tool)
	. = FALSE
	switch(build_state)
		if(LBS_CHASSIS_BOLT)
			to_chat(user, "<span class='notice'>You start to weld the chassis together...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You weld the chassis together.</span>")
				build_state = LBS_CHASSIS_WELD
				update_icon()
				return TRUE
		if(LBS_CHASSIS_WELD)
			to_chat(user, "<span class='notice'>You start to cut the chassis apart.</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You cut the chassis apart.</span>")
				build_state = LBS_CHASSIS_BOLT
				update_icon()
				return TRUE
		if(LBS_ARMOUR_PLATING_BOLT)
			to_chat(user, "<span class='notice'>You start to weld the armour plating to the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You weld the armour plating to the chassis.</span>")
				build_state = LBS_ARMOUR_PLATING_WELD
				update_icon()
				return TRUE
		if(LBS_ARMOUR_PLATING_WELD)
			to_chat(user, "<span class='notice'>You start to cut the armour plating from the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You cut the armour plating from the chassis.</span>")
				build_state = LBS_ARMOUR_PLATING_BOLT
				update_icon()
				return TRUE

/obj/structure/fighter_component/underconstruction_fighter/light_fighter_frame/wirecutter_act(mob/user, obj/item/tool)
	. = FALSE
	switch(build_state)
		if(LBS_APU_WIRE)
			to_chat(user, "<span class='notice'>You start cutting the wiring in [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You cut the wiring in [src].</span>")
				var/obj/item/stack/cable_coil/C = new (loc, 5)
				C.add_fingerprint(user)
				build_state = LBS_APU
				update_icon()
				return TRUE
		if(LBS_AVIONICS_WIRE)
			to_chat(user, "<span class='notice'>You start cutting the wiring in [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You cut the wiring in [src].</span>")
				var/obj/item/stack/cable_coil/C = new (loc, 5)
				C.add_fingerprint(user)
				build_state = LBS_AVIONICS
				update_icon()
				return TRUE

/obj/structure/fighter_component/underconstruction_fighter/light_fighter_frame/crowbar_act(mob/user, obj/item/tool)
	. = FALSE
	switch(build_state)
		if(LBS_ENGINE)
			to_chat(user, "<span class='notice'>You start removing the engine from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the engine from [src].</span>")
				var/atom/movable/ts = get_part(/obj/item/fighter_component/engine)
				ts?.forceMove(get_turf(src))
				build_state = LBS_CHASSIS_WELD
				update_icon()
				return TRUE
		if(LBS_APU)
			to_chat(user, "<span class='notice'>You start removing the APU from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the APU from [src].</span>")
				var/atom/movable/ts = get_part(/obj/item/fighter_component/apu)
				ts?.forceMove(get_turf(src))
				build_state = LBS_ENGINE_BOLT
				update_icon()
				return TRUE
		if(LBS_FUEL_TANK)
			to_chat(user, "<span class='notice'>You start removing the fuel tank from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the fuel tank from [src].</span>")
				var/atom/movable/ts = get_part(/obj/item/fighter_component/fuel_tank)
				ts?.forceMove(get_turf(src))
				build_state = LBS_APU_SCREW
				update_icon()
				return TRUE
		if(LBS_AVIONICS)
			to_chat(user, "<span class='notice'>You start removing the avionics from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the avionics from [src].</span>")
				var/atom/movable/ts = get_part(/obj/item/fighter_component/avionics)
				ts?.forceMove(get_turf(src))
				build_state = LBS_FUEL_TANK_BOLT
				update_icon()
				return TRUE
		if(LBS_TARGETING_SENSOR)
			to_chat(user, "<span class='notice'>You start removing the targeting sensor from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the targeting sensor from [src].</span>")
				var/atom/movable/ts = get_part(/obj/item/fighter_component/targeting_sensor)
				ts?.forceMove(get_turf(src))
				build_state = LBS_AVIONICS_SCREW
				update_icon()
				return TRUE
		if(LBS_COUNTERMEASURE_DISPENSER)
			to_chat(user, "<span class='notice'>You start removing the countermeasure dispenser from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the countermeasure dispenser from [src].</span>")
				var/atom/movable/ts = get_part(/obj/item/fighter_component/countermeasure_dispenser)
				ts?.forceMove(get_turf(src))
				build_state = LBS_TARGETING_SENSOR_SCREW
				update_icon()
				return TRUE
		if(LBS_ARMOUR_PLATING)
			to_chat(user, "<span class='notice'>You start removing the armour plating from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the armour plating from [src].</span>")
				var/atom/movable/ts = get_part(/obj/item/fighter_component/armour_plating)
				ts?.forceMove(get_turf(src))
				build_state = LBS_COUNTERMEASURE_DISPENSER_BOLT
				update_icon()
				return TRUE
		if(LBS_PRIMARY)
			to_chat(user, "<span class='notice'>You start removing the primary armament from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the primary armament from [src].</span>")
				var/atom/movable/ts = get_part(/obj/item/fighter_component/primary/light)
				ts?.forceMove(get_turf(src))
				build_state = LBS_ARMOUR_PLATING_WELD
				update_icon()
				return TRUE
		if(LBS_SECONDARY)
			to_chat(user, "<span class='notice'>You start removing the secondary armament from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the secondary armament from [src].</span>")
				var/atom/movable/ts = get_part(/obj/item/fighter_component/secondary/light)
				ts?.forceMove(get_turf(src))
				build_state = LBS_PRIMARY_BOLT
				update_icon()
				return TRUE
		if(LBS_CHASSIS)
			to_chat(user, "<span class='notice'>You start disassembling the [src]'s chassis... </span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You disassemble the [src]'s fuselage</span>")
				new/obj/structure/fighter_component/light_chassis_crate (loc, 1)
				qdel(src)
				return TRUE

/obj/structure/fighter_component/underconstruction_fighter/light_fighter_frame/attack_hand(mob/user)
	.=..()
	if(build_state == LBS_PAINT_DETAILING)
		fighter_name = input(user, "Name Light Fighter:","Finalize Light Fighter Construction","")
		if(!fighter_name)
			fighter_name = "Su-818 Rapier Light Fighter"
		new_fighter(fighter_name)
		qdel(src)

/obj/structure/fighter_component/underconstruction_fighter/light_fighter_frame/proc/new_fighter(fighter_name)
	var/obj/structure/overmap/fighter/light/LF = new/obj/structure/overmap/fighter/light (loc, 1)
	LF.name = fighter_name
	for(var/atom/movable/C in contents)
		C.forceMove(LF)
	LF.update_stats()
	LF.obj_integrity = LF.max_integrity

#undef LBS_CHASSIS
#undef LBS_CHASSIS_BOLT
#undef LBS_CHASSIS_WELD
#undef LBS_ENGINE
#undef LBS_ENGINE_BOLT
#undef LBS_APU
#undef LBS_APU_WIRE
#undef LBS_APU_SCREW
#undef LBS_FUEL_TANK
#undef LBS_FUEL_TANK_BOLT
#undef LBS_AVIONICS
#undef LBS_AVIONICS_WIRE
#undef LBS_AVIONICS_SCREW
#undef LBS_TARGETING_SENSOR
#undef LBS_TARGETING_SENSOR_SCREW
#undef LBS_COUNTERMEASURE_DISPENSER
#undef LBS_COUNTERMEASURE_DISPENSER_BOLT
#undef LBS_ARMOUR_PLATING
#undef LBS_ARMOUR_PLATING_BOLT
#undef LBS_ARMOUR_PLATING_WELD
#undef LBS_PRIMARY
#undef LBS_PRIMARY_BOLT
#undef LBS_SECONDARY
#undef LBS_SECONDARY_BOLT
#undef LBS_PAINT_PRIMER
#undef LBS_PAINT_DETAILING
