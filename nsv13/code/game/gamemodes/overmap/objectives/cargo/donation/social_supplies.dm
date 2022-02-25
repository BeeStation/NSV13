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
	var/datum/freight_type/single/object/individually_wrapped_presents = new /datum/freight_type/single/object( /obj/item/smallDelivery )
	individually_wrapped_presents.target = 3
	individually_wrapped_presents.item_name = "3 individually wrapped parcels"
	individually_wrapped_presents.approve_inner_contents = TRUE

	var/datum/freight_type/single/object/crate_with_presents = new /datum/freight_type/single/object( /obj/structure/bigDelivery )
	// proc check_contents matches the freight_type's target item
	// For this reason the target should be the number of wrapped crates (1), NOT the number of extra presents inside the crate
	crate_with_presents.target = 1
	crate_with_presents.item_name = "3 items in 1 wrapped crate"
	crate_with_presents.approve_inner_contents = TRUE
	// Special snowflake var because otherwise you and I both know players would start submitting empty wrapped crates :)
	crate_with_presents.require_inner_contents = 3

	freight_type_group = new( list(
		cake,
		drinks,
		new /datum/freight_type/group/require/any( list(
			individually_wrapped_presents,
			crate_with_presents
		) )
	) )
