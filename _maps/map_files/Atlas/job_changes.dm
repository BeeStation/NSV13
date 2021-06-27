//A halfway point between Eclipse and highpop. (Now with 20% less spite) ~Kmc

/*

          _____                _____                    _____            _____                    _____
         /\    \              /\    \                  /\    \          /\    \                  /\    \
        /::\    \            /::\    \                /::\____\        /::\    \                /::\    \
       /::::\    \           \:::\    \              /:::/    /       /::::\    \              /::::\    \
      /::::::\    \           \:::\    \            /:::/    /       /::::::\    \            /::::::\    \
     /:::/\:::\    \           \:::\    \          /:::/    /       /:::/\:::\    \          /:::/\:::\    \
    /:::/__\:::\    \           \:::\    \        /:::/    /       /:::/__\:::\    \        /:::/__\:::\    \
   /::::\   \:::\    \          /::::\    \      /:::/    /       /::::\   \:::\    \       \:::\   \:::\    \
  /::::::\   \:::\    \        /::::::\    \    /:::/    /       /::::::\   \:::\    \    ___\:::\   \:::\    \
 /:::/\:::\   \:::\    \      /:::/\:::\    \  /:::/    /       /:::/\:::\   \:::\    \  /\   \:::\   \:::\    \
/:::/  \:::\   \:::\____\    /:::/  \:::\____\/:::/____/       /:::/  \:::\   \:::\____\/::\   \:::\   \:::\____\
\::/    \:::\  /:::/    /   /:::/    \::/    /\:::\    \       \::/    \:::\  /:::/    /\:::\   \:::\   \::/    /
 \/____/ \:::\/:::/    /   /:::/    / \/____/  \:::\    \       \/____/ \:::\/:::/    /  \:::\   \:::\   \/____/
          \::::::/    /   /:::/    /            \:::\    \               \::::::/    /    \:::\   \:::\    \
           \::::/    /   /:::/    /              \:::\    \               \::::/    /      \:::\   \:::\____\
           /:::/    /    \::/    /                \:::\    \              /:::/    /        \:::\  /:::/    /
          /:::/    /      \/____/                  \:::\    \            /:::/    /          \:::\/:::/    /
         /:::/    /                                 \:::\    \          /:::/    /            \::::::/    /
        /:::/    /                                   \:::\____\        /:::/    /              \::::/    /
        \::/    /                                     \::/    /        \::/    /                \::/    /
         \/____/                                       \/____/          \/____/                  \/____/


*/

//There's no viro on atlas :(
MAP_REMOVE_JOB(virologist)
//Civilian guys without an office
MAP_REMOVE_JOB(curator)
MAP_REMOVE_JOB(lawyer)
//Most of security - Because these guys aren't too useful in a brig this SMALL
MAP_REMOVE_JOB(deputy)
MAP_REMOVE_JOB(brig_phys)
//Munitions
//MAP_REMOVE_JOB(deck_tech)

/datum/uplink_item/explosives/syndicate_bomb/New()
    . = ..()

    if(SSmapping?.config?.map_name != JOB_MODIFICATION_MAP_NAME)
        return
    limited_stock = 0 //This ship is way too small for this shit.
    cant_discount = TRUE
    surplus = 0

/datum/job/munitions_tech/New()
	..()
	MAP_JOB_CHECK
	//Munitech is the new assistant for Atlas. We don't want 20 marines : 1 CIC operator and so on..
	addtimer(CALLBACK(SSjob, /datum/controller/subsystem/job/proc/set_overflow_role, src.title), 10 SECONDS)

/datum/job/marine/New()
	..()
	MAP_JOB_CHECK
	//Very reduced marine count due to the Atlas being small and lowpop. I don't want a shift where every single person rolls marine, and the ship has no one to fly it.
	total_positions = 4
	spawn_positions = 4

/datum/job/pilot/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 1
    spawn_positions = 1

/datum/job/detective/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 1
    spawn_positions = 1

/datum/job/bartender/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 0
    spawn_positions = 0

/datum/job/geneticist/New()
    ..()
    MAP_JOB_CHECK
    total_positions = 1
    spawn_positions = 1

#undef JOB_MODIFICATION_MAP_NAME
