/obj/structure/curtain/obscuring //In other words, curtains that obscure vision when you close them
	name = "black curtains"
	desc = "A sleek, black set of curtains which will keep prying eyes away from whatever youre doing inside..."
	color = "#000000"
	alpha = 255

/obj/structure/curtain/obscuring/grey
	name = "black curtains"
	desc = "A sleek, dark grey set of curtains which will keep prying eyes away from whatever youre doing inside..."
	color = "#696969"

/obj/structure/curtain/obscuring/toggle() //obscure vision when you close them.
	open = !open
	switch(open)
		if(TRUE)
			opacity = FALSE
		if(FALSE)
			opacity = TRUE
	update_icon()