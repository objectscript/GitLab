Class isc.util.LogUtils
{

ClassMethod logVar(var = "", name As %String = "") As %String
{
	do ..log("Variable " _ name)
	zw var
	/*if $isObject(var) {
		zw var
	} elseif $listValid(var) {
		write $lts(var, ", ")
	} else {
		write var
	}*/
}

ClassMethod logException(ex As %Exception.AbstractException)
{
	do ..logStatus(ex.AsStatus())
}

ClassMethod logStatus(sc As %Status)
{
	do ..log($System.Status.GetErrorText(sc))
}

ClassMethod log(msg As %String)
{
	write !, $$$FormatText("[%1] %2", $zdatetime($ztimestamp, 3, 1, 3), msg), !
}

}

