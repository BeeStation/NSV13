 /*
What are the archived variables for?
	Calculations are done using the archived variables with the results merged into the regular variables.
	This prevents race conditions that arise based on the order of tile processing.
*/
#define MINIMUM_HEAT_CAPACITY	0.0003
#define MINIMUM_MOLE_COUNT		0.01
#define QUANTIZE(variable)		(round(variable,0.0000001))/*I feel the need to document what happens here. Basically this is used to catch most rounding errors, however it's previous value made it so that
															once gases got hot enough, most procedures wouldnt occur due to the fact that the mole counts would get rounded away. Thus, we lowered it a few orders of magnititude */

/datum/gas_mixture
	/// Never ever set this variable, hooked into vv_get_var for view variables viewing.
	var/gas_list_view_only
	var/initial_volume = CELL_VOLUME //liters
	var/list/reaction_results
	var/list/analyzer_results //used for analyzer feedback - not initialized until its used
	var/_extools_pointer_gasmixture // Contains the index in the gas vector for this gas mixture in rust land. Don't. Touch. This. Var.

GLOBAL_LIST_INIT(auxtools_atmos_initialized, FALSE)

/proc/auxtools_atmos_init(gas_data)
	return LIBCALL(AUXMOS, "byond:hook_init_ffi")(gas_data)

/datum/gas_mixture/New(volume)
	if (!isnull(volume))
		initial_volume = volume
	AUXTOOLS_CHECK(AUXMOS)
	if(!GLOB.auxtools_atmos_initialized && auxtools_atmos_init(GLOB.gas_data))
		GLOB.auxtools_atmos_initialized = TRUE
	__gasmixture_register()
	reaction_results = new

/*
we use a hook instead
/datum/gas_mixture/Del()
	__gasmixture_unregister()
	. = ..()
*/

/datum/gas_mixture/vv_edit_var(var_name, var_value)
	if(var_name == NAMEOF(src, _extools_pointer_gasmixture))
		return FALSE // please no. segfaults bad.
	if(var_name == NAMEOF(src, gas_list_view_only))
		return FALSE
	return ..()

/datum/gas_mixture/vv_get_var(var_name)
	. = ..()
	if(var_name == NAMEOF(src, gas_list_view_only))
		var/list/dummy = get_gases()
		for(var/gas in dummy)
			dummy[gas] = get_moles(gas)
			dummy["CAP [gas]"] = partial_heat_capacity(gas)
		dummy["TEMP"] = return_temperature()
		dummy["PRESSURE"] = return_pressure()
		dummy["HEAT CAPACITY"] = heat_capacity()
		dummy["TOTAL MOLES"] = total_moles()
		dummy["VOLUME"] = return_volume()
		dummy["THERMAL ENERGY"] = thermal_energy()
		return debug_variable("gases (READ ONLY)", dummy, 0, src)

/datum/gas_mixture/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "---")
	VV_DROPDOWN_OPTION(VV_HK_PARSE_GASSTRING, "Parse Gas String")
	VV_DROPDOWN_OPTION(VV_HK_EMPTY, "Empty")
	VV_DROPDOWN_OPTION(VV_HK_SET_MOLES, "Set Moles")
	VV_DROPDOWN_OPTION(VV_HK_SET_TEMPERATURE, "Set Temperature")
	VV_DROPDOWN_OPTION(VV_HK_SET_VOLUME, "Set Volume")

/datum/gas_mixture/vv_do_topic(list/href_list)
	. = ..()
	if(!.)
		return
	if(href_list[VV_HK_PARSE_GASSTRING])
		var/gasstring = input(usr, "Input Gas String (WARNING: Advanced. Don't use this unless you know how these work.", "Gas String Parse") as text|null
		if(!istext(gasstring))
			return
		log_admin("[key_name(usr)] modified gas mixture [REF(src)]: Set to gas string [gasstring].")
		message_admins("[key_name(usr)] modified gas mixture [REF(src)]: Set to gas string [gasstring].")
		parse_gas_string(gasstring)
	if(href_list[VV_HK_EMPTY])
		log_admin("[key_name(usr)] emptied gas mixture [REF(src)].")
		message_admins("[key_name(usr)] emptied gas mixture [REF(src)].")
		clear()
	if(href_list[VV_HK_SET_MOLES])
		var/list/gases = get_gases()
		for(var/gas in gases)
			gases[gas] = get_moles(gas)
		var/gasid = input(usr, "What kind of gas?", "Set Gas") as null|anything in GLOB.gas_data.ids
		if(!gasid)
			return
		var/amount = input(usr, "Input amount", "Set Gas", gases[gasid] || 0) as num|null
		if(!isnum(amount))
			return
		amount = max(0, amount)
		log_admin("[key_name(usr)] modified gas mixture [REF(src)]: Set gas [gasid] to [amount] moles.")
		message_admins("[key_name(usr)] modified gas mixture [REF(src)]: Set gas [gasid] to [amount] moles.")
		set_moles(gasid, amount)
	if(href_list[VV_HK_SET_TEMPERATURE])
		var/temp = input(usr, "Set the temperature of this mixture to?", "Set Temperature", return_temperature()) as num|null
		if(!isnum(temp))
			return
		temp = max(2.7, temp)
		log_admin("[key_name(usr)] modified gas mixture [REF(src)]: Changed temperature to [temp].")
		message_admins("[key_name(usr)] modified gas mixture [REF(src)]: Changed temperature to [temp].")
		set_temperature(temp)
	if(href_list[VV_HK_SET_VOLUME])
		var/volume = input(usr, "Set the volume of this mixture to?", "Set Volume", return_volume()) as num|null
		if(!isnum(volume))
			return
		volume = max(0, volume)
		log_admin("[key_name(usr)] modified gas mixture [REF(src)]: Changed volume to [volume].")
		message_admins("[key_name(usr)] modified gas mixture [REF(src)]: Changed volume to [volume].")
		set_volume(volume)

