//Fluff components that are only used in building.
/obj/item/fighter_component/avionics
	name = "Fighter Avionics"
	desc = "Avionics for a fighter"
	icon = 'nsv13/icons/obj/fighter_components.dmi'
	icon_state = "avionics"
	tier = null //Cannot be upgraded.

/obj/item/fighter_component/apu
	name = "Fighter Auxiliary Power Unit"
	desc = "An Auxiliary Power Unit for a fighter"
	icon = 'nsv13/icons/obj/fighter_components.dmi'
	icon_state = "apu"

/obj/item/fighter_component/targeting_sensor
	name = "Fighter Targeting Sensors"
	icon = 'icons/obj/crates.dmi'
	icon_state = "weaponcrate"
	tier = null //Cannot be upgraded.

//Woe betide all ye who venture here.

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

/obj/structure/fighter_frame
	name = "Light Fighter Frame"
	desc = "An Incomplete Su-818 Rapier Light Fighter. Just add elbow grease and a bunch of parts!"
	icon = 'nsv13/icons/overmap/nanotrasen/fighter_construction.dmi'
	icon_state = "fighter"
	pixel_x = -12
	pixel_y = -12
	density = TRUE
	anchored = FALSE
	var/build_state = LBS_CHASSIS
	var/building = FALSE
	var/output_path = /obj/structure/overmap/fighter

/obj/structure/fighter_frame/heavy
	name = "Heavy Fighter Frame"
	desc = "An Incomplete Su-410 Scimitar Heavy Fighter"
	icon = 'nsv13/icons/overmap/nanotrasen/heavyfighter_construction.dmi'
	icon_state = "heavy_fighter"
	pixel_x = -32
	pixel_y = -12
	output_path = /obj/structure/overmap/fighter/heavy

/obj/structure/fighter_frame/utility
	name = "Utility Vessel Frame"
	desc = "An Incomplete Su-437 Sabre Utility Vessel"
	icon = 'nsv13/icons/overmap/nanotrasen/raptorconstruction.dmi'
	icon_state = "carrier"
	pixel_x = -32
	pixel_y = -12
	output_path = /obj/structure/overmap/fighter/utility

/obj/structure/fighter_frame/update_icon()
	icon_state = "[initial(icon_state)][build_state]"

/obj/structure/fighter_frame/examine(mob/user)
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
			. += "<span class='notice'>Install the primary weapon module into the forward hardpoint mount.</span>"
		if(LBS_PRIMARY)
			. += "<span class='notice'>Secure the primary weapon module to the forward hardpoint mount with bolts.</span>"
		if(LBS_PRIMARY_BOLT)
			. += "<span class='notice'>Install the secondary weapon module into the secondary hardpoint mount.</span>"
		if(LBS_SECONDARY)
			. += "<span class='notice'>Secure the secondary weapon module to the secondary hardpoint mount with bolts.</span>"
		if(LBS_SECONDARY_BOLT)
			. += "<span class='notice'>Paint the surface of the [src] with primer.</span>"
		if(LBS_PAINT_PRIMER)
			. += "<span class='notice'>Paint the surface of [src] and apply approved detailing as per the diagrams.</span>"
		if(LBS_PAINT_DETAILING)
			. += "<span class='notice'>Finalize the fighter by clicking it with an open hand, and add any missing components to the newly prepared fighter.</span>"

/obj/structure/fighter_frame/attackby(obj/item/W, mob/user, params)
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
	else if(istype(W, /obj/item/fighter_component/armour_plating))
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
	else if(istype(W, /obj/item/fighter_component/targeting_sensor))
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
	else if(istype(W, /obj/item/fighter_component/engine))
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
	else if(istype(W, /obj/item/fighter_component/secondary))
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
	else if(istype(W, /obj/item/fighter_component/primary))
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

/obj/structure/fighter_frame/wrench_act(mob/user, obj/item/tool)
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

