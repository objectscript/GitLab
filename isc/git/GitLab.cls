Class isc.git.GitLab Extends isc.util.LogUtils
{

ClassMethod getDir() [ CodeMode = expression ]
{
##class(%File).NormalizeDirectory($system.Util.GetEnviron("CI_PROJECT_DIR"))
}

/// For CI build - get current commit
ClassMethod getCommit() [ CodeMode = expression ]
{
$system.Util.GetEnviron("CI_COMMIT_SHA")
}

/// Do a full load
/// do ##class(isc.git.GitLab).load()
ClassMethod load()
{
	try {
		set dir = ..getDir()
		do ..executeHooks(.hooks, "before")
		
		do ..log("Importing dir " _ dir)
		do $system.OBJ.ImportDir(dir, ..getExtWildcard(), "c", .errors, 1)
		throw:$get(errors,0)'=0 ##class(%Exception.General).%New("Load error")
		
		do ..executeHooks(.hooks, "after")
		
		$$$TOE(sc, ##class(isc.git.Settings).setSetting("commit", ..getCommit()))
		
		halt
	} catch ex {
		write !,$System.Status.GetErrorText(ex.AsStatus()),!
		do $system.Process.Terminate(, 1)
	}
}

/// Do a diff load
/// do ##class(isc.git.GitLab).loadDiff()
ClassMethod loadDiff()
{
	try {
		#dim sc,sc1 As %Status = $$$OK
		set oldCommit = ##class(isc.git.Settings).getSetting("commit")
		if (oldCommit="") {
			do ..log("Previous commit not found. Doing full load.")
			do ..load()
			halt
		} else {
			set dir = ..getDir()
			do ..executeHooks(.hooks, "before")
						
			set newCommit = ..getCommit()
			do ..log("Importing dir " _ dir)
			do ..log($$$FormatText("Loading diff between %1 and %2", oldCommit, newCommit))
		}
		
		do ##class(isc.git.Diff).buildDiff(dir, oldCommit, newCommit, .modified, .added, .deleted)
		
		set modified = modified _ added
		do ..logVar(modified, "modified")
		set items = ""
		
		for i=1:1:$ll(modified) {
			set file = dir _ $lg(modified, i)
			set sc = $$$ADDSC(sc, $system.OBJ.Load(file,"", .errors, .item,,,,"UTF8"))
			merge items = item	
		}
	
		do ..logVar(.items, "items")
		set sc = $$$ADDSC(sc, $system.OBJ.CompileList(.items, "cuk /checkuptodate=expandedonly", .errors))
		
		// To-Do delete
		set deleteCode = ##class(isc.git.Settings).getSetting("delete")
		if (($ll(deleted)>0) && (deleteCode '="")) {
			do $classmethod($p(deleteCode, ":"), $p(deleteCode, ":", 2), deleted)
		}
				
		throw:$$$ISERR(sc) ##class(%Exception.StatusException).CreateFromStatus(sc)
		throw:$get(errors,0)'=0 ##class(%Exception.General).%New("Load error")
		
		do ..executeHooks(.hooks, "after")
		
		$$$TOE(sc, ##class(isc.git.Settings).setSetting("commit", ..getCommit()))
		
		$$$TOE(sc, $system.OBJ.Export(.items, dir _ "diff.xml"))
		
		halt
	} catch ex {
		do ..logException(ex)
		do $system.Process.Terminate(, 1)
	}
}

ClassMethod executeHooks(Output hooks As %String, method As %String(VALUELIST=",before,after,rollback"))
{
	set hooksDir = ##class(isc.git.Settings).getSetting("hooks")
	if (hooksDir'="") {
		do ..log("Running init hooks: " _ method)
		
		if method = "before" {
			set dir = ..getDir()
			$$$TOE(sc, ##class(isc.git.hook.Manager).execute(dir _ hooksDir, .hooks, "before"))
		} elseif method = "after" {
			$$$TOE(sc, ##class(isc.git.hook.Manager).execute(, .hooks, "after"))
		}
	} else {
		do ..log("No hooks")
	}
}

/// do ##class(isc.git.GitLab).test()
ClassMethod test()
{
	try {
		set tests = ##class(isc.git.Settings).getSetting("tests")
		if (tests'="") {
			set dir = ..getDir()
			set ^UnitTestRoot = dir
			
			$$$TOE(sc, ##class(%UnitTest.Manager).RunTest(tests, "/nodelete"))
			$$$TOE(sc, ..writeTestHTML())
			throw:'..isLastTestOk() ##class(%Exception.General).%New("Tests error")
		}
		halt
	} catch ex {
		do ..logException(ex)
		do $system.Process.Terminate(, 1)
	}
}

/// do ##class(GitLab.Main).package()
ClassMethod package()
{
	try {
		set dir = ..getDir()
		// TODO
		do $system.OBJ.ExportAllClasses(dir _ "full.xml", , .errors)
		throw:$g(errors,0)'=0 ##class(%Exception.General).%New("Package error")
		halt
	} catch ex {
		do ..logException(ex)
		do $system.Process.Terminate(, 1)
	}
}

ClassMethod writeTestHTML()
{
	set text = ##class(%Dictionary.XDataDefinition).IDKEYOpen($classname(), "html").Data.Read()
	set text = $replace(text, "!!!", ..getURL())
	
	set file = ##class(%Stream.FileCharacter).%New()
	set name = ..getDir() _  "tests.html"
	do file.LinkToFile(name)
	do file.Write(text)
	quit file.%Save()
}

ClassMethod getURL()
{
	set url = ##class(isc.git.Settings).getSetting("url")
	set url = url _ $system.CSP.GetDefaultApp("%SYS")
	set url = url_"/%25UnitTest.Portal.Indices.cls?Index="_ $g(^UnitTest.Result, 1) _ "&$NAMESPACE=" _ $zconvert($namespace,"O","URL")
	quit url
}

/// Get extensions as wildcard for import
ClassMethod getExtWildcard() As %String
{
	set extList = ##class(isc.git.Settings).getSetting("ext")
	set ext = "*." _ $lts(##class(isc.git.Settings).getSetting("ext"), ";*.")
	quit ext
}

/// w ##class(GitLab.Main).isLastTestOk()
ClassMethod isLastTestOk() As %Boolean
{
	set in = ##class(%UnitTest.Result.TestInstance).%OpenId(^UnitTest.Result)
	for i=1:1:in.TestSuites.Count() {
		#dim suite As %UnitTest.Result.TestSuite
		set suite = in.TestSuites.GetAt(i)
		return:suite.Status=0 $$$NO
	}
	quit $$$YES
}

XData html
{
<html lang="en-US">
<head>
<meta charset="UTF-8"/>
<meta http-equiv="refresh" content="0; url=!!!"/>
<script type="text/javascript">
window.location.href = "!!!"
</script>
</head>
<body>
If you are not redirected automatically, follow this <a href='!!!'>link to tests</a>.
</body>
</html>
}

}

