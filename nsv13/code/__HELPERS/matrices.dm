/atom/proc/shake_animation(var/intensity = 8) //Makes the object visibly shake
	var/initial_transform = new/matrix(transform)
	var/init_px = pixel_x
	var/shake_dir = pick(-1, 1)
	var/rotation = 2+soft_cap(intensity, 1, 1, 0.94)
	var/offset = 1+soft_cap(intensity*0.3, 1, 1, 0.8)
	var/time = 2+soft_cap(intensity*0.3, 2, 1, 0.92)
	animate(src, transform=turn(transform, rotation*shake_dir), pixel_x=init_px + offset*shake_dir, time=1)
	animate(transform=initial_transform, pixel_x=init_px, time=time, easing=ELASTIC_EASING)