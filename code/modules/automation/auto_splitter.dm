/obj/machinery/automation/router
	name = "router"
	desc = "Outputs items onto nearby conveyor belts that are traveling outwards (respective to this) and will do so evenly."
	var/current_tick = 0 //Where we will output the next item

/obj/machinery/automation/router/Bumped(atom/movable/input)
	if(isitem(input))
		contents += input
	..()

/obj/machinery/automation/router/process()
	..()
