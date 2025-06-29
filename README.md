# NWG: Scavenger
This is a coop PVE roguelite project
It draws its inspiration from the 'Patrol' side missions of Arma 3 single-player campaign
Designed for a small number of players
It consists of purchasing weapons and equipment, moving to a selected point of interest, battle, looting, and selling it for in-game currency
Roguelite comes from player progression between runs where they can save (from loot) or buy (from shop) a better equipment as well as spend money to unlock new gameplay features, increase insurance rate in case of failure and unlock new difficulty levels

# Technical features:
+ Custom localization solution with dictionaries being part of servermod and sent to player based on their game language
+ Custom event-based garbage collector solution
+ Custom enemy spawn and patrol points search
+ Objects composition system with blueprint gathering/placing, faction-specific on-the-fly replacements and fractal (city->house->table) randomized variants placement
+ Battle action-reaction system with enemy flanking, reinforcements, mortar, airstrikes, etc.
+ Resource-friendly FPS-saving player actions conditions and event-based add/remove logic
+ Medicine 'Revive' system overhaul with self-heal, crawl and fix for vanilla instant-kill problem
+ Custom items/vehicles shop with new UI and dynamic prices
+ NPC dialogue system and dialogue trees
+ NPC quest system for optional side-missions

# Servers that run this mission:
+ https://www.battlemetrics.com/servers/arma3/32508153

# Servers with integrated parts of this project:
+ https://www.battlemetrics.com/servers/arma3/31504628
+ https://www.battlemetrics.com/servers/arma3/31504632
