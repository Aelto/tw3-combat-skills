
![banner](docs/banner.png)
<div align="center"><a href="https://www.youtube.com/watch?v=S9fPDVx_Js0">SHOWCASE<a/></div>

# tw3-combat-skills
A mod for The Witcher 3 to change how the parries and counter-attack work in combat

# Installing
- Download the zip archive from the [releases](https://github.com/Aelto/tw3-combat-skills/releases).
- Navigate into the zip archive until you see two folders `bin` and `mods`
- Open your The Witcher 3 directory, drop the two folders from your zip archive into your `The Witcher 3` directory so that you merge their content
- Confirm you now have a directory named `modCombatSkills` into your `The Witcher 3/mods/` directory
- Open the script merging tool of your choice, script merger being the prefered solution.
- Confirm the scripts merger detects two pending merges in `r4player.ws` and `playerInput.ws`
- Proceed with the merges and let the tool resolve every conflict automatically
- Start your game
- Confirm you now have a new mod-menu named `Combat Skills` under `Options` > `Mods`
- Apply the default preset then tweak the settings to your liking

# How to use
The mod aims to add new skills without sacrificing any other skill coming from vanilla or mods.
It is also done in a way to avoid adding new keybinds to your already cluttered keybind settings.
These skills are usable through combos, for example the kick is accessible by doing `Forward (W)` and starting a Parry.
When CombatSkills detects the combo `W + Parry` it will launch a kick move instead of a regular parry.
It is the same for the sidesteps, if you press `A + Parry` it will do a left sidestep, and `D + Parry` a sidestep to the right.

The order in which you do the combo is important though, you can't do Parry then W but only W then Parry.
This allows you to still use the vanilla parry by not moving and starting the parry action, and once you're in vanilla parry you can finally start moving while parrying. 

In conclusion, you now have access to 4 new skills while still keeping access to the regular parry and in a gamepad compatible way
