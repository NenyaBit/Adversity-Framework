Scriptname Adv_Commands hidden

string function AddVariant(string asContext, string asPack, string asName, int aiSeverity) global
    if Adversity.AddVariant(asContext, asPack, asName, aiSeverity)
        return "added variant"
    else
        return "failed to add variant"
    endIf
endFunction

string function Lock(string asMsg) global
    if Adversity.AccquireLock(asMsg)
        return "successfully accquired lock"
    else
        return "failed to accquire lock due to existing locker = " + Adversity.GetLocker()
    endIf   
endFunction

string function GetLocker() global
    return Adversity.GetLocker()
endFunction

string function Release() global
    string locker = Adversity.GetLocker()

    if locker == ""
        return "lock not acquired"
    endIf

    if Adversity.ReleaseLock(locker)
        return "successfully released lock"
    else
        return "failed to release lock due to existing locker = " + Adversity.GetLocker()
    endIf   
endFunction