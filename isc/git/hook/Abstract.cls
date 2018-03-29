/// Base hook class.
/// You should not subclass directly.
/// Extend Global or Local hook classes
Class isc.git.hook.Abstract
{

/// Code executed before main code load/compile.
/// Do not modify.
ClassMethod before() As %Status
{
	try {
		set sc = ..onBefore()
	} catch ex {
		set sc = ex.AsStatus()
	}
	quit sc
}

/// Code executed before main code load/compile.
/// Overwrite this method.
ClassMethod onBefore() As %Status
{
	quit $$$OK
}

/// Code executed after main code load/compile.
/// Do not modify.
ClassMethod after() As %Status
{
	try {
		set sc = ..onAfter()
	} catch ex {
		set sc = ex.AsStatus()
	}
	quit sc
}

/// Code executed before main code load/compile.
/// Overwrite this method.
ClassMethod onAfter() As %Status
{
	quit $$$OK
}

/// Code executed during rollback.
/// Do not modify.
ClassMethod rollback() As %Status
{
	try {
		set sc = ..onRollback()
	} catch ex {
		set sc = ex.AsStatus()
	}
	quit sc
}

/// Code executed during rollback.
/// Overwrite this method.
ClassMethod onRollback() As %Status
{
	quit $$$OK
}

}

