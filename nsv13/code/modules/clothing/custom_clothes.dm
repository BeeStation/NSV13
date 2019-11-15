/obj/item/clothing/under/ship
	name = "Placeholder"
	icon = 'nsv13/icons/obj/clothing/uniforms.dmi' //Placeholder subtype for our own iconsets
	alternate_worn_icon = 'nsv13/icons/mob/uniform.dmi'
	icon_state = "nothing" //References uniforms.dmi
	item_color = "nothing" //Icon state for its worn icon, references uniform.dmi
	item_state = "bl_suit"
	can_adjust = FALSE //Can you roll its sleeves down? Default to no to avoid missing icons

/obj/item/clothing/under/ship/officer
	name = "Officer's uniform"
	desc = "A reasonably comfortable piece of clothing made of sweat absorbing materials. This piece of clothing is designed to keep you cool even when sitting at your station for hours on end."
	icon_state = "officer"
	item_color = "officer"
	item_state = "bl_suit"
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	can_adjust = TRUE

/obj/item/clothing/under/ship/peacekeeper
	name = "Peacekeeper uniform"
	desc = "A padded jumpsuit worn exclusively by North Star peacekeeper forces. It's designed to be lightweight enough for patrols, but sturdy enough to keep you alive in CQB scenarios."
	icon_state = "peacekeeper"
	item_color = "peacekeeper"
	item_state = "bl_suit"
	armor = list("melee" = 10, "bullet" = 10, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 30)
	strip_delay = 50
	sensor_mode = SENSOR_COORDS
	random_sensor = FALSE
	can_adjust = TRUE

/obj/item/clothing/under/ship/engineer
	name = "Engineer's jumpsuit"
	desc = "A thick jumpsuit made of insulated materials which is worn by NT's engineering corps, it's rare to see one of these that isn't covered in layers of engine grease."
	icon_state = "engine"
	item_color = "engine"
	item_state = "bl_suit"
	can_adjust = TRUE

/obj/item/clothing/under/ship/medical
	name = "Doctor's jumpsuit"
	desc = "A durable jumpsuit made of hydrophobic materials which should help keep the blood off."
	icon_state = "medical"
	item_color = "medical"
	item_state = "bl_suit"

/obj/item/clothing/suit/ship
	name = "Placeholder"
	icon = 'nsv13/icons/obj/clothing/suits.dmi' //Placeholder subtype for our own iconsets
	alternate_worn_icon = 'nsv13/icons/mob/suit.dmi'

/obj/item/clothing/suit/ship/peacekeeper
	name = "Peacekeer vest"
	icon_state = "peacekeeper_vest"
	item_state = "peacekeeper_vest"
	desc = "A nanoweave vest capable of impeding most small arms fire as well as improvised weapons. It bears the logo of the North Star peacekeeper force"
	body_parts_covered = CHEST
	cold_protection = CHEST|GROIN
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	strip_delay = 60
	equip_delay_other = 40
	max_integrity = 250
	resistance_flags = NONE
	armor = list("melee" = 30, "bullet" = 40, "laser" = 0, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 60)

/obj/item/clothing/suit/ship/peacekeeper/jacket
	name = "Peacekeeper jacket"
	icon_state = "peacekeeper_jacket"
	item_state = "peacekeeper_jacket"
	desc = "A comfortable grey leather jacket. Despite its heavy armour, it's still extremely comfortable to wear."

/obj/item/clothing/suit/ship/peacekeeper/marine
	name = "NT-4 Marine vest"
	icon_state = "marine"
	item_state = "marine"
	desc = "A bulky vest worn by the colonial peacekeepers. Its nanocarbon mesh fabrics are sure to stop almost any projectile."
	armor = list("melee" = 30, "bullet" = 45, "laser" = 10, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 60)

/obj/item/clothing/suit/ship/officer
	name = "Officer's dress jacket"
	desc = "A rather heavy jacket of a reasonable quality. It's not the most comfortable thing you could wear, but it's remained part of an officer's uniform for quite some time."
	icon_state = "officer_jacket"

/obj/item/clothing/suit/ship/engineer
	name = "Engineering webbing"
	desc = "A basic storage vest which allows you to store a few small tools"
	icon_state = "engineer_vest"
	allowed = list(/obj/item/wrench, /obj/item/weldingtool, /obj/item/wirecutters, /obj/item/screwdriver, /obj/item/extinguisher, /obj/item/crowbar, /obj/item/analyzer, /obj/item/multitool, /obj/item/modular_computer/tablet)

/obj/item/clothing/head/ship
	name = "placeholder"
	icon = 'nsv13/icons/obj/clothing/hats.dmi' //Placeholder subtype for our own iconsets
	alternate_worn_icon = 'nsv13/icons/mob/head.dmi'
	icon_state = "beret"
	item_color = null

