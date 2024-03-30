/obj/item/fighter_component/ftl
	name = "class II torch drive"
	desc = "The torch drive is a far faster and more safe alternative to traditional FTL travel methods, however it requires either a star to jump to, or a phyically placed jump beacon."
	icon_state = "ftl_drive"
	slot = HARDPOINT_SLOT_FTL
	active = FALSE
	power_usage = 200
	weight = 0.5
	var/progress = 0
	var/spoolup_time = 120
	var/ftl_startup_time = 6
	var/ftl_loop = 'nsv13/sound/effects/ship/FTL_loop.ogg'
	var/ftl_start = 'nsv13/sound/effects/ship/FTL_torchdrive.ogg'
	var/ftl_exit = 'nsv13/sound/effects/ship/freespace2/warp_close.wav'
	var/auto_spool_enabled = TRUE
	var/req_charge = 120

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
	var/obj/structure/overmap/ourfighter = get_overmap()
	anchored_to = ourfighter.get_overmap()

/obj/item/fighter_component/ftl/on_install(obj/structure/overmap/target)
	. = ..()
	var/obj/structure/overmap/OM = loc
	OM.ftl_drive = src

/obj/item/fighter_component/ftl/remove_from(obj/structure/overmap/target, due_to_damage)
	var/obj/structure/overmap/OM = loc
	. = ..()
	if(. && istype(OM) && OM.ftl_drive == src)
		OM.ftl_drive = null

/obj/item/fighter_component/ftl/proc/force_jump(datum/star_system/target_system)
	jump(target_system, force=TRUE)

/obj/item/fighter_component/ftl/proc/jump(datum/star_system/target_system, force=FALSE)
	var/obj/structure/overmap/linked = loc
	if(!linked)
		to_chat(usr, "<span class='warning'>This drive was not installed correctly.</span>")
		message_admins("Fighter FTL drive tried to jump but could not find the linked overmap at [ADMIN_VERBOSEJMP(src)]")
		return FALSE
	if(!target_system || !SSmapping.level_trait(loc.z, ZTRAIT_OVERMAP) || SSmapping.level_trait(loc.z, ZTRAIT_RESERVED))
		to_chat(usr, "<span class='warning'>Unable to obtain positional data for jump.</span>")
		return
	if(linked.get_overmap())
		to_chat(usr, "<span class='warning'>The area is not clear to initiate a jump. Move away from other ships and orbital bodies.</span>")
		return
	ftl_state = FTL_STATE_JUMPING
	linked.begin_jump(target_system, force)
	linked.relay('nsv13/sound/effects/ship/freespace2/computer/escape.wav')
	progress = 0

/obj/item/fighter_component/ftl/proc/cancel_ftl()
	depower()

/obj/item/fighter_component/ftl/proc/depower()
	progress = 0
	ftl_state = FTL_STATE_IDLE

/obj/item/fighter_component/ftl/proc/get_jump_speed()
	return jump_speed_factor

/obj/item/fighter_component/ftl/process(delta_time)
	//Not calling parent here as there's no need to use power yet if we're already spooled.
	if(ftl_state == FTL_STATE_JUMPING)
		return
	ftl_state = FTL_STATE_SPOOLING
	if(progress >= spoolup_time)
		ftl_state = FTL_STATE_READY
		return
	if(!power_tick(delta_time))
		return
	progress = CLAMP(progress + delta_time, 0, spoolup_time)


/obj/item/fighter_component/ftl/tier2
	name = "class III torch drive"
	desc = "A micro jump drive with an expanded range."
	max_range = 200

/obj/effect/temp_visual/overmap_ftl
	icon = 'nsv13/icons/overmap/effects.dmi'
	icon_state = "warp"
	duration = 1 SECONDS
	randomdir = FALSE
