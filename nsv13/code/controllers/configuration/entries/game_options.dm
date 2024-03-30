/datum/config_entry/flag/widescreen

/datum/config_entry/flag/show_ranks // Do we display rank with people's names?
/datum/config_entry/string/rank_file // Text file to read ranks from


/datum/config_entry/string/alert_zebra_downto
	config_entry_value = "The station's destruction has been averted. There is still however an immediate serious threat to the station. Security may have weapons unholstered at all times, random searches are allowed and advised."

/datum/config_entry/string/alert_zebra_upto
	config_entry_value = "Attention all hands assume defense condition zebra. Compartmental interlocks have now been activated, prepare for incoming fire."

/datum/config_entry/number/min_pop_kill_objectives
	config_entry_value = 15
	min_val = 0

/datum/config_entry/keyed_list/omode_probability
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM

/datum/config_entry/keyed_list/omode_max_pop
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM

/datum/config_entry/keyed_list/omode_min_pop
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM
