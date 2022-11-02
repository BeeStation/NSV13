/////////////////////////////////////
//////////Limb Grower Designs ///////
/////////////////////////////////////

/datum/design/leftarm
	name = "Left Arm"
	id = "leftarm"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 25)
	build_path = /obj/item/bodypart/l_arm
	category = list("initial","human","lizard","moth","apid","plasmaman","ethereal")

/datum/design/rightarm
	name = "Right Arm"
	id = "rightarm"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 25)
	build_path = /obj/item/bodypart/r_arm
	category = list("initial","human","lizard","moth","apid","plasmaman","ethereal")

/datum/design/leftleg
	name = "Left Leg"
	id = "leftleg"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 25)
	build_path = /obj/item/bodypart/l_leg
	category = list("initial","human","lizard","moth","apid","plasmaman","ethereal")

/datum/design/rightleg
	name = "Right Leg"
	id = "rightleg"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 25)
	build_path = /obj/item/bodypart/r_leg
	category = list("initial","human","lizard","moth","apid","plasmaman","ethereal")

/datum/design/digi_leftleg
	name = "Digitigrade Left Leg"
	id = "digi_leftleg"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 30)
	build_path = /obj/item/bodypart/l_leg/digitigrade
	category = list("lizard")

/datum/design/digi_rightleg
	name = "Digitigrade Right Leg"
	id = "digi_rightleg"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 30)
	build_path = /obj/item/bodypart/r_leg/digitigrade
	category = list("lizard")

//Non-limb limb designs

//Heart
/datum/design/heart
	name = "Heart"
	id = "heart"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 30)
	build_path = /obj/item/organ/heart
	category = list("initial","human")

//Lungs
/datum/design/lungs
	name = "Lungs"
	id = "lungs"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 20)
	build_path = /obj/item/organ/lungs
	category = list("initial","human")

/datum/design/plasmaman_lungs
	name = "Plasma Filter"
	id = "plasmamanlungs"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10, /datum/reagent/toxin/plasma = 20)
	build_path = /obj/item/organ/lungs/plasmaman
	category = list("plasmaman")

/datum/design/apid_lungs
	name = "Apid Lungs"
	id = "apidlungs"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10, /datum/reagent/consumable/honey = 20)
	build_path = /obj/item/organ/lungs/apid
	category = list("apid")

//Liver
/datum/design/liver
	name = "Liver"
	id = "liver"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 20)
	build_path = /obj/item/organ/liver
	category = list("initial","human")

/datum/design/plasmaman_liver
	name = "Reagent Processing Crystal"
	id = "plasmamanliver"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10, /datum/reagent/toxin/plasma = 20)
	build_path = /obj/item/organ/liver/plasmaman
	category = list("plasmaman")

//Stomach
/datum/design/stomach
	name = "Stomach"
	id = "stomach"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 15)
	build_path = /obj/item/organ/stomach
	category = list("initial","human")

/datum/design/plasmaman_stomach
	name = "Digestive Crystal"
	id = "plasmamanstomach"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10, /datum/reagent/toxin/plasma = 20)
	build_path = /obj/item/organ/stomach/plasmaman
	category = list("plasmaman")

/datum/design/ethereal_stomach
	name = "Biological Battery"
	id = "etherealstomach"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10, /datum/reagent/consumable/liquidelectricity = 20)
	build_path = /obj/item/organ/stomach/battery/ethereal
	category = list("ethereal")

//Appendix
/datum/design/appendix
	name = "Appendix"
	id = "appendix"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 5) //why would you need this
	build_path = /obj/item/organ/appendix
	category = list("initial","human")

//Eyes
/datum/design/eyes
	name = "Eyes"
	id = "eyes"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10)
	build_path = /obj/item/organ/eyes
	category = list("initial","human")

/datum/design/moth_eyes
	name = "Moth Eyes"
	id = "motheyes"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 25)
	build_path = /obj/item/organ/eyes/moth
	category = list("moth")

/datum/design/apid_eyes
	name = "Apid Eyes"
	id = "apideyes"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 25)
	build_path = /obj/item/organ/eyes/apid
	category = list("apid")

//Ears
/datum/design/ears
	name = "Ears"
	id = "ears"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10)
	build_path = /obj/item/organ/ears
	category = list("initial","human")

/datum/design/cat_ears
	name = "Cat Ears"
	id = "catears"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10)
	build_path = /obj/item/organ/ears/cat
	category = list("human")

//Tongues
/datum/design/tongue
	name = "Tongue"
	id = "tongue"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10)
	build_path = /obj/item/organ/tongue
	category = list("initial","other")

/datum/design/lizard_tongue
	name = "Forked Tongue"
	id = "liztongue"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 20)
	build_path = /obj/item/organ/tongue/lizard
	category = list("other")

/datum/design/plasmaman_tongue
	name = "Plasma Bone Tongue"
	id = "plasmamantongue"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10, /datum/reagent/toxin/plasma = 20)
	build_path = /obj/item/organ/tongue/bone/plasmaman
	category = list("other")

/datum/design/ethereal_tongue
	name = "Electrical Discharger"
	id = "etherealtongue"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10, /datum/reagent/consumable/liquidelectricity = 20)
	build_path = /obj/item/organ/tongue/ethereal
	category = list("other")

/datum/design/apid_tongue
	name = "Proboscis"
	id = "apidtongue"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 10, /datum/reagent/consumable/honey = 20)
	build_path = /obj/item/organ/tongue/bee
	category = list("other")

//Tails
/datum/design/lizard_tail
	name = "Lizard Tail"
	id = "liztail"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 20)
	build_path = /obj/item/organ/tail/lizard/fake
	category = list("lizard")

