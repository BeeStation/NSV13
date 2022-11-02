/obj/item/disk/design_disk/deck_gun_autoelevator
	name = "Naval Artillery Cannon Autoelevator Design"
	desc = "Design blueprints for a faster-loading naval artillery cannon."
	icon_state = "datadisk2"
	max_blueprints = 1

/obj/item/disk/design_disk/deck_gun_autoelevator/Initialize(mapload)
	. = ..()
	blueprints[1] = new /datum/design/board/deck_gun_autoelevator

/obj/item/disk/design_disk/deck_gun_autorepair
	name = "Naval Artillery Cannon Auto-repair Design"
	desc = "Design blueprints for a self-repairing naval artillery cannon."
	icon_state = "datadisk0"
	max_blueprints = 1

/obj/item/disk/design_disk/deck_gun_autorepair/Initialize(mapload)
	. = ..()
	blueprints[1] = new /datum/design/board/deck_gun_autorepair
