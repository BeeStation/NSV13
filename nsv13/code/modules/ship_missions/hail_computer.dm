
// This lets you view a history of sent hails and active missions

/datum/computer_file/program/ship_hail_logger
  filename = "hailhistory"
  filedesc = "Ship Hail Monitor"
  ui_header = "smmon_0.gif"
  program_icon_state = "smmon_0"
  extended_desc = "This program records outbound and inbound hails. Can also keep a track of missions undertaken by the crew."
  requires_ntnet = TRUE
  usage_flags = PROGRAM_CONSOLE
  size = 4
  tgui_id = "NtosHailLogs"
  ui_x = 550
  ui_y = 650
  var/obj/var/obj/structure/overmap/ship //Our ship

/datum/computer_file/program/ship_hail_logger/run_program(mob/living/user)
  . = ..(user)
  ship = user.get_overmap()

/datum/computer_file/program/ship_hail_logger/process_tick()
	..()
  
/datum/computer_file/program/ship_hail_logger/proc/prep_missions()
  var/list/results = list()
  // TODO: custom message for no active missions?
  for(var/datum/nsv_mission/mission as() in ship.missions)
    results[++results.len] = list("desc" = mission.desc, "status" = mission.stage, "client" = mission.the_client.name)
  return results


/datum/computer_file/program/ship_hail_logger/ui_data()
  var/list/data = get_header_data()
  data["ship_name"] = ship.name
  data["missions"] = prep_missions()
  return data

/datum/computer_file/program/ship_hail_logger/ui_act(action, params)
	if(..())
		return TRUE
