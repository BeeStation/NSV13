#define MULTIZ_PIPE_UP 1
#define MULTIZ_PIPE_DOWN 2


/obj/structure/disposalpipe/trunk/multiz
	name = "Disposal trunk that goes up"
	icon_state = "pipe-up"
	var/multiz_dir = MULTIZ_PIPE_UP

/obj/structure/disposalpipe/trunk/multiz/down
	name = "Disposal trunk that goes down"
	icon_state = "pipe-down"
	multiz_dir = MULTIZ_PIPE_DOWN

/obj/structure/disposalpipe/trunk/multiz/transfer(obj/structure/disposalholder/H)
	if(H.dir == DOWN)		// we just entered from a disposer
		return ..()		// so do base transfer proc
	// otherwise, go to the linked object
	if(multiz_dir)
		var/turf/T = null
		if(multiz_dir == MULTIZ_PIPE_UP)
			T = SSmapping.get_turf_above(get_turf(src))
		if(multiz_dir == MULTIZ_PIPE_DOWN)
			T = SSmapping.get_turf_below(get_turf(src))
		if(!T)
			expel(H)
			return //Nothing located.
		var/obj/structure/disposalpipe/trunk/multiz/pipe = locate(/obj/structure/disposalpipe/trunk/multiz) in T
		if(pipe)
			var/obj/structure/disposalholder/destination = new(pipe)
			destination.init(pipe)
			destination.merge(H)
			destination.active = TRUE
			destination.setDir(DOWN)
			destination.move()
			return null
	else
		var/obj/structure/disposaloutlet/O = linked
		if(istype(O))
			O.expel(H)	// expel at outlet
		else
			var/obj/machinery/disposal/D = linked
			D.expel(H)	// expel at disposal

	// Returning null without expelling holder makes the holder expell itself
	return null

#undef MULTIZ_PIPE_UP
#undef MULTIZ_PIPE_DOWN