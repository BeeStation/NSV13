/// A mob on the main ship should have its get_overmap return the main ship
/datum/unit_test/basic_mob_overmap
	var/mob/living/carbon/human/dummy

/datum/unit_test/basic_mob_overmap/New()
	. = ..()
	var/turf/center = SSmapping.get_station_center()
	dummy = new(center)

/datum/unit_test/basic_mob_overmap/Run()
	dummy.update_overmap()
	TEST_ASSERT_EQUAL(dummy.get_overmap(), SSstar_system.find_main_overmap(), "The mob's overmap was not the main ship")

/datum/unit_test/basic_mob_overmap/Destroy()
	QDEL_NULL(dummy)
	. = ..()

/// A mob inside a basic fighter should have its get_overmap return the fighter
/datum/unit_test/fighter_pilot_overmap
	var/obj/structure/overmap/small_craft/combat/light/fighter = null
	var/mob/living/carbon/human/dummy

/datum/unit_test/fighter_pilot_overmap/New()
	. = ..()
	for(var/obj/structure/overmap/small_craft/combat/light/OM as() in SSstar_system.find_main_overmap().overmaps_in_ship)
		fighter = OM
		break

	if(!fighter)
		var/turf/center = SSmapping.get_station_center()
		fighter = new (center)

	dummy = new()
	fighter.start_piloting(dummy, OVERMAP_USER_ROLE_PILOT | OVERMAP_USER_ROLE_GUNNER)

/datum/unit_test/fighter_pilot_overmap/Run()
	dummy.update_overmap()
	TEST_ASSERT_EQUAL(dummy.get_overmap(), fighter, "The mob's overmap was not the light fighter")

/datum/unit_test/fighter_pilot_overmap/Destroy()
	fighter.stop_piloting(dummy)
	QDEL_NULL(dummy)
	QDEL_NULL(fighter)
	. = ..()
