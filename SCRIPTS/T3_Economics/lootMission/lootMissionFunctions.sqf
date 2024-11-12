/*Other systems->Server*/
//Compile loot catalogue
//returns true if catalogue was compiled successfully, false otherwise
NWG_fnc_lmCompileCatalogue = {
    private _res = call NWG_LM_SER_CompileCatalogue;
    //return
    (_res isNotEqualTo false)
};

//Configures loot machine enrichment
//note: call it before filling containers or vehicles
//params:
// - _setEnrichment - number to modify sets probability for objects (better keep it in range -1..1)
// - _itemEnrichment - number to modify items probability in sets (better keep it in range -1..1)
//returns: true if enrichment was configured successfully, false otherwise
NWG_fnc_lmConfigureEnrichment = {
    // params [["_setEnrichment",0],["_itemEnrichment",0]];
    _this call NWG_LM_SER_ConfigureEnrichment
};

//Fill containers with loot
//note: objects that are not containers will be safely ignored
//params:
// - _faction - faction to use for loot generation
// - _containers - array of containers to fill (it is safe to pass any objects, only containers will be filled)
// - _setEnrichmentOverride - enrichment override for sets (optional, uses pre-configured enrichment by default, which is itself 0 by default)
// - _itemEnrichmentOverride - enrichment override for items (optional, uses pre-configured enrichment by default, which is itself 0 by default)
//returns: array of objects that were filled with loot
NWG_fnc_lmFillContainers = {
    // params [["_faction",""],["_containers",[]],["_setEnrichmentOverride",0],["_itemEnrichmentOverride",0]];
    _this call NWG_LM_SER_FillContainers
};

//Fill vehicles with loot
//params:
// - _faction - faction to use for loot generation
// - _vehicles - array of vehicles to fill
// - _setEnrichmentOverride - enrichment override for sets (optional, uses pre-configured enrichment by default, which is itself 0 by default)
// - _itemEnrichmentOverride - enrichment override for items (optional, uses pre-configured enrichment by default, which is itself 0 by default)
//returns: nothing
NWG_fnc_lmFillVehicles = {
    // params [["_faction",""],["_vehicles",[]],["_setEnrichmentOverride",0],["_itemEnrichmentOverride",0]];
    _this call NWG_LM_SER_FillVehicles
};

//Generate loot set data
//params:
// - _faction - faction to use for filtering (optional, "" by default - any faction)
// - _containerTag - container tag to use for filtering (optional, "" by default - any container)
// - _setsCount - number of sets to sqash into this data (optional, 1 by default)
// - _enrichment - enrichment override - number to modify items probability in sets (optional, uses pre-configured enrichment by default, which is itself 0 by default)
//returns: array of [["CLTH","CLTH"...],["WEAP","WEAP"...],["ITEM","ITEM"...],["AMMO","AMMO"...]] or false if something went wrong
NWG_fnc_lmGenerateLootSet = {
    // params [["_faction",""],["_containerTag",""],["_setsCount",1],["_enrichment",0]];
    _this call NWG_LM_SER_GenerateLootSet
};
