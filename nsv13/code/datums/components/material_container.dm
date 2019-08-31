/datum/component/material_container/proc/retrieve_ores(ore_amt, var/datum/material/M, target = null)
	if(!M.ore_type)
		return 0 //Add greyscale ore handling here later

	if(ore_amt <= 0)
		return 0

	if(!target)
		target = get_turf(parent)

	if(materials[M] < (ore_amt * MINERAL_MATERIAL_AMOUNT))
		ore_amt = round(materials[M] / MINERAL_MATERIAL_AMOUNT)

	var/count = 0

	while(ore_amt > MAX_STACK_SIZE)
		new M.ore_type(target, MAX_STACK_SIZE)
		count += MAX_STACK_SIZE
		use_amount_mat(ore_amt * MINERAL_MATERIAL_AMOUNT, M)
		ore_amt -= MAX_STACK_SIZE

	if(ore_amt >= 1)
		new M.ore_type(target, ore_amt)
		count += ore_amt
		use_amount_mat(ore_amt * MINERAL_MATERIAL_AMOUNT, M)
	return count