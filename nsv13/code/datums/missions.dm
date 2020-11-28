
/*
NOTE:

- give parts to make cargo torp instead of a finished one? they can just load in cargo and save the hassle
- more high risk contents
- Move all of this into a module folder
- Split this file into different files?

*/

/datum/nsv_mission/
  var/name
  var/desc // Used to relay the status of the mission
  var/stage
  var/first_encounter = FALSE

  var/list/valid_factions = list("nanotrasen")

  var/payout = 4000
  var/list/rewards // List of items to be offered as a reward

  var/obj/structure/overmap/owner // Which ship owns this mission
  var/obj/structure/overmap/the_client // Which station issued the mission


/datum/nsv_mission/New(var/o)
  the_client = o


/datum/nsv_mission/proc/check_eligible(var/obj/structure/overmap/ship) // check if the requesting ship is allowed to take this mission
  if(owner)
    return FALSE
  if(!valid_factions.Find(ship.faction))
    return FALSE
  return TRUE

/datum/nsv_mission/proc/pre_register(ship)
  if(!ship)
    return
  owner = ship
  owner.missions += src
  SSstar_system.all_missions += src
  register()

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
    return TRUE // Completed missions are always complete
  if(stage != MISSION_ACTIVE)
    return FALSE // If the mission is not active, it can not be completed

/datum/nsv_mission/proc/payout()
  var/obj/item/holochip/money = owner.send_supplypod(/obj/item/holochip)
  money.credits = payout
  if(LAZYLEN(rewards))
    for(var/a in rewards)
      owner.send_supplypod(a)
    owner.hail("Bounty payout of $[payout] authorised for [owner]. Pre-loaded credit holochip and physical rewards will be delivered to the ship's cargo department.", the_client.name)
  else
    owner.hail("Bounty payout of $[payout] authorised for [owner]. Pre-loaded credit holochip will be delivered to the ship's cargo department.", the_client.name)

/datum/nsv_mission/proc/reward_string() //Output what this mission will reward for tgui
  var/reward_txt = ""
  for(var/i in 1 to LAZYLEN(rewards))
    if(i == LAZYLEN(rewards))
      reward_txt += " and " + rewards[rewards[i]]
    else
      reward_txt += ", " + rewards[rewards[i]]
  return num2text(payout) + " credits" + reward_txt

/datum/nsv_mission/proc/send_item(contents, cargo = TRUE) // Send an item to the players.
  var/c = owner.send_supplypod(contents)
  if(cargo) //if we are cargo, apply the flag to either ourselfs or our contents
    var/obj/structure/closet/cargo_crate = c
    SEND_SIGNAL(cargo_crate, COMSIG_CARGO_REGISTER, src)
    if(LAZYLEN(cargo_crate.contents)) //The contents are the actual cargo
      for(var/atom/a in cargo_crate.contents)
        SEND_SIGNAL(a, COMSIG_CARGO_REGISTER, src)
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

  rewards = list(/obj/structure/closet/crate/nsv_mission_rewards="an ammo crate")

/datum/nsv_mission/kill_ships/proc/targets_in_system(var/valid_only = FALSE)
  var/c = 0
  for(var/obj/structure/overmap/a in owner.current_system.system_contents)
    if(!target_faction.Find(a.faction))
      continue
    if(a.gc_destroyed) //Destroyed ships are not removed from system_contents. This lets me ignore the ones that are actually dead
      continue
    if(valid_only && !target_size.Find(a.mass))
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

  desc = "Our supply lines have been hit hard recently. Destroy [ships_to_kill] [target_ship_string] ships in any system. You have currently destroyed [ships_to_kill - ships_remaining] ships."


/datum/nsv_mission/kill_ships/syndicate
  valid_factions = list("syndicate")
  target_faction = list("nanotrasen")
  target_factions = list(FACTION_ID_NT)
  rewards = list(/obj/item/stack/telecrystal/twenty="20 telecrystals",
                /obj/structure/closet/crate/nsv_mission_rewards="an ammo crate")

// Kill ships in system - Kill X ships owned by Y in specific systems

/datum/nsv_mission/kill_ships/system
  name = "System clearing"
  payout = 5000
  var/target_system = list()
  var/visited_systems = list()
  var/system_alignment = list("syndicate","unaligned","uncharted") // Two lists for targets and systems so we can assign kill syndies in NT space

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
    target_system[chosen_system] = kill_amount
    ships_to_kill += kill_amount
    var/datum/faction/F = SSstar_system.faction_by_id(pick(target_factions))
    F.send_fleet(chosen_system, kill_amount, TRUE)
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
  if(targets_in_system(TRUE) < target_system[owner.current_system])
    var/datum/faction/F = SSstar_system.faction_by_id(pick(target_factions))
    F.send_fleet(owner.current_system, target_system[owner.current_system] - targets_in_system(TRUE), TRUE)

