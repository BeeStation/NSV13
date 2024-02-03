/obj/item/book/granter/spell/sexonbutton
	name = "poorly-written fanfiction"
	desc = "A book, seemingly describing an encounter between a notorious changeling and an infamous lizard, deep in the maintance tunnels of the station's robotics bay."
	icon_state = "book8"
	spell = /obj/effect/proc_holder/spell/targeted/touch/sex
	spellname = "Sex on button"
	remarks = list("Why did he put that proboscis there?", "Oh.", "Why is he holding a bottle of space lube?")
	oneuse = FALSE

/obj/item/book/granter/spell/sexonbutton/one_use
	oneuse = TRUE

/obj/item/book/granter/spell/sexonbutton/on_reading_start(mob/user)
	to_chat(user, "<span class='notice'>You start reading \the [src]...</span>")

/obj/item/book/granter/spell/sexonbutton/on_reading_finished(mob/user)
	to_chat(user, "<span class='notice'>You feel like you want to try this whole \"sex\" thing.</span>")
	var/obj/effect/proc_holder/spell/S = new spell
	user.mind.AddSpell(S)
	user.log_message("learned the spell [spellname] ([S])", LOG_ATTACK, color="orange")
	onlearned(user)

/obj/item/book/granter/spell/sexonbutton/recoil(mob/user)
	user.visible_message("<span class='warning'>[src] explodes in a shower of gibs!</span>")
	new /obj/effect/gibspawner/human/bodypartless(get_turf(src))
	qdel(src)
