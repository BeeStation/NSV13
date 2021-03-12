
// This lets you view a history of sent hails and active missions

/datum/computer_file/program/ship_hail_logger
  filename = "hailhistory"
  filedesc = "Ship Hail Monitor"
  ui_header = "ntnrc_idle.gif"
  program_icon_state = "generic"
  extended_desc = "This program records outbound and inbound hails. Can also keep a track of missions undertaken by the crew."
  requires_ntnet = FALSE
  usage_flags = PROGRAM_ALL
  size = 4
  tgui_id = "NtosHailLogs"
  var/obj/var/obj/structure/overmap/ship //Our ship

/datum/computer_file/program/ship_hail_logger/run_program(mob/living/user)
  . = ..(user)
  ship = user.get_overmap()

/datum/computer_file/program/ship_hail_logger/process_tick()
	..()

/datum/computer_file/program/ship_hail_logger/proc/prep_missions()
  var/list/results = list()
  if(!ship)
    return results
  for(var/m in ship.missions)
    var/datum/nsv_mission/mission = m
    results[++results.len] = list("desc" = mission.desc, "status" = mission.stage, "client" = mission.the_client ? mission.the_client.name : "Corrupted data", "reward" = mission.reward_string())
  return results


/datum/computer_file/program/ship_hail_logger/ui_data()
  var/list/data = get_header_data()
  data["ship_name"] = ship ? ship.name : "No ship detected!"
  data["missions"] = prep_missions()
  return data

/datum/computer_file/program/ship_hail_logger/ui_act(action, params)
	if(..())
		return TRUE
