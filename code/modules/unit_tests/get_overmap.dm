/// A mob on the main ship should have its get_overmap return the main ship
/datum/unit_test/basic_mob_overmap
	var/mob/living/carbon/human/dummy = null

/datum/unit_test/basic_mob_overmap/Run()
	var/turf/center = SSmapping.get_station_center()
	ASSERT(center)
	dummy = new(center)
	dummy.update_overmap()
	TEST_ASSERT_EQUAL(dummy.get_overmap(), SSstar_system.find_main_overmap(), "The mob's overmap was not the main ship")

/datum/unit_test/basic_mob_overmap/Destroy()
	QDEL_NULL(dummy)
	. = ..()

/// A mob inside a basic fighter should have its get_overmap return the fighter
/datum/unit_test/fighter_pilot_overmap
	var/obj/structure/overmap/small_craft/combat/light/fighter = null
	var/mob/living/carbon/human/dummy = null

/datum/unit_test/fighter_pilot_overmap/Run()
	for(var/obj/structure/overmap/small_craft/combat/light/OM as() in SSstar_system.find_main_overmap().overmaps_in_ship)
		fighter = OM
		break

	if(!fighter)
		var/turf/center = SSmapping.get_station_center()
		ASSERT(center)
		fighter = new (center)

	dummy = new()
	fighter.enter(dummy)
	fighter.start_piloting(dummy, OVERMAP_USER_ROLE_PILOT | OVERMAP_USER_ROLE_GUNNER)
	TEST_ASSERT_EQUAL(dummy.get_overmap(), fighter, "The mob's overmap was not the light fighter")
	fighter.stop_piloting(dummy)

/datum/unit_test/fighter_pilot_overmap/Destroy()
	QDEL_NULL(dummy)
	QDEL_NULL(fighter)
	. = ..()


/*
 * Reactivate when map loading system improves
/// A mob inside a sabre should have its get_overmap return the sabre
/datum/unit_test/sabre_occupant_overmap
	var/obj/structure/overmap/small_craft/transport/sabre/sabre = null
	var/mob/living/carbon/human/dummy = null

/datum/unit_test/sabre_occupant_overmap/Run()
	for(var/obj/structure/overmap/small_craft/transport/sabre/OM as() in SSstar_system.find_main_overmap().overmaps_in_ship)
		sabre = OM
		break

	if(!sabre)
		var/turf/center = SSmapping.get_station_center()
		ASSERT(center)
		sabre = new /obj/structure/overmap/small_craft/transport/sabre(center)

	ASSERT(sabre)
	var/tries = 50
	while((tries > 0) && (sabre.interior_status != 2))
		sleep(5 SECONDS)
		tries--
	TEST_ASSERT_EQUAL(sabre.interior_status, 2, "The sabre's interior was not ready")

	dummy = new(get_turf(sabre))
	sabre.enter(dummy)
	dummy.update_overmap()
	TEST_ASSERT_EQUAL(dummy.get_overmap(), sabre, "The mob's overmap was not the sabre")
*/

/datum/unit_test/fighter_pilot_overmap/Destroy()
	QDEL_NULL(dummy)
	. = ..()

/// A fighter inside a larger ship should have its get_overmap return the ship
/datum/unit_test/fighter_on_ship
	var/obj/structure/overmap/small_craft/combat/light/fighter = null

/datum/unit_test/fighter_on_ship/Run()
	for(var/obj/structure/overmap/small_craft/combat/light/OM as() in SSstar_system.find_main_overmap().overmaps_in_ship)
		fighter = OM
		break

	if(!fighter)
		var/turf/center = SSmapping.get_station_center()
		ASSERT(center)
		fighter = new (center)

	TEST_ASSERT_EQUAL(fighter.get_overmap(), SSstar_system.find_main_overmap(), "The fighter's overmap was not the ship")

/datum/unit_test/fighter_on_ship/Destroy()
	QDEL_NULL(fighter)
	. = ..()

/// A fighter that leaves and re-enters a larger ship should have its get_overmap return null while in space, and the ship when back on the ship
/datum/unit_test/fighter_docking
	var/obj/structure/overmap/small_craft/combat/light/fighter = null

/datum/unit_test/fighter_docking/Run()
	for(var/obj/structure/overmap/small_craft/combat/light/OM as() in SSstar_system.find_main_overmap().overmaps_in_ship)
		fighter = OM
		break

	if(!fighter)
		var/turf/center = SSmapping.get_station_center()
		ASSERT(center)
		fighter = new (center)

	fighter.check_overmap_elegibility(ignore_position = TRUE, ignore_cooldown = TRUE)
	TEST_ASSERT_EQUAL(fighter.get_overmap(), null, "The fighter's overmap was not null after entering the overmap")
	fighter.transfer_from_overmap(SSstar_system.find_main_overmap())
	TEST_ASSERT_EQUAL(fighter.get_overmap(), SSstar_system.find_main_overmap(), "The fighter's overmap was not the ship after docking")

/datum/unit_test/fighter_docking/Destroy()
	QDEL_NULL(fighter)
	. = ..()

/* This doesn't work because the interior doesn't load in a reasonable amount of time
/// A small craft that docks with an asteroid should have its get_overmap return the asteroid while inside, and then null after leaving
/datum/unit_test/asteroid_docking
	var/obj/structure/overmap/small_craft/combat/light/fighter = null

/datum/unit_test/asteroid_docking/Run()
	var/start = world.time
	var/time_limit = 1 MINUTES
	for(var/obj/structure/overmap/small_craft/combat/light/OM as() in SSstar_system.find_main_overmap().overmaps_in_ship)
		fighter = OM
		break

	if(!fighter)
		var/turf/center = SSmapping.get_station_center()
		ASSERT(center)
		fighter = new (center)

	fighter.ftl_drive = TRUE //This won't work in real life but it will for the test
	var/obj/item/fighter_component/docking_computer/DC = fighter.loadout.get_slot(HARDPOINT_SLOT_DOCKING)
	DC.docking_mode = TRUE
	fighter.check_overmap_elegibility(ignore_position = TRUE, ignore_cooldown = TRUE)
	TEST_ASSERT_EQUAL(fighter.get_overmap(), null, "The fighter's overmap was not null after entering the overmap from the ship")

	var/obj/structure/overmap/asteroid/asteroid = new(get_turf(fighter))
	fighter.docking_act(asteroid)
	while((world.time - start) < time_limit)
		sleep(10)
	TEST_ASSERT_EQUAL(fighter.get_overmap(), asteroid, "The fighter's overmap was not the asteroid after docking")
	fighter.check_overmap_elegibility(ignore_position = TRUE, ignore_cooldown = TRUE)
	TEST_ASSERT_EQUAL(fighter.get_overmap(), null, "The fighter's overmap was not null after entering the overmap from the asteroid")

/datum/unit_test/asteroid_docking/Destroy()
	QDEL_NULL(fighter)
	. = ..()
*/