/obj/structure/fighter_frame/screwdriver_act(mob/user, obj/item/tool)
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

/obj/structure/fighter_frame/welder_act(mob/user, obj/item/tool)
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

/obj/structure/fighter_frame/wirecutter_act(mob/user, obj/item/tool)
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

/obj/structure/fighter_frame/attack_hand(mob/user)
	.=..()
	if(build_state == LBS_PAINT_DETAILING)
		if(alert(user, "Finalize [src]?",name,"Yes","No") == "Yes" && Adjacent(user))
			var/list/components = list()
			for(var/obj/item/fighter_component/FC in contents)
				components += FC.type
				qdel(FC)
			new output_path(get_turf(src), components)
			qdel(src)

/obj/structure/fighter_frame/proc/fuck()
	var/list/components = list(/obj/item/fighter_component/fuel_tank,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating,
						/obj/item/fighter_component/targeting_sensor,
						/obj/item/fighter_component/engine,
						/obj/item/fighter_component/countermeasure_dispenser,
						/obj/item/fighter_component/secondary/ordnance_launcher,
						/obj/item/fighter_component/oxygenator,
						/obj/item/fighter_component/canopy,
						/obj/item/fighter_component/docking_computer,
						/obj/item/fighter_component/battery,
						/obj/item/fighter_component/primary/cannon)
	new output_path(get_turf(src), components)
	qdel(src)

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

//God fucking help you if you have to read this. This was such a mess to fix. I never want to see it again ~K

/datum/techweb_node/fighter_fabrication
	id = "fighter_fabrication"
	display_name = "Fighter Construction"
	description = "Research into aircraft frames and how they can be turned into aircraft."
	design_ids = list("light_frame", "heavy_frame", "utility_frame")
	prereq_ids = list("base")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
	export_price = 1000

/datum/design/light_frame
	name = "Light Fighter Chassis"
	desc = "A light fighter's airframe, devoid of parts. It'll require additional work to get it flying."
	id = "light_frame"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/titanium = 10000, /datum/material/copper = 7500)
	build_path = /obj/structure/fighter_frame
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/heavy_frame
	name = "Heavy Fighter Chassis"
	desc = "A heavy fighter's airframe, devoid of parts. These fighters are extremely suited to having heavier components mounted on them."
	id = "heavy_frame"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 35000, /datum/material/titanium = 20000, /datum/material/copper = 7500)
	build_path = /obj/structure/fighter_frame/heavy
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/utility_frame
	name = "Utility Fighter Chassis"
	desc = "A utility fighter's airframe, devoid of parts. These fighters excel at forming supply lines and are able to resupply and repair other ships!."
	id = "utility_frame"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/titanium = 10000, /datum/material/copper = 5000)
	build_path = /obj/structure/fighter_frame/utility
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/techweb_node/fighter_tier1
	id = "fighter_tier1"
	display_name = "Standard Fighter Parts"
	description = "Research into the components that make up an aircraft and what makes them tick. Required for the construction of basic fighters."
	design_ids = list("fuel_tank", "avionics", "apu", "armour_plating", "targeting_sensor", "fighter_engine", "countermeasure_dispenser", "ordnance_launcher","fighter_missile_launcher", "oxygenator","docking_computer", "fighter_battery", "primary_cannon", "refuel_kit", "cargo_hold", "resupply")
	prereq_ids = list("fighter_fabrication")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	export_price = 2000

