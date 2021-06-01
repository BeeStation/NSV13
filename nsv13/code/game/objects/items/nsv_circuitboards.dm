////CIC consoles////

/obj/item/circuitboard/computer/ship/helm
	name = "circuit board (helm computer)"
	build_path = /obj/machinery/computer/ship/helm

/obj/item/circuitboard/computer/ship/tactical_computer
	name = "circuit board (tactical computer)"
	build_path = /obj/machinery/computer/ship/tactical

//Dradis
/obj/item/circuitboard/computer/ship/dradis
	name = "circuit board (dradis computer)"
	build_path = /obj/machinery/computer/ship/dradis

/obj/item/circuitboard/computer/ship/dradis/mining
	name = "circuit board (minig dradis computer)"
	build_path = /obj/machinery/computer/ship/dradis/mining

//FTL nav
/obj/item/circuitboard/computer/ship/navigation
	name = "circuit board (FTL Navigation console)"
	build_path = /obj/machinery/computer/ship/navigation

//Secondary ID console
/obj/item/circuitboard/computer/card/secondary_ship_id_console
	name = "circuit board (secondary ID console)"
	build_path = /obj/machinery/computer/secondary_ship_id_console

/obj/item/circuitboard/computer/card/secondary_ship_id_console/syndicate
	name = "circiut board (Syndicate ID console)"
	build_path = /obj/machinery/computer/secondary_ship_id_console/syndicate

////Security////

/obj/item/circuitboard/computer/security/syndicate
	name = "circuit board (Syndicate camera console)"
	build_path = /obj/machinery/computer/security/syndicate

////Science////

/obj/item/circuitboard/computer/astrometrics
	name = "Astrometrics Computer (Computer Board)"
	build_path = /obj/machinery/computer/ship/navigation/astrometrics

////Munitions consoles////

/obj/item/circuitboard/computer/ship/munitions_computer
	name = "circuit board (munitions control computer)"
	build_path = /obj/machinery/computer/ship/munitions_computer

/obj/item/circuitboard/computer/ship/ordnance_computer
	name = "circuit board (ordnance computer)"
	build_path = /obj/machinery/computer/ship/ordnance

/obj/item/circuitboard/computer/ams
	name = "AMS control console (computer)"
	build_path = /obj/machinery/computer/ams

/obj/item/circuitboard/computer/fiftycal
	name = ".50 cal turret console (circuit)"
	build_path = /obj/machinery/computer/fiftycal

/obj/item/circuitboard/computer/ship/fighter_controller
	name = "circuit board (fighter control computer)"
	build_path = /obj/machinery/computer/ship/fighter_controller

//Mag-cat control console
/obj/item/circuitboard/computer/ship/fighter_launcher
	name = "circuit board (Mag-cat control console)"
	build_path = /obj/machinery/computer/ship/fighter_launcher

////SHIP GUNS////

//50 Cal. guns
/obj/item/circuitboard/machine/fiftycal
	name = ".50 cal turret (circuitboard)"
	req_components = list(
		/obj/item/stack/sheet/mineral/titanium = 20,
		/obj/item/stack/sheet/mineral/copper = 10,
		/obj/item/stack/sheet/iron = 30,
		/obj/item/stack/cable_coil = 5)
	build_path = /obj/machinery/ship_weapon/fiftycal

/obj/item/circuitboard/machine/fiftycal/super
	name = "super .50 cal turret (circuitboard)"
	req_components = list(
		/obj/item/stack/sheet/mineral/titanium = 40,
		/obj/item/stack/sheet/mineral/copper = 40,
		/obj/item/stack/sheet/mineral/diamond = 5,
		/obj/item/stack/sheet/iron = 20,
		/obj/item/stack/cable_coil = 5)
	build_path = /obj/machinery/ship_weapon/fiftycal/super

//PDC and flak boards, currently not used
#define PATH_PDC /obj/machinery/ship_weapon/pdc_mount
#define PATH_FLAK  /obj/machinery/ship_weapon/pdc_mount/flak

/obj/item/circuitboard/machine/pdc_mount
	name = "circuit board (pdc mount)"
	desc = "You can use a screwdriver to switch between PDC and flak."
	req_components = list(
		/obj/item/stock_parts/manipulator = 4,
		/obj/item/stock_parts/capacitor = 2,
		/obj/item/stock_parts/matter_bin = 3,
		/obj/item/ship_weapon/parts/firing_electronics = 1
	)

/obj/item/circuitboard/machine/pdc_mount/Initialize()
	. = ..()
	if(!build_path)
		if(prob(50))
			name = "PDC Loading Rack (Machine Board)"
			build_path = PATH_PDC
		else
			name = "Flak Loading Rack (Machine Board)"
			build_path = PATH_FLAK

