//put NSV modular plushes in here

/obj/item/toy/plush/hornet
	name = "strange bug plushie"
	desc = "A cute, soft plush of a long-horned bug."
	icon = 'nsv13/icons/obj/plushes.dmi'
	icon_state = "plushie_hornet"
	attack_verb = list("poked", "shaws")
	squeak_override = list('nsv13/sound/plush/hornet_gitgud.ogg'=1, 'nsv13/sound/plush/hornet_SHAW.ogg'=10) //git gud will play 1 out of 11 times
	gender = FEMALE

/obj/item/toy/plush/hornet/gay
	name = "gay bug plushie"
	desc = "A cute, soft plush of a long-horned bug. Her cloak is in the colors of the lesbian pride flag."
	icon_state = "plushie_gayhornet"

/obj/item/toy/plush/knight
	name = "odd bug plushie"
	desc = "A cute, soft plush of a little bug. It sounds like this one didn't come with a voice box."
	icon = 'nsv13/icons/obj/plushes.dmi'
	icon_state = "plushie_knight"
	attack_verb = list("poked")
	should_squeak = FALSE
