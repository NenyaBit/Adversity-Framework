Scriptname Adversity Hidden 

; contexts
string[] function GetContextEvents(string asContext) global native
string[] function GetContextTags(string asContext) global native
string[] function GetPacks(string asContext) global native

bool function GetContextBool(string asId, string asKey, bool abDefault = false, bool abPersist = true) global native
bool function SetContextBool(string asId, string asKey, bool abValue, bool abPersist = true) global native

int function GetContextInt(string asId, string asKey, int aiDefault = 0, bool abPersist = true) global native
bool function SetContextInt(string asId, string asKey, int aiValue, bool abPersist = true) global native

float function GetContextFloat(string asId, string asKey, float afDefault = 0.0, bool abPersist = true) global native
bool function SetContextFloat(string asId, string asKey, float afValue, bool abPersist = true) global native

string function GetContextString(string asId, string asKey, string asDefault = "", bool abPersist = true) global native
bool function SetContextString(string asId, string asKey, string asDefault = "", bool abPersist = true) global native

Form function GetContextForm(string asId, string asKey, Form akDefault = none, bool abPersist = true) global native
bool function SetContextForm(string asId, string asKey, Form akValue, bool abPersist = true) global native

string[] function GetContextStringList(string asId, string asKey, string[] asDefault, bool abPersist = true) global native
bool function SetContextStringList(string asId, string asKey,  string[] asDefault, bool abPersist = true) global native

Form[] function GetContextFormList(string asId, string asKey, Form[] akDefault, bool abPersist = true) global native
bool function SetContextFormList(string asId, string asKey, Form[] akValue, bool abPersist = true) global native

; packs
Quest function GetPackQuest(string asPack) global native
Adv_PackBase function GetPackScript(string asPack) global
    Quest q = GetPackQuest(asPack)
    return q as Adv_PackBase
endFunction
string[] function GetPackEvents(string asPack) global native
string function GetPackName(string asPack) global native

; events
string function GetEventName(string asEvent) global native
string function GetEventPack(string asEvent) global native
string function GetEventDesc(string asEvent) global native
string[] function GetEventTags(string asEvent) global native
int function GetEventSeverity(string asEvent) global native

int function GetEventStatus(string asEvent) global native
bool function SetEventStatus(string asEvent, int aiStatus) global native

string[] function FilterEventsByLocation(string[] asEvents) global native
string[] function SortEventsByClosestToRef(string[] asEvents, ObjectReference akRef = none) global native

float function GetEventCooldown(string asEvent) global
    return GetEventFloat(asEvent, "cooldown", 0.0, true)
endFunction

ObjectReference[] function GetEventTargets(string asEvent) global
    Form[] forms = GetEventFormList(asEvent, "targets")
    ObjectReference[] refs = PapyrusUtil.ObjRefArray(refs.Length)
    int i = 0
    while i < forms.Length
        refs[i] = forms[i] as ObjectReference
        i += 1
    endWhile

    return refs
endFunction

bool function SetEventCooldown(string asEvent, float afCooldown) global
    afCooldown = PapyrusUtil.ClampFloat(afCooldown, 0, 100)
    return SetEventFloat(asEvent, "cooldown", afCooldown, true)
endFunction

bool function EventHasTag(string asEvent, string asTag) global
    return GetEventTags(asEvent).Find(asTag) >= 0
endFunction
bool function IsExclusive(string asEvent) global native
bool function CanStart(string asEvent) global
    int status = GetEventStatus(asEvent)
    return status >= 1 && status <= 3
endFunction

bool function DoesEventExist(string asEvent) global
    GetEventStatus(asEvent) > -1
endFunction
bool function IsEventActive(string asEvent) global
    return GetEventStatus(asEvent) == 5
endFunction
bool function IsEventEnabled(string asEvent) global
    return GetEventStatus(asEvent) > 0
endFunction
bool function IsEventSelectable(string asEvent) global
    return (GetEventStatus(asEvent) == 1 || GetEventStatus(asEvent) == 3) && FilterEventsByValid(Utility.CreateStringArray(1, asEvent)).Length
endFunction
bool function IsEventDisabled(string asEvent) global
    return GetEventStatus(asEvent) == 0
endFunction

string[] function GetConflictingEvents(string asEvent) global native

bool function GetEventBool(string asId, string asKey, bool abDefault = false, bool abPersist = true) global native
bool function SetEventBool(string asId, string asKey, bool abValue, bool abPersist = true) global native

int function GetEventInt(string asId, string asKey, int aiDefault = 0, bool abPersist = true) global native
bool function SetEventInt(string asId, string asKey, int aiValue, bool abPersist = true) global native

float function GetEventFloat(string asId, string asKey, float afDefault = 0.0, bool abPersist = true) global native
bool function SetEventFloat(string asId, string asKey, float afValue, bool abPersist = true) global native

