//plik pomocniczy do ścieżek ikon pod modularyzacje, NSV stosuje ship do swojego, my będziemy mieć aquila
//to jest po to by nie robić niepotrzebnego bloatu plików i ułatwić sobie zadanie
/*************************************\
|*********** nakrycia głowy **********|
\*************************************/
/obj/item/clothing/head/aquila
	name = "micro tear in fabric of reality" //głupia nazwa do debuggowania
	desc = "if you see this, inform Central Command immediately" //ditto
	icon = 'aquila/icons/obj/clothing/hats.dmi'
	worn_icon = 'aquila/icons/mob/head.dmi'
	dog_fashion = null //jeżeli pies może nosić tą czapke to zmień
	lefthand_file = 'aquila/icons/mob/inhands/clothing_lefthand.dmi' //obiekt widoczny gdy trzymany w dłoni, jeżeli nie jest zrobiony to trzeba zgłośić do spritera by dorobił
	righthand_file = 'aquila/icons/mob/inhands/clothing_righthand.dmi'// ditto

/obj/item/clothing/head/helmet/aquila
	name = "micro tear in fabric of reality"
	desc = "if you see this, inform Central Command immediately"
	icon = 'aquila/icons/obj/clothing/hats.dmi'
	worn_icon = 'aquila/icons/mob/head.dmi'
	dog_fashion = null //ditto
	lefthand_file = 'aquila/icons/mob/inhands/clothing_lefthand.dmi' // ditto
	righthand_file = 'aquila/icons/mob/inhands/clothing_righthand.dmi'// ditto

/obj/item/clothing/head/hooded/aquila
	name = "micro tear in fabric of reality"
	desc = "if you see this, inform Central Command immediately"
	icon = 'aquila/icons/obj/clothing/hats.dmi'
	worn_icon = 'aquila/icons/mob/head.dmi'
	dog_fashion = null //to i tak nie powinno być separowane z właścicielem kaptura

/obj/item/clothing/head/hooded/aquila/huge
	name = "micro tear in fabric of reality"
	desc = "if you see this, inform Central Command immediately"
	icon = 'aquila/icons/obj/clothing/hats.dmi'
	worn_icon = 'aquila/icons/mob/large-worn-icons/head.dmi'
	worn_x_dimension = 64
	worn_y_dimension = 64

/****************************\
|*********** maski **********|
\****************************/
/*/obj/item/clothing/mask/aquila
	name = "micro tear in fabric of reality" //to jest podstawowa nazwa obiektu do debuggowania,
	desc = "if you see this, inform Central Command immediately" //, normalnie nie powinieneś tego widzieć jeżeli wszystko jest dobrze napisane
	icon = 'aquila/icons/obj/clothing/masks.dmi //dodaj ścieżki jak dodajesz nowe obiekty i faktyczne ikony
	worn_icon = 'aquila/icons/mob/mask.dmi'
	lefthand_file = 'aquila/icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/clothing_righthand.dmi'
*/

/***************************\
|*********** oczy **********|
\***************************/
/*/obj/item/clothing/glasses/aquila
	name = "micro tear in fabric of reality" //to jest podstawowa nazwa obiektu do debuggowania,
	desc = "if you see this, inform Central Command immediately" //, normalnie nie powinieneś tego widzieć jeżeli wszystko jest dobrze napisane
	icon = 'aquila/icons/obj/clothing/glasses.dmi' //dodaj ścieżki jak dodajesz nowe obiekty i faktyczne ikony
	worn_icon = 'aquila/icons/mob/eyes.dmi'
	lefthand_file = 'aquila/icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/clothing_righthand.dmi'
*/
/*********************************\
|*********** podubrania **********|
\*********************************/
/obj/item/clothing/under/aquila
	name = "micro tear in fabric of reality"
	desc = "if you see this, inform Central Command immediately"
	icon = 'aquila/icons/obj/clothing/uniforms.dmi'
	worn_icon = 'aquila/icons/mob/uniform.dmi'
	can_adjust = FALSE //jeżeli jest druga ikona na luzowanie ubrania to zamień na true
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON //zmiana wymaga dostosowania ikon pod rozkraczone nogi w osobnym pliku, dodatkowe informacje w update_icons.dm, items.dm oraz species.dm
	fitted = FEMALE_UNIFORM_FULL //puste piksele dla kobiecego ubrania
//	fitted = NO_FEMALE_UNIFORM // opcje do wyboru, tu nic sie nie zmienia
//	fitted = FEMALE_UNIFORM_TOP //tu tylko skasuje górne piksele dla sylwetki
	lefthand_file = 'aquila/icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/under/costume/aquila //nie ma czegoś takiego jak costume co ma własne funkcje, to jest uzywane jedynie do-
	name = "micro tear in fabric of reality"//-do oznaczenia ze to kostium i tyle, ja tego nie wymyśliłem
	desc = "if you see this, inform Central Command immediately"
	icon = 'aquila/icons/obj/clothing/uniforms.dmi'
	worn_icon = 'aquila/icons/mob/uniform.dmi'
	can_adjust = FALSE //ditto
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON //ditto
	fitted = FEMALE_UNIFORM_FULL //ditto
//	fitted = NO_FEMALE_UNIFORM //ditto
//	fitted = FEMALE_UNIFORM_TOP //ditto
	lefthand_file = 'aquila/icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/clothing_righthand.dmi'

