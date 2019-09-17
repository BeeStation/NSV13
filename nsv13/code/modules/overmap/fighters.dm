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
#define BS_COCP			28
#define BS_COCP_SCREW	29
#define BS_COCP_BOLT	30
#define BS_WIRE2		31
#define BS_AVIO			32
#define BS_AVIO_SCREW	33
#define BS_AVIO_MULTI	34
#define BS_TARS			35
#define BS_TARS_SCREW	36
#define BS_TARS_MULTI	37
#define BS_PAINT		38

#define MS_CLOSED 		0
#define MS_UNSECURE 	1
#define MS_OPEN	 		2

//Fighter

/obj/structure/overmap/fighter
	name = "overmap fighter"
	desc = "A space faring fighter craft."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	var/maint_state = MS_CLOSED

/obj/structure/overmap/fighter/Initialize()
	.=..()

//Fighter Build Path - The MaA will kill you if you make them have to go through this

/obj/structure/fighter_component/underconstruction_fighter
	name = "Incomplete Fighter"
	desc = "An Incomplete Fighter"
	icon = 'icons/obj/bedsheets.dmi'
	icon_state = "sheetwhite"
	anchored = TRUE
	density = TRUE
	climbable = TRUE
	var/build_state = BS_FUSE
	var/fighter_name = null

/obj/structure/fighter_component/underconstruction_fighter/examine(mob/user)
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
		if(BS_ARMP_SCREW)
			. += "<span class='notice'>15</span>"
		if(BS_ARMP_WELD)
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
		if(BS_COCP)
			. += "<span class='notice'>28</span>"
		if(BS_COCP_SCREW)
			. += "<span class='notice'>29</span>"
		if(BS_COCP_BOLT)
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

/obj/structure/fighter_component/underconstruction_fighter/proc/get_part(type)
	if(!type)
		return
	var/atom/movable/desired = locate(type) in contents
	return desired

/obj/structure/fighter_component/fuselage_crate/attack_hand(mob/user)
	.=..()
	if(alert(user, "Begin constructing a new fighter?",, "Yes", "No")!="Yes")
		return
	to_chat(user, "<span class='notice'>You begin constructing the fuselage of a new fighter.</span>")
	if(!do_after(user, 5 SECONDS, target=src))
		return
	to_chat(user, "<span class='notice'>You construct the fuselage of a new fighter.</span>")
	new/obj/structure/fighter_component/underconstruction_fighter (loc, 1)
	qdel(src)

