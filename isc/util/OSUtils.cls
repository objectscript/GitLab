Class isc.util.OSUtils
{

/// Create file name
/// If name os empty then random file would be created in a Temp directrory
/// If name is an extension then new filename would be created
/// If name is a filename, then this file would be created
/// stream - %Stream.FileBinary pointing to this file
/// content - write something into a file. Can be a stream or a string
/// 
/// Создать файл name
/// Если name не задан, то возвращается имя созданного файла (в папке Temp). 
/// Если name - расширение, то возвращается имя созданного файла (в папке Temp) с заданным расширением.
/// stream - стрим файла
/// content - строка или stream который записывается в файл
ClassMethod createFile(ByRef name As %String = "", Output stream As %Stream.FileBinary, content As %String) As %Status
{
	#dim sc As %Status = $$$OK
	
	if name="" {
		set name = ##class(%File).TempFilename()
	} elseif $length(name, ".")=1 {
		set name = ##class(%File).TempFilename(name)
	}
	
	set stream = ##class(%Stream.FileBinary).%New()
	set sc = stream.LinkToFile(name)
	
	if $data(content) {
		if $isObject(content) {
			set sc = stream.CopyFrom(content)
		} else {
			set sc = stream.Write(content)
		}
		quit:$$$ISERR(sc) sc
		set sc = stream.%Save()
		do stream.Rewind()
	}
	
	quit sc
}

/// Read file into string. Delete original file
/// Прочитать файл в строку
ClassMethod fileToString(name As %String, Output content As %String, delete As %Boolean = {$$$YES}) As %Status
{
	#dim sc As %Status = $$$OK
	set stream = ##class(%Stream.FileBinary).%New()
	set sc = stream.LinkToFile(name)
	
	set content = stream.Read($$$MaxStringLength)
	
	if delete {
		kill stream
		set sc = ..deleteFile(name)
	}
	
	quit sc
}

/// Delete file
/// Удалить файл
ClassMethod deleteFile(name As %String) As %Status
{
	#dim sc As %Status = $$$OK
	set success = ##class(%File).Delete(name, .code)
	set:success'=$$$YES sc = $$$ERROR($$$GeneralError, $$$FormatText("Error deleting file %1 with code %2", name, code))
	quit sc
}

/// Execute OS command
/// Выполнить команду ОС
ClassMethod execute(cmd, debug As %Boolean = {$$$NO}) As %Status
{
	#dim sc As %Status = $$$OK
	set code = ""
	//set out = ""
	write:debug !, "cmd: ", cmd
	//set sc = ##class(%Net.Remote.Utility).RunCommandViaZF(cmd, , .out, timeout, $$$YES, .code)
	set code = $zf(-1, cmd)
	write:debug !,"code: ", code
	
	if code'=0 {
		set sc1 = $$$ERROR($$$GeneralError, $$$FormatText("ОС command: `%1` exited with status: `%2`", cmd, code))
		set sc = $$$ADDSC(sc, sc1)	
	}
	return sc
}

}

