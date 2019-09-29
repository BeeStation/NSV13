/obj/screen/ai/zup
	name = "Move up a deck"
	icon_state = "zup"

/obj/screen/ai/zup/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.up()

/obj/screen/ai/zdown
	name = "Move down a deck"
	icon_state = "zdown"

/obj/screen/ai/zdown/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.down()