/obj/structure/fighter_component/underconstruction_fighter/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/twohanded/required/fighter_component/cockpit))
		if(build_state == BS_THRU_MULTI)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			build_state = BS_COCP
			update_icon()
			W.forceMove(src)
		return
	else if(istype(W, /obj/item/twohanded/required/fighter_component/wing))
		if(build_state == BS_EMPE_WELD)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			build_state = BS_WING1
			update_icon()
			W.forceMove(src)
		else if(build_state == BS_WING1_WELD)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			build_state = BS_WING2
			update_icon()
			W.forceMove(src)
		return
	else if(istype(W, /obj/item/twohanded/required/fighter_component/empennage))
		if(build_state == BS_FUSE_WELD)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			build_state = BS_EMPE
			update_icon()
			W.forceMove(src)
		return
	else if(istype(W, /obj/item/twohanded/required/fighter_component/landing_gear))
		if(build_state == BS_WING2_WELD)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			build_state = BS_LANG
			update_icon()
			W.forceMove(src)
		return
	else if(istype(W, /obj/item/twohanded/required/fighter_component/armour_plating))
		if(build_state == BS_LANG_BOLT)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			build_state = BS_ARMP
			update_icon()
			W.forceMove(src)
		return
	else if(istype(W, /obj/item/twohanded/required/fighter_component/fuel_tank))
		if(build_state == BS_WIRE1_MULTI)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			build_state = BS_FUET
			update_icon()
			W.forceMove(src)
		return
	else if(istype(W, /obj/item/fighter_component/avionics))
		if(build_state == BS_WIRE2)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			build_state = BS_AVIO
			update_icon()
			W.forceMove(src)
		return
	else if(istype(W, /obj/item/fighter_component/targeting_sensor))
		if(build_state == BS_AVIO_MULTI)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			build_state = BS_TARS
			update_icon()
			W.forceMove(src)
		return
	else if(istype(W, /obj/item/fighter_component/fuel_lines))
		if(build_state == BS_FUET_BOLT)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			build_state = BS_FUEL
			update_icon()
			W.forceMove(src)
		return
	else if(istype(W, /obj/item/fighter_component/engine))
		if(build_state == BS_FUEL_BOLT)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			build_state = BS_ENGI1
			update_icon()
			W.forceMove(src)
		else if(build_state == BS_ENGI1_WELD)
			to_chat(user, "<span class='notice'>You start adding [W] to [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You add [W] to [src].</span>")
			build_state = BS_ENGI2
			update_icon()
			W.forceMove(src)
		return
	else if(istype(W, /obj/item/airlock_painter))
		if(build_state == BS_TARS_MULTI)
			to_chat(user, "<span class='notice'>You start painting [src]...</span>")
			if(!do_after(user, 2 SECONDS, target=src))
				return
			to_chat(user, "<span class='notice'>You paint [src].</span>")
			build_state = BS_PAINT
			update_icon()
		return
	else if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = W
		if(build_state == BS_ARMP_WELD)
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
		else if(build_state == BS_COCP_BOLT)
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
			to_chat(user, "<span class='notice'>You start to bolt the fuselage together...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You bolt the fuselage together.</span>")
				build_state = BS_FUSE_BOLT
				update_icon()
				return TRUE
		if(BS_FUSE_BOLT)
			to_chat(user, "<span class='notice'>You start to unbolt the fuselage...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unbolt the fuselage.</span>")
				build_state = BS_FUSE
				update_icon()
				return TRUE
		if(BS_EMPE)
			to_chat(user, "<span class='notice'>You start to bolt the empennage to the fuselage...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You bolt the empennage to the fuselage.</span>")
				build_state = BS_EMPE_BOLT
				update_icon()
				return TRUE
		if(BS_EMPE_BOLT)
			to_chat(user, "<span class='notice'>You start to unbolt the empennage from the fuselage...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unbolt the empennage from the fuselage.</span>")
				build_state = BS_EMPE
				update_icon()
				return TRUE
		if(BS_WING1)
			to_chat(user, "<span class='notice'>You start to bolt the wing to fuselage...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You bolt the wing to the fuselage.</span>")
				build_state = BS_WING1_BOLT
				update_icon()
				return TRUE
		if(BS_WING1_BOLT)
			to_chat(user, "<span class='notice'>You start to unbolt the wing from the fuselage...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unbolt the wing from the fuselage.</span>")
				build_state = BS_WING1
				update_icon()
				return TRUE
		if(BS_WING2)
			to_chat(user, "<span class='notice'>You start to bolt the wing to fuselage...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You bolt the wing to the fuselage.</span>")
				build_state = BS_WING2_BOLT
				update_icon()
				return TRUE
		if(BS_WING2_BOLT)
			to_chat(user, "<span class='notice'>You start to unbolt the wing from the fuselage...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unbolt the wing from the fuselage.</span>")
				build_state = BS_WING2
				update_icon()
				return TRUE
		if(BS_LANG)
			to_chat(user, "<span class='notice'>You start to bolt the landing gear to the fuselage...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You bolt the landing gear to the fuselage.</span>")
				build_state = BS_LANG_BOLT
				update_icon()
				return TRUE
		if(BS_LANG_BOLT)
			to_chat(user, "<span class='notice'>You start to unbolt the landing gear from the fuselage...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unbolt the landing gear from the fuselage.</span>")
				build_state = BS_LANG
				update_icon()
				return TRUE
		if(BS_FUET)
			to_chat(user, "<span class='notice'>You start to bolt the fuel tank in place...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You bolt the fuel tank in place.</span>")
				build_state = BS_FUET_BOLT
				update_icon()
				return TRUE
		if(BS_FUET_BOLT)
			to_chat(user, "<span class='notice'>You start to unbolt the fuel tank...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unbolt the fuel tank.</span>")
				build_state = BS_FUET
				update_icon()
				return TRUE
		if(BS_FUEL)
			to_chat(user, "<span class='notice'>You start to secure the fuel lines...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You secure the fuel linese.</span>")
				build_state = BS_FUEL_BOLT
				update_icon()
				return TRUE
		if(BS_FUEL_BOLT)
			to_chat(user, "<span class='notice'>You start to unsecure the fuel lines...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unsecure the fuel lines.</span>")
				build_state = BS_FUEL
				update_icon()
				return TRUE
		if(BS_COCP_SCREW)
			to_chat(user, "<span class='notice'>You start to secure the cockpit...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You secure the cockpit.</span>")
				build_state = BS_COCP_BOLT
				update_icon()
				return TRUE
		if(BS_COCP_BOLT)
			to_chat(user, "<span class='notice'>You start to unsecure the cockpit...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unsecure the cockput.</span>")
				build_state = BS_COCP_SCREW
				update_icon()
				return TRUE

