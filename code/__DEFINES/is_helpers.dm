// simple is_type and similar inline helpers

#define in_range(source, user) (get_dist(source, user) <= 1 && (get_step(source, 0)?:z) == (get_step(user, 0)?:z))

/// Within given range, but not counting z-levels
#define IN_GIVEN_RANGE(source, other, given_range) (get_dist(source, other) <= given_range && (get_step(source, 0)?:z) == (get_step(other, 0)?:z))

#define ismovableatom(A) ismovable(A)

#define isatom(A) (isloc(A))

#define isdatum(thing) (istype(thing, /datum))

#define isweakref(D) (istype(D, /datum/weakref))

#define isimage(thing) (istype(thing, /image))

GLOBAL_VAR_INIT(magic_appearance_detecting_image, new /image) // appearances are awful to detect safely, but this seems to be the best way ~ninjanomnom
#define isappearance(thing) (!isimage(thing) && !ispath(thing) && istype(GLOB.magic_appearance_detecting_image, thing))

// The filters list has the same ref type id as a filter, but isnt one and also isnt a list, so we have to check if the thing has Cut() instead
GLOBAL_VAR_INIT(refid_filter, TYPEID(filter(type="angular_blur")))
#define isfilter(thing) (!islist(thing) && hascall(thing, "Cut") && TYPEID(thing) == GLOB.refid_filter)

GLOBAL_DATUM_INIT(regex_rgb_text, /regex, regex(@"^#?(([0-9a-fA-F]{8})|([0-9a-fA-F]{6})|([0-9a-fA-F]{3}))$"))
#define iscolortext(thing) (istext(thing) && GLOB.regex_rgb_text.Find(thing))

// simple check whether or not a player is a guest using their key
#define IS_GUEST_KEY(key)	(findtextEx(key, "Guest-", 1, 7))

//Turfs
//#define isturf(A) (istype(A, /turf)) This is actually a byond built-in. Added here for completeness sake.

GLOBAL_LIST_INIT(turfs_without_ground, typecacheof(list(
	/turf/open/space,
	/turf/open/chasm,
	/turf/open/lava,
	/turf/open/water,
	/turf/open/openspace
	)))

#define isgroundlessturf(A) (is_type_in_typecache(A, GLOB.turfs_without_ground))

#define isopenturf(A) (istype(A, /turf/open))

#define isindestructiblefloor(A) (istype(A, /turf/open/indestructible))

#define isspaceturf(A) (istype(A, /turf/open/space))

#define isfloorturf(A) (istype(A, /turf/open/floor))

#define isclosedturf(A) (istype(A, /turf/closed))

#define isindestructiblewall(A) (istype(A, /turf/closed/indestructible))

#define iswallturf(A) (istype(A, /turf/closed/wall))

#define ismineralturf(A) (istype(A, /turf/closed/mineral))

#define islava(A) (istype(A, /turf/open/lava))

#define ischasm(A) (istype(A, /turf/open/chasm))

#define isplatingturf(A) (istype(A, /turf/open/floor/plating))

//Mobs
#define isliving(A) (istype(A, /mob/living))

#define isbrain(A) (istype(A, /mob/living/brain))

// basic mobs
#define isbasicmob(A) (istype(A, /mob/living/basic))

//Carbon mobs
#define iscarbon(A) (istype(A, /mob/living/carbon))

#define ishuman(A) (istype(A, /mob/living/carbon/human))

//NSV13 - knpc helper
#define isknpc(A) (istype(A, /mob/living/carbon/human/ai_boarder))
//NSV13 end

//Human sub-species
#define isabductor(A) (is_species(A, /datum/species/abductor))
#define isgolem(A) (is_species(A, /datum/species/golem))
#define islizard(A) (is_species(A, /datum/species/lizard))
#define isplasmaman(A) (is_species(A, /datum/species/plasmaman))
#define ispodperson(A) (is_species(A, /datum/species/pod))
#define isflyperson(A) (is_species(A, /datum/species/fly))
#define isjellyperson(A) (is_species(A, /datum/species/jelly))
#define isslimeperson(A) (is_species(A, /datum/species/jelly/slime))
#define isluminescent(A) (is_species(A, /datum/species/jelly/luminescent))
#define isstargazer(A) (is_species(A, /datum/species/jelly/stargazer))
#define isoozeling(A) (is_species(A, /datum/species/oozeling))
#define iszombie(A) (is_species(A, /datum/species/zombie))
#define isskeleton(A) (is_species(A, /datum/species/skeleton))
#define ismoth(A) (is_species(A, /datum/species/moth))
#define ishumanbasic(A) (is_species(A, /datum/species/human) && !is_species(A, /datum/species/human/krokodil_addict))
#define iscatperson(A) (ishumanbasic(A) && is_species(A, /datum/species/human/felinid) ) //NSV13 - I dunno why this wasn't using is_species like the rest
#define isethereal(A) (is_species(A, /datum/species/ethereal))
#define isvampire(A) (is_species(A,/datum/species/vampire))
#define isipc(A) (is_species(A, /datum/species/ipc))
#define isapid(A) (is_species(A, /datum/species/apid))
#define isandroid(A) (is_species(A, /datum/species/android))

