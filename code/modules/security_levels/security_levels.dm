GLOBAL_VAR_INIT(security_level, SEC_LEVEL_GREEN)
//SEC_LEVEL_GREEN = code green
//SEC_LEVEL_BLUE = code blue
//SEC_LEVEL_RED = code red
//SEC_LEVEL_DELTA = code delta

//config.alert_desc_blue_downto

/proc/set_security_level(level)
	switch(level)
		if("green")
			level = SEC_LEVEL_GREEN
		if("blue")
			level = SEC_LEVEL_BLUE
		if("red")
			level = SEC_LEVEL_RED
		if("zebra")
			level = SEC_LEVEL_ZEBRA
		if("delta")
			level = SEC_LEVEL_DELTA

	//Will not be announced if you try to set to the same level as it already is
	//Nsv13 - This entire proc has been fucked with to add gq_announce and condition zebra.
	if(level >= SEC_LEVEL_GREEN && level <= SEC_LEVEL_DELTA && level != GLOB.security_level)
		switch(level)
			if(SEC_LEVEL_GREEN)
				minor_announce(CONFIG_GET(string/alert_green), "Engage Relaxed Operation")
				toggle_gq_lights(FALSE)
				if(SSshuttle.emergency.mode == SHUTTLE_CALL || SSshuttle.emergency.mode == SHUTTLE_RECALL)
					if(GLOB.security_level >= SEC_LEVEL_RED)
						SSshuttle.emergency.modTimer(4)
					else
						SSshuttle.emergency.modTimer(2)
				GLOB.security_level = SEC_LEVEL_GREEN
				for(var/obj/machinery/firealarm/FA in GLOB.machines)
					if(is_station_level(FA.z))
						FA.update_icon()
			if(SEC_LEVEL_BLUE)
				if(GLOB.security_level < SEC_LEVEL_BLUE)
					minor_announce(CONFIG_GET(string/alert_blue_upto), "Resume Standard Operation")//Nsv13 - Condition 1
					if(SSshuttle.emergency.mode == SHUTTLE_CALL || SSshuttle.emergency.mode == SHUTTLE_RECALL)
						SSshuttle.emergency.modTimer(0.5)
				else
					toggle_gq_lights(FALSE)
					minor_announce(CONFIG_GET(string/alert_blue_downto), "Stand Down General Quarters")
					if(SSshuttle.emergency.mode == SHUTTLE_CALL || SSshuttle.emergency.mode == SHUTTLE_RECALL)
						SSshuttle.emergency.modTimer(2)
				GLOB.security_level = SEC_LEVEL_BLUE
				for(var/obj/machinery/firealarm/FA in GLOB.machines)
					if(is_station_level(FA.z))
						FA.update_icon()
			if(SEC_LEVEL_RED)
				if(GLOB.security_level < SEC_LEVEL_RED)
					gq_announce(CONFIG_GET(string/alert_red_upto))//Nsv13 - Condition 1
					if(SSshuttle.emergency.mode == SHUTTLE_CALL || SSshuttle.emergency.mode == SHUTTLE_RECALL)
						if(GLOB.security_level == SEC_LEVEL_GREEN)
							SSshuttle.emergency.modTimer(0.25)
						else
							SSshuttle.emergency.modTimer(0.5)
				else
					gq_announce(CONFIG_GET(string/alert_red_downto)) //Nsv13 - Condition 1
				GLOB.security_level = SEC_LEVEL_RED
				toggle_gq_lights(TRUE)
				addtimer(CALLBACK(GLOBAL_PROC, .proc/toggle_gq_lights, FALSE), 45 SECONDS)

				for(var/obj/machinery/firealarm/FA in GLOB.machines)
					if(is_station_level(FA.z))
						FA.update_icon()
				for(var/obj/machinery/computer/shuttle/pod/pod in GLOB.machines)
					pod.admin_controlled = 0
			if(SEC_LEVEL_ZEBRA)
				if(GLOB.security_level < SEC_LEVEL_ZEBRA)
					gq_announce(CONFIG_GET(string/alert_zebra_upto), sound='nsv13/sound/effects/ship/condition_zebra.ogg')//Nsv13 - Condition Z
					if(SSshuttle.emergency.mode == SHUTTLE_CALL || SSshuttle.emergency.mode == SHUTTLE_RECALL)
						if(GLOB.security_level == SEC_LEVEL_GREEN)
							SSshuttle.emergency.modTimer(0.25)
						else
							SSshuttle.emergency.modTimer(0.5)
				else
					gq_announce(CONFIG_GET(string/alert_zebra_downto), sound='nsv13/sound/effects/ship/condition_zebra.ogg') //Nsv13 - Condition Z
				GLOB.security_level = SEC_LEVEL_ZEBRA
				toggle_gq_lights(TRUE)
				addtimer(CALLBACK(GLOBAL_PROC, .proc/toggle_gq_lights, FALSE), 30 SECONDS)

				for(var/obj/machinery/firealarm/FA in GLOB.machines)
					if(is_station_level(FA.z))
						FA.update_icon()
				for(var/obj/machinery/computer/shuttle/pod/pod in GLOB.machines)
					pod.admin_controlled = 0

			if(SEC_LEVEL_DELTA)
				minor_announce(CONFIG_GET(string/alert_delta), "Attention! Delta security level reached!",1)
				if(SSshuttle.emergency.mode == SHUTTLE_CALL || SSshuttle.emergency.mode == SHUTTLE_RECALL)
					if(GLOB.security_level == SEC_LEVEL_GREEN)
						SSshuttle.emergency.modTimer(0.25)
					else if(GLOB.security_level == SEC_LEVEL_BLUE)
						SSshuttle.emergency.modTimer(0.5)
				GLOB.security_level = SEC_LEVEL_DELTA
				for(var/obj/machinery/firealarm/FA in GLOB.machines)
					if(is_station_level(FA.z))
						FA.update_icon()
				for(var/obj/machinery/computer/shuttle/pod/pod in GLOB.machines)
					pod.admin_controlled = 0
		if(level >= SEC_LEVEL_RED)
			for(var/obj/machinery/door/D in GLOB.machines)
				if(D.red_alert_access)
					D.visible_message("<span class='notice'>[D] whirs as it automatically lifts access requirements!</span>")
					playsound(D, 'sound/machines/boltsup.ogg', 50, TRUE)
		SSblackbox.record_feedback("tally", "security_level_changes", 1, get_security_level())
		SEND_SIGNAL(SSblackbox, COMSIG_ALERT_LEVEL_CHANGE, GLOB.security_level)
		SSnightshift.check_nightshift()
		//NSv13 end
	else
		return
//Nsv13 - Changed this
/proc/get_security_level()
	switch(GLOB.security_level)
		if(SEC_LEVEL_GREEN)
			return "condition 3"
		if(SEC_LEVEL_BLUE)
			return "condition 2"
		if(SEC_LEVEL_RED)
			return "general quarters"
		if(SEC_LEVEL_ZEBRA)
			return "condition Z"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/num2seclevel(num)
	switch(num)
		if(SEC_LEVEL_GREEN)
			return "condition 3"
		if(SEC_LEVEL_BLUE)
			return "condition 2"
		if(SEC_LEVEL_RED)
			return "general quarters"
		if(SEC_LEVEL_ZEBRA)
			return "condition Z"
		if(SEC_LEVEL_DELTA)
			return "delta"

/proc/seclevel2num(seclevel)
	switch( lowertext(seclevel) )
		if("condition 3")
			return SEC_LEVEL_GREEN
		if("condition 2")
			return SEC_LEVEL_BLUE
		if("general quarters")
			return SEC_LEVEL_RED
		if("condition Z")
			return SEC_LEVEL_ZEBRA
		if("delta")
			return SEC_LEVEL_DELTA
