/datum/techweb_node/basic_shuttle_tech
	id = "basic_shuttle"
	display_name = "Basic Shuttle Research"
	description = "Research the technology required to create and use basic shuttles."
	prereq_ids = list("bluespace_travel", "adv_engi")
	design_ids = list("shuttle_creator", "engine_plasma", "engine_heater", "shuttle_control", "wingpack")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 10000)
	export_price = 5000
