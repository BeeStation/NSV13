/*
      ::::::::  :::::::::: :::::::::  :::::::::: ::::    ::: ::::::::: ::::::::::: ::::::::: ::::::::::: ::::::::::: :::   :::
    :+:    :+: :+:        :+:    :+: :+:        :+:+:   :+: :+:    :+:    :+:     :+:    :+:    :+:         :+:     :+:   :+:
   +:+        +:+        +:+    +:+ +:+        :+:+:+  +:+ +:+    +:+    +:+     +:+    +:+    +:+         +:+      +:+ +:+
  +#++:++#++ +#++:++#   +#++:++#:  +#++:++#   +#+ +:+ +#+ +#+    +:+    +#+     +#++:++#+     +#+         +#+       +#++:
        +#+ +#+        +#+    +#+ +#+        +#+  +#+#+# +#+    +#+    +#+     +#+           +#+         +#+        +#+
#+#    #+# #+#        #+#    #+# #+#        #+#   #+#+# #+#    #+#    #+#     #+#           #+#         #+#        #+#
########  ########## ###    ### ########## ###    #### ######### ########### ###       ###########     ###        ###
*/

//The Serendipity has a too extensive of a medbay to justify a brig physician
MAP_REMOVE_JOB(brig_phys)
//There is an ATC console in the bridge but the position is relegated to the executive officer
MAP_REMOVE_JOB(air_traffic_controller)

//Not enough room for more pilots
/datum/job/pilot/New()
	..()
	MAP_JOB_CHECK
	total_positions = 1
	spawn_positions = 1

/datum/uplink_item/explosives/syndicate_bomb/New()
    . = ..()

    if(SSmapping?.config?.map_name != JOB_MODIFICATION_MAP_NAME)
        return
    limited_stock = 0 //This ship is way too small for this shit.
    cant_discount = TRUE
    surplus = 0

/datum/supply_pack/materials/plasma_canister/New() //Plasma gun needs plasma gas
	.=..()
	if(SSmapping?.config?.map_name != JOB_MODIFICATION_MAP_NAME)
		return
	hidden = FALSE

//All other shuttles will shatter the Serendipity!

/datum/map_template/shuttle/New()
	.=..()
	if(SSmapping?.config?.map_name != JOB_MODIFICATION_MAP_NAME)
		return
	can_be_bought = FALSE

#undef JOB_MODIFICATION_MAP_NAME
