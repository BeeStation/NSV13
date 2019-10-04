//Contained within is the SR Ork Mob Bodytype equipment.

//Really all they should ever need (If you decide to give them anything)
//Would be suits and uniforms, as they are 1px taller than a human for effect.

//Parent restrictions - I mostly handled it this way since this needs to be seperate and low maintenance.
/obj/item/clothing/suit/ork
	species_restricted = list("Ork")
	icon = 'icons/obj/clothing/suits.dmi' //OBJ Icon Path - Object representation.
	alternate_worn_icon = 'nsv13/icons/mob/orkequipment.dmi' //MOB Icon path - When worn on mob

/obj/item/clothing/suit/ork/ship
	icon = 'nsv13/icons/obj/clothing/suits.dmi' //Two lines for eerything, versus setting it on each.

/obj/item/clothing/under/ork
	species_restricted = list("Ork") 
	icon = 'icons/obj/clothing/uniforms.dmi' //Default File for now.
	alternate_worn_icon = 'nsv13/icons/mob/orkequipment.dmi' //Not enough to warrant a split.
	can_adjust = FALSE //Set it to true if you want a alternate mob icon display on right click verb toggles.
	has_sensor = NO_SENSORS //Cost saving measure on non-human outfits.
	fitted = NO_FEMALE_UNIFORM //No female specific uniforms.

/obj/item/clothing/under/ork/ship
	icon = 'nsv13/icons/obj/clothing/uniforms.dmi' //Swapping to the other path here too.

/*
	UNDERSHIRTS - Aka Uniforms, Jumpsuits.
											*/

//Detective Uniform Variant 
/obj/item/clothing/under/ork/det 
	name = "hard-worn suit"
	desc = "Someone who wears this means business, and is also the size of a NFL Linebacker"
	icon_state = "detective" //THIS IS THE OBJ ICON STATE
	item_state = "det" //THIS IS APPARENTLY THE INHAND
	item_color = "detective_uniform" //AND THIS IS THE MOB ICON STATE, AND DYE COLOR ON UNDERS.
	armor = list("melee" = 5, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 30)
	strip_delay = 50

//Security Uniform Variant 
/obj/item/clothing/under/ork/ship/peacekeeper 
	name = "Peacekeeper uniform"
	desc = "A padded jumpsuit worn exclusively by North Star peacekeeper forces. It's designed to be lightweight enough for patrols, but sturdy enough to keep you alive in CQB scenarios. This particular one is ork sized."
	icon_state = "peacekeeper"
	item_color = "peacekeeper"
	item_state = "bl_suit"
	armor = list("melee" = 5, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 15, "acid" = 30)
	strip_delay = 50

//Janitor Uniform Variant
/obj/item/clothing/under/ork/janitor
	desc = "It's the official uniform of the station's janitor in ork size. It has minor protection from biohazards."
	name = "janitor's jumpsuit"
	icon_state = "janitor"
	item_color = "janitor"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 0, "fire" = 0, "acid" = 0)

//Quartermaster Uniform Variant
/obj/item/clothing/under/ork/cargo 
	name = "quartermaster's jumpsuit"
	desc = "It's a jumpsuit worn by the quartermaster. It's specially designed to prevent back injuries caused by pushing paper. This one is sized for the occassional ork who worked their way up the ranks."
	icon_state = "qm"
	item_state = "lb_suit"
	item_color = "qm"

//Cargotech Uniform Variant
/obj/item/clothing/under/ork/cargotech 
	name = "cargo technician's jumpsuit"
	desc = "Shooooorts! They're comfy and easy to wear! Especially when this size!"
	icon_state = "cargotech"
	item_state = "lb_suit"
	item_color = "cargo"
	body_parts_covered = CHEST|GROIN|ARMS

// Bartender Uniform Variant
/obj/item/clothing/under/ork/bartender 
	desc = "It looks like it could use some more flair, and probably only fits a larger humans body."
	name = "bartender's uniform"
	icon_state = "barman"
	item_state = "bar_suit"
	item_color = "barman"

