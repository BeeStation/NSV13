/obj/machinery/vending/toyliberationstation
	name = "\improper Syndicate Donksoft Toy Vendor"
	desc = "An ages 8 and up approved vendor that dispenses toys. If you were to find the right wires, you can unlock the adult mode setting!"
	icon_state = "syndi"
	product_slogans = "Zdobądź swoje super zabawki dziś!;Striggeruj swojego validhuntera już dziś!;Zabawkowe bronie najlepszej jakości w niskiej cenie!;Daj je HoPowi za AA!;Daj je Szefowi Ochrony za bilet do permy!"
	product_ads = "Poczuj się robustny ze swoimi zabawkami!;Wyraź swoje wewnętrzne dziecko już dziś!;Zabawkowe bronie nie zabijają ludzi. Ale validhunterzy już tak!;Kto potrzebuje odpowiedzialności jeśli masz zabawkowe bronie?;Uczyń swoje następne morderstwo ZABAWNYM!"
	vend_reply = "Come back for more!"
	light_color = LIGHT_COLOR_RED
	circuit = /obj/item/circuitboard/machine/vending/syndicatedonksofttoyvendor
	products = list(/obj/item/gun/ballistic/automatic/toy/unrestricted = 10,
					/obj/item/gun/ballistic/automatic/toy/pistol/unrestricted = 10,
					/obj/item/gun/ballistic/shotgun/toy/unrestricted = 10,
					/obj/item/toy/sword = 10,
					/obj/item/ammo_box/foambox = 20,
					/obj/item/toy/foamblade = 10,
					/obj/item/toy/syndicateballoon = 10,
					/obj/item/clothing/suit/syndicatefake = 5,
					/obj/item/clothing/head/syndicatefake = 5) //OPS IN DORMS oh wait it's just an assistant
	contraband = list(/obj/item/gun/ballistic/shotgun/toy/crossbow = 10,   //Congrats, you unlocked the +18 setting!
					  /obj/item/gun/ballistic/automatic/c20r/toy/unrestricted/riot = 10,
					  /obj/item/gun/ballistic/automatic/l6_saw/toy/unrestricted/riot = 10,
					  /obj/item/ammo_box/foambox/riot = 20,
					  /obj/item/toy/katana = 10,
					  /obj/item/dualsaber/toy = 5,
					  /obj/item/toy/cards/deck/syndicate = 10) //Gambling and it hurts, making it a +18 item
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 50, "stamina" = 0)
	resistance_flags = FIRE_PROOF
	refill_canister = /obj/item/vending_refill/donksoft
	default_price = 75
	extra_price = 300
	payment_department = ACCOUNT_SRV
