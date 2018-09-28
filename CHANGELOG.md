Toggle Sprint Definitive Edition Changelog
=======
# 1.0.2.0b
* Switched the ToggleSprint sprinting skill and status icon to an icon from DOS2, to help mitigate the texture atlas limit of 7.

# 1.0.2.0
* Settings Menu
	* New User Settings submenu.
		* Sprinting status text can now be disabled for all user-owned characters.
		* The Enable/Disable "Automatically Adding the Sprinting Skill to Summons" option has been moved to this menu, as a user settings.
			* Summon sprinting status text is automatically disabled if "Disable Automatically Adding Sprinting Skill to Summons" is set.
		

# 1.0.1.0
* Fix for the sprinting skill / book not being added when starting from the multiplayer lobby.

# 1.0.0.9
* Added some safety checks for users experiencing issues in multiplayer.

# 1.0.0.8
* Added a non-lobby, non-character creation level check before adding the settings book.

# 1.0.0.7
* Minor tweaks to the host-flagging code (specifically seeing if the host has changed on load).

# 1.0.0.4
* Summons are now ignored by default when adding the "Toggle Sprinting" skill to characters joining the party (this can be re-enabled in the settings menu).
* Added some safety checks for players experiencing bugs with the sprinting skill and book not being added on first load.
	* When TSDE is internally updated, it will check players for missing skills/books. 

# 1.0.0.3
* Initial Release