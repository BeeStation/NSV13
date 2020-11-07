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
//Most of the heads.
MAP_REMOVE_JOB(hos)
MAP_REMOVE_JOB(chief_engineer)
MAP_REMOVE_JOB(rd)
MAP_REMOVE_JOB(cmo)
MAP_REMOVE_JOB(master_at_arms)
//You suck even on big maps.
MAP_REMOVE_JOB(atmos)
//Almost the entire fucking medbay
MAP_REMOVE_JOB(geneticist)
MAP_REMOVE_JOB(virologist)
MAP_REMOVE_JOB(emt)
MAP_REMOVE_JOB(chemist)
//Robots don't exist
MAP_REMOVE_JOB(roboticist)
//Supply
MAP_REMOVE_JOB(qm)
MAP_REMOVE_JOB(mining)
//Civilian
MAP_REMOVE_JOB(bartender)
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
MAP_REMOVE_JOB(deputy)
//Special
MAP_REMOVE_JOB(ai)
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


#undef JOB_MODIFICATION_MAP_NAME
