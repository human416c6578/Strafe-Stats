# Counter-Strike 1.6 Strafe Stats Plugin

## Overview
This AMX Mod X plugin tracks and displays strafing statistics for Counter-Strike 1.6 players.  
Strafing is a movement technique used to gain speed while jumping.  
The plugin shows strafe count, sync percentage, gain, frames, strafe list and console info.  
All player preferences are **saved persistently** using FVault (survives reconnects and map changes).

## Features
- Strafe stats HUD visible to the player and their spectators
- Prestrafe speed display
- Full configuration menu with individual toggles
- Persistent saving: Stats, Pre-Strafe, Strafes, Sync, Gain, Frames, List and Console Info
- Works for spectators: they see stats/prestrafe if **they** have toggles enabled

## Commands
- `/stats` → Opens the main menu (quick toggles for Stats + Prestrafe + link to detailed settings)
- `/statsmenu` → Opens the detailed settings menu directly
- `/pre`, `/showpre`, `/prestrafe` → Quick toggle for Prestrafe (optional)

## Menu System
### Main Menu (`/stats`)
- Stats → Toggle overall strafe stats HUD
- Pre-Strafe → Toggle prestrafe speed display
- Display Settings → Opens detailed options

### Detailed Settings Menu
- Strafes → Show number of strafes
- Sync → Show sync percentage
- Gain → Show average gain
- Frames → Show good/total frames
- List → Show side list of each strafe
- Console Info → Show detailed info in console

All changes are saved instantly and persist across sessions.

## Credits
- **MrShark45 & ftl~** 