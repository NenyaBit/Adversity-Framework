Scriptname Adv_LocUtils extends Quest  

Actor property PlayerRef auto
Location[] property Holds auto ; 0 = Windhelm, 1 = Falkreath, 2 = Solitude, 3 = Morthal, 4 = Dawnstar, 5 = Markarth, 6 = Riften, 7 = Whiterun, 8 = Winterhold
Faction[] property CrimeFactions auto

Adv_LocUtils function Get() global
    return Quest.GetQuest("Adv_LocUtils") as Adv_LocUtils
endFunction

Faction function GetCrimeFaction()
    int i = GetCurrentLocationIndex()
    if i < 0
        return none
    endIf
    return CrimeFactions[i]
endFunction

int function GetCurrentLocationIndex()
    int i = 0
    while i < Holds.length
        if PlayerRef.IsInLocation(Holds[i])
            return i
        endIf

        i += 1
    endWhile

    return -1
endFunction

bool function LocationHasKwd(Location akLoc, Keyword akKwd, bool abAll = false) global
    Location curr = akLoc

    while curr != none
        if curr.HasKeyword(akKwd)
            return true
        endIf

        Location par = PO3_SKSEFunctions.GetParentLocation(curr)
        if curr == par
            curr = none
        else
            curr = par
        endIf
    endWhile

    return false
endFunction

bool function LocationHasKwds(Location akLoc, Keyword[] akKwds, bool abAll = false) global
    Location curr = akLoc

    while curr != none
        if PyramidUtils.FormHasKeyword(curr, akKwds, abAll)
            return true
        endIf

        Location par = PO3_SKSEFunctions.GetParentLocation(curr)
        if curr == par
            curr = none
        else
            curr = par
        endIf
    endWhile

    return false
endFunction

string function GetHoldName()
    return Holds[GetCurrentLocationIndex()].GetName()
endFunction