//more carbon mobs
#define ismonkey(A) (istype(A, /mob/living/carbon/monkey))

#define isxeno(A) (istype(A, /mob/living/carbon/xenomorph))

#define isalien(A) (istype(A, /mob/living/carbon/alien))

#define islarva(A) (istype(A, /mob/living/carbon/alien/larva))

#define isalienadult(A) (istype(A, /mob/living/carbon/alien/humanoid) || istype(A, /mob/living/simple_animal/hostile/alien))

#define isalienhunter(A) (istype(A, /mob/living/carbon/alien/humanoid/hunter))

#define isaliensentinel(A) (istype(A, /mob/living/carbon/alien/humanoid/sentinel))

#define isalienroyal(A) (istype(A, /mob/living/carbon/alien/humanoid/royal))

#define isalienqueen(A) (istype(A, /mob/living/carbon/alien/humanoid/royal/queen))

#define isdevil(A) (istype(A, /mob/living/carbon/true_devil))

//Silicon mobs
#define issilicon(A) (istype(A, /mob/living/silicon))

#define issiliconoradminghost(A) (istype(A, /mob/living/silicon) || IsAdminGhost(A))

#define iscyborg(A) (istype(A, /mob/living/silicon/robot))

#define isAI(A) (istype(A, /mob/living/silicon/ai))

#define ispAI(A) (istype(A, /mob/living/silicon/pai))

//Simple animals
#define isanimal(A) (istype(A, /mob/living/simple_animal))

#define isrevenant(A) (istype(A, /mob/living/simple_animal/revenant))

#define isbot(A) (istype(A, /mob/living/simple_animal/bot))

#define isshade(A) (istype(A, /mob/living/simple_animal/shade))

#define ismouse(A) (istype(A, /mob/living/simple_animal/mouse))

#define isslime(A) (istype(A, /mob/living/simple_animal/slime))

#define isdrone(A) (istype(A, /mob/living/simple_animal/drone))

#define iscat(A) (istype(A, /mob/living/simple_animal/pet/cat))

#define iscorgi(A) (istype(A, /mob/living/simple_animal/pet/dog/corgi))

#define ishostile(A) (istype(A, /mob/living/simple_animal/hostile))

#define isswarmer(A) (istype(A, /mob/living/simple_animal/hostile/swarmer))

#define isguardian(A) (istype(A, /mob/living/simple_animal/hostile/guardian))

#define isclockmob(A) (istype(A, /mob/living/simple_animal/hostile/clockwork))

#define isconstruct(A) (istype(A, /mob/living/simple_animal/hostile/construct))

#define ismegafauna(A) (istype(A, /mob/living/simple_animal/hostile/megafauna))

#define isclown(A) (istype(A, /mob/living/simple_animal/hostile/retaliate/clown))

#define iseminence(A) (istype(A, /mob/living/simple_animal/eminence))

#define iscogscarab(A) (istype(A, /mob/living/simple_animal/drone/cogscarab))

GLOBAL_LIST_INIT(shoefootmob, typecacheof(list(
	/mob/living/carbon/human/,
	/mob/living/simple_animal/cow,
	/mob/living/simple_animal/hostile/cat_butcherer,
	/mob/living/simple_animal/hostile/faithless,
	/mob/living/simple_animal/hostile/nanotrasen,
	/mob/living/simple_animal/hostile/pirate,
	/mob/living/simple_animal/hostile/russian,
	/mob/living/simple_animal/hostile/syndicate,
	/mob/living/simple_animal/hostile/wizard,
	/mob/living/simple_animal/hostile/zombie,
	/mob/living/simple_animal/hostile/retaliate/clown,
	/mob/living/simple_animal/hostile/retaliate/spaceman,
	/mob/living/simple_animal/hostile/retaliate/nanotrasenpeace,
	/mob/living/simple_animal/hostile/retaliate/goat,
	/mob/living/carbon/true_devil,
	)))

GLOBAL_LIST_INIT(clawfootmob, typecacheof(list(
	/mob/living/carbon/alien/humanoid,
	/mob/living/simple_animal/hostile/alien,
	/mob/living/simple_animal/pet/cat,
	/mob/living/simple_animal/pet/dog,
	/mob/living/simple_animal/pet/fox,
	/mob/living/simple_animal/chicken,
	/mob/living/simple_animal/hostile/bear,
	/mob/living/simple_animal/hostile/jungle/mega_arachnid
	)))