/obj/structure/fighter_component/underconstruction_fighter/screwdriver_act(mob/user, obj/item/tool)
	. = FALSE
	switch(build_state)
		if(BS_ARMP)
			to_chat(user, "<span class='notice'>You start to screw the armour plating to [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You screw the armour plating to [src].</span>")
				build_state = BS_ARMP_SCREW
				update_icon()
				return TRUE
		if(BS_ARMP_SCREW)
			to_chat(user, "<span class='notice'>You start to unscrew the armour plating from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unscrew the armour plating from [src].</span>")
				build_state = BS_ARMP
				update_icon()
				return TRUE
		if(BS_COCP)
			to_chat(user, "<span class='notice'>You start to screw the cockpit to the fuselage...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You screw the cockpit to the fuselage.</span>")
				build_state = BS_COCP_SCREW
				update_icon()
				return TRUE
		if(BS_COCP_SCREW)
			to_chat(user, "<span class='notice'>You start to unscrew the cockpit from the fuselage...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unscrew the cockpit from the fuselage.</span>")
				build_state = BS_COCP
				update_icon()
				return TRUE
		if(BS_AVIO)
			to_chat(user, "<span class='notice'>You start securing the avionics into the cockpit...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You secure the avionics in the cockpit.</span>")
				build_state = BS_AVIO_SCREW
				update_icon()
				return TRUE
		if(BS_AVIO_SCREW)
			to_chat(user, "<span class='notice'>You start unsecuring the avionics from the cockpit...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unsecure the avionics from the cockpit.</span>")
				build_state = BS_AVIO
				update_icon()
				return TRUE
		if(BS_TARS)
			to_chat(user, "<span class='notice'>You start securing the targeting sensors...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You secure the targeting sensors.</span>")
				build_state = BS_TARS_SCREW
				update_icon()
				return TRUE
		if(BS_TARS_SCREW)
			to_chat(user, "<span class='notice'>You start unsecuring the targeting sensors...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unsecure the targeting sensors.</span>")
				build_state = BS_TARS
				update_icon()
				return TRUE

/obj/structure/fighter_component/underconstruction_fighter/welder_act(mob/user, obj/item/tool)
	. = FALSE
	switch(build_state)
		if(BS_FUSE_BOLT)
			to_chat(user, "<span class='notice'>You start reinforcing the fuselage...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You reinforce the fuselage.</span>")
				build_state = BS_FUSE_WELD
				update_icon()
				return TRUE
		if(BS_FUSE_WELD)
			to_chat(user, "<span class='notice'>You start cutting the fuselage joints...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You cut through the fuselage joints.</span>")
				build_state = BS_FUSE_BOLT
				update_icon()
				return TRUE
		if(BS_EMPE_BOLT)
			to_chat(user, "<span class='notice'>You start reinforcing the empennage...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You reinforce the empennage.</span>")
				build_state = BS_EMPE_WELD
				update_icon()
				return TRUE
		if(BS_EMPE_WELD)
			to_chat(user, "<span class='notice'>You start cutting the empennage joints...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You cut through the empennage joints.</span>")
				build_state = BS_EMPE_BOLT
				update_icon()
				return TRUE
		if(BS_WING1_BOLT)
			to_chat(user, "<span class='notice'>You start reinforcing the wing...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You reinforce the wing.</span>")
				build_state = BS_WING1_WELD
				update_icon()
				return TRUE
		if(BS_WING1_WELD)
			to_chat(user, "<span class='notice'>You start cutting the wing joints...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You cut through the wing joints.</span>")
				build_state = BS_WING1_BOLT
				update_icon()
				return TRUE
		if(BS_WING2_BOLT)
			to_chat(user, "<span class='notice'>You start reinforcing the wing...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You reinforce the wing.</span>")
				build_state = BS_WING2_WELD
				update_icon()
				return TRUE
		if(BS_WING2_WELD)
			to_chat(user, "<span class='notice'>You start cutting the wing joints...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You cut through the wing joints.</span>")
				build_state = BS_WING2_BOLT
				update_icon()
				return TRUE
		if(BS_ARMP_SCREW)
			to_chat(user, "<span class='notice'>You start welding the armour plating to [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You weld the armour plating to [src].</span>")
				build_state = BS_ARMP_WELD
				update_icon()
				return TRUE
		if(BS_ARMP_WELD)
			to_chat(user, "<span class='notice'>You start cutting the armour plating from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You cut the armour plating</span>")
				build_state = BS_ARMP_SCREW
				update_icon()
				return TRUE
		if(BS_ENGI1)
			to_chat(user, "<span class='notice'>You start welding the engine to [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You weld the engine  to [src].</span>")
				build_state = BS_ENGI1_WELD
				update_icon()
				return TRUE
		if(BS_ENGI1_WELD)
			to_chat(user, "<span class='notice'>You start cutting the engine from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You cut the engine from [src].</span>")
				build_state = BS_ENGI1
				update_icon()
				return TRUE
		if(BS_ENGI2)
			to_chat(user, "<span class='notice'>You start welding the engine to [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You weld the engine  to [src].</span>")
				build_state = BS_ENGI2_WELD
				update_icon()
				return TRUE
		if(BS_ENGI2_WELD)
			to_chat(user, "<span class='notice'>You start cutting the engine from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You cut the engine from [src].</span>")
				build_state = BS_ENGI2
				update_icon()
				return TRUE