string function GetEventString(string asId, string asKey, string asDefault = "", bool abPersist = true) global native
bool function SetEventString(string asId, string asKey, string asDefault = "", bool abPersist = true) global native

Form function GetEventForm(string asId, string asKey, Form akDefault = none, bool abPersist = true) global native
bool function SetEventForm(string asId, string asKey, Form akValue, bool abPersist = true) global native

Form[] function GetEventFormList(string asId, string asKey, Form[] akDefault = none, bool abPersist = true) global native
bool function SetEventFormList(string asId, string asKey, Form[] akValue, bool abPersist = true) global native

function SetLock(bool abEnable) global native
bool function AccquireLock(string asEvent) global
    if !Adv_Sync.Get().Suspend()
        return false
    endIf

    if StorageUtil.GetStringValue(none, "Adv_Lock", asEvent) == asEvent
        SetLock(true)
        StorageUtil.SetStringValue(none, "Adv_Lock", asEvent)

        int handle = ModEvent.Create("Adversity_LockAccquired")
        if handle
            ModEvent.PushString(handle, asEvent)
            ModEvent.Send(handle)
        endIf

        return true
    else
        Adv_Util.LogInfo("AccquireLock - " + asEvent + " failed - mismatch = " + StorageUtil.GetStringValue(none, "Adv_Lock"))
    endIf

    return false
endFunction
bool function ReleaseLock(string asEvent) global
    Adv_Sync.Get().Resume()
    if StorageUtil.GetStringValue(none, "Adv_Lock") == asEvent
        StorageUtil.UnsetStringValue(none, "Adv_Lock")
        SetLock(false)

        int handle = ModEvent.Create("Adversity_LockReleased")
        if handle
            ModEvent.PushString(handle, asEvent)
            ModEvent.Send(handle)
        endIf

        return true
    else
        Adv_Util.LogInfo("ReleaseLock - " + asEvent + " failed - mismatch = " + StorageUtil.GetStringValue(none, "Adv_Lock"))
    endIf

    return false
endFunction
string function GetLocker() global
    return StorageUtil.GetStringValue(none, "Adv_Lock")
endFunction
bool function IsLocked() global
    return StorageUtil.GetStringValue(none, "Adv_Lock") != ""
endFunction


Adv_EventBase function GetEvent(string asEvent) global
    string packId = GetEventPack(asEvent)

    if packId == ""
        return none
    endIf

    Adv_PackBase pack = GetPackScript(packId)

    if !pack
        return none
    endIf

    string name = GetEventName(asEvent)

    if name == ""
        return none
    endIf

    Adv_EventBase ev = pack.GetEventByName(name)

    return ev
endFunction

string[] function FilterEventsByStatus(string[] asEvents, int aiStatus) global native
string[] function FilterEventsBySeverity(string[] asEvents, int aiSeverity, bool abGreater = true, bool abEqual = true) global native
string[] function FilterEventsByTags(string[] asEvents, string[] asTags, bool abAll = false, bool abInvert = false) global native
string[] function FilterEventsByType(string[] asEvents, string asType) global
    return FilterEventsByTags(asEvents, Utility.CreateStringArray(1, "type:" + asType))
endFunction
string[] function FilterEventsByValid(string[] asEvents, Actor akTarget = none) global native
string[] function FilterEventsByCooldown(string[] asEvents) global native
int[] function WeighEventsByActor(string asContext, Actor akActor, string[] asEvents, int aiWeight, bool abDislikes = true, bool abStack = false) global native

bool function EnableEvent(string asEvent) global
    SetEventBool(asEvent, "enabled", true, true)
    return GetEvent(asEvent).Enable()
endFunction
bool function DisableEvent(string asEvent) global
    SetEventBool(asEvent, "enabled", false, true)
    return GetEvent(asEvent).Disable()
endFunction
bool function SelectEvent(string asEvent, Actor akSpeaker = none) global
    return GetEvent(asEvent).Select(akSpeaker)
endFunction
bool function UnselectEvent(string asEvent) global
    return GetEvent(asEvent).Unselect()
endFunction
bool function StartEvent(string asEvent, Actor akTarget = none) global
   return GetEvent(asEvent).Start(akTarget)
endFunction
bool function StopEvent(string asEvent) global
    return GetEvent(asEvent).Stop() 
endFunction
bool function PauseEvent(string asEvent, Actor akTarget = none) global
    return GetEvent(asEvent).Pause()
endFunction
bool function ResumeEvent(string asEvent) global
    return GetEvent(asEvent).Resume() 
endFunction
bool function ReserveEvent(string asEvent) global
    return SetEventStatus(asEvent, 2)
endFunction

