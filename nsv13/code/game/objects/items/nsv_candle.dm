/obj/item/candle/incense
	name = "Incense"
	desc = "Though incense is common all throughout the Federation, the Dominion is particularly known for it's use of incense. This one smells like sandalwood."
	icon = 'nsv13/icons/obj/incense.dmi'
	icon_state = "candle_teal_off"
	item_state = "candle_teal_off"
	light_color = LIGHT_COLOR_FIRE
	heat = 2000
	wax = 500

/obj/item/candle/incense/update_icon()
	icon_state = "[lit ? "candle_teal_lit" : ""]"

/obj/item/candle/incense/pink
	name = "Pink Incense"
	desc = "The Dominion is known for its use of incense in religious ceremony, this one smells like the dawn of winter, a breeze of cold and a shiver through ones spine."
	icon_state = "candle_pink_off"
	item_state = "candle_pink_off"

/obj/item/candle/incense/pink/update_icon()
	icon_state = "[lit ? "candle_pink_lit" : ""]"
