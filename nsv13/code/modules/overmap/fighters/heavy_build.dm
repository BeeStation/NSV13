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
#define HBS_COUNTERMEASURE_DISPENSER		15
#define HBS_COUNTERMEASURE_DISPENSER_BOLT	16
#define HBS_PRIMARY							17
#define HBS_PRIMARY_BOLT					18
#define HBS_SECONDARY						19
#define HBS_SECONDARY_BOLT					20
#define HBS_ARMOUR_PLATING					21
#define HBS_ARMOUR_PLATING_BOLT				22
#define HBS_ARMOUR_PLATING_WELD				23
#define HBS_PAINT_PRIMER					24
#define HBS_PAINT_DETAILING					25

/obj/structure/fighter_component/underconstruction_fighter/heavy_fighter_frame
	name = "Heavy Fighter Frame"
	desc = "An Incomplete Su-410 Scimitar Heavy Attacker"
	icon = 'nsv13/icons/overmap/nanotrasen/heavyfighter_construction.dmi'
	icon_state = "heavy_fighter"
	build_state = HBS_CHASSIS
	fighter_name = null
	pixel_x = -32
	pixel_y = -12

/obj/structure/fighter_component/underconstruction_fighter/heavy_fighter_frame/examine(mob/user)
	. = ..()
	switch(build_state)
		if(HBS_CHASSIS)
			. += "<span class='notice'>Secure the chassis with bolts.</span>"
		if(HBS_CHASSIS_BOLT)
			. += "<span class='notice'>Reinforce the chassis joints with a welder.</span>"
		if(HBS_CHASSIS_WELD)
			. += "<span class='notice'>Install the fuel tank into slot H.</span>"
		if(HBS_FUEL_TANK)
			. += "<span class='notice'>Secure the fuel tank to the chassis with bolts.</span>"
		if(HBS_FUEL_TANK_BOLT)
			. += "<span class='notice'>Install the engine into slot O+.</span>"
		if(HBS_ENGINE)
			. += "<span class='notice'>Secure the engine to the chassis with bolts,</span>"
		if(HBS_ENGINE_BOLT)
			. += "<span class='notice'>Install the auxiliary power unit into slot R.</span>"
		if(HBS_APU)
			. += "<span class='notice'>Follow the wiring diagram to connect the auxiliary power unit to the engine.</span>"
		if(HBS_APU_WIRE)
			. += "<span class='notice'>Secure the auxiliary power unit connections with screws.</span>"
		if(HBS_APU_SCREW)
			. += "<span class='notice'>Install the avionics into slot R+.</span>"
		if(HBS_AVIONICS)
			. += "<span class='notice'>Follow the wiring diagram to connect the avionics to the flight controls and thrusters.</span>"
		if(HBS_AVIONICS_WIRE)
			. += "<span class='notice'>Calibrate the avionics systems with a multitool.</span>"
		if(HBS_AVIONICS_MULTI)
			. += "<span class='notice'>Install the targeting sensor into slot O-.</span>"
		if(HBS_TARGETING_SENSOR)
			. += "<span class='notice'>Secure the targeting sensor to the chassis with screws.</span>"
		if(HBS_TARGETING_SENSOR_SCREW)
			. += "<span class='notice'>Install the countermeasure dispenser into slot R-.</span>"
		if(HBS_COUNTERMEASURE_DISPENSER)
			. += "<span class='notice'>Secure the countermeasure dispenser to the chassis with bolts.</span>"
		if(HBS_COUNTERMEASURE_DISPENSER_BOLT)
			. += "<span class='notice'>Install the primary weapon module into the forward weapon mount.</span>"
		if(HBS_PRIMARY)
			. += "<span class='notice'>Secure the primary weapon module to the forward weapon mount with bolts.</span>"
		if(HBS_PRIMARY_BOLT)
			. += "<span class='notice'>Install the secondary weapon module into the belly weapon mount.</span>"
		if(HBS_SECONDARY)
			. += "<span class='notice'>Secure the secondary weapon module to the belly weapon mount with bolts.</span>"
		if(HBS_SECONDARY_BOLT)
			. += "<span class='notice'>Install the armour plating in all indicated places on the diagram.</span>"
		if(HBS_ARMOUR_PLATING)
			. += "<span class='notice'>Secure the armour plating to chassis with bolts.</span>"
		if(HBS_ARMOUR_PLATING_BOLT)
			. += "<span class='notice'>Reinforce the armour plating bonds with the chassis with a welder.</span>"
		if(HBS_ARMOUR_PLATING_WELD)
			. += "<span class='notice'>Paint the surface of the [src] with primer.</span>"
		if(HBS_PAINT_PRIMER)
			. += "<span class='notice'>Paint the surface of [src] and apply approved detailing as the diagrams.</span>"
		if(HBS_PAINT_DETAILING)
			. += "<span class='notice'>Choose a name for the new Su-410 Scimitar Heavy Fighter.</span>"

