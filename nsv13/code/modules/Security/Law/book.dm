/obj/item/lawbook
	name = "Book of Laws"
	desc = "A standard printed space law book, although this one seems to resonate with an unknown power"
	icon = 'icons/obj/library.dmi'
	icon_state = "bookSpaceLaw"

/obj/item/lawbook/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LawBook", name)
		ui.open()
