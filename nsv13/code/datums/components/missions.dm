
// Trackers for when player ships arrive/leave a system
/datum/component/nsv_mission_arrival_in_system/Initialize()
  RegisterSignal(parent, COMSIG_SHIP_ARRIVED, .proc/activate_missions)

/datum/component/nsv_mission_arrival_in_system/proc/activate_missions()
  message_admins("activate_missions")
  var/obj/structure/overmap/ship = parent
  for(var/datum/nsv_mission/M in ship.current_system.active_missions)
    if(M.owner == ship)
      M.arrive()


/datum/component/nsv_mission_departure_from_system/Initialize()
  RegisterSignal(parent, COMSIG_SHIP_DEPARTED, .proc/deactivate_missions)


/datum/component/nsv_mission_departure_from_system/proc/deactivate_missions()
  message_admins("deactivate_missions")
  var/obj/structure/overmap/ship = parent
  for(var/datum/nsv_mission/M in ship.current_system.active_missions)
    if(M.owner == ship)
      M.depart()


// Reports the death of a ship to kill ship missions TODO: this is not applied to launched fighters it seems.
/datum/component/nsv_mission_killships/Initialize()
  RegisterSignal(parent, COMSIG_SHIP_KILLED, .proc/report_kill)

/datum/component/nsv_mission_killships/proc/report_kill()
  var/obj/structure/overmap/ship = parent
  for(var/datum/nsv_mission/kill_ships/KS in ship.current_system.active_missions)
    KS.report_kill(ship)


// Keeps an eye on cargo that is part of an objective

/datum/component/nsv_mission_cargo/
  var/datum/nsv_mission/cargo/parent_mission
  var/cargo_state = CARGO_INTACT
  var/cargo_value = 500

/datum/component/nsv_mission_cargo/Initialize()
  RegisterSignal(parent, COMSIG_CARGO_DELIVERED, .proc/deliver_cargo)
  RegisterSignal(parent, COMSIG_CARGO_REGISTER, .proc/register_cargo)
  RegisterSignal(parent, COMSIG_CARGO_TAMPERED, .proc/cargo_tampered)
  RegisterSignal(parent, COMSIG_PARENT_QDELETING , .proc/cargo_destroyed) // Called just before Destroy()

  
/datum/component/nsv_mission_cargo/proc/register_cargo(datum/source, datum/mission) // Set the mission we are attached to
  parent_mission = mission
  parent_mission.tracked_cargo += source

/datum/component/nsv_mission_cargo/proc/deliver_cargo()
  parent_mission.deliver_cargo(src)

  
/datum/component/nsv_mission_cargo/proc/cargo_tampered()
  message_admins("Cargo was tampered with! [parent]")
  cargo_state = CARGO_TAMPERED
  parent_mission.report_tampered_cargo(src)


/datum/component/nsv_mission_cargo/proc/cargo_destroyed()
  if(parent_mission.stage != MISSION_ACTIVE)
    return
  parent_mission.report_destroyed_cargo(src)


