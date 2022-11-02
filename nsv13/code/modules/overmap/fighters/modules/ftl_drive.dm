/obj/item/fighter_component/ftl
	name = "class II torch drive"
	desc = "The torch drive is a far faster and more safe alternative to traditional FTL travel methods, however it requires either a star to jump to, or a phyically placed jump beacon."
	icon_state = "ftl_drive"
	slot = HARDPOINT_SLOT_FTL
	active = FALSE
	power_usage = 200
	weight = 0.5
	var/progress = 0
	var/spoolup_time = 2 MINUTES
	var/ftl_startup_time = 6 SECONDS
	var/ftl_loop = 'nsv13/sound/effects/ship/FTL_loop.ogg'
	var/ftl_start = 'nsv13/sound/effects/ship/FTL_torchdrive.ogg'
	var/ftl_exit = 'nsv13/sound/effects/ship/freespace2/warp_close.wav'

	var/jump_speed_factor = 5.5 //How quickly do we jump? Larger is faster.
	var/ftl_state = FTL_STATE_IDLE //Mr Gaeta, spool up the FTLs.

	var/can_cancel_jump = TRUE //Defaults to true. TODO: Make emagging disable this
	var/max_range = 50 //Short range drive
	var/lockout = FALSE

	var/obj/structure/overmap/anchored_to

/obj/item/fighter_component/ftl/Initialize(mapload)
	. = ..()
	if(mapload)
		return INITIALIZE_HINT_LATELOAD

/obj/item/fighter_component/ftl/LateInitialize()
	set waitfor = FALSE
	var/obj/structure/overmap/ourfighter = get_overmap()
	anchored_to = ourfighter.get_overmap()

/obj/item/fighter_component/ftl/tier2
	name = "class III torch drive"
	desc = "A micro jump drive with an expanded range."
	max_range = 200

/obj/item/fighter_component/ftl/proc/jump(datum/star_system/target_system, force=FALSE)
	var/obj/structure/overmap/linked = loc
	if(!linked)
		to_chat(usr, "<span class='warning'>This drive was not installed correctly.</span>")
		message_admins("Fighter FTL drive tried to jump but could not find the linked overmap at [ADMIN_VERBOSEJMP(src)]")
		return FALSE
	if(!target_system || !(SSmapping.level_trait(loc.z, ZTRAIT_OVERMAP) || SSmapping.level_trait(loc.z, ZTRAIT_RESERVED)))
		to_chat(usr, "<span class='warning'>Unable to obtain positional data for jump.</span>")
		return
	if(linked.get_overmap())
		to_chat(usr, "<span class='warning'>The area is not clear to initiate a jump. Move away from other ships and orbital bodies.</span>")
		return
	ftl_state = FTL_STATE_JUMPING
	linked.begin_jump(target_system, force)
	linked.relay('nsv13/sound/effects/ship/freespace2/computer/escape.wav')
	progress = 0
	addtimer(CALLBACK(src, .proc/depower), ftl_startup_time)

/obj/item/fighter_component/ftl/proc/cancel_ftl()
	depower()

/obj/item/fighter_component/ftl/proc/depower()
	progress = 0
	ftl_state = FTL_STATE_IDLE

/obj/item/fighter_component/ftl/process()
	//No need to use power here. We're already spooled.
	var/obj/structure/overmap/OM = loc
	if(OM)
		OM.ftl_drive = src
	if(ftl_state == FTL_STATE_JUMPING)
		return
	ftl_state = FTL_STATE_SPOOLING
	if(progress >= spoolup_time)
		ftl_state = FTL_STATE_READY
		return
	if(!powered())
		return
	progress += 1 SECONDS
	progress = CLAMP(progress, 0, spoolup_time)

/obj/effect/temp_visual/overmap_ftl
	icon = 'nsv13/icons/overmap/effects.dmi'
	icon_state = "warp"
	duration = 1 SECONDS
	randomdir = FALSE
