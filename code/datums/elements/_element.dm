<<<<<<< HEAD
/datum/element
	var/element_flags = NONE

/datum/element/proc/Attach(datum/target)
=======
/**
  * A holder for simple behaviour that can be attached to many different types
  *
  * Only one element of each type is instanced during game init.
  * Otherwise acts basically like a lightweight component.
  */
/datum/element
	/// Option flags for element behaviour
	var/element_flags = NONE

/// Activates the functionality defined by the element on the given target datum
/datum/element/proc/Attach(datum/target)
	SHOULD_CALL_PARENT(1)
>>>>>>> 6019aa33c0e954c94587c43287536eaf970cdb36
	if(type == /datum/element)
		return ELEMENT_INCOMPATIBLE
	if(element_flags & ELEMENT_DETACH)
		RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/Detach)

<<<<<<< HEAD
/datum/element/proc/Detach(datum/source, force)
=======
/// Deactivates the functionality defines by the element on the given datum
/datum/element/proc/Detach(datum/source, force)
	SHOULD_CALL_PARENT(1)
>>>>>>> 6019aa33c0e954c94587c43287536eaf970cdb36
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)

/datum/element/Destroy(force)
	if(!force)
		return QDEL_HINT_LETMELIVE
	SSdcs.elements_by_type -= type
	return ..()

//DATUM PROCS

<<<<<<< HEAD
=======
/// Finds the singleton for the element type given and attaches it to src
>>>>>>> 6019aa33c0e954c94587c43287536eaf970cdb36
/datum/proc/AddElement(eletype, ...)
	var/datum/element/ele = SSdcs.GetElement(eletype)
	args[1] = src
	if(ele.Attach(arglist(args)) == ELEMENT_INCOMPATIBLE)
		CRASH("Incompatible [eletype] assigned to a [type]! args: [json_encode(args)]")

<<<<<<< HEAD
=======
/// Finds the singleton for the element type given and detaches it from src
>>>>>>> 6019aa33c0e954c94587c43287536eaf970cdb36
/datum/proc/RemoveElement(eletype)
	var/datum/element/ele = SSdcs.GetElement(eletype)
	ele.Detach(src)
