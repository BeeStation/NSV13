//traits with no real impact that can be taken freely
//MAKE SURE THESE DO NOT MAJORLY IMPACT GAMEPLAY. those should be positive or negative traits.

/datum/quirk/no_taste
	name = "Aguezja"
	desc = "Nie czujesz smaku! Toksyczne jedzenie nadal jest trujące."
	value = 0
	mob_trait = TRAIT_AGEUSIA
	gain_text = "<span class='notice'>Nie czujesz smaku!</span>"
	lose_text = "<span class='notice'>Znowu czujesz smak!</span>"
	medical_record_text = "Pacjent choruje na aguezję i nie czuje smaku potraw."

/datum/quirk/vegetarian
	name = "Wegetarianin"
	desc = "Uważasz, że jedzenie mięsa jest niemoralne."
	value = 0
	gain_text = "<span class='notice'>Odrzuca cię myśl jedzenia mięsa.</span>"
	lose_text = "<span class='notice'>Uważasz, że mięso nie jest jednak takie złe.</span>"
	medical_record_text = "Pacjent zgłosił, że stosuje dietę wegetariańską."

/datum/quirk/vegetarian/add()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/organ/tongue/T = H.getorganslot(ORGAN_SLOT_TONGUE)
	T?.liked_food &= ~MEAT
	T?.disliked_food |= MEAT

/datum/quirk/vegetarian/remove()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/organ/tongue/T = H.getorganslot(ORGAN_SLOT_TONGUE)
	if(H)
		if(initial(T.liked_food) & MEAT)
			T?.liked_food |= MEAT
		if(!(initial(T.disliked_food) & MEAT))
			T?.disliked_food &= ~MEAT

/datum/quirk/pineapple_liker
	name = "Uwielbienie Ananasa"
	desc = "Uwielbiasz jeść potrawy z ananasem. Nigdy nie masz dość ich słodkości!"
	value = 0
	gain_text = "<span class='notice'>Czujesz niesamowitą potrzebę zjedzenia ananasa.</span>"
	lose_text = "<span class='notice'>Ananasy nie robią już na tobie wrażenia.</span>"
	medical_record_text = "Pacjent wykazuje patologiczne zamiłowanie do spożywania ananasów."

/datum/quirk/pineapple_liker/add()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/organ/tongue/T = H.getorganslot(ORGAN_SLOT_TONGUE)
	T?.liked_food |= PINEAPPLE

/datum/quirk/pineapple_liker/remove()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/organ/tongue/T = H.getorganslot(ORGAN_SLOT_TONGUE)
	T?.liked_food &= ~PINEAPPLE

/datum/quirk/pineapple_hater
	name = "Obrzydzenie Ananasa"
	desc = "Nie lubisz spożywać potraw z ananasem. Serio, komu to w ogóle smakuje? I jaki szaleniec uznał, że dobrym pomysłem jest dodawanie ich do pizzy!?"
	value = 0
	gain_text = "<span class='notice'>Zastanawasz się jakiemu idiocie w ogóle smakują ananasy...</span>"
	lose_text = "<span class='notice'>Ananasy nie robią już na tobie wrażenia.</span>"
	medical_record_text = "Pacjent ma rację uważając, że ananasy są ochydne."

/datum/quirk/pineapple_hater/add()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/organ/tongue/T = H.getorganslot(ORGAN_SLOT_TONGUE)
	T?.disliked_food |= PINEAPPLE

/datum/quirk/pineapple_hater/remove()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/organ/tongue/T = H.getorganslot(ORGAN_SLOT_TONGUE)
	T?.disliked_food &= ~PINEAPPLE

/datum/quirk/deviant_tastes
	name = "Dziwne Preferencje Kulinarne"
	desc = "Nie lubisz jedzenia, które wiekszość ludzi uznaje za dobre, a ubóstwiasz to którego nikt inny nie tknie."
	value = 0
	gain_text = "<span class='notice'>Masz ochotę zjeść coś co smakuje dziwnie.</span>"
	lose_text = "<span class='notice'>Masz ochotę zjeść coś normalnego.</span>"
	medical_record_text = "Kubki smakowe pacjenta działają w nietypowy sposób."

/datum/quirk/deviant_tastes/add()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/organ/tongue/T = H.getorganslot(ORGAN_SLOT_TONGUE)
	var/liked = T?.liked_food
	T?.liked_food = T?.disliked_food
	T?.disliked_food = liked

/datum/quirk/deviant_tastes/remove()
	var/mob/living/carbon/human/H = quirk_holder
	var/obj/item/organ/tongue/T = H.getorganslot(ORGAN_SLOT_TONGUE)
	T?.liked_food = initial(T?.liked_food)
	T?.disliked_food = initial(T?.disliked_food)

/datum/quirk/monochromatic
	name = "Monochromatyczność"
	desc = "Cierpisz na daltonizm, widzisz świat w czerni i bieli."
	value = 0
	medical_record_text = "Pacjent wykazuje niemal całkowity daltonizm."

/datum/quirk/monochromatic/add()
	quirk_holder.add_client_colour(/datum/client_colour/monochrome)

/datum/quirk/monochromatic/post_add()
	if(quirk_holder.mind.assigned_role == JOB_NAME_DETECTIVE)
		to_chat(quirk_holder, "<span class='boldannounce'>Hmm. Ta stacja jest pełna brudu. Cała w odcieniach szarości...</span>")
		quirk_holder.playsound_local(quirk_holder, 'sound/ambience/ambidet1.ogg', 50, FALSE)

/datum/quirk/monochromatic/remove()
	quirk_holder.remove_client_colour(/datum/client_colour/monochrome)

/datum/quirk/mute
	name = "Niemy"
	desc = "Nie możesz mówić."
	value = 0
	mob_trait = TRAIT_MUTE
	gain_text = "<span class='danger'>Czujesz niemoc, by mówić.</span>"
	lose_text = "<span class='notice'>Znów czujesz niemoc, by mówić.</span>"
	medical_record_text = "Pacjent nie może mówić."
