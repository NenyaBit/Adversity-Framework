Scriptname Adv_LicenseUtils extends Quest  

; License Codes: 0 - Magic, 1 - Weapon, 2 - Armor, 3 - Bikini, 4 - Clothes, 5 - Curfew, 6 - Whore, 7 - Freedom, 8 - Property

Adv_InterfaceLicense_Base property ActiveInterface auto hidden
int property InterfaceSelected auto hidden
GlobalVariable[] property StatusGlobals auto

function Maintenance()
    InterfaceSelected = -1
    Adv_InterfaceLicense_Base[] interfaces = new Adv_InterfaceLicense_Base[2]
    interfaces[0] = (self as Quest) as Adv_InterfaceLicense_BMLE
    interfaces[1] = (self as Quest) as Adv_InterfaceLicense_SLS

    ActiveInterface = none

    int i = 0
    while i < interfaces.Length
        if interfaces[i].IsModValid()
            ActiveInterface = interfaces[i]
            interfaces[i].Maintenance()
            InterfaceSelected = i
            i = interfaces.Length
        endIf

        i += 1
    endWhile

    Adv_Util.LogInfo("Adv_LicenseUtils - Maintenance - ActiveInterface = " + ActiveInterface)

    UpdateStatus()

    if ActiveInterface
        GoToState("Active")
    else
        GoToState("")
    endIf
endFunction

Adv_LicenseUtils function Get() global
    return Quest.GetQuest("Adv_LicenseUtils") as Adv_LicenseUtils
endFunction

bool function LicensesAvailable()
    return false
endFunction

function Give(int aiType, int aiTerm = 0, Actor akIssuer = none, bool abPay = false)

endFunction

bool function HasValid(int aiType)
    return false
endFunction

function Remove(int aiType)

endFunction

bool function IsEnabled(int aiType)
    return false
endFunction

bool function IsValid(ObjectReference akInstance)
    return false
endFunction

int[] function GetStatuses()
    int[] statuses = new int[9]
    return statuses
endFunction

function UpdateStatus()

endFunction

state Active
    bool function LicensesAvailable()
        return true
    endFunction

    function Give(int aiType, int aiTerm = 0, Actor akIssuer = none, bool abPay = false)
        ActiveInterface.Give(aiType, aiTerm, akIssuer, abPay)
    endFunction
    
    bool function HasValid(int aiType)
        return ActiveInterface.HasValid(aiType)
    endFunction
    
    function Remove(int aiType)
        ActiveInterface.Remove(aiType)
    endFunction
    
    bool function IsEnabled(int aiType)
        return ActiveInterface.IsEnabled(aiType)
    endFunction
    
    bool function IsValid(ObjectReference akInstance)
        return ActiveInterface.IsValid(akInstance)
    endFunction
    
    int[] function GetStatuses()
        int[] statuses = new int[9]
    
        int i = 0
        while i < statuses.Length
    
            if !IsEnabled(i)
                statuses[i] = -1
            elseIf HasValid(i)
                statuses[i] = 1
            else
                statuses[i] = 0
            endIf
    
            i += 1
        endWhile
    
        return statuses
    endFunction

    function UpdateStatus()
        int i = 0
        while i < 9
            int status
            if !IsEnabled(i) || HasValid(i)
                status = 1
            else
                status = 0
            endIf

            StatusGlobals[i].SetValue(status)
    
            i += 1
        endWhile
    endFunction
endState