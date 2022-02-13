/datum/freight_type/object/mineral
	target = 50

/datum/freight_type/object/mineral/check_contents( var/datum/freight_type_check )
	var/list/prepackagedTargets = get_prepackaged_targets()
	if ( prepackagedTargets )
		return prepackagedTargets

	if ( !allow_replacements )
		return FALSE

	var/datum/freight_contents_index/index = new /datum/freight_contents_index()

	for ( var/obj/item/stack/a in freight_type_check.container.GetAllContents() )
		if( !is_type_in_typecache( a, GLOB.blacklisted_paperwork_itemtypes ) || ( is_type_in_typecache( item_type, GLOB.blacklisted_paperwork_itemtypes ) && is_type_in_typecache( a, GLOB.blacklisted_paperwork_itemtypes ) ) )
			if( istype( a, item_type ) || ( length( prepackaged_items ) && recursive_loc_check( a, item_type ) ) )
				// Add to contents index for more checks
				index.add_amount( a, a.amount )

	var/list/itemTargets = index.get_amount( item_type, target, TRUE )
	add_inner_contents_as_approved( itemTargets )

	if ( length( itemTargets ) )
		freight_type_check.untracked_contents -= itemTargets
		freight_type_check.approved_contents += itemTargets
		return itemTargets

	return FALSE

/datum/freight_type/object/mineral/get_brief_segment()
	return "[item_name] ([target] sheet" + (target!=1?"s":"") + ")"