/datum/gas_mixture/proc/__gasmixture_unregister()
	return LIBCALL(AUXMOS, "byond:unregister_gasmixture_hook_ffi")(src)

/datum/gas_mixture/proc/__gasmixture_register()
	return LIBCALL(AUXMOS, "byond:register_gasmixture_hook_ffi")(src)

/proc/gas_types()
	var/list/L = subtypesof(/datum/gas)
	for(var/gt in L)
		var/datum/gas/G = gt
		L[gt] = initial(G.specific_heat)
	return L

/datum/gas_mixture/proc/heat_capacity() //joules per kelvin
	return LIBCALL(AUXMOS, "byond:heat_cap_hook_ffi")(src)

/datum/gas_mixture/proc/partial_heat_capacity(gas_id)
	return LIBCALL(AUXMOS, "byond:partial_heat_capacity_ffi")(src, gas_id)

/datum/gas_mixture/proc/total_moles()
	return LIBCALL(AUXMOS, "byond:total_moles_hook_ffi")(src)

/datum/gas_mixture/proc/return_pressure() //kilopascals
	return LIBCALL(AUXMOS, "byond:return_pressure_hook_ffi")(src)

/datum/gas_mixture/proc/return_temperature() //kelvins
	return LIBCALL(AUXMOS, "byond:return_temperature_hook_ffi")(src)

/datum/gas_mixture/proc/set_min_heat_capacity(arg_min)
	return LIBCALL(AUXMOS, "byond:min_heat_cap_hook_ffi")(src, arg_min)

/datum/gas_mixture/proc/set_temperature(arg_temp)
	return LIBCALL(AUXMOS, "byond:set_temperature_hook_ffi")(src, arg_temp)

/datum/gas_mixture/proc/set_volume(vol_arg)
	return LIBCALL(AUXMOS, "byond:set_volume_hook_ffi")(src, vol_arg)

/datum/gas_mixture/proc/get_moles(gas_id)
	return LIBCALL(AUXMOS, "byond:get_moles_hook_ffi")(src, gas_id)

/datum/gas_mixture/proc/get_by_flag(flag_val)
	return LIBCALL(AUXMOS, "byond:get_by_flag_hook_ffi")(src, flag_val)

/datum/gas_mixture/proc/set_moles(gas_id, amt_val)
	return LIBCALL(AUXMOS, "byond:set_moles_hook_ffi")(src, gas_id, amt_val)

/datum/gas_mixture/proc/scrub_into(into, ratio_v, gas_list)
	return LIBCALL(AUXMOS, "byond:scrub_into_hook_ffi")(src, into, ratio_v, gas_list)

/datum/gas_mixture/proc/mark_immutable()
	return LIBCALL(AUXMOS, "byond:mark_immutable_hook_ffi")(src)

/datum/gas_mixture/proc/get_gases()
	return LIBCALL(AUXMOS, "byond:get_gases_hook_ffi")(src)

/datum/gas_mixture/proc/add(num_val)
	return LIBCALL(AUXMOS, "byond:add_hook_ffi")(src, num_val)

/datum/gas_mixture/proc/subtract(num_val)
	return LIBCALL(AUXMOS, "byond:subtract_hook_ffi")(src, num_val)

/datum/gas_mixture/proc/multiply(num_val)
	return LIBCALL(AUXMOS, "byond:multiply_hook_ffi")(src, num_val)

/datum/gas_mixture/proc/divide(num_val)
	return LIBCALL(AUXMOS, "byond:divide_hook_ffi")(src, num_val)

