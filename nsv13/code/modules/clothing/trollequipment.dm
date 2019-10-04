//Contained within is the SR Troll Mob Bodytype equipment.

//Really all they should ever need (If you decide to give them anything)
//Would be suits and uniforms, as they are only 3px taller than a human for effect.

//Parent restrictions - I mostly handled it this way since this needs to be seperate and low maintenance.
/obj/item/clothing/suit/troll
	species_restricted = list("Troll")
	icon = 'icons/obj/clothing/suits.dmi' //OBJ Icon Path - Object representation.
	alternate_worn_icon = 'nsv13/icons/mob/trollequipment.dmi' //MOB Icon path - When worn on mob

/obj/item/clothing/suit/troll/ship
	icon = 'nsv13/icons/obj/clothing/suits.dmi' //Two lines for eerything, versus setting it on each.

/obj/item/clothing/under/troll
	species_restricted = list("Troll") 
	icon = 'icons/obj/clothing/uniforms.dmi' //Default File for now. OBJ Icon Path
	alternate_worn_icon = 'nsv13/icons/mob/trollequipment.dmi' //Not enough to warrant a split.
	can_adjust = FALSE //Set it to true if you want a alternate mob icon display on right click verb toggles.
	has_sensor = NO_SENSORS //Cost saving measure on non-human outfits.
	fitted = NO_FEMALE_UNIFORM //No female specific uniforms.

/obj/item/clothing/under/troll/ship
	icon = 'nsv13/icons/obj/clothing/uniforms.dmi' //Another var on parent.

/*
	UNDERSHIRTS - Aka Uniforms, Jumpsuits.
											*/

//Security Uniform Variant
/obj/item/clothing/under/troll/ship/peacekeeper 
	name = "Peacekeeper uniform"
	desc = "A padded jumpsuit worn exclusively by North Star peacekeeper forces. It's designed to be lightweight enough for patrols, but sturdy enough to keep you alive in CQB scenarios. This one is sized for a troll."
	icon_state = "peacekeeper"
	item_color = "peacekeeper"
	item_state = "bl_suit"
	armor = list("melee" = 10, "bullet" = 10, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 30)
	strip_delay = 50

//Janitor Uniform Variant
/obj/item/clothing/under/troll/janitor
	desc = "It's the official uniform of the station's janitor in troll size. It has minor protection from biohazards."
	name = "janitor's jumpsuit"
	icon_state = "janitor"
	item_color = "janitor"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0)

//Cargotech Uniform Variant
/obj/item/clothing/under/troll/cargotech 
	name = "cargo technician's jumpsuit"
	desc = "Shooooorts! They're comfy and easy to wear! XXXL Troll Sized."
	icon_state = "cargotech"
	item_state = "lb_suit"
	item_color = "cargo"
	body_parts_covered = CHEST|GROIN|ARMS

// Bartender Uniform Variant
/obj/item/clothing/under/troll/bartender 
	desc = "It looks like it could use some more flair, and probably a massive body to wear it."
	name = "bartender's uniform"
	icon_state = "barman"
	item_state = "bar_suit"
	item_color = "barman"

//Cook Uniform Variant
/obj/item/clothing/under/troll/chef
	name = "cook's suit"
	desc = "A massive suit which is given only to the most <b>hardcore</b> troll cooks in space."
	icon_state = "chef"
	item_color = "chef_uniform"

//Botanist Uniform Variant
/obj/item/clothing/under/troll/hydroponics 
	desc = "It's a massive jumpsuit designed to protect against minor plant-related hazards to a trolls body."
	name = "botanist's jumpsuit"
	icon_state = "hydroponics"
	item_state = "g_suit"
	item_color = "hydroponics"
	permeability_coefficient = 0.5

//Assistant Uniform Variant
/obj/item/clothing/under/troll/grey 
	name = "grey jumpsuit"
	desc = "A tasteful grey jumpsuit that reminds you of the good old days, or probably most of your days If you are the troll this is ment for."
	icon_state = "grey"
	item_state = "gy_suit"
	item_color = "grey"

/*
	SUITS - Aka Armor, Spacesuits etc.
										*/

//Security Armor Variant
/obj/item/clothing/suit/troll/ship/peacekeeper  
	name = "Peacekeer vest"
	icon_state = "peacekeeper_vest"
	item_state = "peacekeeper_vest"
	desc = "A nanoweave vest capable of impeding most small arms fire as well as improvised weapons. It bears the logo of the North Star peacekeeper force. This one is sized for a troll."
	body_parts_covered = CHEST
	cold_protection = CHEST|GROIN
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	strip_delay = 60
	equip_delay_other = 40
	max_integrity = 250
	resistance_flags = NONE //Ha ha jokes on these guys, their armor was substandard since nonhuman.
	armor = list("melee" = 15, "bullet" = 20, "laser" = 0, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 60)

//Bartender armor vest variant
/obj/item/clothing/suit/troll/vest
	name = "armor vest"
	desc = "A extremely over-sized but slim Type I armored vest that provides decent protection against most types of damage, If you are a troll."
	icon_state = "armoralt"
	item_state = "armoralt"
	blood_overlay_type = "armor"
	dog_fashion = /datum/dog_fashion/back
	allowed = null
	body_parts_covered = CHEST
	cold_protection = CHEST|GROIN
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	strip_delay = 60
	equip_delay_other = 40
	max_integrity = 250
	resistance_flags = NONE 
	armor = list("melee" = 15, "bullet" = 20, "laser" = 0, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 50)

/obj/item/clothing/suit/troll/vest/Initialize()
	. = ..()
	if(!allowed)
		allowed = GLOB.security_vest_allowed

//Cook Toggle Jacket Variant
/obj/item/clothing/suit/troll/chef
	name = "chef's jacket"
	desc = "An extremely oversized apron-jacket used by a high class troll chef."
	icon_state = "chef"
	item_state = "chef"
	gas_transfer_coefficient = 0.9
	permeability_coefficient = 0.5
	body_parts_covered = CHEST|GROIN|ARMS
	allowed = list(/obj/item/kitchen)

/obj/item/clothing/suit/troll/spacesuit
	name = "Troll-Sized space suit"
	desc = "A suit that protects against low pressure environments. The quality of this spacesuit seems to be questionable."
	icon_state = "space"
	item_state = "s_suit"
	w_class = WEIGHT_CLASS_BULKY
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	clothing_flags = STOPSPRESSUREDAMAGE | THICKMATERIAL
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals)
	slowdown = 1
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 70, "rad" = 20, "fire" = 20, "acid" = 30)
	flags_inv = HIDEGLOVES|HIDESHOES|HIDEJUMPSUIT
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	strip_delay = 80
	equip_delay_other = 80
	resistance_flags = NONE