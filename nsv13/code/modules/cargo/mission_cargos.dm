
/*
Here we define the cargo crate, as well as the contents
*/

/obj/structure/closet/crate/large/cargo/
  desc = "A hefty wooden crate. This crate is fitted with an anti-tamper seal. If you really want to open it you'll need a crowbar to get it open."
  icon = 'nsv13/icons/obj/custom_crates.dmi'
  icon_state = "large_cargo_crate"


/obj/structure/closet/crate/large/cargo/Initialize()
  . = ..()
  AddComponent(/datum/component/nsv_mission_cargo_label)


/obj/structure/closet/crate/large/cargo/attackby(obj/item/W, mob/user, params)  
  if(W.tool_behaviour == TOOL_CROWBAR)
    var/choice = input("WARNING: The client requests that the cargo must not be tampered with. Opening this crate will reduce mission payout. Are you sure you wish to open it?", "WARNING!", "No") in list("Yes", "No")
    if(choice != "Yes") 
      return
    if(get_dist(user, src) > 1) //Check they are still in range
      return
    for(var/atom/a in contents)
      SEND_SIGNAL(a, COMSIG_CARGO_TAMPERED)
  ..()

/obj/structure/closet/crate/large/cargo/Destroy()
  for(var/atom/a in contents)
    SEND_SIGNAL(a, COMSIG_CARGO_TAMPERED)
  ..()
  
// Use PopulateContents to create a list of what we want to spawn, then pass it here to mark those items as cargo
/obj/structure/closet/crate/large/cargo/proc/PopulateContentsWithTracker(var/list/items) 
  for(var/i in items)
    var/atom/a = new i(src)
    a.AddComponent(/datum/component/nsv_mission_cargo)

//##############################################################################
//######### Low risk crates
//############################################################################## 

/obj/structure/closet/crate/large/cargo/random //TODO crates that have a bunch of stuff in them?
  var/possible_contents = list(/obj/machinery/portable_atmospherics/canister/oxygen,
                               /obj/machinery/portable_atmospherics/canister/air,
                               /obj/machinery/portable_atmospherics/canister/water_vapor,
                               /obj/structure/reagent_dispensers/beerkeg,
                               /obj/machinery/portable_atmospherics/scrubber,
                               /obj/machinery/portable_atmospherics/pump )

/obj/structure/closet/crate/large/cargo/random/PopulateContents()
  var/list/l = list(pickweight(possible_contents))
  PopulateContentsWithTracker(l)

//##############################################################################
//######### High risk crates
//############################################################################## 

/obj/structure/closet/crate/large/cargo/random/high_risk
  possible_contents = list(/obj/structure/alien/egg/grown = 1,
                           /obj/machinery/portable_atmospherics/canister/toxins = 1)

  
//##############################################################################
//######### Not a nuke crate
//############################################################################## 

/obj/structure/closet/crate/large/cargo/nuke/Initialize()
  . = ..()
  AddComponent(/datum/component/radioactive, 75)

/obj/structure/closet/crate/large/cargo/nuke/PopulateContents()
  var/list/l = list(/obj/machinery/nuclearbomb/nuke/fake_cargo)
  PopulateContentsWithTracker(l)
  
/obj/structure/closet/crate/large/cargo/nuke/forceMove() //Most crates we are fine with letting loop back, but the nuke crate we specifically want to vanish if they try to space it
  . = ..()
  if(istype(loc,/turf/open/space))
    qdel(src)
  return .
  
/obj/machinery/nuclearbomb/nuke/fake_cargo/Initialize()
  . = ..()
  timer_set = 3600
  safety = FALSE	
  timing = TRUE
  previous_level = get_security_level()
  detonation_timer = world.time + (timer_set * 10)
  for(var/obj/item/pinpointer/nuke/syndicate/S in GLOB.pinpointer_list)
    S.switch_mode_to(TRACK_INFILTRATOR)
  countdown.start()
  update_icon()
  
/obj/machinery/nuclearbomb/nuke/fake_cargo/forceMove() 
  . = ..()
  if(istype(loc,/turf/open/space))
    qdel(src)
  return .
  
