<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/farcry/richTextEditor.cfm,v 1.8 2003/11/29 09:45:49 paul Exp $
$Author: paul $
$Date: 2003/11/29 09:45:49 $
$Name: milestone_2-1-2 $
$Revision: 1.8 $

|| DESCRIPTION || 
$Description: Displays an editor for long text input. Based on config settings unless in toggle mode which will display a basic html text area$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfsetting enablecfoutputonly="yes">

<cfimport taglib="/farcry/farcry_core/tags/farcry" prefix="tags">
<cfparam name="attributes.textareaname" default="body">

<!--- check if toggled to text area otherwise use config defined editor --->
<cfif isdefined("session.toggleTextArea") and session.toggleTextArea eq 1>
	<!--- javascript for inserting images etc --->
	<cfoutput>
		<script language="JavaScript">
		function insertHTML( html,field )
		{
			editform.#attributes.textareaname#.value = editform.#attributes.textareaname#.value + (html);
		}
		</script> 
	</cfoutput>
	<!--- display text area --->
	<cfoutput><textarea name="#attributes.textareaname#" cols="60" rows="20">#caller.output[attributes.textareaname]#</textarea></cfoutput>	
	
<cfelse>
	
	<!--- work out which editor to display --->
	<cfswitch expression="#application.config.general.richTextEditor#">
		
		<cfcase value="soEditorPro">
			<!--- javascript for inserting images etc --->
			<cfoutput>
				<script language="JavaScript">
				function insertHTML( html )
				{
					soEditorbody.insertText(html, '', true,true);
				}
				</script> 
			</cfoutput>
			
			<!--- display tag --->
			<tags:soEditor_pro 
				form="editform" 
				field="#attributes.textareaname#" 
				scriptpath="#application.url.farcry#/siteobjects/soeditor/pro/"
				html="#caller.output[attributes.textareaname]#" 
				width="#application.config.soEditorPro.width#"
				height="#application.config.soEditorPro.height#"
				cols="#application.config.soEditorPro.cols#"
				rows="#application.config.soEditorPro.rows#"
				pageedit="#application.config.soEditorPro.pageedit#"
				singlespaced="#application.config.soEditorPro.singlespaced#"
				wordcount="#application.config.soEditorPro.wordcount#"
				baseurl="#application.config.soEditorPro.baseurl#"
				basefont="#application.config.soEditorPro.basefont#"
				basefontsize="#application.config.soEditorPro.basefontsize#"
				basefontcolor="#application.config.soEditorPro.basefontcolor#"
				basebgcolor="#application.config.soEditorPro.basebgcolor#"
				validateonsave="#application.config.soEditorPro.validateonsave#"
				validationmessage="#application.config.soEditorPro.validationmessage#"
				showborders="#application.config.soEditorPro.showborders#"
				initialfocus="#application.config.soEditorPro.initialfocus#"
				new="#application.config.soEditorPro.new#"
				save="#application.config.soEditorPro.save#"
				cut="#application.config.soEditorPro.cut#"
				copy="#application.config.soEditorPro.copy#"
				paste="#application.config.soEditorPro.paste#"
				delete="#application.config.soEditorPro.delete#"
				find="#application.config.soEditorPro.find#"
				undo="#application.config.soEditorPro.undo#"
				redo="#application.config.soEditorPro.redo#"
				hr="#application.config.soEditorPro.hr#"
				image="#application.config.soEditorPro.image#"
				link="#application.config.soEditorPro.link#"
				unlink="#application.config.soEditorPro.unlink#"
				spellcheck="#application.config.soEditorPro.spellcheck#"
				help="#application.config.soEditorPro.help#"
				align="#application.config.soEditorPro.align#"
				list="#application.config.soEditorPro.list#"
				unindent="#application.config.soEditorPro.unindent#"
				indent="#application.config.soEditorPro.indent#"
				fontdialog="#application.config.soEditorPro.fontdialog#"
				format="#application.config.soEditorPro.format#"
				formatlist="#application.config.soEditorPro.formatlist#"
				formatlistlabels="#application.config.soEditorPro.formatlistlabels#"
				font="#application.config.soEditorPro.font#"
				fontlist="#application.config.soEditorPro.fontlist#"
				fontlistlabels="#application.config.soEditorPro.fontlistlabels#"
				size="#application.config.soEditorPro.size#"
				sizelist="#application.config.soEditorPro.sizelist#"
				sizelistlabels="#application.config.soEditorPro.sizelistlabels#"
				bold="#application.config.soEditorPro.bold#"
				italic="#application.config.soEditorPro.italic#"
				underline="#application.config.soEditorPro.underline#"
				superscript="#application.config.soEditorPro.superscript#"
				fgcolor="#application.config.soEditorPro.fgcolor#"
				bgcolor="#application.config.soEditorPro.bgcolor#"
				tables="#application.config.soEditorPro.tables#"
				insertcell="#application.config.soEditorPro.insertcell#"
				deletecell="#application.config.soEditorPro.deletecell#"
				insertrow="#application.config.soEditorPro.insertrow#"
				deleterow="#application.config.soEditorPro.deleterow#"
				insertcolumn="#application.config.soEditorPro.insertcolumn#"
				deletecolumn="#application.config.soEditorPro.deletecolumn#"
				splitcell="#application.config.soEditorPro.splitcell#"
				mergecell="#application.config.soEditorPro.mergecell#"
				cellprop="#application.config.soEditorPro.cellprop#"
				htmledit="#application.config.soEditorPro.htmledit#"
				borders="#application.config.soEditorPro.borders#"
				details="#application.config.soEditorPro.details#"
				anchor = "#application.config.soEditorPro.details#"
				specialCharacter = "#application.config.soEditorPro.specialCharacter#"
				allowFolderCreation = "#application.config.soEditorPro.allowFolderCreation#"
				allowUpload = "#application.config.soEditorPro.allowUpload#"
				autoSweep = "#application.config.soEditorPro.autoSweep#"
				baseCSS = "#application.config.soEditorPro.baseCSS#"
				codeSweeper = "#application.config.soEditorPro.codeSweeper#"
				cssList = "#application.config.soEditorPro.cssList#"
				cssListLabels = "#application.config.soEditorPro.cssListLabels#" 
				cssField = "#application.config.soEditorPro.cssField#"
				formButton = "#application.config.soEditorPro.formButton#"
				genericForm = "#application.config.soEditorPro.genericForm#"
				hiddenBox = "#application.config.soEditorPro.hiddenBox#"
				mailForm  = "#application.config.soEditorPro.mailForm#"
				radioBox = "#application.config.soEditorPro.radioBox#"
				resetButton = "#application.config.soEditorPro.resetButton#"
				selectBox = "#application.config.soEditorPro.selectBox#"
				styleList = "#application.config.soEditorPro.styleList#"
				styleListLabels = "#application.config.soEditorPro.styleListLabels#"
				submitButton = "#application.config.soEditorPro.submitButton#"
				textArea = "#application.config.soEditorPro.textArea#"
				textBox = "#application.config.soEditorPro.textBox#">
		</cfcase>
		
		<cfcase value="soEditor">
		
			<!--- javascript for inserting images etc --->
			<cfoutput>
				<script language="JavaScript">
				function insertHTML( html )
				{
					soEditorbody.insertText(html, '', true,true);
				}
				</script> 
			</cfoutput>
			
			<!--- display tag --->
			<tags:soEditor_lite 
				form="editform" 
				field="#attributes.textareaname#" 
				scriptpath="#application.url.farcry#/siteobjects/soeditor/lite/"
				html="#caller.output[attributes.textareaname]#"
				width="#application.config.soEditor.width#"
				height="#application.config.soEditor.height#"
				cols="#application.config.soEditor.cols#"
				rows="#application.config.soEditor.rows#"
				pageedit="#application.config.soEditor.pageedit#"
				singlespaced="#application.config.soEditor.singlespaced#"
				wordcount="#application.config.soEditor.wordcount#"
				baseurl="#application.config.soEditor.baseurl#"
				basefont="#application.config.soEditor.basefont#"
				basefontsize="#application.config.soEditor.basefontsize#"
				basefontcolor="#application.config.soEditor.basefontcolor#"
				basebgcolor="#application.config.soEditor.basebgcolor#"
				validateonsave="#application.config.soEditor.validateonsave#"
				validationmessage="#application.config.soEditor.validationmessage#"
				showborders="#application.config.soEditor.showborders#"
				initialfocus="#application.config.soEditor.initialfocus#"
				new="#application.config.soEditor.new#"
				save="#application.config.soEditor.save#"
				cut="#application.config.soEditor.cut#"
				copy="#application.config.soEditor.copy#"
				paste="#application.config.soEditor.paste#"
				delete="#application.config.soEditor.delete#"
				find="#application.config.soEditor.find#"
				undo="#application.config.soEditor.undo#"
				redo="#application.config.soEditor.redo#"
				hr="#application.config.soEditor.hr#"
				image="#application.config.soEditor.image#"
				link="#application.config.soEditor.link#"
				unlink="#application.config.soEditor.unlink#"
				spellcheck="#application.config.soEditor.spellcheck#"
				help="#application.config.soEditor.help#"
				align="#application.config.soEditor.align#"
				list="#application.config.soEditor.list#"
				unindent="#application.config.soEditor.unindent#"
				indent="#application.config.soEditor.indent#"
				fontdialog="#application.config.soEditor.fontdialog#"
				format="#application.config.soEditor.format#"
				formatlist="#application.config.soEditor.formatlist#"
				formatlistlabels="#application.config.soEditor.formatlistlabels#"
				font="#application.config.soEditor.font#"
				fontlist="#application.config.soEditor.fontlist#"
				fontlistlabels="#application.config.soEditor.fontlistlabels#"
				size="#application.config.soEditor.size#"
				sizelist="#application.config.soEditor.sizelist#"
				sizelistlabels="#application.config.soEditor.sizelistlabels#"
				bold="#application.config.soEditor.bold#"
				italic="#application.config.soEditor.italic#"
				underline="#application.config.soEditor.underline#"
				superscript="#application.config.soEditor.superscript#"
				fgcolor="#application.config.soEditor.fgcolor#"
				bgcolor="#application.config.soEditor.bgcolor#"
				tables="#application.config.soEditor.tables#"
				insertcell="#application.config.soEditor.insertcell#"
				deletecell="#application.config.soEditor.deletecell#"
				insertrow="#application.config.soEditor.insertrow#"
				deleterow="#application.config.soEditor.deleterow#"
				insertcolumn="#application.config.soEditor.insertcolumn#"
				deletecolumn="#application.config.soEditor.deletecolumn#"
				splitcell="#application.config.soEditor.splitcell#"
				mergecell="#application.config.soEditor.mergecell#"
				cellprop="#application.config.soEditor.cellprop#"
				htmledit="#application.config.soEditor.htmledit#"
				borders="#application.config.soEditor.borders#"
				details="#application.config.soEditor.details#"
				anchor="false">
		</cfcase>
		
		<cfcase value="eWebEditPro">
			<!--- javascript for inserting images etc --->
			<cfoutput>
				<script language="JavaScript">
				function insertHTML( html )
				{
					eWebEditPro.#application.config.eWebEditPro.editorName#.pasteHTML(html);
				}
				</script> 
			</cfoutput>
			<!---display tag--->
			<tags:eWebEditPro3
				path="#application.config.eWebEditPro.path#"
				maxContentSize="#application.config.eWebEditPro.maxContentSize#"
				name="#application.config.eWebEditPro.editorName#"
				editorName="#application.config.eWebEditPro.alternativeEditorName#"
				width="#application.config.eWebEditPro.width#"
				height="#application.config.eWebEditPro.height#"
				value="#caller.output[attributes.textareaname]#"
				license="#application.config.eWebEditPro.license#"
				locale="#application.config.eWebEditPro.locale#"
				config="#application.config.eWebEditPro.config#"
				styleSheet="#application.config.eWebEditPro.styleSheet#"
				bodyStyle="#application.config.eWebEditPro.bodyStyle#"
				hideAboutButton="#application.config.eWebEditPro.hideAboutButton#"
				onDblClickElement="#application.config.eWebEditPro.onDblClickElement#"
				onExecCommand="#application.config.eWebEditPro.onExecCommand#"
				onFocus="#application.config.eWebEditPro.onFocus#"
				onBlur="#application.config.eWebEditPro.onBlur#">
		</cfcase>
		
		<cfcase value="textArea">
		
			<!--- javascript for inserting images etc --->
			<cfoutput>
				<script language="JavaScript">
				function insertHTML( html,field )
				{
					editform.#attributes.textareaname#.value = editform.#attributes.textareaname#.value + (html);
				}
				</script> 
			</cfoutput>
			<!--- display text area --->
			<cfoutput><textarea name="#attributes.textareaname#" cols="60" rows="20">#caller.output[attributes.textareaname]#</textarea></cfoutput>
		</cfcase>
		
		<cfcase value="eopro">
		<cfoutput>
		<script language="javascript">
		<!--
		
			function scriptForm_onsubmit()
			{
				document.editform.#attributes.textareaname#.value = document.MyEditor.getHTMLData("http://");
				document.editform.submit();
			
			}
		
		   //-------------------------------------------------------------------------//
		   //The CSS-Data can not be loaded before HTMLData is completely loaded.
		   //Thats why "ONEDITORLOADED" and "ONDATALOADED" is used below
		   //-------------------------------------------------------------------------//
		   //This function is called when the applet has finished loading
		
			function loadData()
			{
			   document.MyEditor.setHTMLData("http://", document.editform.#attributes.textareaname#.value)
				
			}
		
		   //This function is called when the editor has finished the loading of HTMLData
			function setstyle()
			{
				document.MyEditor.setStyleSheet( document.editform.CSSText.value)
			}	
				
			function insertHTML( html,field )
			{
				document.MyEditor.insertHTMLData("http://", html);
				//editform.#attributes.textareaname#.value = editform.#attributes.textareaname#.value + (html);
			}
			
		
		
		//-->
		</script>
				
		
		<applet code="com.realobjects.eop.applet.EditorApplet" height="#application.config.eoPro.height#" id="editor" codebase="#application.config.eoPro.codebase#" name="MyEditor" width="#application.config.eoPro.width#" archive="edit-on-pro-signed.jar,tidy.jar,ssce.jar" mayscript>
        <param name="cabbase" value="#application.config.eoPro.cabbase#">
        <param name="locale" value="#application.config.eoPro.locale#">
        <param name="help"   value="#application.config.eoPro.help#">
        <param name="configurl"  value="#application.config.eoPro.configURL#">
        <param name="toolbarurl" value="#application.config.eoPro.toolbarurl#">
        <param name="sourceview" value="#application.config.eoPro.sourceview#">
        <param name="sourceviewwordwrap" value="#application.config.eoPro.sourceviewwordwrap#">
        <param name="bodyonly"  value="#application.config.eoPro.bodyonly#">
        <param name="smartindent" value="#application.config.eoPro.smartindent#">
        <param name="multipleundoredo" value="#application.config.eoPro.multipleundoredo#">
        <param name="oldfontstylemode" value="#application.config.eoPro.oldfontstylemode#">
        <param name="nbspfill" value="#application.config.eoPro.nbspfill#">
        <param name="customcolorsenabled" value="#application.config.eoPro.customcolorsenabled#">
        <param name="tablenbspfill" value="#application.config.eoPro.tablenbspfill#">
        <param name="inserttext_html" value="#application.config.eoPro.inserttext_html#">
        <param name="oneditorloaded" value="#application.config.eoPro.oneditorloaded#">
        <param name="ondataloaded" value="#application.config.eoPro.ondataloaded#">
        <!-- Applet Layout params -->
        <param name="windowfacecolor" value="#application.config.eoPro.windowfacecolor#">
        <param name="tabpaneactivecolor" value="#application.config.eoPro.tabpaneactivecolor#">
        <param name="windowhighlightcolor" value="#application.config.eoPro.windowhighlightcolor#">
        <param name="lightedgecolor" value="#application.config.eoPro.lightedgecolor#">
        <param name="darkedgecolor" value="#application.config.eoPro.darkedgecolor#">
        <param name="innertextcolor" value="#application.config.eoPro.innertextcolor#">
        <param name="startupscreenbackgroundcolor" value="#application.config.eoPro.startupscreenbackgroundcolor#">
        <param name="startupscreentextcolor" value="#application.config.eoPro.startupscreentextcolor#">
        <!-- End - Applet Layout params -->
		</applet>
		<textarea name="#attributes.textareaname#" cols="1" rows="1" style="visibility:hidden;">#caller.output[attributes.textareaname]#</textarea>
		</cfoutput>
		<cfif application.config.general.richTextEditor IS "eoPro">

    			<!--This hidden textarea field will receive the CSSData on submitting the form. Needed by RealObjects eoPro-->
				<cfset cssText = "">	
				
				<cfif fileExists(expandPath(application.config.eoPro.defaultcss))>
					<cffile action="read" file="#expandPath(application.config.eoPro.defaultcss)#" variable="cssText">
				</cfif>
				<!--- <cfset cssText = "h1{color:red}"> --->
				<cfoutput>
		    	<textarea name="CSSText" cols="1" rows="1" style="visibility:hidden;">#CSSText#</textarea>
				</cfoutput>
				

		</cfif>
		</cfcase>		
		
		
	</cfswitch>
</cfif>

<cfsetting enablecfoutputonly="no">