/datum/design/fuel_tank
	name = "Fighter Fuel Tank"
	desc = "A tank of fuel which can keep fighters in the air."
	id = "fuel_tank"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000)
	build_path = /obj/item/fighter_component/fuel_tank
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/avionics
	name = "Fighter Avionics"
	desc = "A component used in fighter construction."
	id = "avionics"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/copper = 5000)
	build_path = /obj/item/fighter_component/avionics
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/apu
	name = "Fighter APU"
	desc = "A component used in fighter construction."
	id = "apu"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/copper = 5000)
	build_path = /obj/item/fighter_component/apu
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/armour_plating
	name = "Fighter Armour"
	desc = "A component used in fighter construction."
	id = "armour_plating"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000)
	build_path = /obj/item/fighter_component/armour_plating
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/targeting_sensor
	name = "Fighter Targeting Sensor"
	desc = "A component used in fighter construction."
	id = "targeting_sensor"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/copper = 10000)
	build_path = /obj/item/fighter_component/targeting_sensor
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_engine
	name = "Fighter Engine"
	desc = "A component used in fighter construction."
	id = "fighter_engine"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/copper = 2000)
	build_path = /obj/item/fighter_component/engine
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/countermeasure_dispenser
	name = "Fighter Countermeasure Dispenser"
	desc = "A component used in fighter construction."
	id = "countermeasure_dispenser"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/copper = 2000)
	build_path = /obj/item/fighter_component/countermeasure_dispenser
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/ordnance_launcher
	name = "Fighter Torpedo Rack"
	desc = "A component used in fighter construction."
	id = "ordnance_launcher"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/copper = 2000)
	build_path = /obj/item/fighter_component/secondary/ordnance_launcher/torpedo
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_missile_launcher
	name = "Fighter Missile Rack"
	desc = "A component used in fighter construction."
	id = "fighter_missile_launcher"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/copper = 2000)
	build_path = /obj/item/fighter_component/secondary/ordnance_launcher
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO


/datum/design/oxygenator
	name = "Fighter Atmospheric Regulator"
	desc = "An atmospheric regulation system for fighters which removes the need for a space suit at the cost of some power usage."
	id = "oxygenator"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/copper = 5000)
	build_path = /obj/item/fighter_component/oxygenator
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/docking_computer
	name = "Fighter Docking Computer"
	desc = "An all in one docking solution for fighters. Absolutely essential for shipside ops."
	id = "docking_computer"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/copper = 5000)
	build_path = /obj/item/fighter_component/docking_computer
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_battery
	name = "Fighter Battery"
	desc = "A specialist lead-acid battery which is required to power fighter modules like APUs, oxygenators, and more!."
	id = "fighter_battery"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 7000, /datum/material/copper = 5000, /datum/material/glass = 2000)
	build_path = /obj/item/fighter_component/battery
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/primary_cannon
	name = "Fighter Primary Cannon (Light)"
	desc = "A standard light cannon usable by most fighters, light, cheap, effective. Light cannon."
	id = "primary_cannon"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/copper = 7000, /datum/material/glass = 6000)
	build_path = /obj/item/fighter_component/primary/cannon
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/heavy_cannon
	name = "Fighter Primary Cannon (Heavy)"
	desc = "A standard fighter heavy cannon, capable of using higher caliber rounds. It weighs rather a lot more than its light counterpart but is extremely destructive."
	id = "heavy_cannon"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/copper = 7000, /datum/material/glass = 6000)
	build_path = /obj/item/fighter_component/primary/cannon/heavy
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/refuel_kit
	name = "Air to air refuel kit"
	desc = "A kit that allows utility fighters to transfer fuel, power and ammunition to another fighter."
	id = "refuel_kit"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 5000, /datum/material/copper = 5000, /datum/material/glass = 5000)
	build_path = /obj/item/fighter_component/secondary/utility/resupply
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/cargo_hold
	name = "Fighter Cargo Hold"
	desc = "A cargo hold for utility craft."
	id = "cargo_hold"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 5000)
	build_path = /obj/item/fighter_component/primary/utility/hold
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/resupply
	name = "Air to Air repair kit"
	desc = "A module that allows utility craft to remotely repair fighter craft, when loaded with hull repair juice."
	id = "resupply"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 5000)
	build_path = /obj/item/fighter_component/primary/utility/repairer
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

