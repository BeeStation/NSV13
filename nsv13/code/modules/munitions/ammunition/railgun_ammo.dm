//Railgun bitflags
#define RAIL_BANANA					(1<<0)
#define RAIL_BLUESPACE				(1<<1)
#define RAIL_EMP					(1<<2)
#define RAIL_BURN					(1<<3)

//Legacy Ammo
/obj/item/ship_weapon/ammunition/railgun_ammo //The big slugs that you load into the railgun. These are able to be carried...one at a time
	name = "\improper M4 NTRS 400mm teflon coated tungsten round"
	desc = "A gigantic slug that's designed to be fired out of a railgun. It's extremely heavy, but doesn't actually contain any volatile components, so it's safe to manhandle."
	icon_state = "railgun_ammo"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_righthand.dmi'
	icon = 'nsv13/icons/obj/munitions.dmi'
	w_class = 4
	projectile_type = /obj/item/projectile/bullet/railgun_slug

/obj/item/ship_weapon/ammunition/railgun_ammo/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)

/obj/item/ship_weapon/ammunition/railgun_ammo/uranium
	name = "\improper U4 NTRK 400mm teflon coated uranium round"
	desc = "A gigantic slug that's designed to be fired out of a railgun. It's extremely heavy, but doesn't actually contain any volatile components, so it's safe to manhandle."
	icon_state = "railgun_ammo"
	projectile_type = /obj/item/projectile/bullet/railgun_slug/uranium

//Forged railgun ammunition
/obj/item/ship_weapon/ammunition/railgun_ammo/forged
	name = "\improper Forged 400mm" //Partial name - to be completed by the forging proc
	desc = "A gigantic slug that's designed to be fired out of a railgun. It's extremely heavy, but doesn't actually contain any volatile components, so it's safe to manhandle."
	icon_state = "railgun_ammo"
	projectile_type = /obj/item/projectile/bullet/railgun_forged
	var/railgun_flags = null
	var/material_conductivity = 0
	var/material_density = 0
	var/material_hardness = 0

/obj/item/ship_weapon/ammunition/railgun_ammo/forged/pre_gen_copper_iron //test round
	name = "\improper Forged 400mm copper coated iron slug"
	material_conductivity = 4.675
	material_density = 15
	material_hardness = 4.25

/obj/item/ship_weapon/ammunition/railgun_ammo_canister
	name = "\improper Forged 800mm" //Partial name - to be completed by the forging proc
	desc = "A gigantic cansiter that's designed to be fired out of a railgun. It's extremely heavy, containing an internal chamber for charged ions, unsafe for direct handling."
	icon_state = "railgun_canister_unsealed"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_righthand.dmi'
	icon = 'nsv13/icons/obj/munitions.dmi'
	w_class = 5 //larger
	projectile_type = /obj/item/projectile/bullet/railgun_forged
	var/railgun_flags = null
	var/material_conductivity = 0
	var/material_density = 0
	var/material_hardness = 0
	var/next_slowprocess = 0
	var/material_charge = 0 //As a percentile
	var/canister_integrity = 100
	var/canister_moles = 100  //Hmm?
	var/canister_volume = 50
	var/canister_sealed = FALSE
	var/stabilized = FALSE
	var/datum/gas_mixture/canister_gas = null

/obj/item/ship_weapon/ammunition/railgun_ammo_canister/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src) //Requires processing due integrity/charge deg
	canister_gas = new(canister_volume)
	canister_gas.set_temperature(T20C)
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)

/obj/item/ship_weapon/ammunition/railgun_ammo_canister/examine(mob/user)
	. = ..()
	if(canister_sealed == TRUE)
		. += "<span class='notice'>The canister has been permamently sealed.</span>"
	else
		. += "<span class='notice'>The canister isn't sealed.</span>"

/obj/item/ship_weapon/ammunition/railgun_ammo_canister/Destroy()
	. = ..()
	QDEL_NULL(canister_gas)

/obj/item/ship_weapon/ammunition/railgun_ammo_canister/process()
	if(next_slowprocess < world.time)
		slowprocess()
		next_slowprocess = world.time + 1 SECONDS //Set to process only once a second

/obj/item/ship_weapon/ammunition/railgun_ammo_canister/proc/slowprocess()
	switch(material_charge)
		if(80 to 200)
			if(prob(25))
				material_charge --
		if(50 to 80)
			if(prob(50))
				material_charge --
		if(1 to 50)
			if(prob(75))
				material_charge --

	if(material_charge > 0 && !stabilized)
		if(prob(material_charge))
			canister_integrity --

		if(canister_integrity <= 0)
			burst()

	update_overlay()