/obj/structure/fighter_component/heavy_chassis_crate/attack_hand(mob/user)
	.=..()
	if(alert(user, "Begin constructing an Su-410 Scimitar Heavy Fighter?",, "Yes", "No")!="Yes")
		return
	to_chat(user, "<span class='notice'>You begin constructing the chassis of a new fighter.</span>")
	if(!do_after(user, 10 SECONDS, target=src))
		return
	to_chat(user, "<span class='notice'>You construct the chassis of a new fighter.</span>")
	new/obj/structure/fighter_component/underconstruction_fighter/heavy_fighter_frame (loc, 1)
	qdel(src)

/obj/structure/fighter_component/underconstruction_fighter/heavy_fighter_frame/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(building)
		to_chat(user, "<span class='notice'>You're already installing something into [src]!.</span>")
		return
	if(istype(W, /obj/item/fighter_component/fuel_tank))
		if(build_state == HBS_CHASSIS_WELD)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>You add [W] to [src].</span>")
			build_state = HBS_FUEL_TANK
			update_icon()
			W.forceMove(src)
			building = FALSE
	else if(istype(W, /obj/item/fighter_component/avionics) || !Adjacent(user))
		if(build_state == HBS_APU_SCREW)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>You add [W] to [src].</span>")
			build_state = HBS_AVIONICS
			update_icon()
			W.forceMove(src)
			building = FALSE
	else if(istype(W, /obj/item/fighter_component/apu))
		if(build_state == HBS_ENGINE_BOLT)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>You add [W] to [src].</span>")
			build_state = HBS_APU
			update_icon()
			W.forceMove(src)
			building = FALSE
	else if(istype(W, /obj/item/fighter_component/armour_plating/heavy))
		if(build_state == HBS_SECONDARY_BOLT)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>You add [W] to [src].</span>")
			build_state = HBS_ARMOUR_PLATING
			update_icon()
			W.forceMove(src)
			building = FALSE
	else if(istype(W, /obj/item/fighter_component/targeting_sensor/heavy))
		if(build_state == HBS_AVIONICS_MULTI)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>You add [W] to [src].</span>")
			build_state = HBS_TARGETING_SENSOR
			update_icon()
			W.forceMove(src)
			building = FALSE
	else if(istype(W, /obj/item/fighter_component/engine/heavy))
		if(build_state == HBS_FUEL_TANK_BOLT)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>You add [W] to [src].</span>")
			build_state = HBS_ENGINE
			update_icon()
			W.forceMove(src)
			building = FALSE
	else if(istype(W, /obj/item/fighter_component/countermeasure_dispenser))
		if(build_state == HBS_TARGETING_SENSOR_SCREW)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>You add [W] to [src].</span>")
			build_state = HBS_COUNTERMEASURE_DISPENSER
			update_icon()
			W.forceMove(src)
			building = FALSE
	else if(istype(W, /obj/item/fighter_component/secondary/heavy))
		if(build_state == HBS_PRIMARY_BOLT)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>You add [W] to [src].</span>")
			build_state = HBS_SECONDARY
			update_icon()
			W.forceMove(src)
			building = FALSE
	else if(istype(W, /obj/item/fighter_component/primary/heavy))
		if(build_state == HBS_COUNTERMEASURE_DISPENSER_BOLT)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>You add [W] to [src].</span>")
			build_state = HBS_PRIMARY
			update_icon()
			W.forceMove(src)
			building = FALSE
	else if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if(build_state == HBS_AVIONICS)
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
			build_state = HBS_AVIONICS_WIRE
			update_icon()
			building = FALSE
		if(build_state == HBS_APU)
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
			build_state = HBS_APU_WIRE
			update_icon()
			building = FALSE
	else if(istype(W, /obj/item/airlock_painter)) //replace with an aircraft painter
		if(build_state == HBS_ARMOUR_PLATING_WELD) //check mode later
			to_chat(user, "<span class='notice'>You start painting primer on [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>You prime [src].</span>")
			playsound(src, 'sound/effects/spray.ogg', 100, 1)
			build_state = HBS_PAINT_PRIMER
			update_icon()
			building = FALSE
		else if(build_state == HBS_PAINT_PRIMER) //check mode later
			to_chat(user, "<span class='notice'>You start painting details on [src]...</span>")
			building = TRUE
			if(!do_after(user, 5 SECONDS, target=src) || !Adjacent(user))
				building = FALSE
				return
			to_chat(user, "<spawn class='notice'>You finish painting [src].</span>")
			playsound(src, 'sound/effects/spray.ogg', 100, 1)
			build_state = HBS_PAINT_DETAILING
			update_icon()
			building = FALSE

