
//Generic gas cloud. Shouldn't be used probably maybe.
/obj/effect/overmap_anomaly/gas_cloud
    name = "Fucky-Wucky generic gas cloud"
    desc = "This is a generic type that shouldn't exist. Likely an admin did a whoopsie but report it to a coder (or on Github) anyways."
    starmap_hidden = TRUE
    probe_scannable = FALSE
    research_points = 0 //lets be safe
    ///What riches does this cloud hold?
    var/gas_resources = list()
    ///How long does this cloud exist after creation? In ticks; -1 to disable decay except if gas depleted.
    var/decay_time = -1
    ///Used temporarily to prevent harvesting / new lockons while playing delete animation
    var/decaying = FALSE

/obj/effect/overmap_anomaly/gas_cloud/Initialize(mapload)
    . = ..()
    gas_resources["/datum/gas/oxygen"] = 0
    gas_resources["/datum/gas/nitrogen"] = 0
    gas_resources["/datum/gas/plasma"] = 0
    gas_resources["/datum/gas/carbon_dioxide"] = 0
    gas_resources["/datum/gas/nitrous_oxide"] = 0
    if(decay_time != -1)
        addtimer(CALLBACK(src, .proc/decay_cloud), decay_time)

//Checks for if a gas cloud is empty and deletes it if yes. Permanent gas clouds should override this.
/obj/effect/overmap_anomaly/gas_cloud/proc/empty_check()
    for(var/x as anything in gas_resources)
        if(gas_resources["[x]"] > 0)
            return
    decay_cloud() //nonpermanent cloud depleted, kill it.

///Plays an animation that makes the cloud invisible, then deletes it. Used when gas in a nonpermanent (system) cloud depletes.
/obj/effect/overmap_anomaly/gas_cloud/proc/decay_cloud()
    if(decaying)
        return
    decaying = TRUE
    SEND_SIGNAL(src, COMSIG_CLOUD_DECAYING, src)
    animate(src, alpha = 0, time = 20)
    QDEL_IN(src, 22)

///Adds resources to a gas cloud. Should be done after creation, but can also be used after creation. If there are no resources after such a call, the cloud self-deletes (usually).
/obj/effect/overmap_anomaly/gas_cloud/proc/add_resources(list/incoming_resources)
    //cursed byond variable stuff
    for(var/x as anything in incoming_resources)
        gas_resources["[x]"] += incoming_resources["[x]"]

    empty_check()

///Proc for admins or lazy coders to mess with clouds. Two args, first string for the gas name (aka the part in the datum/gas/[HERE]), then amount. Tis all.
/obj/effect/overmap_anomaly/gas_cloud/proc/lazy_resources(var/name, var/amount)
    if(!gas_resources["/datum/gas/[name]"])
        message_admins("[name] is an invalid gas type. - lazy_resources call")
        return
    var/removing_resources = FALSE
    if(amount < 0)
        removing_resources = TRUE
        if(gas_resources["/datum/gas/[name]"] < amount)
            amount = gas_resources["/datum/gas/[name]"] //:)
    
    gas_resources["/datum/gas/[name]"] += amount
    if(removing_resources)
        empty_check()

//Special gas cloud type that is linked to a starsystem and contains its system resources. Goes invisible if the system is depleted, appears again if there's somehow new resources.
//This should NEVER be destroyed except by the system itself QDELing!!
/obj/effect/overmap_anomaly/gas_cloud/system
    name = "UNLINKED gas harvesting point"
    desc = "This system harvesting point wasn't linked for some reason. Report it on Github or yell at the badmin who did this."
    decay_time = -1 //for clarity
    alpha = 0 //It's just a specific point in space you have to fly close to because the holy ship computer deemed it a nice spot.
    ///Which system is this linked to?
    var/datum/star_system/linked_system

/obj/effect/overmap_anomaly/gas_cloud/system/empty_check()
    return //Do not delete this.

/obj/effect/overmap_anomaly/gas_cloud/system/decay_cloud()
    return //Better be sure.

///Links the system gas cloud to its system. Should always be done immediately after creating it, followed by setting up resources.
/obj/effect/overmap_anomaly/gas_cloud/system/proc/link_system(datum/star_system/link_to)
    if(!link_to)
        CRASH("No system passed to gas cloud linkage proc.")
    linked_system = link_to
    name = "[linked_system.name] gas harvesting point"
    name = "Optimal resourcing point for [linked_system.name]. Proximity required for gas harvesting."

/obj/effect/overmap_anomaly/gas_cloud/shipbreaking
    name = "gas cloud"
    desc = "All that remains of an once proud spacefaring vessel."
    decay_time = 50 MINUTES //These take a while to decay for some emergent storytelling :)

/obj/effect/overmap_anomaly/gas_cloud/rockbreaking
    name = "pulverized asteroid remains"
    desc = "Boom goes the dynamite!"
    decay_time = 7 MINUTES //Work fast.

/obj/structure/overmap/proc/toggle_cloud_lock(obj/effect/overmap_anomaly/gas_cloud/cloud_target, obj/machinery/computer/ship/dradis/locking)
    if(QDELETED(cloud_target))
        return
    if(cloud_target.decaying)
        return
    if(overmap_dist(src, cloud_target) > GAS_HARVESTING_RANGE && cloud_target != locked_gas_cloud)
        if(locking)
            say("Distance to target too far for harvesting lockon.")
        return
    if(locked_gas_cloud == cloud_target)
        if(locking)
            say("Dropping harvesting target.")
        UnregisterSignal(locked_gas_cloud, COMSIG_CLOUD_DECAYING)
        locked_gas_cloud = null
    else if(locked_gas_cloud)
        if(locking)
            say("Cycling harvesting target.")
        UnregisterSignal(locked_gas_cloud, COMSIG_CLOUD_DECAYING)
        locked_gas_cloud = cloud_target
        RegisterSignal(locked_gas_cloud, COMSIG_CLOUD_DECAYING, .proc/drop_cloud_lock)
    else
        if(locking)
            say("Establishing gas harvesting lock.")
        locked_gas_cloud = cloud_target
        RegisterSignal(locked_gas_cloud, COMSIG_CLOUD_DECAYING, .proc/drop_cloud_lock)

/obj/structure/overmap/proc/drop_cloud_lock(obj/effect/overmap_anomaly/gas_cloud/dropped_lock)
    SIGNAL_HANDLER
    UnregisterSignal(dropped_lock, COMSIG_CLOUD_DECAYING)
    locked_gas_cloud = null
