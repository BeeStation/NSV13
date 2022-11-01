/datum/overmap_objective/cargo/donation/social_supplies
	name = "Donate social supplies"
	desc = "Donate 1 or more social supplies"
	crate_name = "Social Supplies crate"

/datum/overmap_objective/cargo/donation/social_supplies/New()
	// Pick a cake
	var/list/picked = pick( list(
		/obj/item/reagent_containers/food/snacks/store/cake/plain,
		/obj/item/reagent_containers/food/snacks/store/cake/birthday,
		/obj/item/reagent_containers/food/snacks/store/cake/holy_cake,
		/obj/item/reagent_containers/food/snacks/store/cake/pound_cake,
	) )
	var/datum/freight_type/single/object/cake = new /datum/freight_type/single/object( picked )

	// Pick a beer
	// Get only craftable chemicals of consumable ethanol
	var/list/possible_chemicals = list()

	for( var/D in subtypesof( /datum/chemical_reaction ) )
		var/datum/chemical_reaction/C = new D()
		if ( C.id )
			if ( ispath( C.id, /datum/reagent/consumable/ethanol ) )
				possible_chemicals += C.id

	var/datum/reagent/consumable/ethanol/picked_ethanol = pick( possible_chemicals )
	var/datum/freight_type/single/reagent/drinks/drinks = new( picked_ethanol )
	drinks.target = 200

	// Setup presents
	var/datum/freight_type/single/object/individually_wrapped_presents = new /datum/freight_type/single/object( /obj )
	individually_wrapped_presents.target = 3
	individually_wrapped_presents.item_name = "any item"
	individually_wrapped_presents.approve_inner_contents = TRUE
	individually_wrapped_presents.require_loc = /obj/item/small_delivery
	individually_wrapped_presents.require_loc_name = "a wrapped parcel"

	var/datum/freight_type/single/object/crate_with_presents = new /datum/freight_type/single/object( /obj )
	crate_with_presents.target = 3
	crate_with_presents.item_name = "any item"
	crate_with_presents.approve_inner_contents = TRUE
	crate_with_presents.require_loc = /obj/structure/big_delivery
	crate_with_presents.require_loc_name = "a wrapped crate"
	// I hate social supplies i HATE SOCIAL SUPPLIES

	freight_type_group = new( list(
		cake,
		drinks,
		new /datum/freight_type/group/require/any( list(
			individually_wrapped_presents,
			crate_with_presents
		) )
	) )
