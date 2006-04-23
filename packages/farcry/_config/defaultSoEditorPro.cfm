<cfset stStatus = StructNew()>
<cfset stConfig = StructNew()>
<cfset aTmp = ArrayNew(1)>

<cfscript>
stConfig.width = "100%"; 
stConfig.height = "80%"; 
stConfig.cols = "60"; 
stConfig.rows = "10"; 
stConfig.pageedit = "false"; 
stConfig.singlespaced = "false"; 
stConfig.wordcount = "true"; 
stConfig.baseurl = "http://#cgi.HTTP_HOST#/#application.url.webroot#"; 
stConfig.basefont = ""; 
stConfig.basefontsize = ""; 
stConfig.basefontcolor = ""; 
stConfig.basebgcolor = ""; 
stConfig.validateonsave = "false"; 
stConfig.validationmessage = ""; 
stConfig.showborders = "false"; 
stConfig.initialfocus = "false"; 
stConfig.new = "false"; 
stConfig.save = "false"; 
stConfig.cut = "true"; 
stConfig.copy = "true"; 
stConfig.paste = "true"; 
stConfig.delete = "true"; 
stConfig.find = "true"; 
stConfig.undo = "true"; 
stConfig.redo = "true"; 
stConfig.hr = "true"; 
stConfig.image = "true"; 
stConfig.link = "true"; 
stConfig.unlink = "true"; 
stConfig.spellcheck = "false"; 
stConfig.help = "true"; 
stConfig.align = "true"; 
stConfig.list = "true"; 
stConfig.unindent = "true"; 
stConfig.indent = "true"; 
stConfig.fontdialog = "false"; 
stConfig.format = "true"; 
stConfig.formatlist = "none,h1,h2,h3,h4,h5,h6,pre"; 
stConfig.formatlistlabels = "Normal,Heading 1,Heading 2,Heading 3,Heading 4,Heading 5,
				Heading 6,Formatted"; 
stConfig.font = "false"; 
stConfig.fontlist = "Arial,Tahoma,Courier New,Times New Roman,Verdana,Wingdings"; 
stConfig.fontlistlabels = "Arial,Tahoma,Courier New,Times New Roman,Verdana,Wingdings"; 
stConfig.size = "false"; 
stConfig.sizelist = "1,2,3,4,5,6,7"; 
stConfig.sizelistlabels = "1,2,3,4,5,6,7"; 
stConfig.bold = "true"; 
stConfig.italic = "true"; 
stConfig.underline = "true"; 
stConfig.superscript = "true"; 
stConfig.fgcolor = "true"; 
stConfig.bgcolor = "true"; 
stConfig.tables = "true"; 
stConfig.insertcell = "true"; 
stConfig.deletecell = "true"; 
stConfig.insertrow = "true"; 
stConfig.deleterow = "true"; 
stConfig.insertcolumn = "true"; 
stConfig.deletecolumn = "true"; 
stConfig.splitcell = "true"; 
stConfig.mergecell = "true"; 
stConfig.cellprop = "true"; 
stConfig.htmledit = "true"; 
stConfig.borders = "true"; 
stConfig.details = "true"; 
//soEditoPro only features
stConfig.anchor = "true";
stConfig.specialCharacter = "true";
stConfig.allowFolderCreation = "false";
stConfig.allowUpload = "false";
stConfig.autoSweep = "false";
stConfig.baseCSS = "/css/dmStyle.css";
stConfig.codeSweeper = "true";
stConfig.cssList = "";
stConfig.cssListLabels = ""; 
stConfig.cssField = "style";
stConfig.formButton = "false";
stConfig.genericForm = "false";
stConfig.hiddenBox = "false";
stConfig.mailForm  = "false";
stConfig.mergeCell = "false";
stConfig.radioBox = "false";
stConfig.resetButton = "false";
stConfig.selectBox = "false";
stConfig.styleList = "title,subtitle,contentbody,description";
stConfig.styleListLabels ="Title,SubTitle,Content,Description";
stConfig.submitButton = "false";
stConfig.textArea = "false";
stConfig.textBox = "false";
</cfscript>

<cfwddx action="CFML2WDDX" input="#stConfig#" output="wConfig">

<cftry>
	<cfquery datasource="#stArgs.dsn#" name="qDelete">
		delete from #application.dbowner#config
		where configname = '#stArgs.configName#'
	</cfquery>
	
	<cfquery datasource="#stArgs.dsn#" name="qUpdate">
		INSERT INTO #application.dbowner#config
		(configName, wConfig)
		VALUES
		('#stArgs.configName#', '#wConfig#')
	</cfquery>

	<cfset stStatus.message = "#stArgs.configName# created successfully">
	<cfcatch>
		<cfset stStatus.message = cfcatch.message>
		<cfset stStatus.detail = cfcatch.detail>
	</cfcatch>
</cftry>