/obj/structure/fighter_component/underconstruction_fighter/heavy_fighter_frame/wrench_act(mob/user, obj/item/tool)
	. = FALSE
	switch(build_state)
		if(HBS_CHASSIS)
			to_chat(user, "<span class='notice'>You start to bolt the chassis together...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You bolt the chassis together.</span>")
				build_state = HBS_CHASSIS_BOLT
				update_icon()
				return TRUE
		if(HBS_CHASSIS_BOLT)
			to_chat(user, "<span class='notice'>You start to unbolt the chassis.</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unbolt the chassis.</span>")
				build_state = HBS_CHASSIS
				update_icon()
				return TRUE
		if(HBS_ENGINE)
			to_chat(user, "<span class='notice'>You start to bolt the engine to the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You bolt the engine to the chassis.</span>")
				build_state = HBS_ENGINE_BOLT
				update_icon()
				return TRUE
		if(HBS_ENGINE_BOLT)
			to_chat(user, "<span class='notice'>You start to unbolt the engine from the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unbolt the engine from the chassis.</span>")
				build_state = HBS_ENGINE
				update_icon()
				return TRUE
		if(HBS_FUEL_TANK)
			to_chat(user, "<span class='notice'>You start to bolt the fuel tank to the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You bolt the fuel tank to the chassis.</span>")
				build_state = HBS_FUEL_TANK_BOLT
				update_icon()
				return TRUE
		if(HBS_FUEL_TANK_BOLT)
			to_chat(user, "<span class='notice'>You start to unbolt the fuel tank from the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unbolt the fuel tank from the chassis.</span>")
				build_state = HBS_FUEL_TANK
				update_icon()
				return TRUE
		if(HBS_COUNTERMEASURE_DISPENSER)
			to_chat(user, "<span class='notice'>You start to bolt the countermeasure dispenser to the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You bolt the countermeasure dispenser to the chassis.</span>")
				build_state = HBS_COUNTERMEASURE_DISPENSER_BOLT
				update_icon()
				return TRUE
		if(HBS_COUNTERMEASURE_DISPENSER_BOLT)
			to_chat(user, "<span class='notice'>You start to unbolt the countermeasure dispenser from the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unbolt the countermeasure dispenser from the chassis.</span>")
				build_state = HBS_COUNTERMEASURE_DISPENSER
				update_icon()
				return TRUE
		if(HBS_ARMOUR_PLATING)
			to_chat(user, "<span class='notice'>You start to bolt the armour plating to the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You bolt the armour plating to the chassis.</span>")
				build_state = HBS_ARMOUR_PLATING_BOLT
				update_icon()
				return TRUE
		if(HBS_ARMOUR_PLATING_BOLT)
			to_chat(user, "<span class='notice'>You start to unbolt the armour plating to the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unbolt the armour plating from the chassis.</span>")
				build_state = HBS_ARMOUR_PLATING_BOLT
				update_icon()
				return TRUE
		if(HBS_PRIMARY)
			to_chat(user, "<span class='notice'>You start to bolt the heavy cannon to the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You bolt the heavy cannon to the chassis.</span>")
				build_state = HBS_PRIMARY_BOLT
				update_icon()
				return TRUE
		if(HBS_PRIMARY_BOLT)
			to_chat(user, "<span class='notice'>You start to unbolt the heavy cannon from the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unbolt the heavy cannon from the chassis.</span>")
				build_state = HBS_PRIMARY
				update_icon()
				return TRUE
		if(HBS_SECONDARY)
			to_chat(user, "<span class='notice'>You start to bolt the torpedo rack to the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You bolt the torpedo rack to the chassis.</span>")
				build_state = HBS_SECONDARY_BOLT
				update_icon()
				return TRUE
		if(HBS_SECONDARY_BOLT)
			to_chat(user, "<span class='notice'>You start to unbolt the torpedo rack from the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unbolt the torpedo rack from the chassis.</span>")
				build_state = HBS_SECONDARY
				update_icon()
				return TRUE

