Scriptname Adv_Util  Hidden 

function Log(string asType, string asMsg) global
    Debug.Trace("Adv: (" + asType + ") " + asMsg)
endFunction

function LogInfo(string asMsg) global
    Log("info", asMsg)
endFunction

bool function BeforeTimeStamp(Form akForm, string asKey, float afTime) global
    float currTime = Utility.GetCurrentGameTime()
    float lastTime = StorageUtil.GetFloatValue(akForm, asKey, currTime - (afTime + 1))

    return (currTime - lastTime) <= afTime
endFunction