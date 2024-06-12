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

NWG_WINFO_GetWorldInfo = {
    //worldName is unreliable in terms of case sensitivity ("stratis" or "Stratis" fuck knows why), so we unify it by using toLower(ANSI)
    //see: https://discord.com/channels/105462288051380224/105462984087728128/1250374649708023810
    //We use toLowerANSI as worldnames are always in english and toLowerANSI is '3x faster' than toLower
    //see: https://community.bistudio.com/wiki/toLowerANSI
    NWG_WINFO_worlds getOrDefault [(toLowerANSI worldName),(NWG_WINFO_worlds get "unknown")]
};
NWG_WINFO_GetWorldName = {
    (call NWG_WINFO_GetWorldInfo) select NAME_RAW
};
NWG_WINFO_GetWorldNameLocKey = {
    (call NWG_WINFO_GetWorldInfo) select NAME_LOC_KEY
};