/obj/structure/fighter_component/underconstruction_fighter/multitool_act(mob/user, obj/item/tool) //enough calibrations to make any turian happy
	. = FALSE
	switch(build_state)
		if(BS_WIRE1)
			to_chat(user, "<span class='notice'>You start calibrating the electrical systems in [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You calibrate the electrical systems in [src].</span>")
				build_state = BS_WIRE1_MULTI
				update_icon()
				return TRUE
		if(BS_WIRE1_MULTI)
			to_chat(user, "<span class='notice'>You start resetting the eletrical systems in [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You reset the electrical systems in [src].</span>")
				build_state = BS_WIRE1
				update_icon()
				return TRUE
		if(BS_ENGI2_WELD)
			to_chat(user, "<span class='notice'>You start calibrating the propulsion systems in [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You calibrate the propulsion systems in [src].</span>")
				build_state = BS_THRU_MULTI
				update_icon()
				return TRUE
		if(BS_THRU_MULTI)
			to_chat(user, "<span class='notice'>You start resetting the propulsion systems in [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You reset the propulsion systems in [src].</span>")
				build_state = BS_ENGI2_WELD
				update_icon()
				return TRUE
		if(BS_AVIO_SCREW)
			to_chat(user, "<span class='notice'>You start calibrating the avionics in [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You calibrate the avionics in [src]</span>")
				build_state = BS_AVIO_MULTI
				update_icon()
				return TRUE
		if(BS_AVIO_MULTI)
			to_chat(user, "<span class='notice'>You start resetting the avionics in [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You reset the avionics in [src].</span>")
				build_state = BS_AVIO_SCREW
				update_icon()
				return TRUE
		if(BS_TARS_SCREW)
			to_chat(user, "<span class='notice'>You start calibrating the targeting sensors in [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You calibrate the targeting sensors in [src].</span>")
				build_state = BS_TARS_MULTI
				update_icon()
				return TRUE
		if(BS_TARS_MULTI)
			to_chat(user, "<span class='notice'>You start resetting the targeting sensors in [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You reset the targeting sensors in [src].</span>")
				build_state = BS_TARS_SCREW
				update_icon()
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
				update_icon()
			return TRUE
		if(BS_WIRE2)
			to_chat(user, "<span class='notice'>You start cutting the wiring in [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You cut the wiring in [src].</span>")
				var/obj/item/stack/cable_coil/C = new (loc, 3)
				C.add_fingerprint(user)
				build_state = BS_COCP_BOLT
				update_icon()
			return TRUE