/datum/design/cat_tail
	name = "Cat Tail"
	id = "cattail"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 20)
	build_path = /obj/item/organ/tail/cat
	category = list("human")

//Wings
/datum/design/moth_wings
	name = "Moth Wings"
	id = "mothwings"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 25)
	build_path = /obj/item/organ/wings/moth
	category = list("moth")

/datum/design/apid_wings
	name = "Apid Wings"
	id = "apidwings"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 25)
	build_path = /obj/item/organ/wings/bee
	category = list("apid")


// Intentionally not growable by normal means - for balance conerns.

/datum/design/armblade
	name = "Arm Blade"
	id = "armblade"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/synthflesh = 75)
	build_path = /obj/item/melee/synthetic_arm_blade
	category = list("other","emagged")

/// Design disks and designs - for adding limbs and organs to the limbgrower.
/obj/item/disk/design_disk/limbs
	name = "Limb Design Disk"
	desc = "A disk containing limb and organ designs for a limbgrower."
	icon_state = "datadisk1"
	/// List of all limb designs this disk contains.
	var/list/limb_designs = list()

/obj/item/disk/design_disk/limbs/Initialize()
	. = ..()
	max_blueprints = limb_designs.len
	for(var/design in limb_designs)
		var/datum/design/new_design = design
		blueprints += new new_design

/datum/design/limb_disk
	name = "Limb Design Disk"
	desc = "Contains designs for various limbs."
	id = "limbdesign_parent"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 300, /datum/material/glass = 100)
	build_path = /obj/item/disk/design_disk/limbs
	category = list("Medical Designs")
	departmental_flags = DEPARTMENTAL_FLAG_MEDICAL

/obj/item/disk/design_disk/limbs/debug
	name = "Debug Limb Design Disk"
	desc = "You should not have this unless you are debugging stuff or trying to adminbus."
	limb_designs = list(/datum/design/cat_tail, /datum/design/cat_ears,
		/datum/design/lizard_tail, /datum/design/lizard_tongue, /datum/design/digi_leftleg, /datum/design/digi_rightleg,
		/datum/design/apid_wings, /datum/design/apid_eyes, /datum/design/apid_lungs, /datum/design/apid_tongue,
		/datum/design/moth_wings, /datum/design/moth_eyes,
		/datum/design/plasmaman_stomach, /datum/design/plasmaman_liver, /datum/design/plasmaman_lungs, /datum/design/plasmaman_tongue,
		/datum/design/ethereal_stomach, /datum/design/ethereal_tongue)

/obj/item/disk/design_disk/limbs/felinid
	name = "Felinid Limb Design Disk"
	limb_designs = list(/datum/design/cat_tail, /datum/design/cat_ears)

/datum/design/limb_disk/felinid
	name = "Felinid Limb Design Disk"
	desc = "Contains designs for felinid bodyparts for the limbgrower - Felinid ears and tail."
	id = "limbdesign_felinid"
	build_path = /obj/item/disk/design_disk/limbs/felinid

/obj/item/disk/design_disk/limbs/lizard
	name = "Lizard Limb Design Disk"
	limb_designs = list(/datum/design/lizard_tail, /datum/design/lizard_tongue, /datum/design/digi_leftleg, /datum/design/digi_rightleg)

/datum/design/limb_disk/lizard
	name = "Lizard Limb Design Disk"
	desc = "Contains designs for lizard bodyparts for the limbgrower - Lizard tongue, tail, and digitigrade legs."
	id = "limbdesign_lizard"
	build_path = /obj/item/disk/design_disk/limbs/lizard

/obj/item/disk/design_disk/limbs/apid
	name = "Apid Limb Design Disk"
	limb_designs = list(/datum/design/apid_wings, /datum/design/apid_eyes, /datum/design/apid_lungs, /datum/design/apid_tongue)

/datum/design/limb_disk/apid
	name = "Apid Limb Design Disk"
	desc = "Contains designs for apid organs for the limbgrower - Apid wings, Apid eyes, lungs and tongue."
	id = "limbdesign_apid"
	build_path = /obj/item/disk/design_disk/limbs/apid

/obj/item/disk/design_disk/limbs/moth
	name = "Moth Limb Design Disk"
	limb_designs = list(/datum/design/moth_wings, /datum/design/moth_eyes)

/datum/design/limb_disk/moth
	name = "Moth Limb Design Disk"
	desc = "Contains designs for moth organs for the limbgrower - Moth wings and Moth eyes."
	id = "limbdesign_moth"
	build_path = /obj/item/disk/design_disk/limbs/moth

/obj/item/disk/design_disk/limbs/plasmaman
	name = "Plasmaman Limb Design Disk"
	limb_designs = list(/datum/design/plasmaman_stomach, /datum/design/plasmaman_liver, /datum/design/plasmaman_lungs, /datum/design/plasmaman_tongue)

/datum/design/limb_disk/plasmaman
	name = "Plasmaman Limb Design Disk"
	desc = "Contains designs for plasmaman organs for the limbgrower - Plasmaman tongue, liver, stomach, and lungs."
	id = "limbdesign_plasmaman"
	build_path = /obj/item/disk/design_disk/limbs/plasmaman

/obj/item/disk/design_disk/limbs/ethereal
	name = "Ethereal Limb Design Disk"
	limb_designs = list(/datum/design/ethereal_stomach, /datum/design/ethereal_tongue)

/datum/design/limb_disk/ethereal
	name = "Ethereal Limb Design Disk"
	desc = "Contains designs for ethereal organs for the limbgrower - Ethereal tongue and stomach."
	id = "limbdesign_ethereal"
	build_path = /obj/item/disk/design_disk/limbs/ethereal
