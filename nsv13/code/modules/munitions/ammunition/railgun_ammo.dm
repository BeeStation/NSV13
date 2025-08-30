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

//Railgun Forge
/obj/item/ship_weapon/ammunition/railgun_slug_forged
	name = "\improper Forged 400mm" //Partial name - to be completed by the forging proc
	desc = "A gigantic slug that's designed to be fired out of a railgun. It's extremely heavy, but doesn't actually contain any volatile components, so it's safe to manhandle."
	icon_state = "railgun_ammo"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_righthand.dmi'
	icon = 'nsv13/icons/obj/munitions.dmi'
	w_class = 4
	projectile_type = /obj/item/projectile/bullet/railgun_forged
	var/material_conductivity = 0
	var/material_density = 0
	var/material_hardness = 0

/obj/item/ship_weapon/ammunition/railgun_slug_forged/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)

/obj/item/ship_weapon/ammunition/railgun_slug_forged/pre_gen_copper_iron //test round
	name = "\improper Forged 400mm copper coated iron slug"
	material_conductivity = 5
	material_density = 30
	material_hardness = 10

/obj/item/ship_weapon/ammunition/railgun_canister_forged
	name = "\improper Forged 800mm" //Partial name - to be completed by the forging proc
	desc = "A gigantic cansiter that's designed to be fired out of a railgun. It's extremely heavy, containing an internal chamber for charged ions, unsafe for direct handling."
	icon_state = "railgun_ammo"
	lefthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'nsv13/icons/mob/inhands/weapons/bombs_righthand.dmi'
	icon = 'nsv13/icons/obj/munitions.dmi'
	w_class = 5
	projectile_type = /obj/item/projectile/bullet/railgun_forged
	var/next_slowprocess = 0
	var/material_conductivity = 0
	var/material_density = 0
	var/material_hardness = 0
	var/material_charge = 0
	var/canister_integrity = 100
	var/canister_volume = 100 //or should this be mols?
	var/canister_gas
	var/stabilized = FALSE

/obj/item/ship_weapon/ammunition/railgun_canister_forged/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE)

/obj/item/ship_weapon/ammunition/railgun_canister_forged/process()
	.=..()
	if(next_slowprocess < world.time)
		slowprocess()
		next_slowprocess = world.time + 1 SECONDS //Set to process only once a second

/obj/item/ship_weapon/ammunition/railgun_canister_forged/proc/slowprocess()
	switch(material_charge)
		if(80 to 100)
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

/obj/item/ship_weapon/ammunition/railgun_canister_forged/proc/update_overlay()
	//here we enter in the overlays when we have them
	//overlay is blue above 20% integrity, red below 20%
	//overlay shifts and shimmers more with higher charge value

/obj/item/ship_weapon/ammunition/railgun_canister_forged/proc/burst()
	if(material_charge > 50)
		empulse(src, 4, 7, log=TRUE)
		for(var/mob/living/carbon/C in orange(7, src))
			C.apply_damage(25, damagetype=CLONE)
	else
		empulse(src, 3, 5, log=TRUE)
		for(var/mob/living/carbon/C in orange(5, src))
			C.apply_damage(10, damagetype=CLONE)

	explosion(get_turf(src), 0, 0, 1, 2, TRUE, TRUE)
	Destroy(src)

/obj/item/ship_weapon/ammunition/railgun_canister_forged/attack_hand(mob/living/carbon/user)
	.=..()
	var/mob/living/carbon/human/H = user
	if(material_charge)
		if(H.gloves)
			return
		else
			user.apply_damage(5, damagetype=CLONE)
			to_chat(user,"<span class='notice'>Your hand tingles and feels warm on touching the [src].</span>")