/obj/structure/fighter_component/underconstruction_fighter/crowbar_act(mob/user, obj/item/tool)
	. = FALSE
	switch(build_state)
		if(BS_TARS)
			to_chat(user, "<span class='notice'>You start removing the targeting sensor from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the targeting sensor from [src].</span>")
				var/atom/movable/ts = get_part(/obj/item/fighter_component/targeting_sensor)
				ts?.forceMove(get_turf(src))
				build_state = BS_AVIO_MULTI
				update_icon()
			return TRUE
		if(BS_AVIO)
			to_chat(user, "<span class='notice'>You start removing the avionics from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the avionics from [src].</span>")
				var/atom/movable/av = get_part(/obj/item/fighter_component/avionics)
				av?.forceMove(get_turf(src))
				update_icon()
			return TRUE
		if(BS_COCP)
			to_chat(user, "<span class='notice'>You start disassembling the cockpit from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You disassemble the cockpit from [src].</span>")
				var/atom/movable/co = get_part(/obj/item/twohanded/required/fighter_component/cockpit)
				co?.forceMove(get_turf(src))
				build_state = BS_THRU_MULTI
				update_icon()
			return TRUE
		if(BS_ENGI2)
			to_chat(user, "<span class='notice'>You start removing the second engine from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the second engine from [src].</span>")
				var/atom/movable/en = get_part(/obj/item/fighter_component/engine)
				en?.forceMove(get_turf(src))
				build_state = BS_ENGI1_WELD
				update_icon()
			return TRUE
		if(BS_ENGI1)
			to_chat(user, "<span class='notice'>You start removing the first engine from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the first engine from [src].</span>")
				var/atom/movable/en = get_part(/obj/item/fighter_component/engine)
				en?.forceMove(get_turf(src))
				build_state = BS_FUEL_BOLT
				update_icon()
			return TRUE
		if(BS_FUEL)
			to_chat(user, "<span class='notice'>You start removing the fuel lines from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the fuel lines from [src].</span>")
				var/atom/movable/fl = get_part(/obj/item/fighter_component/fuel_lines)
				fl?.forceMove(get_turf(src))
				build_state = BS_FUET_BOLT
				update_icon()
			return TRUE
		if(BS_FUET)
			to_chat(user, "<span class='notice'>You start removing the fuel tank from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the fuel tank from [src].</span>")
				var/atom/movable/ft = get_part(/obj/item/twohanded/required/fighter_component/fuel_tank)
				ft?.forceMove(get_turf(src))
				build_state = BS_WIRE1_MULTI
				update_icon()
			return TRUE
		if(BS_ARMP)
			to_chat(user, "<span class='notice'>You start removing the armour plating from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the armour plating from [src].</span>")
				var/atom/movable/ap = get_part(/obj/item/twohanded/required/fighter_component/armour_plating)
				ap?.forceMove(get_turf(src))
				build_state = BS_LANG_BOLT
				update_icon()
			return TRUE
		if(BS_LANG)
			to_chat(user, "<span class='notice'>You start removing the landing gear from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You remove the landing gear from [src].</span>")
				var/atom/movable/lg = get_part(/obj/item/twohanded/required/fighter_component/landing_gear)
				lg?.forceMove(get_turf(src))
				build_state = BS_WING2_WELD
				update_icon()
			return TRUE
		if(BS_WING2)
			to_chat(user, "<span class='notice'>You start disassembling a wing from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You disassemble a wing from [src].</span>")
				var/atom/movable/wi = get_part(/obj/item/twohanded/required/fighter_component/wing)
				wi?.forceMove(get_turf(src))
				build_state = BS_WING1_WELD
				update_icon()
			return TRUE
		if(BS_WING1)
			to_chat(user, "<span class='notice'>You start disassembling a wing from [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You disassemble a wing from [src].</span>")
				var/atom/movable/wi = get_part(/obj/item/twohanded/required/fighter_component/wing)
				wi?.forceMove(get_turf(src))
				build_state = BS_EMPE_WELD
				update_icon()
			return TRUE
		if(BS_EMPE)
			to_chat(user, "<span class='notice'>You start disassembling the [src]'s empennage...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You disassemble the [src]'s empennage.</span>")
				var/atom/movable/em = get_part(/obj/item/twohanded/required/fighter_component/empennage)
				em?.forceMove(get_turf(src))
				build_state = BS_FUSE_WELD
				update_icon()
			return TRUE
		if(BS_FUSE)
			to_chat(user, "<span class='notice'>You start disassembling the [src]'s fuselage... </span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You disassemble the [src]'s fuselage</span>")
				new/obj/structure/fighter_component/fuselage_crate (loc, 1)
				qdel(src)
			return TRUE

//Need to put the naming path in
/obj/structure/fighter_component/underconstruction_fighter/attack_hand(mob/user)
	.=..()
	if(BS_PAINT)
		fighter_name = input(user,"Name Fighter:","Finalize Fighter Construction","")

/obj/structure/fighter_component/underconstruction_fighter/proc/new_fighter()

