Scriptname Adv_InterfaceLicense_SLS extends Adv_InterfaceLicense_Base  

string[] LicenseTokens

function Maintenance()
    LicenseTokens = new string[9]
    LicenseTokens[0] = "Magic"
    LicenseTokens[1] = "Weapon"
    LicenseTokens[2] = "Armor"
    LicenseTokens[3] = "Bikini"
    LicenseTokens[4] = "Clothes"
    LicenseTokens[5] = "Curfew"
    LicenseTokens[6] = "Whore"
    LicenseTokens[7] = "Freedom"
    LicenseTokens[8] = "Property"
endFunction

bool function IsModValid()
    return Game.IsPluginInstalled("SL Survival.esp")
endFunction

bool function HasValid(int aiType)
    if aiType > LicenseTokens.Length
        return false
    endIf
    string storageToken = "_SLS_Licence" + LicenseTokens[aiType] + "ValidUntil"
    float val = StorageUtil.GetFloatValue(None, storageToken, -2.0)
    return val - Math.Ceiling(Utility.GetCurrentGameTime()) > 0.0
endFunction

bool function IsEnabled(int aiType)
    string storageToken = "_SLS_HasValid" + LicenseTokens[aiType] + "Licence"
    return StorageUtil.GetIntValue(None, storageToken, -2) >= 0 
endFunction

function Give(int aiType, int aiTerm = 0, Actor akIssuer = none, bool abPay = false)
    int eventID = ModEvent.Create("_SLS_IssueLicence")
    if eventID
        ModEvent.PushInt(eventID, aiType)
        ModEvent.PushInt(eventID, aiTerm)
        ModEvent.PushForm(eventID, akIssuer)
        ModEvent.PushForm(eventID, Game.GetPlayer())
        ModEvent.PushBool(eventID, abPay)
        ModEvent.PushForm(eventID, self As Form)
        ModEvent.Send(eventID)
    endIf
    
    Utility.Wait(1.0)
endFunction

bool function Remove(int aiType)
    int eventID = ModEvent.Create("_SLS_RevokeLicence")
    if eventID
        ModEvent.PushString(eventID, "_SLS_RevokeLicence")
        ModEvent.PushString(eventID, aiType)
        ModEvent.PushString(eventID, 0.0)
        ModEvent.PushForm(eventID, self As Form)
        ModEvent.Send(eventID)
    endIf

    Utility.Wait(1.0)
endFunction

bool function IsValid(ObjectReference akInst)
    return StorageUtil.GetFloatValue(akInst, "_SLS_LicenceExpiry") > Utility.GetCurrentGameTime()
endFunction