/datum/techweb/specialized/autounlocking/replicator
	design_autounlock_buildtypes = REPLICATOR
	allowed_buildtypes = REPLICATOR


//In hardmode, we give the players a little treat too
/datum/controller/subsystem/research
	var/list/gun_techdesigns = list(
		"gauss_dispenser_circuit" = /datum/techweb_node/advanced_ballistics,
		"gauss_turret" = /datum/techweb_node/advanced_ballistics,
		"ship_firing_electronics" = /datum/techweb_node/advanced_ballistics,
		"deck_gun" = /datum/techweb_node/advanced_ballistics,
		"deck_gun_triple" = /datum/techweb_node/macro_ballistics,
		"vls_tube" = /datum/techweb_node/basic_torpedo_components
	)

//Adds and removes the technologies listed above from the techweb
/datum/controller/subsystem/research/proc/hardmode_tech_enable()
	for(var/i in gun_techdesigns)
		on_design_addition(i,gun_techdesigns[i])

/datum/controller/subsystem/research/proc/hardmode_tech_disable()
	for(var/i in gun_techdesigns)
		on_design_deletion(techweb_design_by_id(i))

//Adding a tech design (back)
//For the subsystem
/datum/controller/subsystem/research/proc/on_design_addition(design, techweb_node) //Needs to be added to a specific node type
	if(!techweb_node || !design)
		return FALSE
	for(var/id in techweb_nodes)
		var/datum/techweb_node/TN = techweb_nodes[id]
		if(istype(TN, techweb_node))
			TN.add_design_id(design)
	for(var/datum/techweb/T in techwebs)
		T.recalculate_nodes(TRUE)

//For the techweb node
/datum/techweb_node/proc/add_design_id(design_id)
	design_ids[design_id] = TRUE