//Alright. Onto tier 2s.
/datum/techweb_node/fighter_tier2
	id = "fighter_tier2"
	display_name = "Advanced Fighter Parts"
	description = "Production of non-standard, upgraded fighter parts to upgrade the ship's fighter complement."
	design_ids = list("fuel_tank_tier2", "apu_tier2", "armour_plating_tier2", "fighter_engine_tier2", "ordnance_launcher_tier2","fighter_missile_launcher_tier2", "oxygenator_tier2", "fighter_battery_tier2", "heavy_cannon", "refuel_kit_tier2", "cargo_hold_tier2", "resupply_tier2")
	prereq_ids = list("fighter_tier1")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 2000

/datum/design/fuel_tank_tier2
	name = "Upgraded Fighter Fuel Tank"
	desc = "A huge tank of fuel which can keep fighters in the air."
	id = "fuel_tank_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000)
	build_path = /obj/item/fighter_component/fuel_tank/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/apu_tier2
	name = "Upgraded Fighter APU"
	desc = "A component used in fighter construction."
	id = "apu_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/copper = 15000)
	build_path = /obj/item/fighter_component/apu/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/armour_plating_tier2
	name = "Upgraded Fighter Armour"
	desc = "A component used in fighter construction."
	id = "armour_plating_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/titanium = 20000)
	build_path = /obj/item/fighter_component/armour_plating/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_engine_tier2
	name = "Upgraded Fighter Engine"
	desc = "A component used in fighter construction."
	id = "fighter_engine_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/diamond = 5000, /datum/material/titanium = 20000)
	build_path = /obj/item/fighter_component/engine/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/ordnance_launcher_tier2
	name = "Upgraded Fighter Torpedo Rack"
	desc = "A component used in fighter construction."
	id = "ordnance_launcher_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000, /datum/material/copper = 20000, /datum/material/titanium = 20000)
	build_path = /obj/item/fighter_component/secondary/ordnance_launcher/torpedo/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_missile_launcher_tier2
	name = "Upgraded Fighter Missile Rack"
	desc = "A component used in fighter construction."
	id = "fighter_missile_launcher_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/copper = 12000, /datum/material/titanium = 10000)
	build_path = /obj/item/fighter_component/secondary/ordnance_launcher/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/oxygenator_tier2
	name = "Upgraded Fighter Atmospheric Regulator"
	desc = "An atmospheric regulation system for fighters which removes the need for a space suit at the cost of some power usage."
	id = "oxygenator_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/copper = 15000)
	build_path = /obj/item/fighter_component/oxygenator/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_battery_tier2
	name = "Upgraded Fighter Battery"
	desc = "A specialist lead-acid battery which is required to power fighter modules like APUs, oxygenators, and more!."
	id = "fighter_battery_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 17000, /datum/material/copper = 15000, /datum/material/glass = 12000)
	build_path = /obj/item/fighter_component/battery/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/refuel_kit_tier2
	name = "Upgraded Air to air refuel kit"
	desc = "A kit that allows utility fighters to transfer fuel, power and ammunition to another fighter."
	id = "refuel_kit_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/copper = 5000, /datum/material/glass = 5000)
	build_path = /obj/item/fighter_component/secondary/utility/resupply/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/cargo_hold_tier2
	name = "Upgraded Fighter Cargo Hold"
	desc = "A cargo hold for utility craft."
	id = "cargo_hold_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000, /datum/material/glass = 15000)
	build_path = /obj/item/fighter_component/primary/utility/hold/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/resupply_tier2
	name = "Upgraded Air to Air repair kit"
	desc = "A module that allows utility craft to remotely repair fighter craft, when loaded with hull repair juice."
	id = "resupply_tier2"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 15000, /datum/material/glass = 15000)
	build_path = /obj/item/fighter_component/primary/utility/repairer/tier2
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

