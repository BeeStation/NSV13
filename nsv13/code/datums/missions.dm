/*
Creating the mission datum has it in an untaken state

Once a crew takes a mission, you must set the ship as the owner, done by setting owner to the overmap object that claimed the mission

The proc register() is then ran, loading in the mission and any items they needs. Most of the other stuff will be handled by signals

TODO: Cargo needs setting up with a proper delivery method

*/

/datum/nsv_mission/
  var/name
  var/mission_brief // A quick summary of what the mission is before the crew take it on
  var/desc // Used to relay the status of the mission
  var/stage
  var/first_encounter = FALSE

  var/payout = 2500

  var/obj/structure/overmap/owner // Which ship owns this mission

/datum/nsv_mission/New(owner)
  . = ..()
  if(!owner)
    return
  src.owner = owner
  SSstar_system.all_missions += src

/datum/nsv_mission/proc/register()
  return FALSE

/datum/nsv_mission/proc/encounter() // Code to be ran when the players first arrive in the target system
  return FALSE

/datum/nsv_mission/proc/arrive() // If the ship arrives in the system, change the mission from idle to active
  if(stage == MISSION_IDLE)
    stage = MISSION_ACTIVE
    if(!first_encounter)
      first_encounter = TRUE
      encounter()

/datum/nsv_mission/proc/depart()// If the ship departs the system, change the mission from active to idle
  if(stage == MISSION_ACTIVE)
    stage = MISSION_IDLE

/datum/nsv_mission/proc/check_completion()
  if(stage == MISSION_COMPLETE)
    payout()
    return TRUE // Completed missions are always complete
  if(stage != MISSION_ACTIVE)
    return FALSE // If the mission is not active, it can not be completed

/datum/nsv_mission/proc/payout()
  var/obj/item/holochip/money = owner.send_supplypod(/obj/item/holochip)
  money.credits = payout
  minor_announce("Bounty payout of $[payout] authorised for [owner]. Pre-loaded credit holochip will be delivered to the ship's cargo department. Have", "Galactic Trade Union")

/datum/nsv_mission/proc/send_item(contents, cargo = TRUE) // Send an item to the players.
  if(!contents)
    return FALSE
  var/area/landingzone = null
  if(owner.role == MAIN_OVERMAP)
    landingzone = GLOB.areas_by_type[/area/quartermaster/warehouse]
  else
    if(!owner.linked_areas.len)
      //owner = owner.last_overmap //Handles fighters going out and buying things on the ship's behalf TODO: uncomment when combined with overmap2
      if(!owner.linked_areas.len)
        return FALSE
    landingzone = pick(owner.linked_areas)
  var/list/empty_turfs = list()
  var/turf/LZ = null
  for(var/turf/open/floor/T in landingzone.contents)//uses default landing zone
    if(is_blocked_turf(T))
      continue
    if(empty_turfs.len >= 10)
      break //Don't bother finding any more.
    LAZYADD(empty_turfs, T)
    CHECK_TICK
  if(empty_turfs?.len)
    LZ = pick(empty_turfs)
  var/obj/structure/closet/supplypod/freight_pod/toLaunch = new /obj/structure/closet/supplypod/freight_pod
  var/shippingLane = GLOB.areas_by_type[/area/centcom/supplypod/flyMeToTheMoon]
  toLaunch.forceMove(shippingLane)
  var/atom/movable/theItem = new contents

  if(cargo) //if we are cargo, apply the flag to either ourselfs or our contents
    if(LAZYLEN(theItem.contents)) //If we have contents, the contents are the cargo
      for(var/atom/a in theItem.contents)
        SEND_SIGNAL(a, COMSIG_CARGO_REGISTER, src)
    else //Otherwise the item is
      SEND_SIGNAL(theItem, COMSIG_CARGO_REGISTER, src)

  theItem.forceMove(toLaunch)
  new /obj/effect/DPtarget(LZ, toLaunch)
  return TRUE

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
  var/list/target_faction = list("syndicate")
  var/list/target_size = list(MASS_SMALL, MASS_MEDIUM, MASS_LARGE, MASS_TITAN) // Prevents fighters from counting towards the objective
  var/max_threat_level = THREAT_LEVEL_UNSAFE  // If we assign systems, give them a break by not giving them objectives in dangerous systems
  var/list/target_factions = list(FACTION_ID_SYNDICATE, FACTION_ID_PIRATES)

