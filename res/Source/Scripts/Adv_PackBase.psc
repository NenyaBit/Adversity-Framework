Scriptname Adv_PackBase extends Quest

string property Context auto
string property PackName auto
string property IndexKey = "Adv_Event_Index_" autoreadonly hidden

Adv_EventBase[] Events
int NumEvents = 0

bool Lock = false

Function Init()
    if !Events
        Events = new Adv_EventBase[128]
        NumEvents = 0
    endIf
EndFunction

Event OnInit()
    Init()
EndEvent

Function RegisterEvent(Adv_EventBase akEvent)
    Init()
    
    int existingIndex = StorageUtil.GetIntValue(self, IndexKey + akEvent.EventName, -1)
  
    if existingIndex >= 0 && Events[existingIndex].GetEventId() == akEvent.GetEventId()
        return
    endIf

    while Lock
        Utility.Wait(0.2)
    endWhile

    Lock = true
     
    Events[NumEvents] = akEvent
    StorageUtil.SetIntValue(self, IndexKey + akEvent.EventName, NumEvents)
    NumEvents += 1
    
    Lock = false
EndFunction

Adv_EventBase Function GetEventByName(string asName)
    int index = StorageUtil.GetIntValue(self, IndexKey + asName, -1)
    
    if index < 0
        return none
    endIf

    if asName == Events[index].EventName
        return Events[index]
    endIf

    int i = 0
    while i < NumEvents
        if Events[i].EventName == asName
            StorageUtil.SetIntValue(self, IndexKey + asName, i)
            return Events[i]
        endIf
        i += 1
    endWhile


    return none
EndFunction