/datum/gas_mixture/proc/get_last_share()

/datum/gas_mixture/proc/clear()
	return LIBCALL(AUXMOS, "byond:clear_hook_ffi")(src)

/datum/gas_mixture/proc/adjust_moles(id_val, num_val)
	return LIBCALL(AUXMOS, "byond:adjust_moles_hook_ffi")(src, id_val, num_val)

/datum/gas_mixture/proc/adjust_moles_temp(id_val, num_val, temp_val)
	return LIBCALL(AUXMOS, "byond:adjust_moles_temp_hook_ffi")(src, id_val, num_val, temp_val)

/datum/gas_mixture/proc/adjust_multi(...)
	var/list/args_copy = args.Copy()
	args_copy.Insert(1, src)
	return LIBCALL(AUXMOS, "byond:adjust_multi_hook_ffi")(arglist(args_copy))

/datum/gas_mixture/proc/return_volume() //liters
	return LIBCALL(AUXMOS, "byond:return_volume_hook_ffi")(src)

/datum/gas_mixture/proc/thermal_energy() //joules
	return LIBCALL(AUXMOS, "byond:thermal_energy_hook_ffi")(src)

/datum/gas_mixture/proc/archive()
	//Update archived versions of variables
	//Returns: 1 in all cases

/datum/gas_mixture/proc/merge(giver)
	//Merges all air from giver into self. Does NOT delete the giver.
	//Returns: 1 if we are mutable, 0 otherwise
	return LIBCALL(AUXMOS, "byond:merge_hook_ffi")(src, giver)

/datum/gas_mixture/proc/remove(amount)
	//Proportionally removes amount of gas from the gas_mixture
	//Returns: gas_mixture with the gases removed

/datum/gas_mixture/proc/remove_by_flag(flag, amount)
	//Removes amount of gas from the gas mixture by flag
	//Returns: gas_mixture with gases that match the flag removed

/datum/gas_mixture/proc/transfer_to(other, moles)
	return LIBCALL(AUXMOS, "byond:transfer_hook_ffi")(src, other, moles)

/datum/gas_mixture/proc/transfer_ratio_to(other, ratio)
	//Transfers ratio of gas to target. Equivalent to target.merge(remove_ratio(amount)) but faster.
	return LIBCALL(AUXMOS, "byond:transfer_ratio_hook_ffi")(src, other, ratio)

/datum/gas_mixture/proc/remove_ratio(ratio)
	//Proportionally removes amount of gas from the gas_mixture
	//Returns: gas_mixture with the gases removed

/datum/gas_mixture/proc/copy()
	//Creates new, identical gas mixture
	//Returns: duplicate gas mixture

/datum/gas_mixture/proc/copy_from(giver)
	//Copies variables from sample
	//Returns: 1 if we are mutable, 0 otherwise
	return LIBCALL(AUXMOS, "byond:copy_from_hook_ffi")(src, giver)

/datum/gas_mixture/proc/copy_from_turf(turf/model)
	//Copies all gas info from the turf into the gas list along with temperature
	//Returns: 1 if we are mutable, 0 otherwise

/datum/gas_mixture/proc/parse_gas_string(gas_string)
	//Copies variables from a particularly formatted string.
	//Returns: 1 if we are mutable, 0 otherwise

/datum/gas_mixture/proc/share(datum/gas_mixture/sharer)
	//Performs air sharing calculations between two gas_mixtures assuming only 1 boundary length
	//Returns: amount of gas exchanged (+ if sharer received)

/datum/gas_mixture/proc/temperature_share(...)
	//Performs temperature sharing calculations (via conduction) between two gas_mixtures assuming only 1 boundary length
	//Returns: new temperature of the sharer
	var/list/args_copy = args.Copy()
	args_copy.Insert(1, src)
	return LIBCALL(AUXMOS, "byond:temperature_share_hook_ffi")(arglist(args_copy))

/datum/gas_mixture/proc/compare(other)
	//Compares sample to self to see if within acceptable ranges that group processing may be enabled
	//Returns: a string indicating what check failed, or "" if check passes
	return LIBCALL(AUXMOS, "byond:compare_hook_ffi")(src, other)

/datum/gas_mixture/proc/react(holder)
	//Performs various reactions such as combustion or fusion (LOL)
	//Returns: 1 if any reaction took place; 0 otherwise
	return LIBCALL(AUXMOS, "byond:react_hook_ffi")(src, holder)

/datum/gas_mixture/proc/adjust_heat(temp)
	//Adjusts the thermal energy of the gas mixture, rather than having to do the full calculation.
	//Returns: null
	return LIBCALL(AUXMOS, "byond:adjust_heat_hook_ffi")(src, temp)

