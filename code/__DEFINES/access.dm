#define ACCESS_SECURITY 1 //! Security equipment, security records, gulag item storage, secbots
#define ACCESS_BRIG 2 //! Brig cells+timers, permabrig, gulag+gulag shuttle, prisoner management console
#define ACCESS_ARMORY 3 //! Armory, gulag teleporter, execution chamber
#define ACCESS_FORENSICS_LOCKERS 4 //! Detective's office, forensics lockers, security+medical records
#define ACCESS_MEDICAL 5
#define ACCESS_MORGUE 6
#define ACCESS_TOX 7 //! R&D department, R&D console, burn chamber on some maps
#define ACCESS_TOX_STORAGE 8 //! Toxins storage, burn chamber on some maps
#define ACCESS_GENETICS 9
#define ACCESS_ENGINE 10 //! Engineering area, power monitor, power flow control console
#define ACCESS_ENGINE_EQUIP 11 //! APCs, EngiVend/YouTool, engineering equipment lockers
#define ACCESS_MAINT_TUNNELS 12
#define ACCESS_EXTERNAL_AIRLOCKS 13
#define ACCESS_PRISONER 14//! Brig turnstile and prisonner locker
#define ACCESS_CHANGE_IDS 15
#define ACCESS_AI_UPLOAD 16
#define ACCESS_TELEPORTER 17
#define ACCESS_EVA 18
#define ACCESS_HEADS 19 //!Bridge, EVA storage windoors, gateway shutters, AI integrity restorer, clone record deletion, comms console
#define ACCESS_CAPTAIN 20
#define ACCESS_ALL_PERSONAL_LOCKERS 21
#define ACCESS_CHAPEL_OFFICE 22
#define ACCESS_TECH_STORAGE 23
#define ACCESS_ATMOSPHERICS 24
#define ACCESS_BAR 25
#define ACCESS_JANITOR 26
#define ACCESS_CREMATORIUM 27
#define ACCESS_KITCHEN 28
#define ACCESS_ROBOTICS 29
#define ACCESS_RD 30
#define ACCESS_CARGO 31
#define ACCESS_CONSTRUCTION 32
#define ACCESS_CHEMISTRY 33
#define ACCESS_BRIGPHYS 34
#define ACCESS_HYDROPONICS 35
#define ACCESS_LIBRARY 37
#define ACCESS_LAWYER 38
#define ACCESS_VIROLOGY 39
#define ACCESS_CMO 40
#define ACCESS_QM 41
#define ACCESS_COURT 42
#define ACCESS_SURGERY 45
#define ACCESS_THEATRE 46
#define ACCESS_RESEARCH 47
#define ACCESS_MINING 48
#define ACCESS_EXPLORATION 49
#define ACCESS_MAILSORTING 50
#define ACCESS_VAULT 53
#define ACCESS_MINING_STATION 54
#define ACCESS_XENOBIOLOGY 55
#define ACCESS_CE 56
#define ACCESS_HOP 57
#define ACCESS_HOS 58
/// Request console announcements
#define ACCESS_RC_ANNOUNCE 59
/// Used for events which require at least two people to confirm them
#define ACCESS_KEYCARD_AUTH 60
/// has access to the entire telecomms satellite / machinery
#define ACCESS_TCOMSAT 61
#define ACCESS_GATEWAY 62
#define ACCESS_SEC_DOORS 63 //! Outer brig doors, department security posts
#define ACCESS_MINERAL_STOREROOM 64 //! For releasing minerals from the ORM
#define ACCESS_MINISAT 65
#define ACCESS_WEAPONS 66 //! Weapon authorization for secbots
#define ACCESS_NETWORK 67 //! NTnet diagnostics/monitoring software
#define ACCESS_CLONING 68 //! Cloning room and clone pod ejection
#define ACCESS_MUNITIONS 69 //NSV13 - Departmental ACCESS
#define ACCESS_MAA 70 //NSV13 - MAA gets an office
#define ACCESS_MUNITIONS_STORAGE 71 //NSV13 - Access to ordinance
#define ACCESS_COMBAT_PILOT 72 //NSV13 - Fighternerds
#define ACCESS_TRANSPORT_PILOT 73 //NSV13 - Imagine getting your ATPLs
#define ACCESS_MINING_ENGINEERING 74
#define ACCESS_MINING_BRIDGE 75
#define ACCESS_SEC_RECORDS 77 //! Update security records //NSV13 - changed from 69
#define ACCESS_HANGAR 79 //NSV13 - Access to the hangar

/// Room and launching.
#define ACCESS_AUX_BASE 76 //NSV13 - changed from 72 to 76 to deconflict
#define ACCESS_RD_SERVER 80 //! Access to the R&D server room //NSV13 - changed to 80

	//BEGIN CENTCOM ACCESS
	/*Should leave plenty of room if we need to add more access levels.
	Mostly for admin fun times.*/
#define ACCESS_CENT_GENERAL 101 //! General facilities. CentCom ferry.
#define ACCESS_CENT_THUNDER 102 //! Thunderdome.
#define ACCESS_CENT_SPECOPS 103 //! Special Ops. Captain's display case, Marauder and Seraph mechs.
#define ACCESS_CENT_MEDICAL 104 //! Medical/Research
#define ACCESS_CENT_LIVING 105 //! Living quarters.
#define ACCESS_CENT_STORAGE 106 //! Generic storage areas.
#define ACCESS_CENT_TELEPORTER 107 //! Teleporter.
#define ACCESS_CENT_CAPTAIN 109 //! Captain's office/ID comp/AI.
#define ACCESS_CENT_BAR 110 //! The non-existent CentCom Bar

	//The Syndicate
#define ACCESS_SYNDICATE 150 //!General Syndicate Access. Includes Syndicate mechs and ruins.
#define ACCESS_SYNDICATE_LEADER 151 //!Nuke Op Leader Access
//Nsv13
#define ACCESS_SYNDICATE_ENGINEERING 152 //! Syndicate engineering wing
#define ACCESS_SYNDICATE_REQUISITIONS 153 //! Syndicate cargo division
#define ACCESS_SYNDICATE_MARINE_ARMOURY 154 //!Syndicate armoury
// /Nsv13

	//Independant Factions
#define ACCESS_PIRATES 180 //! Pirate ship access
#define ACCESS_HUNTERS 181 //! Bounty hunter access

	//Away Missions or Ruins
	/*For generic away-mission/ruin access. Why would normal crew have access to a long-abandoned derelict
	or a 2000 year-old temple? */
#define ACCESS_AWAY_GENERAL 200 //!General facilities.
#define ACCESS_AWAY_MAINT 201 //!Away maintenance
#define ACCESS_AWAY_MED 202 //!Away medical
#define ACCESS_AWAY_SEC 203 //!Away security
#define ACCESS_AWAY_ENGINE 204 //!Away engineering
#define ACCESS_AWAY_GENERIC1 205 //!Away generic access
#define ACCESS_AWAY_GENERIC2 206
#define ACCESS_AWAY_GENERIC3 207
#define ACCESS_AWAY_GENERIC4 208

	//Special, for anything that's basically internal
#define ACCESS_BLOODCULT 250
#define ACCESS_CLOCKCULT 251


	// Mech Access, allows maintanenace of internal components and altering keycard requirements.
#define ACCESS_MECH_MINING 300
#define ACCESS_MECH_MEDICAL 301
#define ACCESS_MECH_SECURITY 302
#define ACCESS_MECH_SCIENCE 303
#define ACCESS_MECH_ENGINE 304
