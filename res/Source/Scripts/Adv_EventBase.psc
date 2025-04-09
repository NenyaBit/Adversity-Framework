Scriptname Adv_EventBase extends ReferenceAlias

string property EventName auto

; GENERIC EVENT SCRIPT
; status: 0 = disabled, 1 = enabled, 2 = reserved, 3 = selected, 4 = paused, 5 = active

; user defined
function OnModuleLoad()
    
endFunction

bool function IsValid(Actor akTarget)
    return true
endFunction

bool function OnSelect(Actor akTarget)
    return true
endFunction

function OnUnselect()
    
endFunction

bool function OnStart(Actor akTarget)
    return true
endFunction

function OnStop()
    
endFunction

function OnPause()

endFunction

function OnResume()

endFunction

; internal
Event OnInit()
    (GetOwningQuest() as Adv_PackBase).RegisterEvent(self)
EndEvent

Event OnPlayerLoadGame()
    OnModuleLoad()
    (GetOwningQuest() as Adv_PackBase).RegisterEvent(self)
EndEvent

string function GetEventId()
    Adv_PackBase packScr = GetOwningQuest() as Adv_PackBase
    return packScr.Context + "/" + packScr.PackName + "/" + EventName
endFunction

bool function Start(Actor akTarget)
    string id = GetEventId()

    if !Adversity.SetEventStatus(id, 5)
        Log("failed to set start status")
        return false
    endIf

    bool locked = false
    if Adversity.IsExclusive(id)
        if Lock()
            locked = true
        else
            Log("failed to accquire lock")
            Adversity.SetEventStatus(id, 1)
            return false
        endIf
    else
        StorageUtil.StringListClear(none, "Conflicting_" + id)
        string[] conflicting = Adversity.GetConflictingEvents(id)
        int i = 0
        while i < conflicting.Length
            Adversity.PauseEvent(conflicting[i])
            StorageUtil.StringListAdd(none, "Conflicting_" + id, conflicting[i])
            i += 1
        endWhile
    endIf
    
    if !OnStart(akTarget)
        Log("failed to start")
        Adversity.SetEventStatus(id, 1)

        if locked
            Adversity.ReleaseLock(id)
        endIf

        return false
    endIf

    int handle = ModEvent.Create("Adv_Event_Start")
    if handle
        ModEvent.PushString(handle, id)
        ModEvent.PushForm(handle, akTarget)
    endIf
    ModEvent.Send(handle)

    handle = ModEvent.Create("Adv_Event_Start_" + id)
    if handle
        ModEvent.PushForm(handle, akTarget)
    endIf
    ModEvent.Send(handle)

    return true
endFunction

function Stop()
    string id = GetEventId()

    OnStop()
    
    if Adversity.IsExclusive(id)
        Release()
    else
        string[] conflicting = StorageUtil.StringListToArray(none, "Conflicting_" + id)
        int i = 0
        while i < conflicting.Length
            Adversity.ResumeEvent(conflicting[i])
            StorageUtil.StringListAdd(none, "Conflicting_" + id, conflicting[i])
            i += 1
        endWhile
    endIf

    int handle = ModEvent.Create("Adv_Event_Stop")
    if handle
        ModEvent.PushString(handle, id)
    endIf
    ModEvent.Send(handle)

    handle = ModEvent.Create("Adv_Event_Stop_" + id)
    ModEvent.Send(handle)

    Adversity.SetEventStatus(id, 1)
    Adversity.SetEventFloat(GetEventId(), "last-stopped", Utility.GetCurrentGameTime(), false)
    Adv_Util.LogInfo("Last Stopped: " + Adversity.GetEventFloat(GetEventId(), "last-stopped", -100.0, false))
endFunction

bool function Select(Actor akSpeaker)
    Log("Selecting")
    if OnSelect(akSpeaker)
        Log("finished selecting")
        return Adversity.SetEventStatus(GetEventId(), 3)
    else
        Log("failed to select")
        return false
    endIf
endFunction 

bool function Unselect()
    OnUnselect()
    return Adversity.SetEventStatus(GetEventId(), 1) 
endFunction

bool function Enable()
    return Adversity.SetEventStatus(GetEventId(), 1)
endFunction

bool function Disable()
    return Adversity.SetEventStatus(GetEventId(), 0)
endFunction

bool function IsActive()
    return Adversity.GetEventStatus(GetEventId()) == 5
endFunction

int function GetStatus()
    return Adversity.GetEventStatus(GetEventId())
endFunction

function Log(string asMsg)
    Adv_Util.LogInfo("[" + GetEventId() + "] " + asMsg)
endFunction

bool function Resume()
    string id = GetEventId()
    
    bool locked = false
    bool exclusive = Adversity.IsExclusive(id)
    if exclusive
        if Lock()
            locked = true
        else
            Log("failed to accquire lock")
            Adversity.SetEventStatus(id, 1)
        endIf
    endIf

    if (!exclusive || locked) && Adversity.SetEventStatus(id, 5)
        OnResume()
        return true
    elseIf locked
        Release()
    endIf

    return false
endFunction

bool function Pause()
    string id = GetEventId()

    if Adversity.IsExclusive(id)
        Release()
    endIf

    if Adversity.SetEventStatus(id, 4)
        OnPause()
        return true
    endIf

    return false
endFunction

function SetObjectiveTargets(Form[] akTargets)
    Adversity.SetEventFormList(GetEventId(), "targets", akTargets, false)
endFunction

function ClearObjectiveTargets()
    Adversity.SetEventFormList(GetEventId(), "targets", Utility.CreateFormArray(0), false)
endFunction

bool function Lock()
    return Adversity.AccquireLock(GetEventId())
endFunction

bool function Release()
    return Adversity.ReleaseLock(GetEventId())
endFunction