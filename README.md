# Counter-Strike 1.6 Strafe Stats Plugin

## Overview
This AMX Mod X plugin is designed for Counter-Strike 1.6 servers to track and display strafing statistics for players. Strafing is a movement technique used to gain speed while jumping.

## Features
- Tracks the number of strafes performed by players.
- Calculates synchronization frames during strafes.
- Displays strafing statistics on the player's HUD and in the console.
- Toggle the display of statistics for individual players.

## Commands
- **/stats:** Toggles the display of strafing statistics for the player.
  
## Native Functions
1. `get_user_sync(player_id)`: Get synchronization percentage for a specific player.
2. `get_user_strafes(player_id)`: Get the number of strafes performed by a specific player.
3. `display_stats(player_id, strafes, sync)`: Display strafing statistics to a specific player.
4. `get_bool_stats(player_id)`: Get the status of statistics display for a specific player.
5. `toggle_stats(player_id)`: Toggle the display of strafing statistics for a specific player.


