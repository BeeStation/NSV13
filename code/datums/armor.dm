#define ARMORID "armor-[melee]-[bullet]-[laser]-[energy]-[bomb]-[bio]-[rad]-[fire]-[acid]-[magic]-[stamina]-[overmap_light]-[overmap_heavy]" //NSV13 overmap light and heavy added to numerious places in this file

/proc/getArmor(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 0, acid = 0, magic = 0, stamina = 0, overmap_light = 0, overmap_heavy = 0)
  . = locate(ARMORID)
  if (!.)
    . = new /datum/armor(melee, bullet, laser, energy, bomb, bio, rad, fire, acid, magic, stamina, overmap_light, overmap_heavy)

/datum/armor
  datum_flags = DF_USE_TAG
  var/melee
  var/bullet
  var/laser
  var/energy
  var/bomb
  var/bio
  var/rad
  var/fire
  var/acid
  var/magic
  var/stamina
  var/overmap_light
  var/overmap_heavy

/datum/armor/New(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 0, acid = 0, magic = 0, stamina = 0, overmap_light = 0, overmap_heavy = 0)
  src.melee = melee
  src.bullet = bullet
  src.laser = laser
  src.energy = energy
  src.bomb = bomb
  src.bio = bio
  src.rad = rad
  src.fire = fire
  src.acid = acid
  src.magic = magic
  src.stamina = stamina
  tag = ARMORID

/datum/armor/proc/modifyRating(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 0, acid = 0, magic = 0, stamina = 0, overmap_light = 0, overmap_heavy = 0)
  return getArmor(src.melee+melee, src.bullet+bullet, src.laser+laser, src.energy+energy, src.bomb+bomb, src.bio+bio, src.rad+rad, src.fire+fire, src.acid+acid, src.magic+magic, src.stamina+stamina, src.overmap_light+overmap_light, src.overmap_heavy+overmap_heavy)

/datum/armor/proc/modifyAllRatings(modifier = 0)
  return getArmor(melee+modifier, bullet+modifier, laser+modifier, energy+modifier, bomb+modifier, bio+modifier, rad+modifier, fire+modifier, acid+modifier, magic+modifier, stamina+modifier, overmap_light+modifier, overmap_heavy+modifier)

/datum/armor/proc/setRating(melee, bullet, laser, energy, bomb, bio, rad, fire, acid, magic, overmap_light, overmap_heavy)
  return getArmor((isnull(melee) ? src.melee : melee),\
                  (isnull(bullet) ? src.bullet : bullet),\
                  (isnull(laser) ? src.laser : laser),\
                  (isnull(energy) ? src.energy : energy),\
                  (isnull(bomb) ? src.bomb : bomb),\
                  (isnull(bio) ? src.bio : bio),\
                  (isnull(rad) ? src.rad : rad),\
                  (isnull(fire) ? src.fire : fire),\
                  (isnull(acid) ? src.acid : acid),\
				  (isnull(magic) ? src.magic : magic),\
				  (isnull(stamina) ? src.stamina : stamina),\
				  (isnull(overmap_light) ? src.overmap_light : overmap_light),\
				  (isnull(overmap_heavy) ? src.overmap_heavy : overmap_heavy))

/datum/armor/proc/getRating(rating)
  return vars[rating]

/datum/armor/proc/getList()
  return list("melee" = melee, "bullet" = bullet, "laser" = laser, "energy" = energy, "bomb" = bomb, "bio" = bio, "rad" = rad, "fire" = fire, "acid" = acid, "magic" = magic, "stamina" = stamina, "overmap light" = overmap_light, "overmap heavy" = overmap_heavy)

/datum/armor/proc/attachArmor(datum/armor/AA)
  return getArmor(melee+AA.melee, bullet+AA.bullet, laser+AA.laser, energy+AA.energy, bomb+AA.bomb, bio+AA.bio, rad+AA.rad, fire+AA.fire, acid+AA.acid, magic+AA.magic, stamina+AA.stamina, overmap_light+AA.overmap_light, overmap_heavy+AA.overmap_heavy)

/datum/armor/proc/detachArmor(datum/armor/AA)
  return getArmor(melee-AA.melee, bullet-AA.bullet, laser-AA.laser, energy-AA.energy, bomb-AA.bomb, bio-AA.bio, rad-AA.rad, fire-AA.fire, acid-AA.acid, magic-AA.magic, stamina-AA.stamina, overmap_light-AA.overmap_light, overmap_heavy-AA.overmap_heavy)

/datum/armor/vv_edit_var(var_name, var_value)
  if (var_name == NAMEOF(src, tag))
    return FALSE
  . = ..()
  tag = ARMORID // update tag in case armor values were edited

#undef ARMORID