/datum/nsv_mission/kill_ships/proc/targets_in_system()
  var/c = 0
  for(var/obj/structure/overmap/a in owner.current_system.system_contents)
    if(!target_faction.Find(a.faction))
      continue
    if(a.gc_destroyed) //Destroyed ships are not removed from system_contents. This lets me ignore the ones that are actually dead
      continue
    c++
  return c

/datum/nsv_mission/kill_ships/register()
  ships_to_kill = rand(2,10)
  ships_remaining = ships_to_kill
  for(var/s in SSstar_system.systems)
    var/datum/star_system/system = s
    system.active_missions += src
  stage = MISSION_ACTIVE
  payout = rand(payout, payout*2)
  update_description()
  return TRUE

/datum/nsv_mission/kill_ships/check_completion()
  . = ..()
  if(ships_remaining <= 0)
    stage = MISSION_COMPLETE
    payout()
    return TRUE
  return FALSE

/datum/nsv_mission/kill_ships/proc/report_kill(var/obj/structure/overmap/ship)
  if(stage != MISSION_ACTIVE)
    return
  if(!target_size.Find(ship.mass))
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

  desc = "Our supply lines have been hit hard recently. Destroy [ships_to_kill] [target_ship_string] ships in any system. You have currently destroyed [ships_to_kill - ships_remaining] ships "


// Kill ships in system - Kill X ships owned by Y in specific systems

/datum/nsv_mission/kill_ships/system
  name = "System clearing"
  payout = 5000
  var/target_system = list()
  var/visited_systems = list()
  var/system_alignment = list("syndicate","unaligned") // Two lists for targets and systems so we can assign kill syndies in NT space

/datum/nsv_mission/kill_ships/system/register()
  var/list/viable_systems = list()
  for(var/s in SSstar_system.systems)
    var/datum/star_system/system = s
    if(system.threat_level > max_threat_level)
      continue
    if(system.alignment in system_alignment)
      viable_systems += system
  ships_to_kill = 0
  for(var/i in 1 to rand(1,3))
    var/datum/star_system/chosen_system = pick(viable_systems)
    target_system += chosen_system
    viable_systems -= chosen_system
    chosen_system.add_mission(src)
    var/kill_amount = rand(1,5)
    ships_to_kill += kill_amount
    var/datum/faction/F = SSstar_system.faction_by_id(pick(target_factions))
    F.send_fleet(chosen_system, kill_amount)
  ships_remaining = ships_to_kill
  stage = MISSION_IDLE
  if(owner.current_system in target_system)
    arrive()
  update_description()
  payout = rand(payout, payout*2)
  return TRUE


/datum/nsv_mission/kill_ships/system/arrive()
  . = ..()
  if(owner.current_system in visited_systems)
    return
  visited_systems += owner.current_system
  if(targets_in_system() <= 2)
    var/datum/faction/F = SSstar_system.faction_by_id(pick(target_factions))
    F.send_fleet(owner.current_system)

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
    var/datum/star_system/foobar = target_system[i]
    if(i == 1)
      target_system_string = capitalize(foobar.name)
    else if(i == LAZYLEN(target_system))
      target_system_string += " or " + capitalize(foobar.name)
    else
      target_system_string += ", " + capitalize(foobar.name)

  desc = "We've received intel that the enemy is attempting to amass an invasion force in [target_system_string]. Locate and destroy the enemy fleet. You have currently destroyed [ships_to_kill - ships_remaining] ships."


// Wave hold - Destroy several waves of enemy ships

/datum/nsv_mission/kill_ships/waves
  name = "Hold system"
  payout = 15000
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
  target_system.add_mission(src)
  stage = MISSION_IDLE
  if(target_system == owner.current_system)
    arrive()
  update_description()
  payout = rand(payout, payout*2)
  return TRUE


/datum/nsv_mission/kill_ships/waves/encounter()
  spawn_new_wave()


