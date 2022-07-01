/// If a sabre is on the overmap and the main ship leaves the system, the sabre should go with it!
/datum/unit_test/sabre_gets_towed
	var/obj/structure/overmap/main
	var/obj/structure/overmap/small_craft/transport/sabre/occupied_sabre = null
	var/obj/structure/overmap/small_craft/transport/sabre/empty_sabre = null
	var/mob/living/carbon/human/dummy

/datum/unit_test/sabre_gets_towed/New()
	. = ..()

	main = SSstar_system.find_main_overmap()

	for(var/obj/structure/overmap/small_craft/transport/sabre/OM as() in main.overmaps_in_ship)
		occupied_sabre = OM
		break

	var/turf/center = SSmapping.get_station_center()
	if(!occupied_sabre)
		occupied_sabre = new /obj/structure/overmap/small_craft/transport(center)
	if(!empty_sabre)
		empty_sabre = new /obj/structure/overmap/small_craft/transport(center)

	dummy = new()
	occupied_sabre.operators += dummy

/datum/unit_test/sabre_gets_towed/Run()
	var/datum/star_system/starting_system = main.current_system
	var/datum/star_system/target_system

	if(length(starting_system.adjacency_list))
		target_system = SSstar_system.system_by_id(pick(main.current_system.adjacency_list))
	else
		target_system = SSstar_system.system_by_id("Ida")

	if(!occupied_sabre.check_overmap_elegibility(ignore_position = TRUE, ignore_cooldown = TRUE))
		Fail("Couldn't put occupied_sabre onto the overmap")
	if(!empty_sabre.check_overmap_elegibility(ignore_position = TRUE, ignore_cooldown = TRUE))
		Fail("Couldn't put empty_sabre onto the overmap")

	log_test("systems before jump: main: [main.current_system], occupied_sabre: [occupied_sabre.current_system], empty_sabre: [empty_sabre.current_system]")
	main.jump_start(target_system, force=TRUE)

	TEST_ASSERT(!occupied_sabre.reserved_z, "occupied_sabre has a reserved Z")
	TEST_ASSERT(!empty_sabre.reserved_z, "empty_sabre has a reserved Z")
	TEST_ASSERT_NOTEQUAL(occupied_sabre.reserved_z, main.reserved_z, "occupied_sabre and main ship reserved the same Z")
	TEST_ASSERT_NOTEQUAL(empty_sabre.reserved_z, main.reserved_z, "occupied_sabre and main ship reserved the same Z")
	TEST_ASSERT_EQUAL(occupied_sabre.z, main.z, "occupied_sabre is not on the main ship's Z")
	TEST_ASSERT(!empty_sabre.z, "empty_sabre was not put into stasis")

	log_test("systems after jump: main: [main.current_system], occupied_sabre: [occupied_sabre.current_system], empty_sabre: [empty_sabre.current_system]")
	TEST_ASSERT_EQUAL(main.current_system, occupied_sabre.current_system, "Main ship and occupied_sabre have different current_system")

	TEST_ASSERT(!starting_system.occupying_z, "Starting system has occupying_z")

/datum/unit_test/sabre_gets_towed/Destroy()
	. = ..()
	occupied_sabre.operators -= dummy
	QDEL_NULL(dummy)
	QDEL_NULL(occupied_sabre)
	QDEL_NULL(empty_sabre)
