///Crushes boulders to turn them into rocks.
/obj/machinery/mineral/ore_crusher
	name = "boulder crusher"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "stacker"
	density = TRUE
	///List of rocks in the machine atm
	var/list/rocks = list()
	///Cooldown for the next rock to be dropped
	var/next_rock_time = 0
	///Cooldown in deciseconds between rocks being dropped
	var/rock_drop_cooldown = 10
	///Rocks that one boulder makes.
	var/rocks_per_boulder = ROCK_COUNT_BOULDER
	///Modifier to the amount of materials kept in the transfer
	var/efficiency = 1

///Shit rocks out when the crusher is deconstructed
/obj/machinery/mineral/ore_crusher/on_deconstruction()
	drop_rocks()
	..()

///When a boulder is in the input position, process it.
/obj/machinery/mineral/ore_crusher/HasProximity(atom/movable/AM)
	. = .. ()
	if(istype(AM, /obj/structure/boulder) && AM.loc == get_step(src, input_dir))
		process_boulder(AM)


/// Drop rocks if we have any, othewrwise try processing any boulders available.
/obj/machinery/mineral/ore_crusher/process()
	if(rocks.len && world.time >= next_rock_time)
		drop_next_rock()

	var/atom/input = get_step(src, input_dir)

	for(var/obj/structure/boulder/B in input)
		process_boulder(B)


///Process the boulder and add the rocks obtained to the rock list
/obj/machinery/mineral/ore_crusher/proc/process_boulder(obj/structure/boulder/B)
	B.forceMove(src) //boulder vore time
	rocks += B.drop_rocks(efficiency)
	qdel(B, FALSE, 0) //Remove with 0 efficiency because we already have the rocks

/// Drops the next rock in the rocks list and resets the cooldown
/obj/machinery/mineral/ore_crusher/proc/drop_next_rock()
	var/obj/item/I = rocks[1]
	I.forceMove(get_step(src, output_dir))
	rocks -= I
	next_rock_time = world.time + rock_drop_cooldown

/// Drops all rocks in the machine
/obj/machinery/mineral/ore_crusher/proc/drop_rocks()
	for(var/i in rocks)
		var/obj/item/dropped = i
		dropped.forceMove(src.drop_location())





