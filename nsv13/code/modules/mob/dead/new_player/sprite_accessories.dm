//Sprite accessories, aka hairs, mutantparts, facial hairs.
//Handled this way because I added a mutparts offset adding full support for them to apply to any race.
//Also solves the surgerical additions to human/reskinned humans from different mob body.

/*--------Variables contained in sprite_accessory.dm ------------
	icon			//the icon file the accessory is located in
	icon_state		//the icon_state of the accessory
	name			//the preview name of the accessory
	gender = NEUTER	//Determines if the accessory will be skipped or included in random hair generations
	gender_specific //Something that can be worn by either gender, but looks different on each
	color_src = MUTCOLORS	//Currently only used by mutantparts so don't worry about hair and stuff. This is the source that this accessory will get its color from. Default is MUTCOLOR, but can also be HAIR, FACEHAIR, EYECOLOR and 0 if none.
	hasinner		//Decides if this sprite has an "inner" part, such as the fleshy parts on ears.
	locked = FALSE		//Is this part locked from roundstart selection? Used for parts that apply effects
	dimension_x = 32
	dimension_y = 32
	center = FALSE	//Should we center the sprite?
*/

//Mutant teeth
/datum/sprite_accessory/teeth
	color_src = 0 //we handle this on icon. basically sets recoloring to false.
	icon = 'nsv13/icons/mob/mutantbodyparts.dmi'

/datum/sprite_accessory/teeth/lowercanineslong
	name = "Long Lower Canines" //Name for species features
	icon_state = "lowercanineslong" //and their state, handled classic style aka it uses statename to assess handling.
	color_src = 0 //By statename, the segment after it handles what layer each icon appears on to create the sum.

//Troll_horns
/datum/sprite_accessory/troll_horns
	color_src = 0
	icon = 'nsv13/icons/mob/mutantbodyparts.dmi'

/datum/sprite_accessory/troll_horns/devilhorns
	name = "Devil"
	icon_state = "devil"

/datum/sprite_accessory/troll_horns/ramhorns
	name = "Ram"
	icon_state = "ram"