string[] function GetSelectedEvents(string asContext) global
    string[] events = GetContextEvents(asContext)
    return FilterEventsByStatus(events, 3)
endFunction

string[] function GetActiveEvents(string asContext, string asType) global
    string[] events = GetContextEvents(asContext)
    events = FilterEventsByStatus(events, 5)

    if asType != ""
        events = FilterEventsByType(events, asType)
    endIf

    return events
endFunction

function ClearSelectedEvents(string asContext, string asType) global
    string[] selected = GetSelectedEvents(asContext)

    if asType != ""
        selected = FilterEventsByTags(selected, Utility.CreateStringArray(1, "type:" + asType))
    endIf

    int i = 0
    while i < selected.length
        UnselectEvent(selected[i])
        i += 1
    endWhile
endFunction

; tags
string[] function FilterTagsByKey(string[] asTags, string asKey) global
    return FilterByPrefix(asTags, asKey + ":")
endFunction

; willpower
float function GetWillpower() global native
float function GetResistance() global native
function ModResistance(float afDelta) global native
bool function IsWillpowerLow() global native
bool function IsWillpowerHigh() global native

; util
int function GetWeightedIndex(int[] weights) global native
int[] function SumArrays(int[] aiWeights1, int[] aiWeights2) global native
string[] function FilterByPrefix(string[] asStrs, string asPrefix) global native
string[] function RemovePrefix(string[] asStrs, string asPrefix) global native
string function GetConfigPath(string asContext, string asPack = "", string asFile = "config") global
    if asPack != ""
        return "../../AdversityFramework/Contexts/" + asContext + "/Packs/" + asPack + "/Config/" + asFile
    endIf
    return "../../AdversityFramework/Contexts/" + asContext + "/Config/" + asFile
endFunction

; devices
Armor[] function GetDevicesByKeyword(string asContext, Actor akActor, Keyword akKwd) global native
Armor function GetDeviceByKeyword(string asContext, Actor akActor, Keyword akKwd) global
    Armor[] devices = GetDevicesByKeyword(asContext, akActor, akKwd)
    if devices.length
        return devices[Utility.RandomInt(0, devices.length - 1)]
    else
        return none
    endIf
endFunction
function LockDeviceByKeyword(string asContext, Actor akActor, Keyword akKwd) global
    (Quest.GetQuest("zadQuest") as zadLibs).LockDevice(akActor, GetDeviceByKeyword(asContext, akActor, akKwd), true)
endFunction

; outfits
string[] function GetOutfits(string asContext, string asName) global native
string function GetNextOutfit(string asVariant, int aiTargetSeverity) global native
string function GetRandomOutfit(string asContext, string asName) global
    string[] outfits = GetOutfits(asContext, asName) 

    if outfits.length == 0
        return ""
    endIf

    return outfits[Utility.RandomInt(0, outfits.length - 1)]
endFunction
bool function AddVariant(string asContext, string asPack, string asName, int aiSeverity) global native
Armor[] function GetOutfitPieces(string asId) global native
bool function ValidateOutfits(string[] asIds) global native
int function GetOutfitSeverity(string asId) global native
string[] function GetOutfitTags(string asId) global native
bool function OutfitHasTag(string asId, string asTag) global
    return GetOutfitTags(asID).Find(asTag) > -1
endFunction
string[] function FilterOutfitsBySeverity(string[] asIds, int aiSeverity, bool abGreater = true, bool abEqual = true) global native
string[] function FilterOutfitsByTags(string[] asIds, string[] asTags, bool abAll = false, bool abInvert = false) global native
int function GiveOutfitPieces(Actor akActor, string asId) global
    int cost = 0

    Armor[] pieces = GetOutfitPieces(asId)
    int i = 0
    while i < pieces.length
        if !akActor.GetItemCount(pieces[i])
            akActor.AddItem(pieces[i])
            cost += pieces[i].GetGoldValue()
        endIf
        i += 1
    endWhile

    return cost
endFunction

int function EquipOutfitPieces(Actor akActor, string asId) global
    int cost = 0

    Armor[] pieces = GetOutfitPieces(asId)
    int i = 0
    while i < pieces.length
        if !akActor.GetItemCount(pieces[i])
            cost += pieces[i].GetGoldValue()
            akActor.AddItem(pieces[i])
        endIf
        akActor.EquipItem(pieces[i])
        i += 1
    endWhile

    return cost
