// robot_upgrades.dm
// Contains NSV13 exclusive borg upgrades.

/obj/item/borg/upgrade/exp_welder
	name = "Experimental cyborg welder"
	desc = "A experimental welder replacement for the engieborg's standard welder."
	icon_state = "cyborg_upgrade3"
	require_module = 1
	module_type = /obj/item/robot_module/engineering

/obj/item/borg/upgrade/exp_welder/action(mob/living/silicon/robot/R)
	. = ..()
	if(.)
		for(var/obj/item/weldingtool/largetank/cyborg/WT in R.module.modules)
			R.module.remove_module(WT, TRUE)

		var/obj/item/weldingtool/experimental/cyborg/EWT = new /obj/item/weldingtool/experimental/cyborg(R.module)
		R.module.basic_modules += EWT
		R.module.add_module(EWT, FALSE, TRUE)

/obj/item/borg/upgrade/exp_welder/deactivate(mob/living/silicon/robot/R, user = usr)
	. = ..()
	if(.)
		for(var/obj/item/weldingtool/experimental/cyborg/EWT in R.module.modules)
			R.module.remove_module(EWT, TRUE)

		var/obj/item/weldingtool/largetank/cyborg/WT = new (R.module)
		R.module.basic_modules += WT
		R.module.add_module(WT, FALSE, TRUE)