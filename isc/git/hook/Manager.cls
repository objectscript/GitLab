/// Manages hooks
/// Class to store local hooks execution
Class isc.git.hook.Manager Extends isc.util.LogUtils
{

Parameter GLVN = "^isc.git.Hooks";

ClassMethod add(class As %Dictionary.CacheClassname)
{
	set @..#GLVN@(class) = ""
}

ClassMethod isDone(class As %Dictionary.CacheClassname) As %Boolean [ CodeMode = expression ]
{
$data(@..#GLVN@(class))
}

/// do ##class(isc.git.hook.Manager).execute()
ClassMethod execute(directory As %String = "", ByRef hooks As %String = "", method As %String(VALUELIST=",before,after,rollback")) As %Status
{
	try {
		#dim sc As %Status = $$$OK
		do:directory'="" ..load(directory, .loadedHooks)
		merge hooks = loadedHooks
		
		if (method="before") {
		
			/// Execute global hooks
			do ..executeInternal(.hooks, method, "isc.git.hook.Global")
			
			/// Execute local hooks
			do ..executeInternal(.hooks, method, "isc.git.hook.Local")
		} elseif (method="after") {
			/// Execute local hooks
			do ..executeInternal(.hooks, method, "isc.git.hook.Local")
			
			/// Execute global hooks
			do ..executeInternal(.hooks, method, "isc.git.hook.Global")
		}
	} catch ex {
		set sc = ex.AsStatus()
	}
	quit sc
}

ClassMethod executeInternal(ByRef hooks As %String = "", method As %String(VALUELIST=",before,after"), type As %String(VALUELIST=",isc.git.hook.Global,isc.git.hook.Local"))
{
	/// Execute hooks
	set key = ""
	for {
		set key=$order(hooks(key)) 
		quit:key=""
		continue:$p(key, ".", *)'="cls"
		set class = $p(key, ".", 1, *-1)
		continue:'$classmethod(class, "%IsA", type)
		continue:class=type
		continue:((type="isc.git.hook.Local") && (..isDone(class)))
		
		do ..log("Executing hook class: " _ class)
		
		$$$TOE(sc, $classmethod(class, method))
		do:((type="isc.git.hook.Local") && (method="after")) ..add(class)
	}
}

/// do ##class(isc.git.hook.Manager).load(,.h)
ClassMethod load(directory As %String, Output hooks As %String)
{
	do ..log("Importing hooks dir " _ directory)
	set hooks = ""
	do $system.OBJ.ImportDir(directory, ##class(isc.git.GitLab).getExtWildcard(), "cukb /displaylog=0", .errors, 1, .hooks)
	throw:$get(errors,0)'=0 ##class(%Exception.General).%New("Hooks load error")
}

}

