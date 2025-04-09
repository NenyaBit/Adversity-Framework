Scriptname Adv_OutfitManager extends Quest  

string[] ActiveRules

Adv_OutfitManager function Get()
    return Quest.GetQuest("Adv_OutfitManager") as Adv_OutfitManager
endFunction

function Add(string asRule, string[] asOutfits, GlobalVariable akStatus)
    StorageUtil.StringListCopy(self, asRule, asOutfits)
    StorageUtil.SetFormValue(self, asRule, akStatus)

    ActiveRules = PapyrusUtil.PushString(ActiveRules, asRule)
endFunction

function Remove(string asRule)
    StorageUtil.StringListClear(self, asRule)
    StorageUtil.UnsetFormValue(self, asRule)

    ActiveRules = PapyrusUtil.RemoveString(ActiveRules, asRule)
endFunction

function Swap(string asRule, string[] asOutfits)
    StorageUtil.StringListCopy(self, asRule, asOutfits)
    (StorageUtil.GetFormValue(self, asRule) as GlobalVariable).SetValue(1)
endFunction

string[] function GetOutfits(string asRule)
    return StorageUtil.StringListToArray(self, asRule)
endFunction

function ValidateAll()
    int i = 0
    while i < ActiveRules.Length
        bool valid = Adversity.ValidateOutfits(GetOutfits(ActiveRules[i]))
        (StorageUtil.GetFormValue(self, ActiveRules[i]) as GlobalVariable).SetValue(valid as int)
        i += 1
    endWhile
endFunction

bool function IsValid(string asRule)
    if ActiveRules.Find(asRule) < 0
        return false
    endIf

    return Adversity.ValidateOutfits(StorageUtil.StringListToArray(self, asRule))
endFunction

bool function Has(string asRule)
    return ActiveRules.Find(asRule) > -1
endFunction