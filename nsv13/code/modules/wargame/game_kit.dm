/obj/item/storage/secure/briefcase/wargame_kit
	name = "DIY Wargaming Kit"
	desc = "Contains everything an aspiring naval officer (or just massive nerd) would need for a proper modern naval wargame."
	custom_premium_price = PAYCHECK_MEDIUM * 2

/obj/item/storage/secure/briefcase/wargame_kit/PopulateContents()
	var/static/items_inside = list(

	)
	generate_items_inside(items_inside, src)