/obj/item/ship_weapon/ammunition/railgun_ammo_canister/proc/update_overlay()
	if(canister_sealed)
		if(canister_integrity > 20)
			cut_overlays()
			switch(material_charge)
				if(166 to 200)
					add_overlay("railgun_canister_charge_200_integrity_high")
				if(133 to 166)
					add_overlay("railgun_canister_charge_166_integrity_high")
				if(100 to 133)
					add_overlay("railgun_canister_charge_133_integrity_high")
				if(66 to 100)
					add_overlay("railgun_canister_charge_100_integrity_high")
				if(33 to 66)
					add_overlay("railgun_canister_charge_66_integrity_high")
				if(1 to 33)
					add_overlay("railgun_canister_charge_33_integrity_high")
		else
			cut_overlays()
			switch(material_charge)
				if(166 to 200)
					add_overlay("railgun_canister_charge_200_integrity_low")
				if(133 to 166)
					add_overlay("railgun_canister_charge_166_integrity_low")
				if(100 to 133)
					add_overlay("railgun_canister_charge_133_integrity_low")
				if(66 to 100)
					add_overlay("railgun_canister_charge_100_integrity_low")
				if(33 to 66)
					add_overlay("railgun_canister_charge_66_integrity_low")
				if(1 to 33)
					add_overlay("railgun_canister_charge_33_integrity_low")

	//here we enter in the overlays when we have them
	//overlay is blue above 20% integrity, red below 20%
	//overlay shifts and shimmers more with higher charge value

/obj/item/ship_weapon/ammunition/railgun_ammo_canister/proc/burst()
	if(istype(loc, /obj/machinery/ship_weapon/hybrid_rail))
		var/obj/machinery/ship_weapon/hybrid_rail/G = loc
		if(material_charge > 100)
			G.alignment -= rand(50, 100)
			G.maint_req -= rand(40, 75)
			empulse(src, 1, 3, log=TRUE)
		else if(material_charge > 50)
			G.alignment -= rand(25, 75)
			G.maint_req -= rand(20, 45)
		else
			G.alignment -= rand(10, 50)
			G.maint_req -= rand(10, 20)

		if(G.alignment < 0)
			G.alignment = 0
		if(G.maint_req < 0)
			G.maint_req = 0

		G.misfire()
		G.unload()

	else if(istype(loc, /obj/machinery/ammo_sorter))
		var/obj/machinery/ammo_sorter/A
		if(material_charge > 100)
			Destroy(A)
			explosion(src, 0, 1, 3, 5)
			empulse(src, 3, 5, log=TRUE)
			for(var/mob/living/carbon/C in orange(5, src))
				C.apply_damage(20, damagetype=CLONE)
		else if(material_charge > 50)
			Destroy(A)
			empulse(src, 3, 5, log=TRUE)
			for(var/mob/living/carbon/C in orange(5, src))
				C.apply_damage(10, damagetype=CLONE)
		else
			A.durability = 0
			A.jammed = TRUE
			empulse(A.loc, 2, 4, log=TRUE)
			for(var/mob/living/carbon/C in orange(3, src))
				C.apply_damage(10, damagetype=CLONE)

	else
		if(material_charge > 100)
			var/turf/T = get_turf(src)
			if(T)
				var/datum/gas_mixture/env = T.return_air()
				var/datum/gas_mixture/buffer = canister_gas.remove(100) //hope there was nothing spicy in there
				env.merge(buffer)
			empulse(src, 4, 7, log=TRUE)
			for(var/mob/living/carbon/C in orange(7, src))
				C.apply_damage(40, damagetype=CLONE)
			explosion(get_turf(src), 0, 0, 2, 7, TRUE, TRUE, 1)
		else if(material_charge > 50)
			empulse(src, 4, 7, log=TRUE)
			for(var/mob/living/carbon/C in orange(7, src))
				C.apply_damage(25, damagetype=CLONE)
			explosion(get_turf(src), 0, 0, 2, 5, TRUE, TRUE)
		else
			empulse(src, 3, 5, log=TRUE)
			for(var/mob/living/carbon/C in orange(5, src))
				C.apply_damage(10, damagetype=CLONE)
			explosion(get_turf(src), 0, 0, 1, 3, TRUE, TRUE)

	Destroy(src)

/obj/item/ship_weapon/ammunition/railgun_ammo_canister/attack_hand(mob/living/carbon/user)
	.=..()
	var/mob/living/carbon/human/H = user
	if(material_charge)
		if(H.gloves)
			return
		else
			user.apply_damage(5, damagetype=CLONE)
			to_chat(user,"<span class='notice'>Your hand tingles and feels warm when touching the [src].</span>")

/obj/item/ship_weapon/ammunition/railgun_ammo_canister/pre_gen_copper_iron //test round
	name = "\improper Forged 800mm copper coated iron canister"
	material_conductivity = 3.94
	material_density = 16
	material_hardness = 4.8
