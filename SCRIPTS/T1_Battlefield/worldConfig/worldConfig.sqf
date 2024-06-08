//================================================================================================================
//================================================================================================================
//World info
#define NAME_RAW 0
#define NAME_LOC_KEY 1

NWG_WINFO_worlds = createHashMapFromArray [
    ["stratis", ["Stratis","#WORLD_NAME_STRATIS#"]],
    ["altis",   ["Altis","#WORLD_NAME_ALTIS#"]],
    ["tanoa",   ["Tanoa","#WORLD_NAME_TANOA#"]],
    ["malden",  ["Malden","#WORLD_NAME_MALDEN#"]],
    ["bootcamp",["Bootcamp","#WORLD_NAME_BOOTCAMP#"]],
    ["vr",      ["VR","#WORLD_NAME_VR#"]],

    ["unknown", ["Unknown","#WORLD_NAME_UNKNOWN#"]]
];

NWG_WINFO_GetWorldName = {
    (NWG_WINFO_worlds getOrDefault [worldName,(NWG_WINFO_worlds get "unknown")]) select NAME_RAW
};
NWG_WINFO_GetWorldNameLocKey = {
    (NWG_WINFO_worlds getOrDefault [worldName,(NWG_WINFO_worlds get "unknown")]) select NAME_LOC_KEY
};