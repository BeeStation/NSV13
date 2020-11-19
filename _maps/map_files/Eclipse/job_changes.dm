//And you thought sausage was bad? -Francinum

/*
 _______  _______  _       _________ _______  _______  _______ 
(  ____ \(  ____ \( \      \__   __/(  ____ )(  ____ \(  ____ \
| (    \/| (    \/| (         ) (   | (    )|| (    \/| (    \/
| (__    | |      | |         | |   | (____)|| (_____ | (__    
|  __)   | |      | |         | |   |  _____)(_____  )|  __)   
| (      | |      | |         | |   | (            ) || (      
| (____/\| (____/\| (____/\___) (___| )      /\____) || (____/\
(_______/(_______/(_______/\_______/|/       \_______)(_______/
                                                               
*/
//You suck even on big maps.
MAP_REMOVE_JOB(atmos)
//The entire fucking medbay
MAP_REMOVE_JOB(doctor)
MAP_REMOVE_JOB(geneticist)
MAP_REMOVE_JOB(virologist)
MAP_REMOVE_JOB(emt)
MAP_REMOVE_JOB(chemist)
//And research
MAP_REMOVE_JOB(scientist)
MAP_REMOVE_JOB(roboticist)
//Supply
MAP_REMOVE_JOB(cargo_tech)
MAP_REMOVE_JOB(mining)
//Civilian
MAP_REMOVE_JOB(hydro)
MAP_REMOVE_JOB(cook)
MAP_REMOVE_JOB(janitor)
MAP_REMOVE_JOB(curator)
MAP_REMOVE_JOB(lawyer)
MAP_REMOVE_JOB(chaplain)
MAP_REMOVE_JOB(mime)
//Security
MAP_REMOVE_JOB(warden)
MAP_REMOVE_JOB(detective)
MAP_REMOVE_JOB(officer)
MAP_REMOVE_JOB(deputy)
MAP_REMOVE_JOB(brig_phys)
//Special
MAP_REMOVE_JOB(cyborg)
//Munitions
MAP_REMOVE_JOB(deck_tech)
MAP_REMOVE_JOB(flight_leader)
MAP_REMOVE_JOB(fighter_pilot)
MAP_REMOVE_JOB(air_traffic_controller)

/datum/uplink_item/explosives/syndicate_bomb/New()
    . = ..()
    
    if(SSmapping?.config?.map_name != JOB_MODIFICATION_MAP_NAME)
        return
    limited_stock = 0 //This ship is way too small for this shit.
    cant_discount = TRUE
    surplus = 0

/datum/job/hos/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 0
    spawn_positions = 0

/datum/job/chief_engineer/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 0
    spawn_positions = 0

/datum/job/rd/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 0
    spawn_positions = 0

/datum/job/cmo/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 0
    spawn_positions = 0

/datum/job/bartender/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 0
    spawn_positions = 0

/datum/job/master_at_arms/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 0
    spawn_positions = 0

/datum/job/ai/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 0
    spawn_positions = 0

/datum/job/qm/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 0
    spawn_positions = 0

/datum/job/New()
    ..()
    MAP_JOB_CHECK
    minimal_access += list(ACCESS_ENGINE_EQUIP, ACCESS_ATMOSPHERICS)
    access += list(ACCESS_ENGINE_EQUIP, ACCESS_ATMOSPHERICS)

#undef JOB_MODIFICATION_MAP_NAME
