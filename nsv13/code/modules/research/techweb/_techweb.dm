/datum/techweb/specialized/autounlocking/replicator
	design_autounlock_buildtypes = REPLICATOR
	allowed_buildtypes = REPLICATOR


//In hardmode, we give the players a little treat too
/datum/controller/subsystem/research
	var/list/gun_techdesigns = list(
		/datum/design/ship_firing_electronics = /datum/techweb_node/advanced_ballistics,
		/datum/design/board/deck_turret = /datum/techweb_node/advanced_ballistics,
		/datum/design/board/multibarrel_upgrade/_3 = /datum/techweb_node/macro_ballistics,
		/datum/design/board/gauss_dispenser_circuit = /datum/techweb_node/advanced_ballistics,
		/datum/design/board/vls_tube = /datum/techweb_node/basic_torpedo_components
	)

//Adds and removes the technologies listed above from the techweb
/datum/controller/subsystem/research/proc/hardmode_tech_enable()
	for(var/i in gun_techdesigns)
		on_design_addition(i,gun_techdesigns[i])

/datum/controller/subsystem/research/proc/hardmode_tech_disable()
	for(var/i in gun_techdesigns)
		on_design_deletion(i)

//Adding a tech design (back)
//For the subsystem to use, a positive version of deletion procs

/datum/controller/subsystem/research/proc/on_design_addition(datum/design/D, techweb_node) //Needs to be added to a specific node type
	if(!techweb_node || !D)
		return FALSE
	for(var/i in techweb_nodes)
		var/datum/techweb_node/T = techwebs[i]
		if(istype(techweb_node, T))
			T.on_design_addition(D)
	for(var/i in techwebs)
		var/datum/techweb/T = i
		T.recalculate_nodes(TRUE)

//For the techweb (nodes) themselves

/datum/techweb_node/proc/on_design_addition(datum/design/D)
	add_design_id(D.id)

/datum/techweb_node/proc/add_design_id(design_id)
	design_ids |= design_id