/obj/item/circuitboard/machine/pdc_mount/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		var/obj/item/circuitboard/new_type
		var/new_setting
		switch(build_path)
			if(PATH_PDC)
				new_type = /obj/item/circuitboard/machine/pdc_mount/flak
				new_setting = "Flak"
			if(PATH_FLAK)
				new_type = /obj/item/circuitboard/machine/pdc_mount/
				new_setting = "PDC"
		name = initial(new_type.name)
		build_path = initial(new_type.build_path)
		I.play_tool_sound(src)
		to_chat(user, "<span class='notice'>You change the circuitboard setting to \"[new_setting]\".</span>")
		return

/obj/item/circuitboard/machine/pdc_mount
	name = "PDC Mount (Machine Board)"
	build_path = PATH_PDC

/obj/item/circuitboard/machine/pdc_mount/flak
	name = "Flak Loading Rack (Machine Board)"
	build_path = PATH_FLAK

#undef PATH_PDC
#undef PATH_FLAK

//Deck Gun
/obj/item/circuitboard/computer/deckgun
	name = "Deck gun loading computer (circuit)"
	build_path = /obj/machinery/computer/deckgun

/obj/item/circuitboard/machine/deck_gun
	name = "Deck gun core (circuitboard)"
	req_components = list(
		/obj/item/stack/sheet/mineral/titanium = 10,
		/obj/item/stack/cable_coil = 5)
	build_path = /obj/machinery/deck_turret

/obj/item/circuitboard/machine/deck_gun/powder
	name = "Deck gun powder gate (circuitboard)"
	req_components = list(
		/obj/item/stack/sheet/iron = 20,
		/obj/item/stack/sheet/mineral/copper = 20,
		/obj/item/stack/cable_coil = 5)
	build_path = /obj/machinery/deck_turret/powder_gate

/obj/item/circuitboard/machine/deck_gun/payload
	name = "Deck gun payload gate (circuitboard)"
	req_components = list(
		/obj/item/stack/sheet/iron = 20,
		/obj/item/stack/sheet/mineral/titanium = 5,
		/obj/item/stack/sheet/mineral/copper = 10,
		/obj/item/ship_weapon/parts/railgun_rail = 1,
		/obj/item/ship_weapon/parts/loading_tray=1,
		/obj/item/stack/cable_coil = 10)
	build_path = /obj/machinery/deck_turret/payload_gate

//Upgrades
/obj/item/circuitboard/machine/deck_gun/autoelevator
	name = "Deck gun auto-elevator (circuitboard)"
	req_components = list(
		/obj/item/stack/sheet/mineral/titanium = 40,
		/obj/item/stack/sheet/mineral/copper = 20,
		/obj/item/stack/sheet/mineral/diamond = 5,
		/obj/item/stack/cable_coil = 10)
	build_path = /obj/machinery/deck_turret/autoelevator

/obj/item/circuitboard/machine/deck_gun/autorepair
	name = "Deck gun auto-repair module (circuitboard)"
	req_components = list(
		/obj/item/stack/sheet/mineral/titanium = 40,
		/obj/item/stack/sheet/mineral/copper = 20,
		/obj/item/stack/sheet/mineral/diamond = 2,
		/obj/item/stack/sheet/mineral/uranium = 10,
		/obj/item/stack/cable_coil = 10)
	build_path = /obj/machinery/deck_turret/autorepair

//Missile factory
/obj/item/circuitboard/machine/missile_builder
	name = "Seegson model 'Ford' robotic autowrench (board)"
	build_path = /obj/machinery/missile_builder

/obj/item/circuitboard/machine/missile_builder/wirer
	name = "Seegson model 'Ford' robotic autowirer (board)"
	build_path = /obj/machinery/missile_builder/wirer

/obj/item/circuitboard/machine/missile_builder/welder
	name = "Seegson model 'Ford' robotic autowelder (board)"
	build_path = /obj/machinery/missile_builder/welder

/obj/item/circuitboard/machine/missile_builder/screwdriver
	name = "Seegson model 'Ford' robotic bolt driver (board)"
	build_path = /obj/machinery/missile_builder/screwdriver

/obj/item/circuitboard/machine/missile_builder/assembler
	name = "Seegson model 'Ford' robotic missile assembly arm (board)"
	build_path = /obj/machinery/missile_builder/assembler

//Missile system
/obj/item/circuitboard/machine/vls
	name = "M14 VLS Tube (Circuitboard)"
	build_path = /obj/machinery/ship_weapon/vls
	req_components = list(
		/obj/item/stack/sheet/mineral/titanium = 20,
		/obj/item/stack/sheet/mineral/copper = 20,
		/obj/item/stack/sheet/iron = 30,
		/obj/item/stack/cable_coil = 10)