/obj/structure/fighter_component/underconstruction_fighter/heavy_fighter_frame/screwdriver_act(mob/user, obj/item/tool)
	. = FALSE
	switch(build_state)
		if(HBS_APU_WIRE)
			to_chat(user, "<span class='notice'>You start to screw the APU to the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You screw the APU to the chassis.</span>")
				build_state = HBS_APU_SCREW
				update_icon()
				return TRUE
		if(HBS_APU_SCREW)
			to_chat(user, "<span class='notice'>You start to unscrew the APU from the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unscrew the APU from the chassis.</span>")
				build_state = HBS_APU_WIRE
				update_icon()
				return TRUE
		if(HBS_TARGETING_SENSOR)
			to_chat(user, "<span class='notice'>You start to screw the targeting sensor to the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You screw the APU to the chassis.</span>")
				build_state = HBS_TARGETING_SENSOR_SCREW
				update_icon()
				return TRUE
		if(HBS_TARGETING_SENSOR_SCREW)
			to_chat(user, "<span class='notice'>You start to unscrew the targeting sensor to the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unscrew the targeting sensor to the chassis.</span>")
				build_state = HBS_TARGETING_SENSOR
				update_icon()
				return TRUE

/obj/structure/fighter_component/underconstruction_fighter/heavy_fighter_frame/welder_act(mob/user, obj/item/tool)
	. = FALSE
	switch(build_state)
		if(HBS_CHASSIS_BOLT)
			to_chat(user, "<span class='notice'>You start to weld the chassis together...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You weld the chassis together.</span>")
				build_state = HBS_CHASSIS_WELD
				update_icon()
				return TRUE
		if(HBS_CHASSIS_WELD)
			to_chat(user, "<span class='notice'>You start to cut the chassis apart.</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You cut the chassis apart.</span>")
				build_state = HBS_CHASSIS_BOLT
				update_icon()
				return TRUE
		if(HBS_ARMOUR_PLATING_BOLT)
			to_chat(user, "<span class='notice'>You start to weld the armour plating to the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You weld the armour plating to the chassis.</span>")
				build_state = HBS_ARMOUR_PLATING_WELD
				update_icon()
				return TRUE
		if(HBS_ARMOUR_PLATING_WELD)
			to_chat(user, "<span class='notice'>You start to cut the armour plating from the chassis...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You cut the armour plating from the chassis.</span>")
				build_state = HBS_ARMOUR_PLATING_BOLT
				update_icon()
				return TRUE

/obj/structure/fighter_component/underconstruction_fighter/heavy_fighter_frame/wirecutter_act(mob/user, obj/item/tool)
	. = FALSE
	switch(build_state)
		if(HBS_APU_WIRE)
			to_chat(user, "<span class='notice'>You start cutting the wiring in [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You cut the wiring in [src].</span>")
				var/obj/item/stack/cable_coil/C = new (loc, 5)
				C.add_fingerprint(user)
				build_state = HBS_APU
				update_icon()
				return TRUE
		if(HBS_AVIONICS_WIRE)
			to_chat(user, "<span class='notice'>You start cutting the wiring in [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You cut the wiring in [src].</span>")
				var/obj/item/stack/cable_coil/C = new (loc, 5)
				C.add_fingerprint(user)
				build_state = HBS_AVIONICS
				update_icon()
				return TRUE

