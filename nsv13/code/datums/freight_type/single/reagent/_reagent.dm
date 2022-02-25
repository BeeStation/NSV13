// Reagent type cargo objectives

/datum/freight_type/single/reagent
	var/datum/reagent/reagent_type = null
	var/list/containers = list(
		/obj/item/reagent_containers
	)
	target = 30 // Standard volume of a bottle

/datum/freight_type/single/reagent/New( var/datum/reagent/medicine, var/amount )
	if ( medicine )
		reagent_type = medicine

	if ( amount )
		target = amount

	set_item_name()

/datum/freight_type/single/reagent/set_item_name()
	var/datum/reagent/R = new reagent_type()
	item_name = R.name
	return TRUE

/datum/freight_type/single/reagent/check_contents( var/datum/freight_type_check/freight_type_check )
	var/list/prepackagedTargets = get_prepackaged_targets( freight_type_check.container )
	if ( prepackagedTargets )
		return prepackagedTargets

	if ( !allow_replacements )
		return FALSE

	if ( istype( src, /datum/freight_type/single/reagent/blood ) ) // Run the actual blood type check please thank you
		return FALSE

	var/datum/freight_contents_index/index = new /datum/freight_contents_index()

	for ( var/obj/item/reagent_containers/a in freight_type_check.container.GetAllContents() )
		if ( is_type_in_list( a, containers ) )
			var/datum/reagents/reagents = a.reagents
			for ( var/datum/reagent/R in reagents.reagent_list )
				if ( istype( R, reagent_type ) )
					// Add to contents index for more checks
					index.add_amount( a, R.volume, R.type )

	var/list/itemTargets = index.get_amount( reagent_type, target, TRUE )
	itemTargets = add_inner_contents_as_approved( itemTargets )

	if ( length( itemTargets ) )
		return itemTargets

	return FALSE

/datum/freight_type/single/reagent/get_brief_segment()
	return "[item_name ? item_name : reagent_type] ([target] unit" + (target!=1?"s":"") + ")"

/datum/freight_type/single/reagent/get_supply_request_form_segment()
	return "<span>permissible containers: most reagent containers</span><br>"
