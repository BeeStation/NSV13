MAP_REMOVE_JOB(virologist)
MAP_REMOVE_JOB(curator)
MAP_REMOVE_JOB(lawyer)
MAP_REMOVE_JOB(deputy)

/datum/uplink_item/explosives/syndicate_bomb/New()
    . = ..()

    if(SSmapping?.config?.map_name != JOB_MODIFICATION_MAP_NAME)
        return
    limited_stock = 0 //This ship is way too small for this shit.
    cant_discount = TRUE
    surplus = 0

/datum/job/pilot/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 5
    spawn_positions = 5

/datum/job/detective/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 1
    spawn_positions = 1

#undef JOB_MODIFICATION_MAP_NAME