// Keybinds for NSV vehicles
/datum/keybinding/vehicle
		category = CATEGORY_VEHICLE
		weight = WEIGHT_VEHICLE


// Toggling brakes for tugs/similar vehicles
/datum/keybinding/vehicle/toggle_brakes
	key = "Alt"
	name = "toggle_car_brakes"
	full_name = "Toggle Brakes"
	description = "Toggle a vehicle's brakes."
	keybind_signal = COMSIG_KB_VEHICLE_TOGGLE_BRAKES

/datum/keybinding/vehicle/toggle_brakes/down(client/user)
	. = ..()
	if(.) return
	if(!user.mob) return

	var/mob/M = user.mob
	var/obj/vehicle/sealed/car/realistic/vehicle = M.focus
	if(!istype(vehicle)) return
	if(!vehicle.is_driver(M)) return

	vehicle.toggle_brakes()
	return TRUE