/datum/gas_mixture/proc/equalize_with(total)
	//Makes this mix have the same temperature and gas ratios as the giver, but with the same pressure, accounting for volume.
	//Returns: null
	return LIBCALL(AUXMOS, "byond:equalize_with_hook_ffi")(src, total)

/datum/gas_mixture/proc/get_oxidation_power(temp)
	//Gets how much oxidation this gas can do, optionally at a given temperature.
	return LIBCALL(AUXMOS, "byond:oxidation_power_hook_ffi")(src, temp)

/datum/gas_mixture/proc/get_fuel_amount(temp)
	//Gets how much fuel for fires (not counting trit/plasma!) this gas has, optionally at a given temperature.
	return LIBCALL(AUXMOS, "byond:fuel_amount_hook_ffi")(src, temp)

/proc/equalize_all_gases_in_list(gas_list)
	//Makes every gas in the given list have the same pressure, temperature and gas proportions.
	//Returns: null
	return LIBCALL(AUXMOS, "byond:equalize_all_hook_ffi")(gas_list)

/datum/gas_mixture/proc/__remove_by_flag(into, flag_val, amount_val)
	return LIBCALL(AUXMOS, "byond:remove_by_flag_hook_ffi")(src, into, flag_val, amount_val)

/datum/gas_mixture/remove_by_flag(flag, amount)
	var/datum/gas_mixture/removed = new type
	__remove_by_flag(removed, flag, amount)

	return removed

/datum/gas_mixture/proc/__remove(into, amount_arg)
	return LIBCALL(AUXMOS, "byond:remove_hook_ffi")(src, into, amount_arg)

/datum/gas_mixture/remove(amount)
	var/datum/gas_mixture/removed = new type
	__remove(removed, amount)

	return removed

/datum/gas_mixture/proc/__remove_ratio(into, ratio_arg)
	return LIBCALL(AUXMOS, "byond:remove_ratio_hook_ffi")(src, into, ratio_arg)

/datum/gas_mixture/remove_ratio(ratio)
	var/datum/gas_mixture/removed = new type
	__remove_ratio(removed, ratio)

	return removed

/datum/gas_mixture/copy()
	var/datum/gas_mixture/copy = new type
	copy.copy_from(src)

	return copy

/datum/gas_mixture/copy_from_turf(turf/model)
	set_temperature(initial(model.initial_temperature))
	parse_gas_string(model.initial_gas_mix)
	return 1

/datum/gas_mixture/proc/__auxtools_parse_gas_string(string)
	return LIBCALL(AUXMOS, "byond:parse_gas_string_ffi")(src, string)

/datum/gas_mixture/parse_gas_string(gas_string)
	return __auxtools_parse_gas_string(gas_string)
	/*
	var/list/gas = params2list(gas_string)
	if(gas["TEMP"])
		var/temp = text2num(gas["TEMP"])
		gas -= "TEMP"
		if(!isnum(temp) || temp < 2.7)
			temp = 2.7
		set_temperature(temp)
	clear()
	for(var/id in gas)
		set_moles(id, text2num(gas[id]))
	*/

/datum/gas_mixture/proc/set_analyzer_results(instability)
	if(!analyzer_results)
		analyzer_results = new
	analyzer_results["fusion"] = instability

//Mathematical proofs:
/*
get_breath_partial_pressure(gas_pp) --> gas_pp/total_moles()*breath_pp = pp
get_true_breath_pressure(pp) --> gas_pp = pp/breath_pp*total_moles()

10/20*5 = 2.5
10 = 2.5/5*20
*/

/datum/gas_mixture/turf

/// Releases gas from src to output air. This means that it can not transfer air to gas mixture with higher pressure.
/datum/gas_mixture/proc/release_gas_to(datum/gas_mixture/output_air, target_pressure)
	var/output_starting_pressure = output_air.return_pressure()
	var/input_starting_pressure = return_pressure()

	if(output_starting_pressure >= min(target_pressure,input_starting_pressure-10))
		//No need to pump gas if target is already reached or input pressure is too low
		//Need at least 10 kPa difference to overcome friction in the mechanism
		return FALSE

	//Calculate necessary moles to transfer using PV = nRT
	if((total_moles() > 0) && (return_temperature()>0))
		var/pressure_delta = min(target_pressure - output_starting_pressure, (input_starting_pressure - output_starting_pressure)/2)
		//Can not have a pressure delta that would cause output_pressure > input_pressure

		var/transfer_moles = pressure_delta*output_air.return_volume()/(return_temperature() * R_IDEAL_GAS_EQUATION)

		//Actually transfer the gas
		var/datum/gas_mixture/removed = remove(transfer_moles)
		output_air.merge(removed)
		return TRUE
	return FALSE

/datum/gas_mixture/proc/vv_react(datum/holder)
	return react(holder)
