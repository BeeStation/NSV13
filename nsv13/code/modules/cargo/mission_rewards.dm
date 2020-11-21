
/obj/structure/closet/crate/nsv_mission_rewards
  name = "combat supply crate"
  desc = "a crate containing a small cache of ammo"
  
/obj/structure/closet/crate/nsv_mission_rewards/PopulateContents()
  for(var/i in 1 to 2)
    new /obj/item/ammo_box/magazine/pdc(src)
    new /obj/item/ship_weapon/ammunition/railgun_ammo(src)
  for(var/i in 1 to 6)
    new /obj/item/ship_weapon/ammunition/gauss(src)
    