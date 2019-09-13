#define BS_FUSE 		0
#define BS_FUSE_BOLT 	1
#define BS_FUSE_WELD 	2
#define BS_EMPE 		3
#define BS_EMPE_BOLT 	4
#define BS_EMPE_WELD 	5
#define BS_WING1 		6
#define BS_WING1_BOLT 	7
#define BS_WING1_WELD 	8
#define BS_WING2 		9
#define BS_WING2_BOLT 	10
#define BS_WING2_WELD	11
#define BS_LANG			12
#define BS_LANG_BOLT	13
#define BS_ARMP			14
#define BS_ARMP_SCREW	15
#define BS_ARMP_WELD	16
#define BS_WIRE1		17
#define BS_WIRE1_MULTI	18
#define BS_FUET			19
#define BS_FUET_BOLT	20
#define BS_FUEL			21
#define BS_FUEL_BOLT	22
#define BS_ENGI1		23
#define BS_ENGI1_WELD	24
#define BS_ENGI2		25
#define BS_ENGI2_WELD	26
#define BS_THRU_MULTI	27
#define BS_COCK			28
#define BS_COCK_SCREW	29
#define BS_COCK_BOLT	30
#define BS_WIRE2		31
#define BS_AVIO			32
#define BS_AVIO_SCREW	33
#define BS_AVIO_MULTI	34
#define BS_TARS			35
#define BS_TARS_SCREW	36
#define BS_TARS_MULTI	37
#define BS_PAINT		38

//Fighter

/obj/structure/overmap/fighter
	name = "overmap fighter"
	desc = "A space faring fighter craft."
	icon = 'nsv13/icons/overmap/default.dmi'
	icon_state = "default"

/obj/structure/overmap/fighter/Initialize()
	.=..()


/obj/structure/overmap/fighter/attackby

//Fighter Build Path - The MaA will kill you if you make them have to go through this

/obj/structure/fighter_component/underconstruction_fighter
	name = "Incomplete Fighter"
	desc = "An Incomplete Fighter"
	icon = ""
	icon_state = ""
	anchored = TRUE
	density = TRUE
	climable = TRUE
	var/build_state = BS_FUSE
	var/obj/item/twohanded/required/fighter_component/armour_plating/ap = null
	var/obj/item/twohanded/required/fighter_component/fuel_tank/ft = null
	var/obj/item/fighter_component/engine/en1 = null
	var/obj/item/fighter_component/engine/en2 = null
	var/obj/item/fighter_component/avionics/av = null
	var/obj/item/fighter_component/targeting_system/ts = null

