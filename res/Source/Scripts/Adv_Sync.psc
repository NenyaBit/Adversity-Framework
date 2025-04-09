Scriptname Adv_Sync extends Quest conditional

bool property Blocked = false auto hidden conditional

Adv_Sync function Get() global
    return Quest.GetQuest("Adv_Sync") as Adv_Sync
endFunction

function Maintenance()
    RegisterForModEvent("dhlp-Suspend", "OnSuspend")
    RegisterForModEvent("dhlp-Resume", "OnResume")
endFunction

bool function Suspend()
    if Blocked
        return false
    endIf

    Adv_Util.LogInfo("DHLP internally suspending")

    SendModEvent("dhlp-Suspend")

    return true
endFunction

bool function Resume()
    if Blocked
        return false
    endIf

    Adv_Util.LogInfo("DHLP internally resuming")

    SendModEvent("dhlp-Resume")

    return true
endFunction

event OnSuspend(string asEvent, string asStr, float afNum, Form akSender)
    DFR_Util.Log("OnSuspend - " + akSender)

    if akSender == self
        Adv_Util.LogInfo("DHLP internal suspend")
        return
    endif

    Adv_Util.LogInfo("DHLP external suspend")

    Blocked = true
endEvent

event OnResume(string asEvent, string asStr, float afNum, Form akSender)
    DFR_Util.Log("OnResume - " + akSender)
    
    if akSender == self
        Adv_Util.LogInfo("DHLP internal resume")
        return
    endif

    Adv_Util.LogInfo("DHLP external resume")

    Blocked = false
endEvent