//Checks every process() to see if it has the allowed ingredients inside of it's contents to then craft a thing

/obj/machinery/automation/crafter //Takes a recipe datum, accepts ingredients for them and makes it
	name = "autocrafter"
	desc = "Takes in ingredients and outputs products."
	var/datum/crafting_recipe/currentrecipe
	var/datum/personal_crafting/craftproc = new //The thing that has all the procs we gotta call
	var/obj/possible_item
	dir = SOUTH //Default outputs south
	radial_categories = list(
	"Change Crafting Recipe")

/obj/machinery/automation/crafter/Initialize()
	. = ..()
	radial_categories["Change Crafting Recipe"] = image(icon = 'icons/mob/radial.dmi', icon_state = "auto_change_output")

/obj/machinery/automation/crafter/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>This [src] is currently producing a recipe called <span class='bold'>[currentrecipe.name]</span></span>")

/obj/machinery/automation/crafter/MakeRadial(mob/living/user)
	var/category = show_radial_menu(user, src, radial_categories, null, require_near = TRUE)
	if(category)
		switch(category)
			if("Change Crafting Recipe")
				var/list/crafting_categories = craftproc.categories
				var/cate_chosen = input(user, "Pick a crafting category", "Please select a crafting category to narrow your choices") in crafting_categories
				if(cate_chosen)
					if(craftproc.categories[craftproc.categories.Find(cate_chosen)])
						var/sub_cate_chosen = input(user, "Pick a sub crafting category", "Please select a sub crafting category to narrow your choices") in craftproc.categories[craftproc.categories.Find(cate_chosen)]
						var/list/stuff_to_choose = list()
						for(var/datum/crafting_recipe/recipe in GLOB.crafting_recipes)
							if(recipe.category == cate_chosen)
								if(sub_cate_chosen)
									if(recipe.subcategory == sub_cate_chosen)
										stuff_to_choose += recipe
								else
									stuff_to_choose += recipe
						for(var/datum/crafting_recipe/recipe2 in stuff_to_choose)
							stuff_to_choose[recipe2.name] = recipe2
						var/recipe_chosen = input(user, "Pick a recipe", "Choose the crafting recipe for the machine to use") in stuff_to_choose
						currentrecipe = recipe_chosen
						to_chat(user, "You set the recipe to [currentrecipe.name].")

/obj/machinery/automation/crafter/process()
	possible_item = craftproc.construct_item(src, currentrecipe)
	if(isobj(possible_item)) //The returned one can either be null, a string or the object itself; the object itself means it's crafted
		possible_item.loc = get_step(src, outputdir)
	possible_item = null
	..()

/obj/machinery/automation/crafter/Bumped(atom/input)
	for(var/ingredients in currentrecipe.reqs)
		if(istype(input, ingredients))
			contents += input
			break
	..()