//Top tier parts require top tier mats. Stonks.
/datum/techweb_node/fighter_tier3
	id = "fighter_tier3"
	display_name = "Experimental Fighter Parts"
	description = "Research into highly theoretical fighter parts which, if constructed, could guarantee air superiority."
	design_ids = list("fuel_tank_tier3", "apu_tier3", "armour_plating_tier3", "fighter_engine_tier3", "ordnance_launcher_tier3","fighter_missile_launcher_tier3", "oxygenator_tier3", "fighter_battery_tier3", "refuel_kit_tier3", "cargo_hold_tier3", "resupply_tier3")
	prereq_ids = list("fighter_tier2")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 12500)
	export_price = 5000

/datum/design/fuel_tank_tier3
	name = "Experimental Fighter Fuel Tank"
	desc = "An unreasonably large tank of fuel which can keep fighters in the air."
	id = "fuel_tank_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000, /datum/material/titanium = 25000, /datum/material/glass = 25000)
	build_path = /obj/item/fighter_component/fuel_tank/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/apu_tier3
	name = "Experimental Fighter APU"
	desc = "A component used in fighter construction."
	id = "apu_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/copper = 15000, /datum/material/titanium = 25000)
	build_path = /obj/item/fighter_component/apu/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/armour_plating_tier3
	name = "Experimental Fighter Armour"
	desc = "A component used in fighter construction."
	id = "armour_plating_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/plasma = 20000, /datum/material/diamond = 25000)
	build_path = /obj/item/fighter_component/armour_plating/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_engine_tier3
	name = "Experimental Fighter Engine"
	desc = "A component used in fighter construction."
	id = "fighter_engine_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 35000, /datum/material/uranium = 15000, /datum/material/diamond = 10000, /datum/material/titanium = 20000)
	build_path = /obj/item/fighter_component/engine/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/ordnance_launcher_tier3
	name = "Experimental Fighter Torpedo Rack"
	desc = "A component used in fighter construction."
	id = "ordnance_launcher_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/plasma = 25000, /datum/material/copper = 20000, /datum/material/titanium = 20000)
	build_path = /obj/item/fighter_component/secondary/ordnance_launcher/torpedo/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_missile_launcher_tier3
	name = "Experimental Fighter Missile Rack"
	desc = "A component used in fighter construction."
	id = "fighter_missile_launcher_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/plasma = 15000, /datum/material/copper = 12000, /datum/material/titanium = 10000)
	build_path = /obj/item/fighter_component/secondary/ordnance_launcher/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/oxygenator_tier3
	name = "Experimental Fighter Atmospheric Regulator"
	desc = "An atmospheric regulation system for fighters which removes the need for a space suit at the cost of some power usage."
	id = "oxygenator_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 10000, /datum/material/titanium = 15000)
	build_path = /obj/item/fighter_component/oxygenator/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/fighter_battery_tier3
	name = "Experimental Fighter Battery"
	desc = "A specialist lead-acid battery which is required to power fighter modules like APUs, oxygenators, and more!."
	id = "fighter_battery_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 20000, /datum/material/titanium = 15000, /datum/material/diamond = 5000)
	build_path = /obj/item/fighter_component/battery/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/refuel_kit_tier3
	name = "Experimental Air to air refuel kit"
	desc = "A kit that allows utility fighters to transfer fuel, power and ammunition to another fighter."
	id = "refuel_kit_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000, /datum/material/copper = 7000, /datum/material/glass = 10000)
	build_path = /obj/item/fighter_component/secondary/utility/resupply/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/cargo_hold_tier3
	name = "Experimental Fighter Cargo Hold"
	desc = "A cargo hold for utility craft."
	id = "cargo_hold_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 35000, /datum/material/titanium = 15000)
	build_path = /obj/item/fighter_component/primary/utility/hold/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/resupply_tier3
	name = "Experimental Air to Air repair kit"
	desc = "A module that allows utility craft to remotely repair fighter craft, when loaded with hull repair juice."
	id = "resupply_tier3"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 25000, /datum/material/glass = 15000, /datum/material/titanium = 5000 )
	build_path = /obj/item/fighter_component/primary/utility/repairer/tier3
	category = list("Ship Components")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO
