/*
Creating the mission datum has it in an untaken state

Once a crew takes a mission, the proc register() is ran, loading in the mission and any items they needs


*/

/datum/nsv_mission/
  var/name
  var/desc
  var/stage
  var/first_encounter = FALSE
  
  var/payout = 500
  
  var/obj/structure/overmap/owner // Which ship owns this mission
  
/datum/nsv_mission/proc/register()
  message_admins("spawn") 
  return TRUE
  
/datum/nsv_mission/proc/encounter() // Code to be ran when the players first arrive in the target system
  message_admins("encounter")
  
/datum/nsv_mission/proc/arrive() // If the ship arrives in the system, change the mission from idle to active
  message_admins("arrive")
  if(stage == MISSION_IDLE)
    stage = MISSION_ACTIVE
    if(!first_encounter)
      first_encounter = TRUE
      encounter()
  
/datum/nsv_mission/proc/depart()// If the ship departs the system, change the mission from active to idle
  message_admins("depart")
  if(stage == MISSION_ACTIVE)
    stage = MISSION_IDLE
      
/datum/nsv_mission/proc/check_completion()
  message_admins("check_completion")
  if(stage == MISSION_COMPLETE) 
    return TRUE // Completed missions are always complete
  if(stage != MISSION_ACTIVE) 
    return FALSE // If the mission is not active, it can not be completed
    
/datum/nsv_mission/proc/update_description()
  desc = "THIS IS A BUG AAAA"

  
//##############################################################################
//######### Combat objectives
//##############################################################################  


// Kill ships - Kill X ships owned by Y with no location requirement

/datum/nsv_mission/kill_ships
  name = "Ship bounty"

  var/ships_to_kill
  var/ships_remaining 
  var/target_faction = list("syndicate")
  var/target_size = MASS_SMALL // Prevents fighters from counting towards the objective
  var/max_threat_level = THREAT_LEVEL_UNSAFE  // If we assign systems, give them a break by not giving them objectives in dangerous systems

/datum/nsv_mission/kill_ships/register()
  ships_to_kill = rand(2,10)
  ships_remaining = ships_to_kill
  for(var/s in SSstar_system.systems)
    var/datum/star_system/system = s
    system.active_missions += src
  update_description()
  return TRUE
  
/datum/nsv_mission/kill_ships/check_completion()
  . = ..()
  if(ships_remaining <= 0)
    stage = MISSION_COMPLETE
    return TRUE
  return FALSE  

/datum/nsv_mission/kill_ships/proc/report_kill(var/obj/structure/overmap/ship)
  if(stage != MISSION_ACTIVE) 
    return 
  if(ship.mass < target_size) 
    return
  if(ship.current_system != owner.current_system) 
    return
  if(!ships_to_kill)
    return
  
  if(ship.faction in target_faction)
    ships_remaining --
    check_completion() 
    update_description()
    
/datum/nsv_mission/kill_ships/update_description()
  var/target_ship_string
  for(var/i in 1 to LAZYLEN(target_faction))
    if(i == 1)
      target_ship_string = capitalize(target_faction[i])
    else if(i == LAZYLEN(target_faction))
      target_ship_string += " or " + capitalize(target_faction[i])
    else
      target_ship_string += ", " + capitalize(target_faction[i])
    
  desc = "Destroy [ships_to_kill] [target_ship_string] ships. You have currently destroyed [ships_to_kill - ships_remaining] ships "
    
    
// Kill ships in system - Kill X ships owned by Y in specific systems

/datum/nsv_mission/kill_ships/system
  name = "System clearing"

  var/target_system = list()
  var/visited_systems = list()
  var/system_alignment = list("syndicate","unaligned") // Two lists for targets and systems so we can assign kill syndies in NT space

/datum/nsv_mission/kill_ships/system/register()
  ships_to_kill = rand(5,20)
  ships_remaining = ships_to_kill
  var/list/viable_systems = list()
  for(var/s in SSstar_system.systems)
    var/datum/star_system/system = s  
    if(system.threat_level > max_threat_level)
      continue
    if(system.alignment in system_alignment)
      viable_systems += system
        
  for(var/i in 1 to 1 + round(ships_remaining/5, 1)) // TODO:may double pick systems
    var/datum/star_system/chosen_system = pick(viable_systems)
    target_system += chosen_system
    viable_systems -= chosen_system
    chosen_system.active_missions += src
  update_description()
  return TRUE
  
  
/datum/nsv_mission/kill_ships/system/arrive() //TODO: Figure out a solution to going to an already cleared system
  . = ..()
  if(owner.current_system in visited_systems)
    return
  visited_systems += owner.current_system
  message_admins("[LAZYLEN(owner.current_system.enemies_in_system)]")
  if(LAZYLEN(owner.current_system.enemies_in_system) <= 2) // If the system is empty, add some more ships
    owner.current_system.spawn_enemies(null, 5)
  
/datum/nsv_mission/kill_ships/system/update_description()
  var/target_ship_string
  for(var/i in 1 to LAZYLEN(target_faction))
    if(i == 1)
      target_ship_string = capitalize(target_faction[i])
    else if(i == LAZYLEN(target_faction))
      target_ship_string += " or " + capitalize(target_faction[i])
    else
      target_ship_string += ", " + capitalize(target_faction[i])
      
  var/target_system_string
  for(var/i in 1 to LAZYLEN(target_system))
    if(i == 1)
      target_system_string = capitalize(target_system[i].name)
    else if(i == LAZYLEN(target_system))
      target_system_string += " or " + capitalize(target_system[i].name)
    else
      target_system_string += ", " + capitalize(target_system[i].name)
    
  desc = "Destroy [ships_to_kill] [target_ship_string] ships located in [target_system_string]. You have currently destroyed [ships_to_kill - ships_remaining] ships " 
  
  
