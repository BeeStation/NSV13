// A list of all the special byond lists that need to be handled different by vv
GLOBAL_LIST_INIT(vv_special_lists, init_special_list_names())

/proc/init_special_list_names()
	var/list/output = list()
	var/obj/sacrifice = new
	for(var/varname in sacrifice.vars)
		var/value = sacrifice.vars[varname]
		if(!islist(value))
			if(!isdatum(value) && hascall(value, "Cut"))
				output += varname
			continue
		if(isnull(locate(REF(value))))
			output += varname
	return output

GLOBAL_LIST_INIT(color_vars, list("color"))