/obj/item/clothing/head/ship/marine
	name = "Nt-4 Marine helmet"
	desc = "A large helmet made out of damage resistant materials."
	icon = 'nsv13/icons/obj/clothing/hats.dmi' //Placeholder subtype for our own iconsets
	alternate_worn_icon = 'nsv13/icons/mob/head.dmi'
	icon_state = "marine"
	item_color = null
	armor = list("melee" = 20, "bullet" = 20, "laser" = 10,"energy" = 5, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)

/obj/item/clothing/head/beret/ship
	name = "beret"
	desc = "A beret, a mime's favorite headwear."
	icon = 'nsv13/icons/obj/clothing/hats.dmi' //Placeholder subtype for our own iconsets
	alternate_worn_icon = 'nsv13/icons/mob/head.dmi'
	icon_state = "beret"
	item_color = null

/obj/item/clothing/head/beret/ship/captain
	name = "captain's beret"
	desc = "An extremely comfortable cotton beret. It is emblazened with Nanotrasen's insignia and is only worn by those who have proven themselves."
	icon_state = "captain"
	armor = list("melee" = 15, "bullet" = 5, "laser" = 0, "energy" = 5, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 5)

/obj/item/clothing/head/beret/ship/xo
	name = "XO's beret"
	desc = "A very comfortable beret worn by a ship's second in command. If you're seeing this, you should probably salute"
	icon_state = "xo"
	armor = list("melee" = 15, "bullet" = 5, "laser" = 0, "energy" = 5, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 5)

/obj/item/clothing/head/beret/ship/cag
	name = "CAG's beret"
	desc = "A sturdy beret worn by air group commanders, this stunning beret is designed to make CAGs feel confident in their leadership."
	icon_state = "xo"
	armor = list("melee" = 15, "bullet" = 5, "laser" = 0, "energy" = 5, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 5)

/obj/item/clothing/head/beret/ship/engineer
	name = "engineer's beret"
	desc = "In parts a fashion statement and a hard hat, this beret has been specially reinforced to protect its wearer against workplace accidents."
	icon_state = "engineer"
	armor = list("melee" = 15, "bullet" = 0, "laser" = 0, "energy" = 5, "bomb" = 10, "bio" = 0, "rad" = 5, "fire" = 30, "acid" = 5)

/obj/item/clothing/head/radiation //CREDIT TO GOON FOR THE SPRITE!
	name = "hazmat hood"
	desc = "A lead lined hood which is guaranteed to keep you safe from harmful nuclear emissions. Recommended by 9/10 nuclear engineers."
	icon = 'nsv13/icons/obj/clothing/hats.dmi' //Placeholder subtype for our own iconsets
	alternate_worn_icon = 'nsv13/icons/mob/head.dmi'

/obj/item/clothing/suit/radiation //CREDIT TO GOON FOR THE SPRITE!
	name = "hazmat suit"
	icon = 'nsv13/icons/obj/clothing/suits.dmi' //Placeholder subtype for our own iconsets
	alternate_worn_icon = 'nsv13/icons/mob/suit.dmi'

	//Hardsuits
/obj/item/clothing/head/helmet/space/hardsuit/pilot
	name = "fighter pilot helmet"
	icon = 'nsv13/icons/obj/clothing/hats.dmi'
	alternate_worn_icon = 'nsv13/icons/mob/head.dmi'
	icon_state = "hardsuit0-pilot_helmet"
	item_state = "pilot_helmet"
	item_color = "pilot_helmet"
	desc = "A lightweight space-helmet designed to protect fighter pilots in combat situations."
	armor = list("melee" = 20, "bullet" = 30, "laser" = 10, "energy" = 10, "bomb" = 70, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR //we want to see the mask
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT

/obj/item/clothing/suit/space/hardsuit/pilot
	name = "fighter pilot flightsuit"
	desc = "A space-proof flightsuit worn by fighter pilots in the Nanotrasen navy. It has been specially reinforced to protect its wearer against most threats."
	icon = 'nsv13/icons/obj/clothing/suits.dmi'
	alternate_worn_icon = 'nsv13/icons/mob/suit.dmi'
	icon_state = "pilot"
	item_state = "pilot"
	item_color = "pilot"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/pilot
	armor = list("melee" = 40, "bullet" = 50, "laser" = 50, "energy" = 25, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT //this needed to be added a long fucking time ago

/obj/item/clothing/under/ship/pilot
	name = "Pilot's combat jumpsuit"
	desc = "A lightweight jumpsuit with harness points and carabiners which is designed to be worn with a pilot's flightsuit."
	icon_state = "pilot"
	item_color = "pilot"
	item_state = "bl_suit"

/obj/item/clothing/head/beret/ship/pilot
	name = "pilot's beret"
	desc = "In parts a fashion statement and a hard hat, this beret has been specially reinforced to protect its wearer against workplace accidents."
	icon_state = "pilot"
	armor = list("melee" = 15, "bullet" = 0, "laser" = 0, "energy" = 5, "bomb" = 10, "bio" = 0, "rad" = 5, "fire" = 30, "acid" = 5)