/datum/nsv_mission/kill_ships/system/update_description()
  var/target_ship_string
  for(var/i in 1 to LAZYLEN(target_faction))
    if(i == 1)
      target_ship_string = capitalize(target_faction[i])
    else if(i == LAZYLEN(target_faction))
      target_ship_string += " and " + capitalize(target_faction[i])
    else
      target_ship_string += ", " + capitalize(target_faction[i])

  var/target_system_string
  for(var/i in 1 to LAZYLEN(target_system))
    var/datum/star_system/foobar = target_system[i]
    if(i == 1)
      target_system_string = capitalize(foobar.name)
    else if(i == LAZYLEN(target_system))
      target_system_string += " and " + capitalize(foobar.name)
    else
      target_system_string += ", " + capitalize(foobar.name)

  desc = "We've received intel that the enemy is attempting to amass an invasion force in [target_system_string]. Locate and destroy the enemy fleet. You have currently destroyed [ships_to_kill - ships_remaining] ships."


/datum/nsv_mission/kill_ships/system/syndicate
  valid_factions = list("syndicate")
  target_faction = list("nanotrasen")
  target_factions = list(FACTION_ID_NT)
  system_alignment = list("nanotrasen","unaligned","uncharted")
  rewards = list(/obj/item/stack/telecrystal/twenty="20 telecrystals",
                /obj/structure/closet/crate/nsv_mission_rewards="an ammo crate")


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


/datum/nsv_mission/kill_ships/waves/proc/spawn_new_wave(var/override_ships)
  if(owner.current_system != target_system) //Safety check if they bail before the next wave spawns.
    return
  stage = MISSION_ACTIVE //Reactivate kill tracking
  var/ships = override_ships
  if(!override_ships)
    ships_to_kill = rand(2, 2 + total_waves - waves_remaining)
    ships = ships_to_kill
    ships_remaining = ships_to_kill
  var/datum/faction/F = SSstar_system.faction_by_id(pick(target_factions))
  F.send_fleet(target_system, ships, TRUE)
  update_description()

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
      payout()
      return TRUE
    else
      addtimer(CALLBACK(src, .proc/spawn_new_wave), rand(10,30) SECONDS)
  else if(!targets_in_system(TRUE)) //If they have ships remaining, but we have no more ships in the system, spawn some more in so the mission doesn't get stuck
    spawn_new_wave(ships_remaining)
  return FALSE


/datum/nsv_mission/kill_ships/waves/depart()
  if(stage == MISSION_ACTIVE || stage == MISSION_IDLE)
    stage = MISSION_FAILED
    update_description()


/datum/nsv_mission/kill_ships/waves/update_description()
  if(stage == MISSION_FAILED)
    desc = "After you fled from [target_system] our forces in a neighbouring system were overwhelmed from the fleets you were supposed to distract."
  if(stage == MISSION_COMPLETE)
    desc = "You held [target_system] for [total_waves] waves! Ships in a neighbouring system were able to complete their mission thanks to your distraction."
  else if(owner.current_system != target_system)
    desc = "We need you to cause a distraction. Travel to [target_system] and prepare to fight [waves_remaining] waves of enemy ships."
  else if(ships_remaining)
    var/target_ship_string
    for(var/i in 1 to LAZYLEN(target_faction))
      if(i == 1)
        target_ship_string = capitalize(target_faction[i])
      else if(i == LAZYLEN(target_faction))
        target_ship_string += " or " + capitalize(target_faction[i])
      else
        target_ship_string += ", " + capitalize(target_faction[i])
    desc = "Destroy [ships_to_kill] [target_ship_string] ships located in [target_system]. You have currently destroyed [ships_to_kill - ships_remaining] ships. There are [waves_remaining] waves remaining."
  else
    desc = "Wait for enemy reinforcements."


/datum/nsv_mission/kill_ships/waves/syndicate
  valid_factions = list("syndicate")
  target_faction = list("nanotrasen")
  target_factions = list(FACTION_ID_NT)
  rewards = list(/obj/item/stack/telecrystal/twenty="20 telecrystals",
                /obj/structure/closet/crate/nsv_mission_rewards="an ammo crate")

