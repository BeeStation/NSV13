/obj/effect/decal/cleanable/proc/add_bloodiness(var/amount)
	var/old = bloodiness
	bloodiness += amount
	bloodiness = min(MAX_SHOE_BLOODINESS, bloodiness)
	bloodiness = max(0, bloodiness)
	return bloodiness - old
