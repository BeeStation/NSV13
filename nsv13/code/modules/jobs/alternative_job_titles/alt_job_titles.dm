/**
 * This is the file you should use to add alternate titles for each job, just
 * follow the way they're done here, it's easy enough and shouldn't take any
 * time at all to add more or add some for a job that doesn't have any.
 */

/datum/job
	/// The list of alternative job titles people can pick from, null by default.
	var/list/alt_titles = null


/datum/job/ai
	alt_titles = list(
		"AI",
		"Station Intelligence",
		"Automated Overseer"
		)

/datum/job/assistant
	alt_titles = list(
		"Midshipman",
		"Ensign"
		)

/datum/job/atmospheric_technician
	alt_titles = list(
		"Atmospheric Technician",
		"Life Support Technician",
		"Emergency Fire Technician"
		)

/datum/job/bartender
	alt_titles = list(
		"Bartender",
		"Mixologist",
		"Barkeeper",
		"Barista"
		)

/datum/job/botanist
	alt_titles = list(
		"Botanist",
		"Hydroponicist",
		"Gardener",
		"Botanical Researcher",
		"Herbalist",
		"Florist"
		)

/datum/job/brig_physician
	alt_titles = list(
		"Brig Physician",
		"Field Medic",
		"Corpsman",
		"Combat Medic"
		)

/datum/job/captain
	alt_titles = list(
		"Captain",
		"Commanding Officer",
		"Skipper"
		)

/datum/job/cargo_technician
	alt_titles = list(
		"Cargo Technician",
		"Deck Worker",
		"Mailman"
		)

/datum/job/chaplain
	alt_titles = list(
		"Chaplain",
		"Priest",
		"Preacher",
		"Oracle"
		)

/datum/job/chemist
	alt_titles = list(
		"Chemist",
		"Pharmacist",
		"Pharmacologist",
		"Trainee Pharmacist"
		)

/datum/job/chief_engineer
	alt_titles = list(
		"Chief Engineer",
		"Engineering Foreman",
		"Head of Engineering"
		)

/datum/job/chief_medical_officer
	alt_titles = list(
		"Chief Medical Officer",
		"Medical Director",
		"Head of Medical",
		"Chief Physician",
		"Head Physician"
		)

/datum/job/clown
	alt_titles = list(
		"Clown",
		"Jester",
		"Ship Mascot",
		"Loud Menace",
		"Comedian"
		)

/datum/job/cook
	alt_titles = list(
		"Cook",
		"Chef",
		"Butcher",
		"Culinary Artist",
		"Sous-Chef",
		"Baker"
		)

/datum/job/curator
	alt_titles = list(
		"Curator",
		"Librarian",
		"Journalist",
		"Archivist"
		)

/datum/job/cyborg
	alt_titles = list(
		"Cyborg",
		"Robot",
		"Android"
		)

/datum/job/detective
	alt_titles = list(
		"Detective",
		"Forensic Technician",
		"Private Investigator",
		"Forensic Scientist"
		)

/datum/job/deputy
	alt_titles = list(
		"Deputy"
		)

/datum/job/exploration_crew
	alt_titles = list(
		"Exploration Crew",
		"Exploration Field Medic",
		"Exploration Ordinance Expert"
		)

/datum/job/geneticist
	alt_titles = list(
		"Geneticist",
		"Mutation Researcher"
		)

/datum/job/gimmick
	alt_titles = list(
		"Gimmick"
		)

/datum/job/head_of_personnel
	alt_titles = list(
		"Executive Officer",
		"Commander",
		"First Officer",
		"Chief Officer",
		"Mate",
		"Co-Pilot",
		"Chief Mate"
		)

/datum/job/head_of_security
	alt_titles = list(
		"Head of Security",
		"Security Commander",
		"Chief Constable",
		"Chief of Security",
		"Sheriff"
		)