/obj/structure/fighter_component/underconstruction_fighter/update_icon()
	cut_overlays()
	switch(build_state)
		if(BS_FUSE)
			icon_state = "sheetgrey"
		if(BS_FUSE_BOLT)
			icon_state = "sheetred"
		if(BS_FUSE_WELD)
			icon_state = "sheetorange"
		if(BS_EMPE)
			icon_state = "sheetyellow"
		if(BS_EMPE_BOLT)
			icon_state = "sheetgreen"
		if(BS_EMPE_WELD)
			icon_state = "sheetblue"
		if(BS_WING1)
			icon_state = "sheetpurple"
		if(BS_WING1_BOLT)
			icon_state = "sheetbrown"
		if(BS_WING1_WELD)
			icon_state = "sheetblack"
		if(BS_WING2)
			icon_state = "sheetrainbow"
		if(BS_WING2_BOLT)
			icon_state = "sheetclown"
		if(BS_LANG)
			icon_state = "sheetmime"
		if(BS_LANG_BOLT)
			icon_state = "sheetmedical"
		if(BS_ARMP)
			icon_state = "sheetrd"
		if(BS_ARMP_SCREW)
			icon_state = "sheetcmo"
		if(BS_ARMP_WELD)
			icon_state = "sheethos"
		if(BS_WIRE1)
			icon_state = "sheetce"
		if(BS_WIRE1_MULTI)
			icon_state = "sheethop"
		if(BS_FUET)
			icon_state = "sheetcaptain"
		if(BS_FUET_BOLT)
			icon_state = "sheetian"
		if(BS_FUEL)
			icon_state = "sheetnt"
		if(BS_FUEL_BOLT)
			icon_state = "sheetcentcom"
		if(BS_ENGI1)
			icon_state = "sheetsyndie"
		if(BS_ENGI1_WELD)
			icon_state = "sheetcult"
		if(BS_ENGI2)
			icon_state = "sheetwiz"
		if(BS_ENGI2_WELD)
			icon_state = "sheetqm"
		if(BS_THRU_MULTI)
			icon_state = "sheetUSA"
		if(BS_COCP)
			icon_state = "random_bedsheet"
		if(BS_COCP_SCREW)
			icon_state = "sheetcosmos"
		if(BS_COCP_BOLT)
			icon_state = "sheetgrey"
		if(BS_WIRE2)
			icon_state = "sheetred"
		if(BS_AVIO)
			icon_state = "sheetorange"
		if(BS_AVIO_SCREW)
			icon_state = "sheetyellow"
		if(BS_AVIO_MULTI)
			icon_state = "sheetgreen"
		if(BS_TARS)
			icon_state = "sheetblue"
		if(BS_TARS_SCREW)
			icon_state = "sheetpurple"
		if(BS_TARS_MULTI)
			icon_state = "sheetbrown"
		if(BS_PAINT)
			icon_state = "sheetblack"


//Fighter Maintenance
/obj/structure/overmap/fighter/proc/get_part(type)
	if(!type)
		return
	var/atom/movable/desired = locate(type) in contents
	return desired

/obj/structure/overmap/fighter/wrench_act(mob/user, obj/item/tool) //opening hatch p1
	. = FALSE
	switch(maint_state)
		if(MS_CLOSED)
			to_chat(user, "<span class='notice'>You start unsecure the maintenance hatch on [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You unsecure the maintenance hatch on [src].</span>")
				maint_state = MS_UNSECURE
				//update_icon()
				return TRUE
		if(MS_UNSECURE)
			to_chat(user, "<span class='notice'>You start secure the maintenance hatch on [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You secure the maintenance hatch on [src].</span>")
				maint_state = MS_CLOSED
				//update_icon()
				return TRUE

/obj/structure/overmap/fighter/crowbar_act(mob/user, obj/item/tool) //opening hatch p2
	. = FALSE
	switch(maint_state)
		if(MS_UNSECURE)
			to_chat(user, "<span class='notice'>You start pry open the maintenance hatch on [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You pry open the maintenance hatch on [src].</span>")
				maint_state = MS_OPEN
				//update_icon()
				return TRUE
		if(MS_OPEN)
			to_chat(user, "<span class='notice'>You start replace the maintenance hatch on [src]...</span>")
			if(tool.use_tool(src, user, 40, volume=100))
				to_chat(user, "<span class='notice'>You replace the maintenance hatch on [src].</span>")
				maint_state = MS_UNSECURE
				//update_icon()
				return TRUE


/obj/structure/overmap/fighter/attackby  //fueling and changing equipment

/obj/structure/overmap/fighter/attack_hand(mob/user)  //
	.=..()
	switch(maint_state)
		if(MS_OPEN)
			user.set_machine(src)
			var/dat
			dat += "<h2> Overview: </h2>"
//hp, fuel etc go here
			dat += "<h2> Components: </h2>"
			var/atom/movable/ap = get_part(/obj/item/twohanded/required/fighter_component/armour_plating)
			if(ap == null)
				dat += "<p><b>ARMOUR PLATING NOT INSTALLED</font></p>"
			else
				dat += "<a href='?src=[REF(src)];armour_plating=1'>[ap?.name]</a><br>"
			var/atom/movable/ft = get_part(/obj/item/twohanded/required/fighter_component/fuel_tank)
			if(ft == null)
				dat += "<p><b>FUEL TANK NOT INSTALLED</font></p>"
			else
				dat += "<a href='?src=[REF(src)];fuel_tank=1'>[ft?.name]</a><br>"
			var/atom/movable/fl = get_part(/obj/item/fighter_component/fuel_lines)
			if(fl == null)
				dat += "<p><b>FUEL LINES NOT INSTALLED</font></p>"
			else
				dat += "<a href='?src=[REF(src)];fuel_lines=1'>[fl?.name]</a><br>"
			var/atom/movable/ts = get_part(/obj/item/fighter_component/targeting_sensor)
			if(ts == null)
				dat += "<p><b>TARGETING SENSOR NOT INSTALLED</font></p>"
			else
				dat += "<a href='?src=[REF(src)];targeting_sensor=1'>[ts?.name]</a><br>"