/* ideasguys zone - TODO

station defend
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

  var/total_cargo = 4 // How many crates the crew will have to deliver
  var/list/possible_crates = list(/obj/structure/closet/crate/large/cargo/random = 4) // Weighted list of possible crates
  var/obj/structure/overmap/delivery_target

  var/destination_faction = FACTION_ID_NT

  var/max_payout = 4000
  payout = 0


/datum/nsv_mission/cargo/register()
  var/list/valid_traders = list()
  for(var/t in SSstar_system.traders)
    var/datum/trader/traders = t
    var/obj/structure/overmap/station = traders.current_location
    if(station == the_client)
      continue
    if(traders.faction_type == destination_faction)
      valid_traders += station

  delivery_target = pick(valid_traders)

  for(var/c in 1 to total_cargo)
    var/chosen_cargo = pickweight(possible_crates)
    possible_crates[chosen_cargo]--
    send_item(chosen_cargo)
  send_item(/obj/item/ship_weapon/ammunition/torpedo/freight, FALSE) //Give them a free cargo torp on the house
  stage = MISSION_ACTIVE
  update_description()
  return TRUE


/datum/nsv_mission/cargo/check_completion()
  . = ..()
  update_description()
  if(LAZYLEN(tracked_cargo))
    return FALSE//There is still cargo to deliver
  if(delivered_cargo || tampered_cargo) //if they managed to deliver at least one cargo, give them the payout
    stage = MISSION_COMPLETE
    payout()
  else
    stage = MISSION_FAILED



/datum/nsv_mission/cargo/proc/deliver_cargo(var/datum/component/nsv_mission_cargo/cargo, var/obj/structure/overmap/destination)
  if(delivery_target != destination) //Delivered to the wrong location...
    if(destination.role != MAIN_OVERMAP && !destination.linked_areas.len)
      report_destroyed_cargo(cargo) // If we delivered to a ship that isn't the destination, or a crewed ship the cargo is lost for good
      return
  tracked_cargo -= cargo.parent
  switch(cargo.cargo_state)
    if(CARGO_INTACT)
      delivered_cargo++
    if(CARGO_TAMPERED)
      tampered_cargo++
  payout = round(max_payout * (delivered_cargo + (0.25 * tampered_cargo)) / total_cargo ,1)
  qdel(cargo)
  check_completion()


/datum/nsv_mission/cargo/proc/report_destroyed_cargo(var/datum/component/nsv_mission_cargo/cargo)
  if(!tracked_cargo.Find(cargo.parent))
    return
  tracked_cargo -= cargo.parent
  lost_cargo++
  qdel(cargo)
  check_completion()


/datum/nsv_mission/cargo/reward_string()
  var/reward_txt = ""
  for(var/i in 1 to LAZYLEN(rewards))
    if(i == LAZYLEN(rewards))
      reward_txt += " and " + rewards[rewards[i]]
    else
      reward_txt += ", " + rewards[rewards[i]]
  return "A maximum of " + num2text(max_payout) + " credits" + reward_txt


/datum/nsv_mission/cargo/proc/report_tampered_cargo(var/datum/component/nsv_mission_cargo/cargo) // We only count the cargo if delivered tampered. This is mostly a hook if you want tampers to be fails
  check_completion()


/datum/nsv_mission/cargo/update_description()
  desc = "Transport [total_cargo] crates of cargo via a freight torpedo to [delivery_target.name], located in the [delivery_target.starting_system] system. You have delivered [delivered_cargo + tampered_cargo]/[total_cargo] crates."


// High risk cargo - Things that react badly to being tampered with

/datum/nsv_mission/cargo/high_risk
  total_cargo = 2
  possible_crates = list(/obj/structure/closet/crate/large/cargo/random = 1,
                         /obj/structure/closet/crate/large/cargo/random/high_risk = 4)

  max_payout = 5000


/datum/nsv_mission/cargo/nuke
  total_cargo = 1
  possible_crates = list(/obj/structure/closet/crate/large/cargo/nuke = 1)

  max_payout = 100000 // to get this payout, you gotta nuke an NT station


/datum/nsv_mission/cargo/nuke/register()
  . = ..()
  message_admins("The [owner.name] has just undertaken the live nuke mission! There will be multiple ingame warnings about the cargo.")
  addtimer(CALLBACK(src, .proc/first_warning), 15 MINUTES) // 45 min to go


/datum/nsv_mission/cargo/nuke/report_tampered_cargo(var/datum/component/nsv_mission_cargo/cargo)
  stage = MISSION_FAILED // The mission requires the delivery of an undercover nuke.
  check_completion()


/datum/nsv_mission/cargo/nuke/update_description()
  desc = "Transport 9999\"; DROP CONNECTION ; NEW CONNECTION(\" Hey, I need you to move one crate of cargo to [delivery_target.name]. You'll find it in [delivery_target.starting_system]. DO NOT open the crate and ignore the ticking it is an antique alarm clock. This needs to be delivered in less than one hour."

/datum/nsv_mission/cargo/nuke/proc/first_warning()
  if(stage != MISSION_ACTIVE) // Only report the crate is suspect if the mission is ongoing
    return
  owner.hail("[owner.name], we have noticed that a mission was assigned to you, asking to deliver a crate of cargo to [delivery_target.name]. However we don't have the request form from them to send the crate. Please hold off on delivering that crate until we figure out what is going on.", the_client.name)
  addtimer(CALLBACK(src, .proc/second_warning), 15 MINUTES) // 30 min to go

/datum/nsv_mission/cargo/nuke/proc/second_warning()
  if(stage != MISSION_ACTIVE) // Only report the crate is suspect if the mission is ongoing
    return
  owner.hail("We have looked into that crate you were asked to deliver to [delivery_target.name] and found that someone has tampered with that job listing. We have found the person responsible and will attempt to find out why they want you to move that crate.", the_client.name)
  addtimer(CALLBACK(src, .proc/third_warning), 15 MINUTES) // 15 min to go

/datum/nsv_mission/cargo/nuke/proc/third_warning()
  if(stage != MISSION_ACTIVE) // Only report the crate is suspect if the mission is ongoing
    return
  owner.hail("The person who tampered with the job listing revealed they are a Syndicate agent after a breif 'talking' too. You need to destroy or dispose of that crate as they intended to have you destroy [delivery_target.name].", the_client.name)

/datum/nsv_mission/cargo/nuke/payout()
  if(delivered_cargo)
    . = ..()
    owner.hail("Thanks, but we don't believe we requested this crate? Wait, why do I hear ticking...", delivery_target.name)
    QDEL_IN(delivery_target,10 SECONDS) //f
  else
    owner.hail("[owner.name], why did you just try to send us a live nuke? We have spaced it for now but will have to raise this with Central Command.", delivery_target.name)


/datum/nsv_mission/cargo/nuke/syndicate/update_description() //Exactly the same as the normal one but with different flavor text/warnings
  desc = "You... Want to do a mission for us? Sure. I mean you've come this far, why not take a gift back to [delivery_target.name]. Hopefuly this gift will better our relations. Don't peek inside, I'm sure the admiral wants this gift undamaged."


/datum/nsv_mission/cargo/nuke/syndicate/first_warning()
  if(stage != MISSION_ACTIVE)
    return
  owner.hail("A routine scan of your communication logs has identified that the [owner.name] has been in contact with a Syndicate station. You and your crew will face disciplinary action while we asses just what the fuck you were doing contacting the enemy.", "Central Command")

// TODO, make the player ship KOS if they deliver the nuke?

//##############################################################################
//######### Other missions
//##############################################################################

// Explore - Travel to a sector. Will just be navigate through the random sector

/datum/nsv_mission/explore
  var/datum/star_system/destination
  payout = 5000

/datum/nsv_mission/explore/New(var/o)
  . = ..()
  if(istype(the_client, /obj/structure/overmap/trader))
    var/obj/structure/overmap/trader/T = the_client
    T.inhabited_trader.possible_mission_types -= /datum/nsv_mission/explore

/datum/nsv_mission/explore/register()
  destination = SSstar_system.system_by_id("Rubicon")
  destination.active_missions += src
  update_description()
  return TRUE

/datum/nsv_mission/explore/encounter()
  check_completion()

/datum/nsv_mission/explore/check_completion()
  . = ..()
  if(owner.current_system == destination)
    stage = MISSION_COMPLETE
    payout()
    return TRUE
  return FALSE

/datum/nsv_mission/explore/update_description()
  desc = "We have been struggling to map a route into Syndicate space. Every time we send a scout to find a viable route they get lost. If you can navigate to and arrive in Rubicon, we'll pay you for information on the route you took. "


//##############################################################################
//######### Admin missions
//##############################################################################


// Custom - A blank objective for admins to create custom missions. They will not automatically process

/datum/nsv_mission/custom/
  desc = "A mission missing the correct paperwork to define what is required. Contact NT if you see this!"
  var/admin_hints = "SET 'the_client' TO THE OVERMAP STATION! Set stage to different things to mark progress. -1 is failed. 0 is idle and 2 is complete."