/datum/job/janitor
	alt_titles = list(
		"Janitor",
		"Custodian",
		"Custodial Technician",
		"Sanitation Technician",
		"Maintenance Technician",
		"Concierge"
		)

/datum/job/lawyer
	alt_titles = list(
		"Lawyer",
		"Internal Affairs Agent",
		"Human Resources Agent",
		"Defence Attorney",
		"Public Defender",
		"Barrister",
		"Prosecutor",
		"Legal Clerk"
		)

/datum/job/mime
	alt_titles = list(
		"Mime",
		"Pantomimist",
		"Silent Menace"
		)

/datum/job/medical_doctor
	alt_titles = list(
		"Medical Doctor",
		"Surgeon",
		"Nurse",
		"General Practitioner",
		"Medical Resident",
		"Physician",
		"Medical Intern"
		)

/datum/job/paramedic
	alt_titles = list(
		"Paramedic",
		"Emergency Medical Technician",
		"Search and Rescue Technician"
		)

/datum/job/quartermaster
	alt_titles = list(
		"Quartermaster",
		"Deck Chief",
		"Supply Foreman",
		"Requisition Officer",
		"Logistics Officer"
		)

/datum/job/research_director
	alt_titles = list(
		"Research Director",
		"Silicon Administrator",
		"Lead Researcher",
		"Biorobotics Director",
		"Research Supervisor",
		"Chief Science Officer"
		)

/datum/job/roboticist
	alt_titles = list(
		"Roboticist",
		"Biomechanical Engineer",
		"Mechatronic Engineer",
		"Apprentice Roboticist"
		)

/datum/job/scientist
	alt_titles = list(
		"Scientist",
		"Circuitry Designer",
		"Nanomachine Programmer",
		"Plasma Researcher",
		"Lab Technician",
		"Theoretical Physicist",
		"Xenobiologist",
		"Xenoarchaeologist",
		"Research Assistant",
		"Graduate Student"
		)

/datum/job/security_officer
	alt_titles = list(
		"Military Police",
		"Peacekeeper",
		"Military Police Cadet"
		)

/datum/job/shaft_miner
	alt_titles = list(
		"Shaft Miner",
		"Excavator",
		"Spelunker",
		"Prospector",
		"Explorer"
		)

/datum/job/station_engineer
	alt_titles = list(
		"Station Engineer",
		"Emergency Damage Control Technician",
		"Electrician",
		"Engine Technician",
		"EVA Technician",
		"Mechanic",
		"Apprentice Engineer",
		"Engineering Trainee"
		)

/datum/job/virologist
	alt_titles = list(
		"Virologist",
		"Pathologist",
		"Junior Pathologist"
		)

/datum/job/warden
	alt_titles = list(
		"Warden",
		"Brig Sergeant",
		"Dispatch Officer",
		"Drill Sergeant",
		"Brig Governor",
		"Jailer"
		)

//NSV13 Jobs

/datum/job/air_traffic_controller
	alt_titles = list(
		"Air Traffic Controller",
		"Flight Controller",
		"Controller",
		"Air Coordinator"
		)

/datum/job/bridge
	alt_titles = list(
		"Bridge Staff",
		"Deck Officer",
		"Bridgie",
		"Helmsman",
		"Gunner",
		"TAC Officer",
		"Helm Officer"
		)

/datum/job/master_at_arms
	alt_titles = list(
		"Master At Arms",
		"Chief Petty Officer",
		"Warrant Officer",
		"Sergeant At Arms"
		)

/datum/job/munitions_tech
	alt_titles = list(
		"Munitions Technician",
		"Ordinance Expert",
		"Powder Jockey",
		"Powder Monkey",
		"Gun Runner"
		)

/datum/job/pilot
	alt_titles = list(
		"Pilot",
		"Transport Pilot",
		"Ace Pilot",
		"Aeronaut",
		"Wingman",
		"Aviator",
		"Fighter Jockey"
		)
