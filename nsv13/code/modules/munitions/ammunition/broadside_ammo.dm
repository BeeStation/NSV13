/obj/item/ship_weapon/ammunition/broadside_shell
	name = "\improper SNBC Type 1 Shell"
	desc = "A large packed shell, complete with powder and projectile, ready to be loaded and fired."
	icon_state = "broadside"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_righthand.dmi'
	icon = 'nsv13/icons/obj/munitions.dmi'
	w_class = WEIGHT_CLASS_BULKY
	projectile_type = /obj/item/projectile/bullet/broadside

/obj/item/ship_weapon/ammunition/broadside_shell/plasma
	name = "\improper SNBC Type P Shell"
	desc = "A large packed shell, complete with plasma and projectile, ready to be loaded and fired."
	icon_state = "broadside_plasma"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_righthand.dmi'
	icon = 'nsv13/icons/obj/munitions.dmi'
	w_class = WEIGHT_CLASS_BULKY
	projectile_type = /obj/item/projectile/bullet/broadside/plasma

/obj/machinery/broadside_shell_packer
	name = "\improper Broadside Shell Packer Bench"
	desc = "An automated table that packs broadside shell casings, just add components!"
	icon = 'nsv13/icons/obj/munitions/packing_bench.dmi'
	icon_state = "packing_bench"
	density = TRUE
	anchored = TRUE
	circuit = /obj/item/circuitboard/machine/broadside_shell_packer
	bound_width = 64
	var/casing_amount = 0
	var/load_amount = 0
	var/bag_amount = 0
	var/amount_to_pack = 5
	var/obj/item/powder_bag/plasma/plasma = FALSE
	var/obj/item/powder_bag/gunpowder = FALSE
	var/static/list/thingy = typecacheof(list(
		/obj/item/ship_weapon/parts/broadside_casing,
		/obj/item/ship_weapon/parts/broadside_load,
		/obj/item/powder_bag))

/obj/machinery/broadside_shell_packer/examine(mob/user)
	. = ..()
	. += "It has [casing_amount] shells, [load_amount] loads, and [bag_amount] bags."
	. += "The Packer requires 5 Shells, 5 Loads and 1 Powder Bag to pack 5 Broadside Shells."

/obj/machinery/broadside_shell_packer/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(thingy[I.type])
		if(istype(I, /obj/item/ship_weapon/parts/broadside_casing))
			if(casing_amount < amount_to_pack)
				casing_amount++
				to_chat(user, "<span class='notice'>You add a shell to the table.</span>")
				I.forceMove(src)
				qdel(I)
				playsound(user, 'sound/items/screwdriver2.ogg', 30)
			if(casing_amount > 0)
				add_overlay("casing-[casing_amount]")
			else
				to_chat(user, "<span class='warning'>The table is already full of casings!</span>")
		if(istype(I, /obj/item/ship_weapon/parts/broadside_load))
			if(load_amount < amount_to_pack)
				load_amount++
				to_chat(user, "<span class='notice'>You add a load to the table.</span>")
				I.forceMove(src)
				qdel(I)
				playsound(user, 'sound/items/screwdriver2.ogg', 30)
			if(load_amount > 0)
				add_overlay("load-[load_amount]")
			else
				to_chat(user, "<span class='warning'>The table is already full of loads!</span>")
		if(istype(I, /obj/item/powder_bag))
			if(bag_amount < 1)
				if(istype(I, /obj/item/powder_bag/plasma))
					plasma = TRUE
					to_chat(user, "<span class='notice'>You add a plasma bag to the table.</span>")
				else if(istype(I, /obj/item/powder_bag))
					gunpowder = TRUE
					to_chat(user, "<span class='notice'>You add a gunpowder bag to the table.</span>")
				I.forceMove(src)
				bag_amount++
				playsound(user, 'nsv13/sound/effects/ship/mac_load.ogg', 20)
				qdel(I)
			if(bag_amount == 1)
				add_overlay("powder-1")
			else
				to_chat(user, "<span class='warning'>The table is already packed with a bag!</span>")

/obj/machinery/broadside_shell_packer/attack_hand(mob/living/user)
	. = ..()
	if(casing_amount == amount_to_pack && load_amount == amount_to_pack && bag_amount == 1)
		icon_state = "packing_bench_loading"
		cut_overlays()
		to_chat(user, "<span class='notice'>The table starts to stuff the shell casings!</span>")
		playsound(user, 'nsv13/sound/effects/ship/mac_load.ogg', 20)
		sleep(0.5 SECONDS)
		for(var/i in 1 to amount_to_pack)
			if(plasma)
				new /obj/item/ship_weapon/ammunition/broadside_shell/plasma(get_turf(src))
			else if(gunpowder)
				new /obj/item/ship_weapon/ammunition/broadside_shell(get_turf(src))
		reset()
	else
		if(casing_amount < amount_to_pack)
			to_chat(user, "<span class='warning'>The table is missing [amount_to_pack - casing_amount] shells!</span>")
		if(load_amount < amount_to_pack)
			to_chat(user, "<span class='warning'>The table is missing [amount_to_pack - load_amount] loads!</span>")
		if(bag_amount < 1)
			to_chat(user, "<span class='warning'>The table is missing a bag!</span>")
	return

/obj/machinery/broadside_shell_packer/proc/reset()
	casing_amount = 0
	load_amount = 0
	bag_amount = 0
	plasma = FALSE
	gunpowder = FALSE
	icon_state = "packing_bench"
	update_icon()
	return

/obj/item/circuitboard/machine/broadside_shell_packer
	name = "circuit board (Broadside Shell Packer)"
	desc = "Pack the shells and get that ice cream ration pack from the kitchen!"
	req_components = list(
		/obj/item/stack/sheet/iron = 20,
	)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	build_path = /obj/machinery/broadside_shell_packer
