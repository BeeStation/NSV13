/**

 _____       _            _   _
|  __ \     | |          | | (_)
| |  \/ __ _| | __ _  ___| |_ _  ___ __ _
| | __ / _` | |/ _` |/ __| __| |/ __/ _` |
| |_\ \ (_| | | (_| | (__| |_| | (_| (_| |
 \____/\__,_|_|\__,_|\___|\__|_|\___\__,_|



*/

MAP_REMOVE_JOB(lawyer) //not ours, don't need 'em

/datum/job/fighter_pilot/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 5
    spawn_positions = 5

/datum/job/munitions_tech/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 12
    spawn_positions = 12

/datum/job/staffjudgeadvocate/New() //big ship needs much oversight
    ..()
    MAP_JOB_CHECK
    total_positions = 2
    spawn_positions = 2