//engines go here

			var/datum/browser/popup = new(user, "fighter", name, 400, 600)
			popup.set_content(dat)
			popup.open()
			return TRUE
		if(!MS_OPEN)
			to_chat(user, "<span class='notice'You run your hand over the sleek surface of [src].</span>")
			return TRUE

/obj/structure/overmap/fighter/Topic(href, href_list)
	if(!in_range(src, usr))
		return
	if(!isliving(usr))
		return
	var/mob/living/user = usr
	var/atom/movable/ap = get_part(/obj/item/twohanded/required/fighter_component/armour_plating)
	var/atom/movable/ft = get_part(/obj/item/twohanded/required/fighter_component/fuel_tank)
	var/atom/movable/fl = get_part(/obj/item/fighter_component/fuel_lines)
	var/atom/movable/ts = get_part(/obj/item/fighter_component/targeting_sensor)
	if(href_list["armour_plating"])
		if(ap)
			ap?.forceMove(get_turf(src))
			to_chat(user, "<span class='notice'>You uninstall [ap.name] from [src].</span>")
	if(href_list["fuel_tank"])
		if(ft)
			ft?.forceMove(get_turf(src))
			to_chat(user, "<span class='notice'>You uninstall [ft.name] from [src].</span>")
	if(href_list["fuel_lines"])
		if(fl)
			fl?.forceMove(get_turf(src))
			to_chat(user, "<span class='notice'>You uninstall [fl.name] from [src].</span>")
	if(href_list["targeting_sensor"])
		if(ts)
			ts?.forceMove(get_turf(src))
			to_chat(user, "<span class='notice'>You uninstall [ts.name] from [src].</span>")

//Fighter Components

/obj/structure/fighter_component/fuselage_crate
	name = "Fighter Fuselage Components"
	desc = "A crate full of fuselage components for a fighter"
	icon = 'icons/obj/crates.dmi'
	icon_state = "radiation"
	anchored = FALSE
	density = TRUE
	climbable = TRUE

/obj/item/twohanded/required/fighter_component/cockpit
	name = "Fighter Cockpit Components"
	desc = "A box of cockpit components for a fighter"
	icon = 'icons/obj/crates.dmi'
	icon_state = "crate"
	lefthand_file = ""
	righthand_file = ""
	w_class = WEIGHT_CLASS_GIGANTIC

/obj/item/twohanded/required/fighter_component/wing
	name = "Fighter Wing Components"
	desc = "A box of wing components for a fighter"
	icon = 'icons/obj/crates.dmi'
	icon_state = "medicalcrate"
	lefthand_file = ""
	righthand_file = ""
	w_class = WEIGHT_CLASS_GIGANTIC

/obj/item/twohanded/required/fighter_component/empennage
	name = "Fighter Empennage Componets"
	desc = "A box of empennage components for a fighter"
	icon = 'icons/obj/crates.dmi'
	icon_state = "engi_e_crate"
	lefthand_file = ""
	righthand_file = ""
	w_class = WEIGHT_CLASS_GIGANTIC

/obj/item/twohanded/required/fighter_component/landing_gear
	name = "Fighter Landing Gear Componets"
	desc = "A box of landing gear components for a fighter"
	icon = 'icons/obj/crates.dmi'
	icon_state = "engi_crate"
	lefthand_file = ""
	righthand_file = ""
	w_class = WEIGHT_CLASS_GIGANTIC

/obj/item/twohanded/required/fighter_component/armour_plating
	name = "Fighter Armour Plating"
	desc = "Armour plating for a fighter"
	icon = 'icons/obj/crates.dmi'
	icon_state = "engi_secure_crate"
	lefthand_file = ""
	righthand_file = ""
	w_class = WEIGHT_CLASS_GIGANTIC
	var/armour = 50 //BONUS HP VALUE

/obj/item/twohanded/required/fighter_component/armour_plating/improved
	name = "Fighter Improved Armour Plating"
	desc = "Improved armour plating for a fighter"
	armour = 100

