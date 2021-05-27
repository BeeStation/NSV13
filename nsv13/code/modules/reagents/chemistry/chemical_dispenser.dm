/obj/structure/reagent_dispensers/chem
	name = "Chem Dispenser"
	desc = "..."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "large_grenade_locked"
	density = FALSE
	anchored = TRUE
	tank_volume = 300
	var/refilling = FALSE

/obj/structure/reagent_dispensers/chem/Initialize()
	create_reagents(tank_volume, REFILLABLE | DRAINABLE | AMOUNT_VISIBLE)
	if(reagent_id)
		reagents.add_reagent(reagent_id, tank_volume)
	. = ..()

/obj/structure/reagent_dispensers/chem/attackby(obj/item/W, mob/user, params)
	if(refilling == FALSE)
		if(W.is_refillable())
			return 0
		else
			return ..()

	else
		if(W.is_drainable())
			return 0
		else
			return ..()

/obj/structure/reagent_dispensers/chem/attack_hand(mob/user)
	if(refilling)
		to_chat(user, "<span class='notice'>You close the [src]'s lid.</span>")
		refilling = FALSE

	if(!refilling)
		to_chat(user, "<span class='notice'>You open on the [src]'s lid.</span>")
		refilling = TRUE

/obj/structure/reagent_dispensers/chem/attack_ai(mob/user)
	return

/obj/structure/reagent_dispensers/chem/attack_robot(mob/user)
	return

/obj/structure/reagent_dispensers/chem/attack_ghost(mob/user)
	return

/obj/structure/reagent_dispensers/chem/aluminium
	name = "Chem Dispenser - Aluminium"
	reagent_id = /datum/reagent/aluminium

/obj/structure/reagent_dispensers/chem/bromine
	name = "Chem Dispenser - Bromine"
	reagent_id = /datum/reagent/bromine

/obj/structure/reagent_dispensers/chem/carbon
	name = "Chem Dispenser - Carbon"
	reagent_id = /datum/reagent/carbon

/obj/structure/reagent_dispensers/chem/chlorine
	name = "Chem Dispenser - Chlorine"
	reagent_id = /datum/reagent/chlorine

/obj/structure/reagent_dispensers/chem/copper
	name = "Chem Dispenser - Copper"
	reagent_id = /datum/reagent/copper

/obj/structure/reagent_dispensers/chem/ethanol
	name = "Chem Dispenser - Ethanol"
	reagent_id = /datum/reagent/consumable/ethanol

/obj/structure/reagent_dispensers/chem/fluorine
	name = "Chem Dispenser - Fluorine"
	reagent_id = /datum/reagent/fluorine

/obj/structure/reagent_dispensers/chem/hydrogen
	name = "Chem Dispenser - Hydrogen"
	reagent_id = /datum/reagent/hydrogen

/obj/structure/reagent_dispensers/chem/iodine
	name = "Chem Dispenser - Iodine"
	reagent_id = /datum/reagent/iodine

/obj/structure/reagent_dispensers/chem/iron
	name = "Chem Dispenser - Iron"
	reagent_id = /datum/reagent/iron

/obj/structure/reagent_dispensers/chem/lithium
	name = "Chem Dispenser - Lithium"
	reagent_id = /datum/reagent/lithium

/obj/structure/reagent_dispensers/chem/mercury
	name = "Chem Dispenser - Mercury"
	reagent_id = /datum/reagent/mercury

/obj/structure/reagent_dispensers/chem/nitrogen
	name = "Chem Dispenser - Nitrogen"
	reagent_id = /datum/reagent/nitrogen

/obj/structure/reagent_dispensers/chem/oxygen
	name = "Chem Dispenser - Oxygen"
	reagent_id = /datum/reagent/oxygen

/obj/structure/reagent_dispensers/chem/phosphorus
	name = "Chem Dispenser - Phosphorus"
	reagent_id = /datum/reagent/phosphorus

/obj/structure/reagent_dispensers/chem/potassium
	name = "Chem Dispenser - Potassium"
	reagent_id = /datum/reagent/potassium

/obj/structure/reagent_dispensers/chem/radium
	name = "Chem Dispenser - Radium"
	reagent_id = /datum/reagent/uranium/radium

/obj/structure/reagent_dispensers/chem/silicon
	name = "Chem Dispenser - Silicon"
	reagent_id = /datum/reagent/silicon

/obj/structure/reagent_dispensers/chem/silver
	name = "Chem Dispenser - Silver"
	reagent_id = /datum/reagent/silver

/obj/structure/reagent_dispensers/chem/sodium
	name = "Chem Dispenser - Sodium"
	reagent_id = /datum/reagent/sodium

/obj/structure/reagent_dispensers/chem/plasma
	name = "Chem Dispenser - Stable Plasma"
	reagent_id = /datum/reagent/toxin/plasma

/obj/structure/reagent_dispensers/chem/sugar
	name = "Chem Dispenser - Sugar"
	reagent_id = /datum/reagent/consumable/sugar

/obj/structure/reagent_dispensers/chem/sulfur
	name = "Chem Dispenser - Sulfur"
	reagent_id = /datum/reagent/sulfur

/obj/structure/reagent_dispensers/chem/sulphuric
	name = "Chem Dispenser - Sulphuric Acid"
	reagent_id = /datum/reagent/toxin/acid

/obj/structure/reagent_dispensers/chem/welding_fuel
	name = "Chem Dispenser - Welding Fuel"
	reagent_id = /datum/reagent/fuel
