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
//Though the Serendipity is a research vessel, there is no place for recreational reading
MAP_REMOVE_JOB(curator)
//There is an ATC console in the bridge but the position is relegated to the executive officer
MAP_REMOVE_JOB(air_traffic_controller)
//No explanation needed
MAP_REMOVE_JOB(gimmick)

//All other shutters will shatter the Serendipity!

/datum/map_template/shuttle/New()
	.=..()
	if(SSmapping?.config?.map_name != JOB_MODIFICATION_MAP_NAME)
		return
	can_be_bought = FALSE

/datum/uplink_item/explosives/syndicate_bomb/New()
    . = ..()

    if(SSmapping?.config?.map_name != JOB_MODIFICATION_MAP_NAME)
        return
    limited_stock = 0 //This ship is way too small for this shit.
    cant_discount = TRUE
    surplus = 0

#undef JOB_MODIFICATION_MAP_NAME