GLOBAL_LIST_INIT(barefootmob, typecacheof(list(
	/mob/living/carbon/monkey,
	/mob/living/simple_animal/pet/penguin,
	/mob/living/simple_animal/hostile/gorilla,
	/mob/living/simple_animal/hostile/jungle/mook
	)))

GLOBAL_LIST_INIT(heavyfootmob, typecacheof(list(
	/mob/living/simple_animal/hostile/megafauna,
	/mob/living/simple_animal/hostile/jungle/leaper
	)))

//Misc mobs
#define isobserver(A) (istype(A, /mob/dead/observer))

#define isdead(A) (istype(A, /mob/dead))

#define isnewplayer(A) (istype(A, /mob/dead/new_player))

#define isovermind(A) (istype(A, /mob/camera/blob))

#define iscameramob(A) (istype(A, /mob/camera))

#define isaicamera(A) (istype(A, /mob/camera/ai_eye))

//Footstep helpers
#define isshoefoot(A) (is_type_in_typecache(A, GLOB.shoefootmob))

#define isclawfoot(A) (is_type_in_typecache(A, GLOB.clawfootmob))

#define isbarefoot(A) (is_type_in_typecache(A, GLOB.barefootmob))

#define isheavyfoot(A) (is_type_in_typecache(A, GLOB.heavyfootmob))

//Objects
#define isobj(A) istype(A, /obj) //override the byond proc because it returns true on children of /atom/movable that aren't objs

#define isitem(A) (istype(A, /obj/item))

#define isgrenade(A) (istype(A, /obj/item/grenade))

#define islandmine(A) (istype(A, /obj/effect/mine))

#define isammocasing(A) (istype(A, /obj/item/ammo_casing))

#define isidcard(I) (istype(I, /obj/item/card/id))

#define isstructure(A) (istype(A, /obj/structure))

#define ismachinery(A) (istype(A, /obj/machinery))

#define ismecha(A) (istype(A, /obj/mecha))

#define is_cleanable(A) (istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/rune)) //if something is cleanable

#define isorgan(A) (istype(A, /obj/item/organ))

#define isclothing(A) (istype(A, /obj/item/clothing))

GLOBAL_LIST_INIT(pointed_types, typecacheof(list(
	/obj/item/pen,
	/obj/item/screwdriver,
	/obj/item/reagent_containers/syringe,
	/obj/item/kitchen/fork)))

#define is_pointed(W) (is_type_in_typecache(W, GLOB.pointed_types))

#define isbodypart(A) (istype(A, /obj/item/bodypart))

#define isprojectile(A) (istype(A, /obj/item/projectile))

#define isgun(A) (istype(A, /obj/item/gun))

//Assemblies
#define isassembly(O) (istype(O, /obj/item/assembly))

#define isigniter(O) (istype(O, /obj/item/assembly/igniter))

#define isprox(O) (istype(O, /obj/item/assembly/prox_sensor))

#define issignaler(O) (istype(O, /obj/item/assembly/signaler))

GLOBAL_LIST_INIT(glass_sheet_types, typecacheof(list(
	/obj/item/stack/sheet/glass,
	/obj/item/stack/sheet/rglass,
	/obj/item/stack/sheet/plasmaglass,
	/obj/item/stack/sheet/plasmarglass,
	/obj/item/stack/sheet/titaniumglass,
	/obj/item/stack/sheet/nanocarbon_glass, //NSV13
	/obj/item/stack/sheet/plastitaniumglass)))

#define is_glass_sheet(O) (is_type_in_typecache(O, GLOB.glass_sheet_types))

#define iseffect(O) (istype(O, /obj/effect))

#define isholoeffect(O) (istype(O, /obj/effect/holodeck_effect))

#define isblobmonster(O) (istype(O, /mob/living/simple_animal/hostile/blob))

#define isshuttleturf(T) (length(T.baseturfs) && (/turf/baseturf_skipover/shuttle in T.baseturfs))

/// isnum() returns TRUE for NaN. Also, NaN != NaN. Checkmate, BYOND.
#define isnan(x) ( (x) != (x) )

#define isinf(x) (isnum((x)) && (((x) == SYSTEM_TYPE_INFINITY) || ((x) == -SYSTEM_TYPE_INFINITY)))

#define isProbablyWallMounted(O) (O.pixel_x > 20 || O.pixel_x < -20 || O.pixel_y > 20 || O.pixel_y < -20)

#define isbook(O) (is_type_in_typecache(O, GLOB.book_types))

/// NaN isn't a number, damn it. Infinity is a problem too.
#define isnum_safe(x) ( isnum((x)) && !isnan((x)) && !isinf((x)) )

#define iscash(A) (istype(A, /obj/item/coin) || istype(A, /obj/item/stack/spacecash) || istype(A, /obj/item/holochip))