//Cook Uniform Variant
/obj/item/clothing/under/ork/chef 
	name = "cook's suit"
	desc = "A suit which is given only to the most <b>hardcore</b> cooks in space. This one is made for a ork hash slinger."
	icon_state = "chef"
	item_color = "chef_uniform"

//Botanist Uniform Variant
/obj/item/clothing/under/ork/hydroponics 
	desc = "It's a jumpsuit designed to protect against minor plant-related hazards. Its larger than normal."
	name = "botanist's jumpsuit"
	icon_state = "hydroponics"
	item_state = "g_suit"
	item_color = "hydroponics"
	permeability_coefficient = 0.5

//Clown Uniform Variant
/obj/item/clothing/under/ork/clown 
	name = "XL clown suit"
	desc = "<i>'HONK!'</i>"
	icon_state = "clown"
	item_state = "clown"
	item_color = "clown"

//Assistant Uniform Variant
/obj/item/clothing/under/ork/grey 
	name = "XL grey jumpsuit"
	desc = "A tasteful grey jumpsuit that reminds you of the good old days, or in this case your low prospect of promotion."
	icon_state = "grey"
	item_state = "gy_suit"
	item_color = "grey"

/*
	SUITS - Aka Armor, Spacesuits etc.
										*/

//Detective Jacket Variant
/obj/item/clothing/suit/ork/det_suit
	name = "trenchcoat"
	desc = "An 18th-century multi-purpose XL trenchcoat. The ork who wears this means serious business."
	icon_state = "detective"
	item_state = "det_suit"
	blood_overlay_type = "coat"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	armor = list("melee" = 25, "bullet" = 10, "laser" = 25, "energy" = 10, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 45)
	cold_protection = CHEST|GROIN|LEGS|ARMS
	heat_protection = CHEST|GROIN|LEGS|ARMS

/obj/item/clothing/suit/ork/det_suit/Initialize() //Gives the variant its suit storage item list.
	. = ..()
	allowed = GLOB.detective_vest_allowed

//Security Armor Variant
/obj/item/clothing/suit/ork/ship/peacekeeper
	name = "Peacekeer vest"
	icon_state = "peacekeeper_vest"
	item_state = "peacekeeper_vest"
	desc = "A nanoweave vest capable of impeding most small arms fire as well as improvised weapons. It bears the logo of the North Star peacekeeper force. This particular one is ork sized."
	body_parts_covered = CHEST
	cold_protection = CHEST|GROIN
	min_cold_protection_temperature = ARMOR_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN
	max_heat_protection_temperature = ARMOR_MAX_TEMP_PROTECT
	strip_delay = 60
	equip_delay_other = 40
	max_integrity = 250
	resistance_flags = NONE //Ha ha jokes on these guys, their armor was substandard since nonhuman.
	armor = list("melee" = 15, "bullet" = 20, "laser" = 0, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 50)

// Bartender Armor vest Variant.
/obj/item/clothing/suit/ork/vest 
	name = "armor vest"
	desc = "A slim but upsized Type I armored vest that provides decent protection against most types of damage."
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

/obj/item/clothing/suit/ork/vest/Initialize() //Gives the variant its suit storage item list.
	. = ..()
	if(!allowed)
		allowed = GLOB.security_vest_allowed

//Cook Toggle Jacket Variant
/obj/item/clothing/suit/ork/chef
	name = "chef's jacket"
	desc = "An extra large apron-jacket used by a high class chef."
	icon_state = "chef" //AH YES, THE FUCKING OBJ AND MOB SHARE THE SAME ICON STATES.
	item_state = "chef" //And this is the inhand.
	gas_transfer_coefficient = 0.9
	permeability_coefficient = 0.5
	body_parts_covered = CHEST|GROIN|ARMS
	allowed = list(/obj/item/kitchen)

/obj/item/clothing/suit/ork/spacesuit
	name = "ork-sized space suit"
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