// Wave hold - Destroy several waves of enemy ships
  
/datum/nsv_mission/kill_ships/waves
  name = "Hold system"
  
  var/total_waves
  var/waves_remaining
  var/datum/star_system/target_system
  

/datum/nsv_mission/kill_ships/waves/register()
  total_waves = rand(2,4)
  waves_remaining = total_waves
  var/list/viable_systems = list()
  for(var/s in SSstar_system.systems)
    var/datum/star_system/system = s
    if(system.threat_level > max_threat_level)
      continue
    if(system.alignment in target_faction)
      viable_systems += system
      
  target_system = pick(viable_systems)
  target_system.active_missions += src
  update_description()
  return TRUE
  
/datum/nsv_mission/kill_ships/waves/encounter()
  spawn_new_wave()

/datum/nsv_mission/kill_ships/waves/proc/spawn_new_wave()
  if(owner.current_system != target_system) //Safety check if they bail before the next wave spawns.
    return
  stage = MISSION_ACTIVE
  ships_to_kill = rand(3, 3 + total_waves - waves_remaining)
  ships_remaining = ships_to_kill
  owner.current_system.spawn_enemies(null,ships_to_kill)// TODO: this spawns fighters which don't count for the obejctive. have our own list of enemies?
  
/datum/nsv_mission/kill_ships/waves/check_completion()  
  if(stage == MISSION_COMPLETE) 
    return TRUE 
  if(stage != MISSION_ACTIVE) 
    return FALSE 
  if(ships_remaining <= 0)
    stage = MISSION_IDLE // Set to idle while we wait for the next wave to spawn
    waves_remaining --
    if(!waves_remaining)
      stage = MISSION_COMPLETE
      return TRUE
    else
      addtimer(CALLBACK(src, .proc/spawn_new_wave), rand(20,60) SECONDS)
  return FALSE    

/datum/nsv_mission/kill_ships/waves/depart() 
  message_admins("depart")
  if(stage == MISSION_COMPLETE)
    stage = MISSION_FAILED


/* ideasguys zone - TODO

Wave hold/station defend

kill single target
  kill station

*/    
    
    
//##############################################################################
//######### Cargo missions
//##############################################################################  

/datum/nsv_mission/cargo/
  var/list/tracked_cargo = list()
  var/delivered_cargo = 0
  var/tampered_cargo = 0
  var/lost_cargo = 0 
  
  var/total_cargo = 2 // How many crates the crew will have to deliver
  var/list/possible_crates = list(/obj/structure/closet/crate/large/cargo/random = 4) // Weighted list of possible crates
  
  var/max_payout = 500
  payout = 0
  
/datum/nsv_mission/cargo/register()
  message_admins("spawn cargo") 
  for(var/c in 1 to total_cargo)    
    var/chosen_cargo = pickweight(possible_crates)
    possible_crates[chosen_cargo]--
    spawn_crate(chosen_cargo)
  return TRUE
  
/datum/nsv_mission/cargo/proc/spawn_crate(var/chosen_cargo) // TODO improve with trader pr/ move this to nsv_mission so that we can spawn physical rewards in for the crew
  var/turf/open/o //temp code to spawn crates
  var/list/valid = list()
  for(var/area/bridge/b in GLOB.sortedAreas)
    for(var/turf/open/op in b.contents)
      valid += op
      
  o = pick(valid)
  var/obj/structure/closet/crate/large/cargo/crate = new chosen_cargo(o)
  for(var/atom/a in crate.contents)
    SEND_SIGNAL(a, COMSIG_CARGO_REGISTER, src)


/datum/nsv_mission/cargo/encounter() 
  message_admins("encounter")

/datum/nsv_mission/cargo/check_completion()
  . = ..()
  if(LAZYLEN(tracked_cargo))
    return FALSE//There is still cargo to deliver
    
    
  
/datum/nsv_mission/cargo/proc/deliver_cargo(var/datum/component/nsv_mission_cargo/cargo)  
  tracked_cargo -= cargo.parent
  switch(cargo.cargo_state)
    if(CARGO_INTACT)
      delivered_cargo++ 
    if(CARGO_TAMPERED)
      tampered_cargo++ 
    else 
      lost_cargo++
  payout = round(max_payout * (delivered_cargo /total_cargo ),0) + round(0.25 * max_payout * (tampered_cargo /total_cargo ),0)
  qdel(cargo)
  check_completion() 
  
/datum/nsv_mission/cargo/proc/report_destroyed_cargo(var/datum/component/nsv_mission_cargo/cargo)   
  tracked_cargo -= cargo.parent
  lost_cargo++
  check_completion() 
  
/datum/nsv_mission/cargo/proc/report_tampered_cargo(var/datum/component/nsv_mission_cargo/cargo) // We only count the cargo if delivered tampered. This is mostly a hook if you want tampers to be fails
  check_completion()
  
/* ideasguys zone - TODO

Move freight between stations
recover salvage
move "cargo"

*/    

    
//##############################################################################
//######### Admin missions
//##############################################################################  


// Custom - A blank objective for admins to create custom missions. They will not automatically process

/datum/nsv_mission/custom/
  desc = "A mission missing the correct paperwork to define what is required. Contact NT if you see this!"
  var/admin_hints = "Set stage to different things to mark progress. -1 is failed. 0 is idle and 2 is complete."