/obj/structure/fighter_component/underconsttruction_fighter/examine(mob/user)
	. = ..()
	switch(build_state)
		if(BS_FUSE)
		. += "<span class='notice'>0</span>"
		if(BS_FUSE_BOLT)
		. += "<span class='notice'>1</span>"
		if(BS_FUSE_WELD)
		. += "<span class='notice'>2</span>"
		if(BS_EMPE)
		. += "<span class='notice'>3</span>"
		if(BS_EMPE_BOLT)
		. += "<span class='notice'>4</span>"
		if(BS_EMPE_WELD)
		. += "<span class='notice'>5</span>"
		if(BS_WING1)
		. += "<span class='notice'>6</span>"
		if(BS_WING1_BOLT)
		. += "<span class='notice'>7</span>"
		if(BS_WING1_WELD)
		. += "<span class='notice'>8</span>"
		if(BS_WING2)
		. += "<span class='notice'>9</span>"
		if(BS_WING2_BOLT)
		. += "<span class='notice'>10</span>"
		if(BS_WING2_WELD)
		. += "<span class='notice'>11</span>"
		if(BS_LANG)
		. += "<span class='notice'>12</span>"
		if(BS_LANG_BOLT)
		. += "<span class='notice'>13</span>"
		if(BS_ARMP)
		. += "<span class='notice'>14</span>"
		if(BS_ARMP_BOLT)
		. += "<span class='notice'>15</span>"
		if(BS_ARMP_SCREW)
		. += "<span class='notice'>16</span>"
		if(BS_WIRE1)
		. += "<span class='notice'>17</span>"
		if(BS_WIRE1_MULTI)
		. += "<span class='notice'>18</span>"
		if(BS_FUET)
		. += "<span class='notice'>19</span>"
		if(BS_FUET_BOLT)
		. += "<span class='notice'>20</span>"
		if(BS_FUEL)
		. += "<span class='notice'>21</span>"
		if(BS_FUEL_BOLT)
		. += "<span class='notice'>22</span>"
		if(BS_ENGI1)
		. += "<span class='notice'>23</span>"
		if(BS_ENGI1_WELD)
		. += "<span class='notice'>24</span>"
		if(BS_ENGI2)
		. += "<span class='notice'>25</span>"
		if(BS_ENGI2_WELD)
		. += "<span class='notice'>26</span>"
		if(BS_THRU_MULTI)
		. += "<span class='notice'>27</span>"
		if(BS_COCK)
		. += "<span class='notice'>28</span>"
		if(BS_COCK_SCREW)
		. += "<span class='notice'>29</span>"
		if(BS_COCK_BOLT)
		. += "<span class='notice'>30</span>"
		if(BS_WIRE2)
		. += "<span class='notice'>31</span>"
		if(BS_AVIO)
		. += "<span class='notice'>32</span>"
		if(BS_AVIO_SCREW)
		. += "<span class='notice'>33</span>"
		if(BS_AVIO_MULTI)
		. += "<span class='notice'>34</span>"
		if(BS_TARS)
		. += "<span class='notice'>35</span>"
		if(BS_TARS_SCREW)
		. += "<span class='notice'>36</span>"
		if(BS_TARS_MULTI)
		. += "<span class='notice'>37/span>"
		if(BS_PAINT)
		. += "<span class='notice'>38/span>"

/obj/structure/fighter_component/fuselage_crate/attack_hand(mob/user)
	.=..()
	to_chat(user, "<span class='notice'>You begin constructing the fuselage of a new fighter.</span>")
	if(!do_after(user, 5 SECONDS, target=src))
		return
	to_chat(user, "<span class='notice'>You construct the fuselage of a new fighter.</span>")
	new/obj/structure/fighter_component/underconstruction_fighter
	qdel(src)

