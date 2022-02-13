/datum/freight_type/object/credits
	item_type = /obj/item/holochip
	target = 1
	var/credits = 10000

/datum/freight_type/object/credits/New( var/number )
	if ( number )
		credits = number

	item_name = "[credits] credit holochip"

/datum/freight_type/object/credits/add_item_to_crate( var/obj/C )
	var/obj/item/holochip/newitem = new item_type( C )
	newitem.credits = credits // Preset value for possible prepackage transfer objectives
	newitem.name = "\improper [credits] credit transfer holochip" // Hopefully fixes cargo crate description fubar
	return newitem

/datum/freight_type/object/credits/check_contents( var/obj/container )
	var/list/prepackagedTargets = ..()
	if ( prepackagedTargets )
		return prepackagedTargets

	if ( !allow_replacements )
		return FALSE

	var/datum/freight_contents_index/index = new /datum/freight_contents_index()

	for ( var/obj/item/holochip/a in container.GetAllContents() )
		if( !is_type_in_typecache( a, GLOB.blacklisted_paperwork_itemtypes ) || ( is_type_in_typecache( item_type, GLOB.blacklisted_paperwork_itemtypes ) && is_type_in_typecache( a, GLOB.blacklisted_paperwork_itemtypes ) ) )
			if( istype( a, item_type ) )
				// Add to contents index for more checks
				index.add_amount( a, a.credits )

	var/list/itemTargets = index.get_amount( item_type, target, TRUE )
	add_inner_contents_additional_packaging( itemTargets )
	return itemTargets

/datum/freight_type/object/credits/get_brief_segment()
	return "[credits] credit" + (target!=1?"s":"")
