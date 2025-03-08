//Modular attachment - hardsuit tails. Have to define it on /clothing, but only used on hardsuits for the time being, and in general only useful on SUIT slot clothing.
/obj/item/clothing
	///Defines colors used for this particular hardsuit's tail rendering. Only useful on clothing that goes in the outer SUIT slot.
	var/list/hardsuit_tail_colors

//Hexadecimal color lists for hardsuit tail sprites.
//The list gets used by the overlay renderer turned to RGB values, and overlayed onto the uncolored tailsprite in tails_hardsuit.dmi

/obj/item/clothing/suit/space/hardsuit/engine
	hardsuit_tail_colors = list("974", "A62", "C95")

/obj/item/clothing/suit/space/hardsuit/engine/atmos
	hardsuit_tail_colors = list("974", "487", "498")

/obj/item/clothing/suit/space/hardsuit/engine/elite
	hardsuit_tail_colors = list("321", "CCB", "EEE")

/obj/item/clothing/suit/space/hardsuit/mining
	hardsuit_tail_colors = list("877", "BA9", "655")

/obj/item/clothing/suit/space/hardsuit/syndi
	hardsuit_tail_colors = list("A11", "322", "c45")

/obj/item/clothing/suit/space/hardsuit/syndi/elite
	hardsuit_tail_colors = list("222", "454", "443")

/obj/item/clothing/suit/space/hardsuit/medical
	hardsuit_tail_colors = list("DDD", "A75", "FFF")

/obj/item/clothing/suit/space/hardsuit/research_director
	hardsuit_tail_colors = list("CB7", "839", "995")

/obj/item/clothing/suit/space/hardsuit/security
	hardsuit_tail_colors = list("222", "C23", "335")

/obj/item/clothing/suit/space/hardsuit/security/head_of_security
	hardsuit_tail_colors = list("212", "C32", "234")

/obj/item/clothing/suit/space/hardsuit/swat
	hardsuit_tail_colors = list("333", "345", "335")

/obj/item/clothing/suit/space/hardsuit/swat/captain
	hardsuit_tail_colors = list("368", "CA0", "030")

/obj/item/clothing/suit/space/hardsuit/shielded/syndi
	hardsuit_tail_colors = list("A11", "322", "c45")

/obj/item/clothing/suit/space/hardsuit/shielded/swat
	hardsuit_tail_colors = list("222", "454", "443")

/obj/item/clothing/suit/space/hardsuit/deathsquad
	hardsuit_tail_colors = list("222", "510", "443")

/obj/item/clothing/suit/space/hardsuit/ert
	hardsuit_tail_colors = list("112", "553", "28F")

/obj/item/clothing/suit/space/hardsuit/ert/sec
	hardsuit_tail_colors = list("411", "D34", "D34")

/obj/item/clothing/suit/space/hardsuit/ert/engi
	hardsuit_tail_colors = list("333", "FA0", "FA0")

/obj/item/clothing/suit/space/hardsuit/ert/med
	hardsuit_tail_colors = list("321", "FFF", "FFF")

/obj/item/clothing/suit/space/hardsuit/ert/jani
	hardsuit_tail_colors = list("112", "93E", "93E")

/obj/item/clothing/suit/space/hardsuit/ert/paranormal
	hardsuit_tail_colors = list("9AA", "A23", "222")

/obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor
	hardsuit_tail_colors = list("223", "521", "721")

/obj/item/clothing/suit/space/hardsuit/pilot
	hardsuit_tail_colors = list("111", "555", "555")
