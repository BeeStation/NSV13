
CONTRIBUTING
===

## Table of Contents

1. Introduction
2. Getting Started - Contributing for Dummies
3. Recommended Tools - Creating a Decent Dev Environment
4. Code Standards
5. Codebase-specific Policies
6. Asset Policy
7. Banned Content

## 1. Introduction
Hello and welcome to BeeStation's contributing page. You are presumably here because you are interested in contributing - thank you! Everyone is free to contribute to this project as long as they follow the simple guidelines and specifications below; at BeeStation, we strive to maintain code stability and maintainability, and to do that, we need all pull requests to meet our standards. It's in everyone's best interests - including yours!

First things first, we want to make it clear how you can contribute (if you've never contributed before), as well as the kinds of powers the team has over your additions, to avoid any unpleasant surprises if your pull request is closed for a reason you didn't foresee.

## 2. Getting Started - Contributing for Dummies

BeeStation doesn't have any kind of design document outlining planned changes; we instead allow freedom for contributors to suggest and create their ideas for the game. That doesn't mean we aren't determined to squash bugs, which unfortunately pop up a lot due to the deep complexity of the game.

If you want to contribute the first thing you'll need to do is set up a decent development environment. The default tools for working with BYOND simply aren't sufficient, and the next section explains what we use. We also have a few guides to help you get started with git and making a pull request:

* [Here](https://forums.beestation13.com/t/github-building-the-hive/1334) is a guide for setting up Git and GitKraken.

For beginners, it is strongly recommended you work on small projects like bugfixes or very minor features at first. While we are willing to assist you, we have no desire to write your code for you.

**Please note that you need to credit any code that you port from other codebases.**

There are a variety of ways to give credit, here is a list of our most strongly preferred method to least preferred:
1. Cherry-pick (Guide coming soon). May not always be feasible.
2. Provide a link to the specific pull request(s) in your pull request's description.
3. Mention the codebase it's from in your pull request description.

You can of course, as always, ask for help on our discord.

## 3. Recommended Tools - Creating a Decent Dev Environment

By default, the only thing BYOND provides people with is Dream Maker. It is hardly sufficient, and few (if any) contributors regularly use it. Instead, we have a variety of alternative tools for different purposes that make our lives a lot easier:

* Git client - [GitKraken](https://www.gitkraken.com/)
* Code editing - [VSCode](https://code.visualstudio.com/) (NOT THE SAME AS VISUAL STUDIO)
* VSCode Extensions - [DM syntax highlighting](https://marketplace.visualstudio.com/items?itemName=gbasood.byond-dm-language-support), [DM language support](https://marketplace.visualstudio.com/items?itemName=platymuus.dm-langclient)
* Map editing - [FastDMM2](https://fastdmm2.ss13.io/) or [StrongDMM](https://github.com/SpaiR/StrongDMM)

## 4. Code Standards
There are a variety of ways you can write valid DM code. However, BeeStation is not as lenient. Maintaining good code standards is important for performance and readability reasons. You can find details about our code standards [here](https://github.com/BeeStation/BeeStation-Hornet/wiki/Code-Standards).

They are mostly the same as /tg/station's code standards, though we are not quite as strict about enforcing them. A notable example is that we don't require our code to be thoroughly documented for autodoc.

Failure to meet these standards can result in your pull request being closed. The code standards are non-exhaustive and Maintainers have the final say.

## 5. Codebase-specific Policies
### HippieStation
HippieStation's code standards are much more lax than BeeStation. Their code typically does not meet our standards. Therefore, you should not attempt to port code from HippieStation unless you have the experience and knowledge necessary to rewrite the code to our standards. Maintainers will not hold your hand for this, instead they will simply close the pull request.

### Goonstation
**Attempting to use Goonstation code without using the steps outlined in this section is grounds for an immediate repoban.**

Goonstation's code license is not compatible with [AGPLv3](https://www.gnu.org/licenses/agpl-3.0.en.html). Therefore, there are very specific steps that need to be taken in order to use Goonstation code:
1. Get approval from a BeeStation Maintainer, explaining specifically what you want to port.
2. Get permission from **EVERY** code author that was involved with writing the code you wish to port.
3. Open the pull request. It must have "[GOON]" at the start of the pull request title. It must say "CONTAINS CODE FROM GOONSTATION" at the top of the pull request description. List **ALL** of the code authors somewhere in your pull request description.
4. Have **EVERY** code author from step two comment on your pull request giving you permission to use the code. The specifics of how they should word their comment can vary on a case-by-case basis.
5. Wait for final approval from a BeeStation Maintainer. This will involve us reaching out to a Goonstation representative for their sign-off.

Failing to correctly follow any step will result in the pull request being closed. If done maliciously, it will also result in a repoban.

## 6. Asset Policy
Assets are things such as art, sprites, sounds, music, etc. Different policies apply depending on where the assets are from, so please look at the relevant subsection.

**If you are the sole creator of the assets and your work is not a derivative, you can ignore the remainder of this section.** Note that by contributing your assets, you are agreeing to license them under [CC-BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/).

**If you are not the sole creator, or if you created a derivative, then regardless of the source, you must give the creator credit in your pull request.**

### Assets from other SS13 servers (other than Goonstation)
Most Space Station 13 servers, with the notable exception of Goonstation, all use the same asset license: [CC-BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/). However, you always need to double-check. Most asset licenses are mentioned in the codebase's README. Therefore, as long as all assets you are adding are from another SS13 server with the [CC-BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/) asset license, you shouldn't have to worry as long as you give credit in your pull request.

### Assets from Goonstation
Goonstation uses a similar license, with the exception that their assets cannot be used commercially. All assets from Goonstation should be placed in the `goon` folder, which is licensed under [CC-BY-NC-SA 3.0](https://creativecommons.org/licenses/by-nc-sa/3.0/).

### Assets from external (non-SS13) sources
All assets must comply with our asset license, [CC-BY-SA 3.0](https://creativecommons.org/licenses/by-sa/3.0/). You should always ask the author for permission to use their work.

If you are adding new assets that are not already explicitly licensed under CC-BY-SA 3.0, you must get permission from the author using a very specific process. Them direct messaging you "Sure, you can use it" is not sufficient. You can speak to a Maintainer on Discord for more details.

**Attempting to add assets by falsely claiming it is CC-BY-SA 3.0 is grounds for an immediate repoban. If the offending pull request has been merged, it will immediately be reverted.**

If at any point you are confused or unsure of an asset's license or our policy, ask a Maintainer to help you.

## 7. Banned Content

Do not add any of the following in a Pull Request or risk getting the PR closed:

- Any content that violates GitHub Terms of Service.
- Racial or homophobic slurs of any kind.
-  National Socialist Party of Germany content, National Socialist Party of Germany related content, or National Socialist Party of Germany references
-  Code adding, removing, or updating the availability of alien races/species/human mutants without prior approval. Pull requests attempting to add or remove features from said races/species/mutants require prior approval as well.

### Type paths must be lowercase
eg: `/datum/thing/blue`, not `datum/thing/BLUE` or `datum/thing/Blue`

### Datum type paths must began with "datum"
In DM, this is optional, but omitting it makes finding definitions harder.

### Do not use text/string based type paths
It is rarely allowed to put type paths in a text format, as there are no compile errors if the type path no longer exists. Here is an example:

```DM
//Good
var/path_type = /obj/item/baseball_bat

//Bad
var/path_type = "/obj/item/baseball_bat"
```

### Use var/name format when declaring variables
While DM allows other ways of declaring variables, this one should be used for consistency.

### Tabs, not spaces
You must use tabs to indent your code, NOT SPACES.

(You may use spaces to align something, but you should tab to the block level first, then add the remaining spaces)

### No hacky code
Hacky code, such as adding specific checks, is highly discouraged and only allowed when there is ***no*** other option. (Protip: 'I couldn't immediately think of a proper way so thus there must be no other option' is not gonna cut it here! If you can't think of anything else, say that outright and admit that you need help with it. Maintainers exist for exactly that reason.)

You can avoid hacky code by using object-oriented methodologies, such as overriding a function (called "procs" in DM) or sectioning code into functions and then overriding them as required.

### No duplicated code
Copying code from one place to another may be suitable for small, short-time projects, but /tg/station is a long-term project and highly discourages this.

Instead you can use object orientation, or simply placing repeated code in a function, to obey this specification easily.

### Startup/Runtime tradeoffs with lists and the "hidden" init proc
First, read the comments in [this BYOND thread](http://www.byond.com/forum/?post=2086980&page=2#comment19776775), starting where the link takes you.

There are two key points here:

1) Defining a list in the variable's definition calls a hidden proc - init. If you have to define a list at startup, do so in New() (or preferably Initialize()) and avoid the overhead of a second call (Init() and then New())

2) It also consumes more memory to the point where the list is actually required, even if the object in question may never use it!

Remember: although this tradeoff makes sense in many cases, it doesn't cover them all. Think carefully about your addition before deciding if you need to use it.

### Prefer `Initialize()` over `New()` for atoms
Our game controller is pretty good at handling long operations and lag, but it can't control what happens when the map is loaded, which calls `New` for all atoms on the map. If you're creating a new atom, use the `Initialize` proc to do what you would normally do in `New`. This cuts down on the number of proc calls needed when the world is loaded. See here for details on `Initialize`: https://github.com/tgstation/tgstation/blob/master/code/game/atoms.dm#L49
While we normally encourage (and in some cases, even require) bringing out of date code up to date when you make unrelated changes near the out of date code, that is not the case for `New` -> `Initialize` conversions. These systems are generally more dependant on parent and children procs so unrelated random conversions of existing things can cause bugs that take months to figure out.

### No magic numbers or strings
This means stuff like having a "mode" variable for an object set to "1" or "2" with no clear indicator of what that means. Make these #defines with a name that more clearly states what it's for. For instance:
````DM
/datum/proc/do_the_thing(thing_to_do)
	switch(thing_to_do)
		if(1)
			(...)
		if(2)
			(...)
````
There's no indication of what "1" and "2" mean! Instead, you'd do something like this:
````DM
#define DO_THE_THING_REALLY_HARD 1
#define DO_THE_THING_EFFICIENTLY 2
/datum/proc/do_the_thing(thing_to_do)
	switch(thing_to_do)
		if(DO_THE_THING_REALLY_HARD)
			(...)
		if(DO_THE_THING_EFFICIENTLY)
			(...)
````
This is clearer and enhances readability of your code! Get used to doing it!

### Control statements
(if, while, for, etc)

* All control statements must not contain code on the same line as the statement (`if (blah) return`)
* All control statements comparing a variable to a number should use the formula of `thing` `operator` `number`, not the reverse (eg: `if (count <= 10)` not `if (10 >= count)`)

### Use early return
Do not enclose a proc in an if-block when returning on a condition is more feasible
This is bad:
````DM
/datum/datum1/proc/proc1()
	if (thing1)
		if (!thing2)
			if (thing3 == 30)
				do stuff
````
This is good:
````DM
/datum/datum1/proc/proc1()
	if (!thing1)
		return
	if (thing2)
		return
	if (thing3 != 30)
		return
	do stuff
````
This prevents nesting levels from getting deeper then they need to be.

### Develop Secure Code

* Player input must always be escaped safely, we recommend you use stripped_input in all cases where you would use input. Essentially, just always treat input from players as inherently malicious and design with that use case in mind

* Calls to the database must be escaped properly - use sanitizeSQL to escape text based database entries from players or admins, and isnum() for number based database entries from players or admins.

* All calls to topics must be checked for correctness. Topic href calls can be easily faked by clients, so you should ensure that the call is valid for the state the item is in. Do not rely on the UI code to provide only valid topic calls, because it won't.

* Information that players could use to metagame (that is, to identify round information and/or antagonist type via information that would not be available to them in character) should be kept as administrator only.

* It is recommended as well you do not expose information about the players - even something as simple as the number of people who have readied up at the start of the round can and has been used to try to identify the round type.

* Where you have code that can cause large-scale modification and *FUN*, make sure you start it out locked behind one of the default admin roles - use common sense to determine which role fits the level of damage a function could do.

### Files
* Because runtime errors do not give the full path, try to avoid having files with the same name across folders.

* File names should not be mixed case, or contain spaces or any character that would require escaping in a uri.

* Files and path accessed and referenced by code above simply being #included should be strictly lowercase to avoid issues on filesystems where case matters.

### SQL
* Do not use the shorthand sql insert format (where no column names are specified) because it unnecessarily breaks all queries on minor column changes and prevents using these tables for tracking outside related info such as in a connected site/forum.

* All changes to the database's layout(schema) must be specified in the database changelog in SQL, as well as reflected in the schema files

* Any time the schema is changed the `schema_revision` table and `DB_MAJOR_VERSION` or `DB_MINOR_VERSION` defines must be incremented.

* Queries must never specify the database, be it in code, or in text files in the repo.

* Primary keys are inherently immutable and you must never do anything to change the primary key of a row or entity. This includes preserving auto increment numbers of rows when copying data to a table in a conversion script. No amount of bitching about gaps in ids or out of order ids will save you from this policy.

### Mapping Standards
* TGM Format & Map Merge
	* All new maps submitted to the repo through a pull request must be in TGM format (unless there is a valid reason present to have it in the default BYOND format.) This is done using the [Map Merge](https://github.com/tgstation/tgstation/wiki/Map-Merger) utility included in the repo to convert the file to TGM format.
	* Likewise, you MUST run Map Merge prior to opening your PR when updating existing maps to minimize the change differences (even when using third party mapping programs such as FastDMM.)
		* Failure to run Map Merge on a map after using third party mapping programs (such as FastDMM) greatly increases the risk of the map's key dictionary becoming corrupted by future edits after running map merge. Resolving the corruption issue involves rebuilding the map's key dictionary; id est rewriting all the keys contained within the map by reconverting it from BYOND to TGM format - which creates very large differences that ultimately delay the PR process and is extremely likely to cause merge conflicts with other pull requests.

* Variable Editing (Var-edits)
	* While var-editing an item within the editor is perfectly fine, it is preferred that when you are changing the base behavior of an item (how it functions) that you make a new subtype of that item within the code, especially if you plan to use the item in multiple locations on the same map, or across multiple maps. This makes it easier to make corrections as needed to all instances of the item at one time as opposed to having to find each instance of it and change them all individually.
		* Subtypes only intended to be used on away mission or ruin maps should be contained within an .dm file with a name corresponding to that map within `code\modules\awaymissions` or `code\modules\ruins` respectively. This is so in the event that the map is removed, that subtype will be removed at the same time as well to minimize leftover/unused data within the repo.
	* Please attempt to clean out any dirty variables that may be contained within items you alter through var-editing. For example, due to how DM functions, changing the `pixel_x` variable from 23 to 0 will leave a dirty record in the map's code of `pixel_x = 0`. Likewise this can happen when changing an item's icon to something else and then back. This can lead to some issues where an item's icon has changed within the code, but becomes broken on the map due to it still attempting to use the old entry.
	* Areas should not be var-edited on a map to change it's name or attributes. All areas of a single type and it's altered instances are considered the same area within the code, and editing their variables on a map can lead to issues with powernets and event subsystems which are difficult to debug.


### Other Notes
* Code should be modular where possible; if you are working on a new addition, then strongly consider putting it in its own file unless it makes sense to put it with similar ones (i.e. a new tool would go in the "tools.dm" file)

* Bloated code may be necessary to add a certain feature, which means there has to be a judgement over whether the feature is worth having or not. You can help make this decision easier by making sure your code is modular.

* You are expected to help maintain the code that you add, meaning that if there is a problem then you are likely to be approached in order to fix any issues, runtimes, or bugs.

* Do not divide when you can easily convert it to multiplication. (ie `4/2` should be done as `4*0.5`)

* If you used regex to replace code during development of your code, post the regex in your PR for the benefit of future developers and downstream users.

* Changes to the `/config` tree must be made in a way that allows for updating server deployments while preserving previous behaviour. This is due to the fact that the config tree is to be considered owned by the user and not necessarily updated alongside the remainder of the code. The code to preserve previous behaviour may be removed at some point in the future given the OK by maintainers.

* The dlls section of tgs3.json is not designed for dlls that are purely `call()()`ed since those handles are closed between world reboots. Only put in dlls that may have to exist between world reboots.

#### Enforced not enforced
The following coding styles are not only not enforced at all, but are generally frowned upon to change for little to no reason:

* English/British spelling on var/proc names
	* Color/Colour - both are fine, but keep in mind that BYOND uses `color` as a base variable
* Spaces after control statements
	* `if()` and `if ()` - nobody cares!

### Operators
#### Spacing
(this is not strictly enforced, but more a guideline for readability's sake)

* Operators that should be separated by spaces
	* Boolean and logic operators like &&, || <, >, ==, etc (but not !)
	* Bitwise AND &
	* Argument separator operators like , (and ; when used in a forloop)
	* Assignment operators like = or += or the like
* Operators that should not be separated by spaces
	* Bitwise OR |
	* Access operators like . and :
	* Parentheses ()
	* logical not !

Math operators like +, -, /, *, etc are up in the air, just choose which version looks more readable.

#### Use
* Bitwise AND - '&'
	* Should be written as ```bitfield & bitflag``` NEVER ```bitflag & bitfield```, both are valid, but the latter is confusing and nonstandard.
* Associated lists declarations must have their key value quoted if it's a string
	* WRONG: list(a = "b")
	* RIGHT: list("a" = "b")

### Dream Maker Quirks/Tricks
Like all languages, Dream Maker has its quirks, some of them are beneficial to us, like these

#### In-To for-loops
```for(var/i = 1, i <= some_value, i++)``` is a fairly standard way to write an incremental for loop in most languages (especially those in the C family), but DM's ```for(var/i in 1 to some_value)``` syntax is oddly faster than its implementation of the former syntax; where possible, it's advised to use DM's syntax. (Note, the ```to``` keyword is inclusive, so it automatically defaults to replacing ```<=```; if you want ```<``` then you should write it as ```1 to some_value-1```).

HOWEVER, if either ```some_value``` or ```i``` changes within the body of the for (underneath the ```for(...)``` header) or if you are looping over a list AND changing the length of the list then you can NOT use this type of for-loop!

### for(var/A in list) VS for(var/i in 1 to list.len)
The former is faster than the latter, as shown by the following profile results:
https://file.house/zy7H.png
Code used for the test in a readable format:
https://pastebin.com/w50uERkG


#### Istypeless for loops
A name for a differing syntax for writing for-each style loops in DM. It's NOT DM's standard syntax, hence why this is considered a quirk. Take a look at this:
```DM
var/list/bag_of_items = list(sword, apple, coinpouch, sword, sword)
var/obj/item/sword/best_sword
for(var/obj/item/sword/S in bag_of_items)
	if(!best_sword || S.damage > best_sword.damage)
		best_sword = S
```
The above is a simple proc for checking all swords in a container and returning the one with the highest damage, and it uses DM's standard syntax for a for-loop by specifying a type in the variable of the for's header that DM interprets as a type to filter by. It performs this filter using ```istype()``` (or some internal-magic similar to ```istype()``` - this is BYOND, after all). This is fine in its current state for ```bag_of_items```, but if ```bag_of_items``` contained ONLY swords, or only SUBTYPES of swords, then the above is inefficient. For example:
```DM
var/list/bag_of_swords = list(sword, sword, sword, sword)
var/obj/item/sword/best_sword
for(var/obj/item/sword/S in bag_of_swords)
	if(!best_sword || S.damage > best_sword.damage)
		best_sword = S
```
specifies a type for DM to filter by. 

With the previous example that's perfectly fine, we only want swords, but here the bag only contains swords? Is DM still going to try to filter because we gave it a type to filter by? YES, and here comes the inefficiency. Wherever a list (or other container, such as an atom (in which case you're technically accessing their special contents list, but that's irrelevant)) contains datums of the same datatype or subtypes of the datatype you require for your loop's body,
you can circumvent DM's filtering and automatic ```istype()``` checks by writing the loop as such:
```DM
var/list/bag_of_swords = list(sword, sword, sword, sword)
var/obj/item/sword/best_sword
for(var/s in bag_of_swords)
	var/obj/item/sword/S = s
	if(!best_sword || S.damage > best_sword.damage)
		best_sword = S
```
Of course, if the list contains data of a mixed type then the above optimisation is DANGEROUS, as it will blindly typecast all data in the list as the specified type, even if it isn't really that type, causing runtime errors.

#### Dot variable
Like other languages in the C family, DM has a ```.``` or "Dot" operator, used for accessing variables/members/functions of an object instance.
eg:
```DM
var/mob/living/carbon/human/H = YOU_THE_READER
H.gib()
```
However, DM also has a dot variable, accessed just as ```.``` on its own, defaulting to a value of null. Now, what's special about the dot operator is that it is automatically returned (as in the ```return``` statement) at the end of a proc, provided the proc does not already manually return (```return count``` for example.) Why is this special?

With ```.``` being everpresent in every proc, can we use it as a temporary variable? Of course we can! However, the ```.``` operator cannot replace a typecasted variable - it can hold data any other var in DM can, it just can't be accessed as one, although the ```.``` operator is compatible with a few operators that look weird but work perfectly fine, such as: ```.++``` for incrementing ```.'s``` value, or ```.[1]``` for accessing the first element of ```.```, provided that it's a list.

## Globals versus static

DM has a var keyword, called global. This var keyword is for vars inside of types. For instance:

```DM
mob
	var
		global
			thing = TRUE
```
This does NOT mean that you can access it everywhere like a global var. Instead, it means that that var will only exist once for all instances of its type, in this case that var will only exist once for all mobs - it's shared across everything in its type. (Much more like the keyword `static` in other languages like PHP/C++/C#/Java)

Isn't that confusing? 

There is also an undocumented keyword called `static` that has the same behaviour as global but more correctly describes BYOND's behaviour. Therefore, we always use static instead of global where we need it, as it reduces suprise when reading BYOND code.

## Pull Request Process

There is no strict process when it comes to merging pull requests. Pull requests will sometimes take a while before they are looked at by a maintainer; the bigger the change, the more time it will take before they are accepted into the code. Every team member is a volunteer who is giving up their own time to help maintain and contribute, so please be courteous and respectful. Here are some helpful ways to make it easier for you and for the maintainers when making a pull request.

* Make sure your pull request complies to the requirements outlined in [this guide](http://tgstation13.org/wiki/Getting_Your_Pull_Accepted)

* You are going to be expected to document all your changes in the pull request. Failing to do so will mean delaying it as we will have to question why you made the change. On the other hand, you can speed up the process by making the pull request readable and easy to understand, with diagrams or before/after data.

* We ask that you use the changelog system to document your change, which prevents our players from being caught unaware by changes - you can find more information about this [on this wiki page](http://tgstation13.org/wiki/Guide_to_Changelogs).

* If you are proposing multiple changes, which change many different aspects of the code, you are expected to section them off into different pull requests in order to make it easier to review them and to deny/accept the changes that are deemed acceptable.

* If your pull request is accepted, the code you add no longer belongs exclusively to you but to everyone; everyone is free to work on it, but you are also free to support or object to any changes being made, which will likely hold more weight, as you're the one who added the feature. It is a shame this has to be explicitly said, but there have been cases where this would've saved some trouble.

* Please explain why you are submitting the pull request, and how you think your change will be beneficial to the game. Failure to do so will be grounds for rejecting the PR.

## Porting features/sprites/sounds/tools from other codebases

If you are porting features/tools from other codebases, you must give them credit where it's due. Typically, crediting them in your pull request and the changelog is the recommended way of doing it. Take note of what license they use though, porting stuff from AGPLv3 and GPLv3 codebases are allowed.

Regarding sprites & sounds, you must credit the artist and possibly the codebase. All /tg/station assets including icons and sound are under a [Creative Commons 3.0 BY-SA license](https://creativecommons.org/licenses/by-sa/3.0/) unless otherwise indicated. However if you are porting assets from GoonStation or usually any assets under the [Creative Commons 3.0 BY-NC-SA license](https://creativecommons.org/licenses/by-nc-sa/3.0/) are to go into the 'goon' folder of the /tg/station codebase.

## Banned content
Do not add any of the following in a Pull Request or risk getting the PR closed:
* National Socialist Party of Germany content, National Socialist Party of Germany related content, or National Socialist Party of Germany references
* Code where one line of code is split across mutiple lines (except for multiple, separate strings and comments; in those cases, existing longer lines must not be split up)
* Code adding, removing, or updating the availability of alien races/species/human mutants without prior approval. Pull requests attempting to add or remove features from said races/species/mutants require prior approval as well.
* PRs adding rank config lists, Place them on the forums [Here](https://nsv.beestation13.com/phpBB3/viewforum.php?f=20).

Just because something isn't on this list doesn't mean that it's acceptable. Use common sense above all else.

Violations of the banned content policy can potentially result in a repoban.
