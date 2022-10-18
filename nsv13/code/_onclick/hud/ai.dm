/atom/movable/screen/ai/zup
	name = "Move up a deck"
	icon_state = "zup"

/atom/movable/screen/ai/zup/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.up()

/atom/movable/screen/ai/zdown
	name = "Move down a deck"
	icon_state = "zdown"

/atom/movable/screen/ai/zdown/Click()
	if(..())
		return
	var/mob/living/silicon/ai/AI = usr
	AI.down()