/obj/structure/fighter_component/underconstruction_fighter/heavy_fighter_frame/crowbar_act(mob/user, obj/item/tool)
	. = FALSE
	switch(build_state)
		if(HBS_ENGINE)
			to_chat(user, "<span class='notice'>You start removing the engine from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the engine from [src].</span>")
				var/atom/movable/ts = get_part(/obj/item/fighter_component/engine)
				ts?.forceMove(get_turf(src))
				build_state = HBS_FUEL_TANK_BOLT
				update_icon()
				return TRUE
		if(HBS_APU)
			to_chat(user, "<span class='notice'>You start removing the APU from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the APU from [src].</span>")
				var/atom/movable/ts = get_part(/obj/item/fighter_component/apu)
				ts?.forceMove(get_turf(src))
				build_state = HBS_ENGINE_BOLT
				update_icon()
				return TRUE
		if(HBS_FUEL_TANK)
			to_chat(user, "<span class='notice'>You start removing the fuel tank from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the fuel tank from [src].</span>")
				var/atom/movable/ts = get_part(/obj/item/fighter_component/fuel_tank)
				ts?.forceMove(get_turf(src))
				build_state = HBS_CHASSIS_WELD
				update_icon()
				return TRUE
		if(HBS_AVIONICS)
			to_chat(user, "<span class='notice'>You start removing the avionics from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the avionics from [src].</span>")
				var/atom/movable/ts = get_part(/obj/item/fighter_component/avionics)
				ts?.forceMove(get_turf(src))
				build_state = HBS_APU_SCREW
				update_icon()
				return TRUE
		if(HBS_TARGETING_SENSOR)
			to_chat(user, "<span class='notice'>You start removing the targeting sensor from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the targeting sensor from [src].</span>")
				var/atom/movable/ts = get_part(/obj/item/fighter_component/targeting_sensor)
				ts?.forceMove(get_turf(src))
				build_state = HBS_AVIONICS_MULTI
				update_icon()
				return TRUE
		if(HBS_COUNTERMEASURE_DISPENSER)
			to_chat(user, "<span class='notice'>You start removing the countermeasure dispenser from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the countermeasure dispenser from [src].</span>")
				var/atom/movable/ts = get_part(/obj/item/fighter_component/countermeasure_dispenser)
				ts?.forceMove(get_turf(src))
				build_state = HBS_TARGETING_SENSOR_SCREW
				update_icon()
				return TRUE
		if(HBS_ARMOUR_PLATING)
			to_chat(user, "<span class='notice'>You start removing the armour plating from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the armour plating from [src].</span>")
				var/atom/movable/ts = get_part(/obj/item/fighter_component/armour_plating)
				ts?.forceMove(get_turf(src))
				build_state = HBS_SECONDARY_BOLT
				update_icon()
				return TRUE
		if(HBS_PRIMARY)
			to_chat(user, "<span class='notice'>You start removing the primary armament from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the primary armament from [src].</span>")
				var/atom/movable/ts = get_part(/obj/item/fighter_component/primary/heavy)
				ts?.forceMove(get_turf(src))
				build_state = HBS_COUNTERMEASURE_DISPENSER_BOLT
				update_icon()
				return TRUE
		if(HBS_SECONDARY)
			to_chat(user, "<span class='notice'>You start removing the secondary armament from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the secondary armament from [src].</span>")
				var/atom/movable/ts = get_part(/obj/item/fighter_component/secondary/heavy)
				ts?.forceMove(get_turf(src))
				build_state = HBS_PRIMARY_BOLT
				update_icon()
				return TRUE
		if(HBS_CHASSIS)
			to_chat(user, "<span class='notice'>You start disassembling the [src]'s chassis... </span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You disassemble the [src]'s fuselage</span>")
				new/obj/structure/fighter_component/heavy_chassis_crate (loc, 1)
				qdel(src)
				return TRUE

/obj/structure/fighter_component/underconstruction_fighter/heavy_fighter_frame/multitool_act(mob/user, obj/item/tool)
	. = FALSE
	switch(build_state)
		if(HBS_AVIONICS_WIRE)
			to_chat(user, "<span class='notice'>You start calibrating the avionics in [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You calibrate the avionics in [src].</span>")
				build_state = HBS_AVIONICS_MULTI
				update_icon()
				return TRUE
		if(HBS_AVIONICS_MULTI)
			to_chat(user, "<span class='notice'>You start resetting the avionics in [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You reset the avionics in [src].</span>")
				build_state = HBS_AVIONICS_WIRE
				update_icon()
				return TRUE

/obj/structure/fighter_component/underconstruction_fighter/heavy_fighter_frame/attack_hand(mob/user)
	.=..()
	if(build_state == HBS_PAINT_DETAILING)
		fighter_name = input(user, "Name Heavy Fighter:","Finalize Heavy Fighter Construction","")
		if(!fighter_name)
			fighter_name = "Su-410 Scimitar Heavy Attacker"
		new_fighter(fighter_name)
		qdel(src)

/obj/structure/fighter_component/underconstruction_fighter/heavy_fighter_frame/proc/new_fighter(fighter_name)
	var/obj/structure/overmap/fighter/heavy/HF = new/obj/structure/overmap/fighter/heavy (loc, 1)
	HF.name = fighter_name
	for(var/atom/movable/C in contents)
		C.forceMove(HF)
	HF.update_stats()
	HF.obj_integrity = HF.max_integrity

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
#undef HBS_COUNTERMEASURE_DISPENSER
#undef HBS_COUNTERMEASURE_DISPENSER_BOLT
#undef HBS_PRIMARY
#undef HBS_PRIMARY_BOLT
#undef HBS_SECONDARY
#undef HBS_SECONDARY_BOLT
#undef HBS_ARMOUR_PLATING
#undef HBS_ARMOUR_PLATING_BOLT
#undef HBS_ARMOUR_PLATING_WELD
#undef HBS_PAINT_PRIMER
#undef HBS_PAINT_DETAILING
