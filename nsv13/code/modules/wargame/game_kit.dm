/datum/map_template/holodeck/wargame
	name = "Holodeck - Naval Wargames"
	template_id = "holodeck_wargame"
	mappath = "_maps/holodeck/holodeck_wargame.dmm"

/obj/item/storage/secure/briefcase/wargame_kit
	name = "DIY Wargaming Kit"
	desc = "Contains everything an aspiring naval officer (or just massive nerd) would need for a proper modern naval wargame."
	custom_premium_price = PAYCHECK_MEDIUM * 2

/obj/item/storage/secure/briefcase/wargame_kit/PopulateContents()
	var/static/items_inside = list(
		/obj/item/wargame_projector/ships = 1,
		/obj/item/wargame_projector/ships/red = 1,
		/obj/item/wargame_projector/terrain = 1,
		/obj/item/storage/pill_bottle/dice = 1,
		/obj/item/book/manual/wargame_rules = 1,
		/obj/item/book/manual/wargame_rules/examples = 1,
		)
	generate_items_inside(items_inside, src)