endFunction
int function SwapOutfitPieces(Actor akActor, string asCurrent, string asNext, bool abEquip = false) global
    if asCurrent == asNext
        return EquipOutfitPieces(akActor, asNext)
    endIf

    string CommonItemKey = "Adv_RequiredItem"

    Armor[] currentPieces = GetOutfitPieces(asCurrent)
    Armor[] nextPieces = GetOutfitPieces(asNext)


    int cost = 0
    int i = 0
    while i < nextPieces.length
        Armor piece = nextPieces[i]

        StorageUtil.SetIntValue(piece, CommonItemKey, 1)

        if !akActor.GetItemCount(piece)
            cost += piece.GetGoldValue()
            akActor.AddItem(piece)
        endIf

        if abEquip
            akActor.EquipItem(piece)
        endIf

        i += 1 
    endWHile

    i = 0
    while i < currentPieces.length
        Armor piece = currentPieces[i]

        if !StorageUtil.GetIntValue(piece, CommonItemKey)
            akActor.RemoveItem(piece, akActor.GetItemCount(piece))
        endIf

        i += 1
    endWhile

    i = 0
    while i < nextPieces.length
        StorageUtil.UnsetIntValue(nextPieces[i], CommonItemKey)
        i += 1
    endWhile

    return cost
endFunction
int function RemoveOutfitPieces(Actor akActor, string asId) global
    int cost = 0
    
    Armor[] pieces = GetOutfitPieces(asId)
    
    int i = 0
    while i < pieces.length
        int count = akActor.GetItemCount(pieces[i])
        if count
            akActor.RemoveItem(pieces[i], count)
        else
            cost += pieces[i].GetGoldValue()
        endIf

        i += 1
    endWhile

    return cost
endFunction
string function GiveRandomOutfit(Actor akActor, string asContext, string asName) global
    string variant = GetRandomOutfit(asContext, asName)
    GiveOutfitPieces(akActor, variant)
    return variant
endFunction
string function EquipRandomOutfit(Actor akActor, string asContext, string asName) global
    string variant = GetRandomOutfit(asContext, asName)
    EquipOutfitPieces(akActor, variant)
    return variant
endFunction


; tattoos - prob refactor this later using OM directly
int function GetNumGroups(string asContext, string asName) global native ; todo
string[] function GetTattooGroup(string asContext, string asName, int aiIndex) global native ; todo
string[] function SplitTattoo(string asTattoo) global
    return StringUtil.split(asTattoo, "<>")
endFunction
string[] function GetRandomTattooGroup(string asContext, string asName) global
    int num = GetNumGroups(asContext, asName)
    string[] group = GetTattooGroup(asContext, asName, Utility.RandomInt(0, num - 1))
    return group
endFunction
function ApplyTattooGroup(Actor akTarget, string[] asGroup, bool abLocked = false, bool abSilent = true) global

    int template = JMap.object()
    int matches = JArray.object()
    
    int i = 0
    while i < asGroup.length
        string[] splits = SplitTattoo(asGroup[i])

        string section = splits[0]
        string name = splits[1]

        JMap.setStr(template, "section", section)
        JMap.setStr(template, "name", name)

        SlaveTats.query_available_tattoos(template, matches)

        if JArray.count(matches)
            int tattoo = JArray.getObj(matches, 0)
            if abLocked
                JMap.setInt(tattoo, "locked", 1)
            endIf

            SlaveTats.add_tattoo(akTarget, tattoo)
        endIf
        i += 1
    endWhile

    SlaveTats.synchronize_tattoos(akTarget, abSilent)
endFunction
function RemoveTattooGroup(Actor akTarget, string[] asGroup, bool abSilent = true) global
    int i = 0
    while i < asGroup.length
        string[] splits = SplitTattoo(asGroup[i])
        string section = splits[0]
        string name = splits[1]

        SlaveTats.simple_remove_tattoo(akTarget, section, name, i == asGroup.length - 1, abSilent)
        i += 1
    endWhile
endFunction

; persistent actor data - use storage util for runtime data
string[] function GetTraits(string asContext, Actor akActor) global native
function InitializeActor(string asContext, Actor akActor) global native

Actor[] function GetActorsByBool(string asContext, string asKey, bool abValue) global native

bool function GetActorBool(string asContext, Actor akActor, string asKey, bool abDefault = false) global native
bool function SetActorBool(string asContext, Actor akActor, string asKey, bool abValue) global native

int function GetActorInt(string asContext, Actor akActor, string asKey, int aiDefault = 0) global native
bool function SetActorInt(string asContext, Actor akActor, string asKey, int aiValue) global native

float function GetActorFloat(string asContext, Actor akActor, string asKey, float afDefault = 0.0) global native
bool function SetActorFloat(string asContext, Actor akActor, string asKey, float afValue) global native

string function GetActorString(string asContext, Actor akActor, string asKey, string asDefault = "") global native
bool function SetActorString(string asContext, Actor akActor, string asKey, string asDefault = "") global native

Form function GetActorForm(string asContext, Actor akActor, string asKey, Form akDefault = none) global native
bool function SetActorForm(string asContext, Actor akActor, string asKey, Form akValue) global native