/datum/nsv_mission/kill_ships/waves/proc/spawn_new_wave()
  if(owner.current_system != target_system) //Safety check if they bail before the next wave spawns.
    return
  stage = MISSION_ACTIVE //Reactivate kill tracking
  ships_to_kill = rand(3, 3 + total_waves - waves_remaining)
  var/datum/faction/F = SSstar_system.faction_by_id(pick(target_factions))
  F.send_fleet(target_system, ships_to_kill)
  ships_remaining = ships_to_kill

/datum/nsv_mission/kill_ships/waves/check_completion()
  if(stage == MISSION_COMPLETE)
    payout()
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
  if(stage == MISSION_COMPLETE)
    stage = MISSION_FAILED


/datum/nsv_mission/kill_ships/waves/update_description()
  if(stage == MISSION_COMPLETE)
    desc = "You held [target_system] for [initial(waves_remaining)]!"
  if(owner.current_system != target_system)
    desc = "We need you to cause a distraction. Travel to [target_system] and prepare to fight [waves_remaining] waves of enemy ships"
  if(ships_remaining)
    desc = "Destroy [ships_to_kill] [target_faction] ships located in [target_system]. You have currently destroyed [ships_to_kill - ships_remaining] ships. There are [waves_remaining] waves remaining."
  else
    desc = "Wait for enemy reinforcements."

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

  var/total_cargo = 3 // How many crates the crew will have to deliver
  var/list/possible_crates = list(/obj/structure/closet/crate/large/cargo/random = 3) // Weighted list of possible crates

  var/max_payout = 600
  payout = 0


/datum/nsv_mission/cargo/register()
  for(var/c in 1 to total_cargo)
    var/chosen_cargo = pickweight(possible_crates)
    possible_crates[chosen_cargo]--
    send_item(chosen_cargo)
  stage = MISSION_ACTIVE
  return TRUE


/datum/nsv_mission/cargo/check_completion()
  . = ..()
  update_description()
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


/datum/nsv_mission/cargo/update_description()
  desc = "Transport [total_cargo] crates of cargo to (TODO, ADD DESTINATION STATION). You have delivered [delivered_cargo + tampered_cargo]/[total_cargo] crates."


// High risk cargo - Things that react badly to being tampered with

/datum/nsv_mission/cargo/high_risk
  total_cargo = 2
  possible_crates = list(/obj/structure/closet/crate/large/cargo/random = 1,
                         /obj/structure/closet/crate/large/cargo/random/high_risk = 4)

  max_payout = 1000

  // High risk cargo - Things that react badly to being tampered with

/*
TODO: with pre-mission flavor text, give a hint that this mission is a bad idea. I'm thinking like the listing was hacked
  Also "haha ignore the ticking its uh... vintage clocks... and the geiger counters going off is uhhh....... radium."

  ALSO: figure out how to call del on the payload if they try to space it, as it just loops on the z level right now
*/

/datum/nsv_mission/cargo/nuke
  total_cargo = 1
  possible_crates = list(/obj/structure/closet/crate/large/cargo/nuke = 1)

  max_payout = 100000 // to get this payout, you gotta nuke an NT station


/datum/nsv_mission/cargo/nuke/register()
  . = ..()
  addtimer(CALLBACK(src, .proc/first_warning), 7 MINUTES) // 13 min to go


/datum/nsv_mission/cargo/nuke/report_tampered_cargo(var/datum/component/nsv_mission_cargo/cargo)
  stage = MISSION_FAILED // The mission requires the delivery of an undercover nuke.
  check_completion()


/datum/nsv_mission/cargo/nuke/proc/first_warning()
  if(stage != MISSION_ACTIVE) // Only report the crate is suspect if the mission is ongoing
    return
  priority_announce("This is an automated message, please do not respond. You have been identified as a ship who purchased cargo from an individual who was selling dangerous contraband. Please check any purchased items for anything suspect.", "Trade Station Security Desk")
  addtimer(CALLBACK(src, .proc/second_warning), 6 MINUTES) // 7 min to go



/datum/nsv_mission/cargo/nuke/proc/second_warning()
  if(stage != MISSION_ACTIVE) // Only report the crate is suspect if the mission is ongoing
    return
  priority_announce("This is an automated message, please do not respond. Re: Suspect seller. During a search of the sellers shuttle, we found components to create multiple nuclear weapons. We beleive you are currently transporting one. We hope this message reaches you in good time.", "Trade Station Security Desk")

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

