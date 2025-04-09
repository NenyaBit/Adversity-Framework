Scriptname Adv_SleepUtils extends Quest  

Actor property PlayerRef auto
ImageSpaceModifier property SleepyTimeFadeIn auto
Idle property WoozyGetUp auto
ObjectReference property Marker auto
GlobalVariable property GameHour auto

float property DesiredSleepTime auto hidden

bool IsPlayerSleeping = false

string CurrKey = ""
float CurrDelay = 0.0

function Maintenance()
    Adv_Util.LogInfo("Sleep - Maintenance")
    RegisterForSleep()
endFunction

Adv_SleepUtils function Get() global
    return Quest.GetQuest("Adv_SleepUtils") as Adv_SleepUtils
endFunction

event OnSleepStart(float afSleepStartTime, float afDesiredSleepEndTime)
    Adv_Util.LogInfo("Sleep start")
    IsPlayerSleeping = true
    bool isInSamePlace = true
    int startTime = Math.Floor(GameHour.GetValue())
    int currTime = startTime
    Location currLocation = PlayerRef.GetCurrentLocation()

    DesiredSleepTime = afDesiredSleepEndTime

    Marker.MoveTo(PlayerRef)

    while Math.Floor(GameHour.GetValue()) == currTime && IsPlayerSleeping
        Utility.WaitMenuMode(0.2)
        
        if !PlayerRef.GetCurrentLocation().IsSameLocation(currLocation)
            Adv_Util.LogInfo("SleepUtils - no longer in same place - exiting")
            return
        endIf

        currTime = Math.Floor(GameHour.GetValue())
        
        if CurrKey != "" && (currTime - startTime) >= CurrDelay
            SendModEvent("Adv_SleepInterrupt", CurrKey)
            IsPlayerSleeping = false
        endIf
    endWhile
endEvent

event OnSleepStop(bool abInterrupted)
    IsPlayerSleeping = false
endEvent

function Wakeup()
    Adv_Util.LogInfo("Sleep - Wakeup")
    Marker.MoveTo(PlayerRef)
    PlayerRef.MoveTo(Marker)
    IsPlayerSleeping = false
endFunction

function WoozyEffect(bool abWoozy = true, bool abWakeup = true)
    Game.ForceFirstPerson()
    if abWoozy
        SleepyTimeFadeIn.Apply()
    endIf
    if abWakeup
        PlayerRef.PlayIdle(WoozyGetUp)
    endIf
endFunction

bool function RegisterInterrupt(string asKey, float afDelta)
    if CurrKey == asKey || CurrKey == ""
        
        CurrKey = asKey
        CurrDelay = afDelta

        Adv_Util.LogInfo("Registered interrupt - " + asKey + " = " + afDelta)
        return true
    endIf

    Adv_Util.LogInfo("Failed to register interrupt - " + asKey + " = " + afDelta)
    return false
endFunction

bool function RemoveInterrupt(string asKey)
    if asKey == "" || asKey == CurrKey
        CurrKey = ""
        CurrDelay = 0.0
        Adv_Util.LogInfo("Unregistered interrupt - " + asKey)
        return true
    endIf

    Adv_Util.LogInfo("Failed to unregister interrupt - " + asKey)
    return false
endFunction