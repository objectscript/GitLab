Class isc.git.hook.Local Extends isc.git.hook.Abstract
{

/// Code executed after main code load/compile.
/// Do not modify.
ClassMethod after() As %Status
{
	try {
		set sc = ..onAfter()
		do ##class(isc.git.hook.Log).add($classname())
	} catch ex {
		set sc = ex.AsStatus()
	}
	quit sc
}

}