/obj/structure/fighter_component/underconstruction_fighter/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/twohanded/required/fighter_component/cockpit))
		if(BS_THRU_MULTI)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			//wh = W
			build_state = BS_COCK
			update_icon()
			qdel(W)
		return
	else if(istype(W, /obj/item/twohanded/required/fighter_component/wing))
		if(BS_EMPE_WELD)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			//wh = W
			build_state = BS_WING1
			update_icon()
			qdel(W)
		else if(BS_WING1_WELD)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			//wh = W
			build_state = BS_WING2
			update_icon()
			qdel(W)
		return
	else if(istype(W, /obj/item/twohanded/required/fighter_component/empennage))
		if(BS_FUSE_WELD)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			//wh = W
			build_state = BS_EMPE
			update_icon()
			qdel(W)
		return
	else if(istype(W, /obj/item/twohanded/required/fighter_component/landing_gear))
		if(BS_WING2_WELD)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			//wh = W
			build_state = BS_LANG
			update_icon()
			qdel(W)
		return
	else if(istype(W, /obj/item/twohanded/required/fighter_component/armour_plating))
		if(BS_LANG_BOLT)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			//wh = W
			build_state = BS_ARMP
			update_icon()
			qdel(W)
		return
	else if(istype(W, /obj/item/twohanded/required/fighter_component/fuel_tank))
		if(BS_WIRE1_MULTI)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			//wh = W
			build_state = BS_FUET
			update_icon()
			qdel(W)
		return
	else if(istype(W, /obj/item/fighter_component/avionics))
		if(BS_WIRE2)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			//wh = W
			build_state = BS_AVIO
			update_icon()
			qdel(W)
		return
	else if(istype(W, /obj/item/fighter_component/targeting_sensor))
		if(BS_AVIO_MULTI)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			//wh = W
			build_state = BS_AVIO
			update_icon()
			qdel(W)
		return
	else if(istype(W, /obj/item/fighter_component/fuel_lines))
		if(BS_FUET_BOLT)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			//wh = W
			build_state = BS_FUEL
			update_icon()
			qdel(W)
		return
	else if(istype(W, /obj/item/fighter_component/engine))
		if(BS_FUEL_BOLT)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			//wh = W
			build_state = BS_ENGI1
			update_icon()
			qdel(W)
		else if(BS_ENGI1_WELD)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			//wh = W
			build_state = BS_ENGI2
			update_icon()
			qdel(W)
		return
	else if(istype(W, /obj/item/airlock_painter))
		if(BS_TARS_MULTI)
			to_chat(user, "<span class='notice'></span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'></span>")
			//wh = W
			build_state = BS_PAINT
			update_icon()
		return
	else if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if(BS_POWP_SCREW)
			if(C.get_amount() < 3)
				to_chat(user, "<span class='notice'>You need at least three cable pieces to wire [src]!</span>")
				return
			to_chat(user, "<span class='notice'>You start wiring [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			W.use(3)
			to_chat(user, "<span class='notice'>You wire [src].</span>")
			build_state = BS_WIRE1
			update_icon()
		else if(BS_COCK_BOLT)
			if(C.get_amount() < 3)
				to_chat(user, "<span class='notice'>You need at least three cable pieces to wire [src]!</span>")
				return
			to_chat(user, "<span class='notice'>You start wiring [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			W.use(3)
			to_chat(user, "<span class='notice'>You wire [src].</span>")
			build_state = BS_WIRE2
			update_icon()
		return

/obj/structure/fighter_component/underconstruction_fighter/wrench_act(mob/user, obj/item/tool)
	. = FALSE
	switch(build_state)
		if(BS_FUSE)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				build_state = BS_FUSE_BOLT
				update_icon()
				return TRUE
		if(BS_FUSE_BOLT)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				build_state = BS_FUSE
				update_icon()
				return TRUE
		if(BS_EMPE)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				build_state = BS_EMPE_BOLT
				update_icon()
				return TRUE
		if(BS_EMPE_BOLT)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				build_state = BS_EMPE
				update_icon()
				return TRUE
		if(BS_WING1)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				build_state = BS_WING1_BOLT
				update_icon()
				return TRUE
		if(BS_WING1_BOLT)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				build_state = BS_WING1
				update_icon()
				return TRUE
		if(BS_WING2)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				build_state = BS_WING2_BOLT
				update_icon()
				return TRUE
		if(BS_WING2_BOLT)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				build_state = BS_WING2
				update_icon()
				return TRUE
		if(BS_LANG)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				build_state = BS_LANG_BOLT
				update_icon()
				return TRUE
		if(BS_LANG_BOLT)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				build_state = BS_LANG
				update_icon()
				return TRUE
		if(BS_FUET)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				build_state = BS_FUET_BOLT
				update_icon()
				return TRUE
		if(BS_FUET_BOLT)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				build_state = BS_FUET
				update_icon()
				return TRUE
		if(BS_FUEL)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				build_state = BS_FUEL_BOLT
				update_icon()
				return TRUE
		if(BS_FUEL_BOLT)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				build_state = BS_FUEL
				update_icon()
				return TRUE
		if(BS_COCK_SCREW)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				build_state = BS_COCK_BOLT
				update_icon()
				return TRUE
		if(BS_COCK_BOLT)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				build_state = BS_COCK_SCREW
				update_icon()
				return TRUE

/obj/structure/fighter_componenet/underconstruction_fighter/screwdriver_act(mob/user, obj/item/tool)
	. = FALSE
	switch(build_state)
		if(BS_ARMP)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_ARMP_SCREW
				update_overlay()
				return TRUE
		if(BS_ARMP_SCREW)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_ARMP
				update_overlay()
				return TRUE
		if(BS_COCK)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_COCK_SCREW
				update_overlay()
				return TRUE
		if(BS_COCK_SCREW)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_COCK
				update_overlay()
				return TRUE
		if(BS_AVIO)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_AVIO_SCREW
				update_overlay()
				return TRUE
		if(BS_AVIO_SCREW)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_AVIO
				update_overlay()
				return TRUE
		if(BS_TARS)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_TARS_SCREW
				update_overlay()
				return TRUE
		if(BS_TARS_SCREW)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_TARS
				update_overlay()
				return TRUE

/obj/structure/fighter_componenet/underconstruction_fighter/welder_act(mob/user, obj/item/tool)
	. = FALSE
	switch(build_state)
		if(BS_FUSE_BOLT)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_FUSE_WELD
				update_overlay()
				return TRUE
		if(BS_FUSE_WELD)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_FUSE_BOLT
				update_overlay()
				return TRUE
		if(BS_EMPE_BOLT)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_EMPE_WELD
				update_overlay()
				return TRUE
		if(BS_EMPE_WELD)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_EMPE_BOLT
				update_overlay()
				return TRUE
		if(BS_WING1_BOLT)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_WING1_WELD
				update_overlay()
				return TRUE
		if(BS_WING1_WELD)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_WING1_BOLT
				update_overlay()
				return TRUE
		if(BS_WING2_BOLT)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_WING2_WELD
				update_overlay()
				return TRUE
		if(BS_WING2_WELD)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_WING2_BOLT
				update_overlay()
				return TRUE
		if(BS_ARMP_SCREW)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_ARMP_WELD
				update_overlay()
				return TRUE
		if(BS_ARMP_WELD)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_ARMP_SCREW
				update_overlay()
				return TRUE
		if(BS_ENGI1)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_ENGI1_WELD
				update_overlay()
				return TRUE
		if(BS_ENGI1_WELD)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_ENGI1
				update_overlay()
				return TRUE
		if(BS_ENGI2)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_ENGI2_WELD
				update_overlay()
				return TRUE
		if(BS_ENGI2_WELD)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_ENGI2
				update_overlay()
				return TRUE

/obj/structure/fighter_componenet/underconstruction_fighter/multitool_act(mob/user, obj/item/tool)
	. = FALSE
	switch(build_state)
		if(BS_WIRE1)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_WIRE1_MULTI
				update_overlay()
				return TRUE
		if(BS_WIRE1_MULTI)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_WIRE1
				update_overlay()
				return TRUE
		if(BS_ENGI2_WELD)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_THRU_MULTI
				update_overlay()
				return TRUE
		if(BS_THRU_MULTI)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_ENGI2_WELD
				update_overlay()
				return TRUE
		if(BS_AVIO_SCREW)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_AVIO_MULTI
				update_overlay()
				return TRUE
		if(BS_AVIO_MULTI)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_AVIO_SCREW
				update_overlay()
				return TRUE
		if(BS_TARS_SCREW)
			to_chat(user, "<span class='notice'></span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'></span>")
				maint_state = BS_TARS_MULTI
				update_overlay()
				return TRUE

/obj/structure/fighter_component/underconstruction_fighter/wirecutter_act(mob/user, obj/item/tool)
	. = FALSE
	switch(build_state)
		if(BS_WIRE1)
			to_chat(user, "<span class='notice'>You start cutting the wiring in [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You cut the wiring in [src].</span>")
				var/obj/item/stack/cable_coil/C = new (loc, 3)
				C.add_fingerprint(user)
				build_state = BS_ARMP_WELD
				update_overlay()
			return TRUE
		if(BS_WIRE2)
			to_chat(user, "<span class='notice'>You start cutting the wiring in [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You cut the wiring in [src].</span>")
				var/obj/item/stack/cable_coil/C = new (loc, 3)
				C.add_fingerprint(user)
				build_state = BS_COCK_BOLT
				update_overlay()
			return TRUE

/obj/structure/fighter_component/underconstruction_fighter/crowbar_act(mob/user, obj/item/tool)
	. = FALSE
	switch(build_state)
		if(BS_TARS)
			to_chat(user, "<span class='notice'>You start removing [ts.name] from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove [ts.name] from [src].</span>")
				ts = new (loc, 1)
				ts = null
				state = BS_AVIO_MULTI
				update_icon()
			return TRUE
		if(BS_AVIO)
			to_chat(user, "<span class='notice'>You start removing the avionics from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the avionics from [src].</span>")
				new/obj/item/fighter_component/avionics
				state = BS_WIRE2
				update_icon()
			return TRUE
		if(BS_COCK)
			to_chat(user, "<span class='notice'>You start disassembling the cockpit from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You disassemble the cockpit from [src].</span>")
				new/obj/twohanded/required/fighter_component/cockpit
				state = BS_THRU_MULTI
				update_icon()
			return TRUE
		if(BS_ENGI2)
			to_chat(user, "<span class='notice'>You start removing [en2.name] from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove [en2.name] from [src].</span>")
				en2 = new (loc, 1)
				en2 = null
				state = BS_ENGI1_WELD
				update_icon()
			return TRUE
		if(BS_ENGI1)
			to_chat(user, "<span class='notice'>You start removing [en1.name] from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove [en1.name] from [src].</span>")
				en1 = new (loc, 1)
				en1 = null
				state = BS_FUEL_BOLT
				update_icon()
			return TRUE
		if(BS_FUEL)
			to_chat(user, "<span class='notice'>You start removing [fl.name] from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove [fl.name] from [src].</span>")
				fl = new (loc, 1)
				fl = null
				state = BS_FUET_BOLT
				update_icon()
			return TRUE
		if(BS_FUET)
			to_chat(user, "<span class='notice'>You start removing [ft.name] from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove [ft.name] from [src].</span>")
				ft = new (loc, 1)
				ft = null
				state = BS_WIRE1_MULTI
				update_icon()
			return TRUE
		if(BS_ARMP)
			to_chat(user, "<span class='notice'>You start removing [ap.name] from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove [ap.name] from [src].</span>")
				ap = new (loc, 1)
				ap = null
				state = BS_LANG_BOLT
				update_icon()
			return TRUE
		if(BS_LANG)
			to_chat(user, "<span class='notice'>You start removing the landing gear from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the landing gear from [src].</span>")
				new/obj/twohanded/required/fighter_component/landing_gear
				state = BS_WING2_WELD
				update_icon()
			return TRUE
		if(BS_WING2)
			to_chat(user, "<span class='notice'>You start disassembling a wing from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You disassemble a wing from [src].</span>")
				new/obj/twohanded/required/fighter_component/wing
				state = BS_WING1_WELD
				update_icon()
			return TRUE
		if(BS_WING1)
			to_chat(user, "<span class='notice'>You start disassembling a wing from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You disassemble a wing from [src].</span>")
				new/obj/twohanded/required/fighter_component/wing
				state = BS_EMPE_WELD
				update_icon()
			return TRUE
		if(BS_EMPE)
			to_chat(user, "<span class='notice'>You start disassembling the [src] empennage...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You disassemble the [src] empennage.</span>")
				new/obj/twohanded/required/fighter_component/empennage
				state = BS_FUSE_WELD
				update_icon()
			return TRUE
		if(BS_FUSE)
			to_chat(user, "<span class='notice'>You start disassembling the [src] fuselage... </span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You disassemble the [src] fuselage</span>")
				new/obj/structure/fighter_component/fuselage_crate
				qdel(src)
			return TRUE

//Fighter Components

/obj/structure/fighter_component/fuselage_crate
	name = "Fighter Fuselage Components"
	desc = "A crate full of fuselage components for a fighter"
	icon = ""
	icon_state = ""
	anchored = FALSE
	density = TRUE
	climable = TRUE

/obj/item/twohanded/required/fighter_component/cockpit
	name = "Fighter Cockpit Components"
	desc = "A box of cockpit components for a fighter"
	icon = ""
	icon_state = ""
	lefthand_file = ""
	righthand_file = ""
	w_class = WEIGHT_CLASS_COLOSSAL

/obj/item/twohanded/required/fighter_component/wing
	name = "Fighter Wing Components"
	desc = "A box of wing components for a fighter"
	icon = ""
	icon_state = ""
	lefthand_file = ""
	righthand_file = ""
	w_class = WEIGHT_CLASS_COLOSSAL

/obj/item/twohanded/required/fighter_component/empennage
	name = "Fighter Empennage Componets"
	desc = "A box of empennage components for a fighter"
	icon = ""
	icon_state = ""
	lefthand_file = ""
	righthand_file = ""
	w_class = WEIGHT_CLASS_COLOSSAL

/obj/item/twohanded/required/fighter_component/landing_gear
	name = "Fighter Landing Gear Componets"
	desc = "A box of landing gear components for a fighter"
	icon = ""
	icon_state = ""
	lefthand_file = ""
	righthand_file = ""
	w_class = WEIGHT_CLASS_COLOSSAL

/obj/item/twohanded/required/fighter_component/armour_plating
	name = "Fighter Armour Plating"
	desc = "Armour plating for a fighter"
	icon = ""
	icon_state = ""
	lefthand_file = ""
	righthand_file = ""
	w_class = WEIGHT_CLASS_COLOSSAL
	var/armour = 50 //BONUS HP VALUE

/obj/item/twohanded/required/fighter_component/fuel_tank
	name = "Fighter Fuel Tank"
	desc = "The fuel tank of a fighter"
	icon = ""
	icon_state = ""
	lefthand_file = ""
	righthand_file = ""
	w_class = WEIGHT_CLASS_COLOSSAL
	var/capacity = 1000 //Fuel Capacity

/obj/item/twohanded/required/fighter_component/primary_weapon
	name = "Fighter Primary Weapon"
	desc = "Fighter Primary Weapon"
	icon = ""
	icon_state = ""
	lefthand_file = ""
	righthand_file = ""
	w_class = WEIGHT_CLASS_COLOSSAL

/obj/item/twohanded/required/fighter_component/secondary_weapon
	name = "Fighter Secondary Weapon"
	desc = "Fighter Secondary Weapon"
	icon = ""
	icon_state = ""
	lefthand_file = ""
	righthand_file = ""
	w_class = WEIGHT_CLASS_COLOSSAL

/obj/item/fighter_component/avionics
	name = "Fighter Avionics"
	desc = "Avionics for a fighter"
	icon = ""
	icon_state = ""
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/fighter_component/targeting_sensor
	name = "Fighter Targeting Sensors"
	desc = "Targeting sensors for a fighter"
	icon = ""
	icon_state = ""
	w_class = WEIGHT_CLASS_NORMAL
	var/weapon_efficiency = 1 //Primary ammo usage modifier

/obj/item/fighter_component/fuel_lines
	name = "Fighter Fuel Lines Kit"
	desc = "Fuel line kit for routing fuel around a fighter"
	icon = ""
	icon_state = ""
	w_class = WEIGHT_CLASS_NORMAL
	var/fuel_efficiency = 1 //Fuel usage modifier

/obj/item/fighter_componet/engine
	name = "Fighter Engine"
	desc = "An engine assembly for a fighter"
	icon = ""
	icon_state = ""
	w_class = WEIGHT_CLASS_BULKY
	var/speed = 1 //Speed modifier
	var/consumption = 1 //How fast we burn fuel

