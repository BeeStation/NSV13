/// If a sabre is on the overmap and the main ship leaves the system, the sabre should stay behind
/datum/unit_test/sabre_gets_towed

/datum/unit_test/sabre_gets_towed/Run()
	var/obj/structure/overmap/main = SSstar_system.find_main_overmap()
	var/obj/structure/overmap/small_craft/transport/sabre/straggler = null
	var/datum/star_system/starting_system = main.current_system
	var/datum/star_system/target_system

	if(length(starting_system.adjacency_list))
		target_system = SSstar_system.system_by_id(pick(main.current_system.adjacency_list))
	else
		target_system = SSstar_system.system_by_id("Ida")

	for(var/obj/structure/overmap/small_craft/transport/sabre/OM as() in main.overmaps_in_ship)
		straggler = OM
		break

	if(!straggler)
		var/turf/center = SSmapping.get_station_center()
		straggler = new /obj/structure/overmap/small_craft/transport(center)
		straggler.forceMove(center)

	var/mob/living/carbon/human/dummy = new()
	straggler.operators += dummy

	if(!straggler.check_overmap_elegibility(ignore_position = TRUE, ignore_cooldown = TRUE))
		Fail("Couldn't put straggler onto the overmap")
	main.jump_start(target_system, force=TRUE)

	TEST_ASSERT(!straggler.reserved_z, "Sabre has a reserved Z")
	TEST_ASSERT_NOTEQUAL(straggler.reserved_z, main.reserved_z, "Sabre and main ship reserved the same Z")
	TEST_ASSERT_EQUAL(straggler.z, main.z, "Sabre is not on the main ship's Z")

	TEST_ASSERT_NOTEQUAL(main.current_system, straggler.current_system, "Main ship and sabre have different current_system")

	TEST_ASSERT(!starting_system.occupying_z, "Starting system has occupying_z")