/obj/item/twohanded/required/fighter_component/fuel_tank
	name = "Fighter Fuel Tank"
	desc = "The fuel tank of a fighter"
	icon = 'icons/obj/crates.dmi'
	icon_state = "secgearcrate"
	lefthand_file = ""
	righthand_file = ""
	w_class = WEIGHT_CLASS_GIGANTIC
	var/capacity = 1000 //Fuel Capacity

/obj/item/twohanded/required/fighter_component/fuel_tank/extended
	name = "Fighter Extended Fuel Tank"
	desc = "The extended fuel tank of a fighter"
	capacity = 1500

/obj/item/twohanded/required/fighter_component/primary_weapon
	name = "Fighter Primary Weapon"
	desc = "Fighter Primary Weapon"
	icon = 'icons/obj/crates.dmi'
	icon_state = "o2crate"
	lefthand_file = ""
	righthand_file = ""
	w_class = WEIGHT_CLASS_GIGANTIC

/obj/item/twohanded/required/fighter_component/secondary_weapon
	name = "Fighter Secondary Weapon"
	desc = "Fighter Secondary Weapon"
	icon = 'icons/obj/crates.dmi'
	icon_state = "securecrate"
	lefthand_file = ""
	righthand_file = ""
	w_class = WEIGHT_CLASS_GIGANTIC

/obj/item/fighter_component/avionics
	name = "Fighter Avionics"
	desc = "Avionics for a fighter"
	icon = 'icons/obj/crates.dmi'
	icon_state = "freezer"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/fighter_component/targeting_sensor
	name = "Fighter Targeting Sensors"
	desc = "Targeting sensors for a fighter"
	icon = 'icons/obj/crates.dmi'
	icon_state = "weaponcrate"
	w_class = WEIGHT_CLASS_NORMAL
	var/weapon_efficiency = 1 //Primary ammo usage modifier

/obj/item/fighter_component/targeting_sensor/enhanced
	name = "Fighter Enhanced Targeting Sensors"
	desc = "Enhanced targeting sensors for a fighter"
	weapon_efficiency = 0.8

/obj/item/fighter_component/fuel_lines
	name = "Fighter Fuel Lines Kit"
	desc = "Fuel line kit for routing fuel around a fighter"
	icon = 'icons/obj/crates.dmi'
	icon_state = "plasmacrate"
	w_class = WEIGHT_CLASS_BULKY
	var/fuel_efficiency = 1 //Fuel usage modifier

/obj/item/fighter_component/fuel_lines/streamlined
	name = "Fighter Streamlined Fuel Lines Kit"
	desc = "Streamlined fuel line kit for routing fuel around a fighter"
	fuel_efficiency = 0.8

/obj/item/fighter_component/engine
	name = "Fighter Engine"
	desc = "An engine assembly for a fighter"
	icon = 'icons/obj/crates.dmi'
	icon_state = "hydrocrate"
	w_class = WEIGHT_CLASS_BULKY
	var/speed = 1 //Speed modifier
	var/consumption = 1 //How fast we burn fuel

/obj/item/fighter_component/engine/overclocked
	name = "Fighter Overclocked Engine"
	desc = "An overclocked engine assembly for a fighter"
	speed = 1.2
	consumption = 1.2

#undef BS_FUSE
#undef BS_FUSE_BOLT
#undef BS_FUSE_WELD
#undef BS_EMPE
#undef BS_EMPE_BOLT
#undef BS_EMPE_WELD
#undef BS_WING1
#undef BS_WING1_BOLT
#undef BS_WING1_WELD
#undef BS_WING2
#undef BS_WING2_BOLT
#undef BS_WING2_WELD
#undef BS_LANG
#undef BS_LANG_BOLT
#undef BS_ARMP
#undef BS_ARMP_SCREW
#undef BS_ARMP_WELD
#undef BS_WIRE1
#undef BS_WIRE1_MULTI
#undef BS_FUET
#undef BS_FUET_BOLT
#undef BS_FUEL
#undef BS_FUEL_BOLT
#undef BS_ENGI1
#undef BS_ENGI1_WELD
#undef BS_ENGI2
#undef BS_ENGI2_WELD
#undef BS_THRU_MULTI
#undef BS_COCP
#undef BS_COCP_SCREW
#undef BS_COCP_BOLT
#undef BS_WIRE2
#undef BS_AVIO
#undef BS_AVIO_SCREW
#undef BS_AVIO_MULTI
#undef BS_TARS
#undef BS_TARS_SCREW
#undef BS_TARS_MULTI
#undef BS_PAINT

#undef MS_CLOSED
#undef MS_UNSECURE
#undef MS_OPEN