/***************************\
|*********** buty **********|
\***************************/
/obj/item/clothing/shoes/aquila
	name = "micro tear in fabric of reality"
	desc = "if you see this, inform Central Command immediately"
	icon = 'aquila/icons/obj/clothing/shoes.dmi'
	worn_icon = 'aquila/icons/mob/feet.dmi'
	equip_delay_other = 50 //tak wszystkie buty mają
	strip_delay = 5 //ditto
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON
	lefthand_file = 'aquila/icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/clothing_righthand.dmi'

/*******************************\
|*********** rękawice **********|
\*******************************/
/*/obj/item/clothing/gloves/aquila
	name = "micro tear in fabric of reality" //to jest podstawowa nazwa obiektu do debuggowania,
	desc = "if you see this, inform Central Command immediately" //, normalnie nie powinieneś tego widzieć jeżeli wszystko jest dobrze napisane
	icon = 'aquila/icons/obj/clothing/gloves.dmi //dodaj ścieżki jak dodajesz nowe obiekty i faktyczne ikony
	worn_icon = 'aquila/icons/mob/glove.dmi'
	lefthand_file = 'aquila/icons/mob/inhands/clothing_lefthand.dmi' // ditto
	righthand_file = 'aquila/icons/mob/inhands/clothing_righthand.dmi'// ditto
 */
/***************************\
|*********** uszy **********|
\***************************/
/*/obj/item/clothing/ears/aquila
	name = "micro tear in fabric of reality" //to jest podstawowa nazwa obiektu do debuggowania,
	desc = "if you see this, inform Central Command immediately" //, normalnie nie powinieneś tego widzieć jeżeli wszystko jest dobrze napisane
	icon = 'aquila/icons/obj/radio.dmi' !!może być inna ścieżka!! //dodaj ścieżki jak dodajesz nowe obiekty. Po dodaniu skasuj komentarz placeholder
	worn_icon = 'aquila/icons/mob/ears.dmi'
	lefthand_file = 'aquila/icons/mob/inhands/clothing_lefthand.dmi' // ditto
	righthand_file = 'aquila/icons/mob/inhands/clothing_righthand.dmi'// ditto
 */
/***************************\
|*********** szyja **********|
\***************************/
/*/obj/item/clothing/neck/aquila
	name = "micro tear in fabric of reality" //to jest podstawowa nazwa obiektu do debuggowania,
	desc = "if you see this, inform Central Command immediately" //, normalnie nie powinieneś tego widzieć jeżeli wszystko jest dobrze napisane
	icon = 'aquila/icons/obj/clothing/neck.dmi //dodaj ścieżki jak dodajesz nowe obiekty i faktyczne ikony
	worn_icon = 'aquila/icons/mob/neck.dmi'
	lefthand_file = 'aquila/icons/mob/inhands/clothing_lefthand.dmi' // ditto
	righthand_file = 'aquila/icons/mob/inhands/clothing_righthand.dmi'// ditto
 */
/*********************************\
|*********** przebrania **********|
\*********************************/
/obj/item/clothing/suit/armor/aquila
	name = "micro tear in fabric of reality"
	desc = "if you see this, inform Central Command immediately"
	icon = 'aquila/icons/obj/clothing/suits.dmi'
	worn_icon = 'aquila/icons/mob/suit.dmi'
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON
	lefthand_file = 'aquila/icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/suit/aquila
	name = "micro tear in fabric of reality"
	desc = "if you see this, inform Central Command immediately"
	icon = 'aquila/icons/obj/clothing/suits.dmi'
	worn_icon = 'aquila/icons/mob/suit.dmi'
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON
	lefthand_file = 'aquila/icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/suit/hooded/aquila
	name = "micro tear in fabric of reality"
	desc = "if you see this, inform Central Command immediately"
	icon = 'aquila/icons/obj/clothing/suits.dmi'
	worn_icon = 'aquila/icons/mob/suit.dmi'
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON
	lefthand_file = 'aquila/icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/clothing_righthand.dmi'

/*******************************\
|********** skafandry **********|
\*******************************/
/obj/item/clothing/suit/space/aquila
	name = "micro tear in fabric of reality"
	desc = "if you see this, inform Central Command immediately"
	icon = 'aquila/icons/obj/clothing/suits.dmi'
	worn_icon = 'aquila/icons/mob/suit.dmi'
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON
	lefthand_file = 'aquila/icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/head/helmet/space/aquila
	name = "micro tear in fabric of reality"
	desc = "if you see this, inform Central Command immediately"
	icon = 'aquila/icons/obj/clothing/hats.dmi'
	worn_icon = 'aquila/icons/mob/head.dmi'
	lefthand_file = 'aquila/icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/clothing_righthand.dmi'

//hardsuit
/obj/item/clothing/suit/space/hardsuit/aquila
	name = "micro tear in fabric of reality"
	desc = "if you see this, inform Central Command immediately"
	icon = 'aquila/icons/obj/clothing/suits.dmi'
	worn_icon = 'aquila/icons/mob/suit.dmi'
	supports_variations = DIGITIGRADE_VARIATION_NO_NEW_ICON
	lefthand_file = 'aquila/icons/mob/inhands/clothing_lefthand.dmi'
	righthand_file = 'aquila/icons/mob/inhands/clothing_righthand.dmi'

/obj/item/clothing/head/helmet/space/hardsuit/aquila
	name = "micro tear in fabric of reality"
	desc = "if you see this, inform Central Command immediately"
	icon = 'aquila/icons/obj/clothing/hats.dmi'
	worn_icon = 'aquila/icons/mob/head.dmi'
