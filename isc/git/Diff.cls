Class isc.git.Diff Extends isc.util.OSUtils
{

/// Get diff between two points in repository
/// repo - repository root directory
/// sha1, commitEnd - poins of history in repository
/// modified - list of modified files
/// added - list of added files 
/// deleted - list of deleted files
/// 
/// Internal diff statuses:
/// M modified - File has been modified
/// C copy-edit - File has been copied and modified //3-arg form
/// R rename-edit - File has been renamed and modified //3-arg form
/// A added - File has been added
/// D deleted - File has been deleted
/// U unmerged - File has conflicts after a merge 
/// 
/// do ##class(isc.git.Diff).buildDiff("C:\\temp\GitLab\", "HEAD~10", "HEAD", .modified, .added, .deleted)
ClassMethod buildDiff(repo As %String, commitBegin As %String, commitEnd As %String, Output modified As %List, Output added As %List, Output deleted As %List)
{
	#include %occCPTJSgen
	set (modified, added, deleted) = ""
	$$$TOE(sc, ..createFile(.tempFile))
	do $system.Process.CurrentDirectory(repo)
	$$$TOE(sc, ..execute($$$FormatText("git diff --name-status %1 %2 > %3 2>&1", commitBegin, commitEnd, tempFile)))
	$$$TOE(sc, ..fileToString(tempFile, .diffRaw))
	for i=1:1:$length(diffRaw, $c(10)) {
		set element = $piece(diffRaw, $c(10), i)
		set status = $e($piece(element, $$$TAB))
		set file = $piece(element, $$$TAB, 2)
		
		if ((element="") || ('..isRelevantFile(repo, file))) {
			continue
		} elseif ($length(element, $$$TAB)=2) {
			if ((status="M") || (status="U"))  {
				set modified = modified _ $lb(file)
			} elseif (status="A") {
				set added = added _ $lb(file)
			} elseif (status="D") {
				set deleted = deleted _ $lb(file)
			} else {
				throw ##class(%Exception.General).%New("INVALID DIFF STATUS: " _ status)
			}
		} elseif ($length(element, $$$TAB)=3) {
			set newFile = $piece(element, $c(9), 3)
			if (status="C")  {
				set added = added _ $lb(newFile)
			} elseif (status="R") {
				set added = added _ $lb(newFile)
				set deleted = deleted _ $lb(file)	
			} else {
				throw ##class(%Exception.General).%New("INVALID DIFF STATUS: " _ status)
			}
		} else {
			throw ##class(%Exception.General).%New("INVALID DIFF LINE: " _ element)
		}
	}
}

/// Determine if the file is neede for git diff 
ClassMethod isRelevantFile(dir As %String, file As %String) As %Boolean
{
	set ext = $select($length(file, ".")=1:"", 1:$piece(file, ".", *))
	quit $lf(##class(isc.git.Settings).getSetting("ext"), ext)>0
}

}

