/*
 * Zawartość:
 *		opaski różno kolorowe oraz specjalne
 *		kask motocyklowy
 *		kask Riczard'a
 *		kaptur kostiumu ducha
 */
/****************************\
|*********** opaski **********|
\****************************/
/obj/item/clothing/head/aquila/headband //zwykła ma być biała, edycja opaski z kolorami
	name = "white headband"
	desc = "An headband. It looks badass."
	icon_state = "headband"
	clothing_flags = SNUG_FIT
	custom_price = 10
	w_class = WEIGHT_CLASS_SMALL
	dynamic_hair_suffix = ""

/obj/item/clothing/head/aquila/headband/black
	name = "cool black headband"
	desc = "An robust black headband. Uses normal fabric to offer zero protection. It looks badass."
	icon_state = "headband"
	color = "#4A4A4B"

/obj/item/clothing/head/aquila/headband/red
	name = "red headband"
	icon_state = "headband"
	color = "#D91414"

/obj/item/clothing/head/aquila/headband/pink
	name = "pink headband"
	icon_state = "headband"
	color = "#a835a3"

/obj/item/clothing/head/aquila/headband/green
	name = "green headband"
	icon_state = "headband"
	color = "#43ad37"

/obj/item/clothing/head/aquila/headband/blue
	name = "blue headband"
	icon_state = "headband"
	color = "#0e51e2"

/obj/item/clothing/head/aquila/headband/purple
	name = "purple headband"
	icon_state = "headband"
	color = "#9557C5"

/obj/item/clothing/head/aquila/headband/yellow
	name = "yellow headband"
	icon_state = "headband"
	color = "#E0C14F"

/obj/item/clothing/head/aquila/headband/orange
	name = "orange headband"
	icon_state = "headband"
	color = "#ff6200"

/obj/item/clothing/head/aquila/headband/cyan
	name = "cyan headband"
	icon_state = "headband"
	color = "#0ccce6"

//opaski specjalne
/obj/item/clothing/head/aquila/headband/red/sec
	name = "red headband"
	desc = "An robust red headband. Uses reinforced fabric to offer protection. It looks badass."
	icon_state = "headband"
	armor = list("melee" = 15, "bullet" = 5, "laser" = 15, "energy" = 5, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 5, "stamina" = 20)
	strip_delay = 15

/obj/item/clothing/head/aquila/headband/black/solid //twarda metalowa zębatka
	name = "cool black headband"
	desc = "An robust black headband. Uses reinforced fabric to offer protection. It looks badass."
	armor = list("melee" = 15, "bullet" = 10, "laser" = 10, "energy" = 5, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 50, "stamina" = 30)
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/exo/large //youtu.be/9DpkW7OUVjM?si=YRxGzlOIQcm4tyrv
	resistance_flags = FIRE_PROOF //by się nie skopciła, to nie jest zwykła opaska
	flags_cover = HEADCOVERSEYES
	flags_inv = HIDEFACE
	blockTracking = TRUE //dla fantazji bycia fajnym tajnym agentem
	strip_delay = 60

/****************************\
|*********** czapki *********|
\****************************/

/obj/item/clothing/head/helmet/aquila/biker
	name = "motorcycle helmet"
	desc = "You had your chance."
	icon_state = "biker_helmet"
	armor = list("melee" = 20, "bullet" = 5, "laser" = 10, "energy" = 20, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 0, "stamina" = 0)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH

/obj/item/clothing/head/aquila/richard
	name = "Chicken mask"
	desc = "Why don't you finish what you've started?"
	icon_state = "richard"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 10, "rad" = 10, "fire" = 20, "acid" = 0, "stamina" = 20)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH

/obj/item/clothing/head/hooded/aquila/huge/ghostcosstumehood
	name = "spooky ghost costume hood"
	desc = "spooky ghost costume hood."
	icon_state = "ghostcostumehood"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
