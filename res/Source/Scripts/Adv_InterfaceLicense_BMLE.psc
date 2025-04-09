Scriptname Adv_InterfaceLicense_BMLE extends Adv_InterfaceLicense_Base  

BM_Licenses Licenses
BM_Licenses_MCM Config
BM_Licenses_Utility Util

int[] LicenseTypeMapping

; License Codes: 0 - Magic, 1 - Weapon, 2 - Armor, 3 - Bikini, 4 - Clothes, 5 - Curfew, 6 - Whore, 7 - Freedom, 8 - Property

function Maintenance()
    Licenses = Quest.GetQuest("BM_Licenses") as BM_Licenses
    Config = Quest.GetQuest("BM_Licenses_MCM") as BM_Licenses_MCM
    Util = Quest.GetQuest("BM_Licenses_Utility") as BM_Licenses_Utility

    LicenseTypeMapping = new int[9]
    LicenseTypeMapping[0] = 4
    LicenseTypeMapping[1] = 5
    LicenseTypeMapping[2] = 1
    LicenseTypeMapping[3] = 2
    LicenseTypeMapping[4] = 3
    LicenseTypeMapping[5] = 10
    LicenseTypeMapping[6] = 12
    LicenseTypeMapping[7] = 0
    LicenseTypeMapping[8] = 9
endFunction

bool function IsModValid()
    return Game.IsPluginInstalled("Licenses.esp")
endFunction

bool function HasValid(int aiType)
    if aiType == 0
        return Licenses.hasMagicLicense
    elseIf aiType == 1
        return Licenses.hasWeaponLicense
    elseIf aiType == 2
        return Licenses.hasArmorLicense
    elseIf aiType == 3
        return Licenses.hasBikiniLicense
    elseIf aiType == 4
        return Licenses.hasClothingLicense
    elseIf aiType == 5
        return Licenses.hasCurfewExemption
    elseIf aiType == 6
        return Licenses.hasWhoreLicense
    elseIf aiType == 7
        return true
    elseIf aiType == 8
        return Licenses.hasInsurance
    endIf

    return false
endFunction

bool function IsEnabled(int aiType)
    if aiType == 0
        return Config.isMagicLicenseFeatureEnabled
    elseIf aiType == 1
        return Config.isWeaponLicenseFeatureEnabled
    elseIf aiType == 2
        return Config.isArmorLicenseFeatureEnabled
    elseIf aiType == 3
        return Config.isBikiniLicenseFeatureEnabled
    elseIf aiType == 4
        return Config.isClothingLicenseFeatureEnabled
    elseIf aiType == 5
        return Config.isCurfewExemptionFeatureEnabled
    elseIf aiType == 6
        return Config.isWhoreLicenseFeatureEnabled
    elseIf aiType == 7
        return false
    elseIf aiType == 8
        return Config.isInsuranceFeatureEnabled
    endIf

    return false
endFunction

function Give(int aiType, int aiTerm = 0, Actor akIssuer = none, bool abPay = false)
    Util.PurchaseLicense(LicenseTypeMapping[aiType], abPay)
endFunction

bool function Remove(int aiType)
    Util.RemoveLicense(LicenseTypeMapping[aiType])
endFunction

bool function IsValid(ObjectReference akInst)
    return true
endFunction