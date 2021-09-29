
// /proc/recursive_locate( the item we are looking for, the item we're checking in )

/proc/recursive_locate( var/atom/item, var/atom/target )
	var/found
	if ( target.contents )
		found = ( locate( item ) in target.contents )
	
		// If one of the items in contents is the item we're looking for, return it regardless of if it also has contents 
		if ( found )
			return found 
		else 
			for ( var/atom/i in target.contents )
				found = recursive_locate( item, i )
				if ( found )
					break 

	return found 
