/obj/machinery/broadside_shell_packer
	name = "\improper Broadside Shell Packer Bench"
	desc = "An automated table that packs broadside shell casings, just add components!"
	icon = 'icons/obj/cryogenic2.dmi' //TEMP
	icon_state = "bscanner_open" //TEMP
	density = TRUE
	anchored = TRUE
	circuit = /obj/item/circuitboard/machine/broadside_shell_packer
	var/shell_amount = 0
	var/load_amount = 0
	var/bag_amount = 0
	var/amount_to_pack = 5
	var/obj/item/powder_bag/plasma/plasma = FALSE
	var/obj/item/powder_bag/gunpowder = FALSE
	var/static/list/thingy = typecacheof(list(
		/obj/item/ship_weapon/parts/broadside_shell,
		/obj/item/ship_weapon/parts/broadside_load,
		/obj/item/powder_bag))

/obj/machinery/broadside_shell_packer/examine(mob/user)
	. = ..()
	. += "It has [shell_amount] shells, [load_amount]loads, and [bag_amount] bags."
	. += "The Packer requires 5 Shells, 5 Loads and 1 Powder Bag to pack 5 Broadside Shells."

/obj/machinery/broadside_shell_packer/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(thingy[I.type])
		if(istype(I, /obj/item/ship_weapon/parts/broadside_shell))
			//if(shell_amount == 0)
			//add_overlay("broadside_shell")
			if(shell_amount < amount_to_pack)
				shell_amount++
				to_chat(user, "<span class='notice'>You add a shell to the table.</span>")
				I.forceMove(src)
				qdel(I)
			else
				to_chat(user, "<span class='warning'>The table is already full of shells!</span>")
		if(istype(I, /obj/item/ship_weapon/parts/broadside_load))
			//if(load_amount == 0)
			//add_overlay("broadside_load")
			if(load_amount < amount_to_pack)
				load_amount++
				to_chat(user, "<span class='notice'>You add a load to the table.</span>")
				I.forceMove(src)
				qdel(I)
			else
				to_chat(user, "<span class='warning'>The table is already full of loads!</span>")
		if(istype(I, /obj/item/powder_bag))
			//if(bag_amount == 0)
			//add_overlay("broadside_bag")
			if(bag_amount < 1)
				if(istype(I, /obj/item/powder_bag/plasma))
					plasma = TRUE
					to_chat(user, "<span class='notice'>You add a plasma bag to the table.</span>")
				else if(istype(I, /obj/item/powder_bag))
					gunpowder = TRUE
					to_chat(user, "<span class='notice'>You add a gunpowder bag to the table.</span>")
				I.forceMove(src)
				bag_amount++
				qdel(I)
			else
				to_chat(user, "<span class='warning'>The table is already packed with a bag!</span>")

/obj/machinery/broadside_shell_packer/attack_hand(mob/living/user)
	. = ..()
	if(shell_amount == amount_to_pack && load_amount == amount_to_pack && bag_amount == 1)
		//cut_overlays()
		to_chat(user, "<span class='notice'>The table starts to stuff the shell casings!</span>")
		for(var/i in 1 to amount_to_pack)
			if(plasma)
				new /obj/item/ship_weapon/ammunition/broadside_shell/plasma(get_turf(src))
			else if(gunpowder)
				new /obj/item/ship_weapon/ammunition/broadside_shell(get_turf(src))
		reset()
	else
		if(shell_amount < amount_to_pack)
			to_chat(user, "<span class='warning'>The table is missing [amount_to_pack - shell_amount] shells!</span>")
		if(load_amount < amount_to_pack)
			to_chat(user, "<span class='warning'>The table is missing [amount_to_pack - load_amount] loads!</span>")
		if(bag_amount < 1)
			to_chat(user, "<span class='warning'>The table is missing a bag!</span>")
	return

/obj/machinery/broadside_shell_packer/proc/reset()
	shell_amount = 0
	load_amount = 0
	bag_amount = 0
	plasma = FALSE
	gunpowder = FALSE
	return

/obj/item/circuitboard/machine/broadside_shell_packer
	name = "circuit board (Broadside Shell Packer)"
	desc = "Pack the shells and get that ice cream ration pack from the kitchen!"
	req_components = list(
		/obj/item/stack/sheet/iron = 20,
	)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	build_path = /obj/machinery/broadside_shell_packer
