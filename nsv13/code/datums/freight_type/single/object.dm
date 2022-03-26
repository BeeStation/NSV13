// Handheld item type objectives

/datum/freight_type/single/object
	target = 1

/datum/freight_type/single/object/New( var/obj/object, var/number )
	// Object should be initialized
	if ( object )
		item_type = object

	if ( number )
		target = number

	set_item_name()

/datum/freight_type/single/object/get_item_targets( var/datum/freight_type_check/freight_type_check )
	message_admins( "/datum/freight_type/single/object/get_item_targets" )
	var/datum/freight_contents_index/index = new /datum/freight_contents_index()

	for ( var/atom/a in freight_type_check.container.GetAllContents() )
		if( !is_type_in_typecache( a, GLOB.blacklisted_paperwork_itemtypes ) || ( is_type_in_typecache( item_type, GLOB.blacklisted_paperwork_itemtypes ) && is_type_in_typecache( a, GLOB.blacklisted_paperwork_itemtypes ) ) )
			if( istype( a, item_type ) )
				// Add to contents index for more checks
				index.add_amount( a, 1 )

	message_admins( index.get_amount( item_type, target, TRUE ) )
	message_admins( "length: [length( index.get_amount( item_type, target, TRUE ) ) ] [ADMIN_VV( index.get_amount( item_type, target, TRUE ) ) ]" )
	return index.get_amount( item_type, target, TRUE )

/datum/freight_type/single/object/get_brief_segment()
	return (target==1?"[item_name]":"[item_name] ([target] items)")
