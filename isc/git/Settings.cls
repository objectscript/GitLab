Include %syPrompt

Class isc.git.Settings
{

/// List of extensions relevant to code load
Parameter EXT As List = {$lb("xml", "cls", "csp", "csr", "mac", "int", "bas", "inc", "gbl", "prj", "obj", "pkg", "gof", "dfi", "pivot", "dashboard")};

Parameter URL = "http://127.0.0.1:57772";

Parameter GLVN = "^isc.git.Settings";

/// Get setting
/// Получить настойку
/// write ##class(isc.git.Settings).getSetting("ext")
ClassMethod getSetting(name As %String) As %String [ CodeMode = expression ]
{
$get(@..#GLVN@($zcvt(name, "l")), $parameter(,$zcvt(name, "U")))
}

/// Get setting
/// Установить настройку
/// write ##class(isc.git.Settings).setSetting("ext")
ClassMethod setSetting(name As %String = "", value As %String = "") As %Status
{
	#dim sc As %Status = $$$OK
	
	if name = "tests" {
		// Path relative from the repo root to test suite	
	} elseif name = "ext" {
		set:'$listValid(value) sc = $$$ERROR($$$GeneralError, "Extension list should be in $lb format.")	
	} elseif name = "commit" {
		// TO-DO commit validation.  
	} elseif name = "delete" { 
		set:$length(value, ":")'=2 sc = $$$ERROR($$$GeneralError, "Delete should be in a format: 'class:method'")
	} elseif name = "url" {
		// TO-DO url validation. 
		// "http://127.0.0.1:57772"
	} elseif name = "hooks" {
		// Path relative from the repo root to hooks
	} else {
		set sc = $$$ERROR($$$GeneralError, $$$FormatText("Setting '%1' does not exist", name))
	}
	
	set:$$$ISOK(sc) @..#GLVN@($zcvt(name, "l")) = value
	return sc
}

}

