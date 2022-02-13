/datum/freight_type/single/object/credits
	item_type = /obj/item/holochip
	target = 1
	var/credits = 10000

/datum/freight_type/single/object/credits/New( var/number )
	if ( number )
		credits = number

	item_name = "[credits] credit holochip"

/datum/freight_type/single/object/credits/add_item_to_crate( var/obj/C )
	var/obj/item/holochip/newitem = new item_type( C )
	newitem.credits = credits // Preset value for possible prepackage transfer objectives
	newitem.name = "\improper [credits] credit transfer holochip" // Hopefully fixes cargo crate description fubar
	return newitem

/datum/freight_type/single/object/credits/check_contents( var/datum/freight_type_check )
	var/list/prepackagedTargets = get_prepackaged_targets()
	if ( prepackagedTargets )
		return prepackagedTargets

	if ( !allow_replacements )
		return FALSE

	var/datum/freight_contents_index/index = new /datum/freight_contents_index()

	for ( var/obj/item/holochip/a in freight_type_check.container.GetAllContents() )
		if( !is_type_in_typecache( a, GLOB.blacklisted_paperwork_itemtypes ) || ( is_type_in_typecache( item_type, GLOB.blacklisted_paperwork_itemtypes ) && is_type_in_typecache( a, GLOB.blacklisted_paperwork_itemtypes ) ) )
			if( istype( a, item_type ) )
				// Add to contents index for more checks
				index.add_amount( a, a.credits )

	var/list/itemTargets = index.get_amount( item_type, target, TRUE )
	add_inner_contents_as_approved( itemTargets )

	if ( length( itemTargets ) )
		freight_type_check.untracked_contents -= itemTargets
		freight_type_check.approved_contents += itemTargets
		return itemTargets

	return FALSE

/datum/freight_type/single/object/credits/get_brief_segment()
	return "[credits] credit" + (target!=1?"s":"")
