/obj/item
	
/* Species-specific sprites, stolen from Baystation, Paradise, /vg/, Oraclestation.
ex:
sprite_sheets = list(
	"Vox" = 'icons/mob/species/vox/head.dmi'
	)
If index term exists and icon_override is not set, this sprite sheet will be used.
*/
	var/list/sprite_sheets = null
	var/icon_override = null  //Used to override hardcoded clothing dmis in human clothing proc.
	var/sprite_sheets_obj = null //Used to override hardcoded clothing inventory object dmis in human clothing proc.
	var/list/species_fit = null //This object has a different appearance when worn by these species