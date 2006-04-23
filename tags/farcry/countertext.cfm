<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/farcry/countertext.cfm,v 1.2.6.1 2005/05/03 05:55:50 guy Exp $
$Author: guy $
$Date: 2005/05/03 05:55:50 $
$Name: milestone_2-3-2 $
$Revision: 1.2.6.1 $

|| DESCRIPTION || 
Custom tag that creates a TextArea Form Field with
adjoining Disabled Input Box that contains the number of
characters remaining that can be entered into the TextArea Form Field.

|| DEVELOPER ||
M (m@daemon.com.au)

|| ATTRIBUTES ||
in: FormName : REQUIRED: Name of the form containing the Text box (Case Sensitive) 
in:	FieldName : REQUIRED: Name of the field (Case Sensitive)
in:	FieldValue : Default value of the field.
in:	Counter: Total number of characters allowed in the Field.
in:	Default Style: CSS Style to be used
out:

ChangeLog: 
04/09/05 - By Emanuel Costa (emanuel@fortaleza.net): Add support for firefox (change innertext to innerhtml;
04/09/05 - By Emanuel Costa (emanuel@fortaleza.net): Add cfsavecontent and cfhtmlhead to display content on the head portion of the html document;
--->

<cfsetting enablecfoutputonly="Yes">

<cfparam name="Attributes.FormName">
<cfparam name="Attributes.FieldName">
<cfparam name="ATTRIBUTES.FieldValue" default="">
<cfparam name="ATTRIBUTES.Counter" default="255">
<cfparam name="ATTRIBUTES.DefaultStyle" default="Yes">


<cfset InitialCounter = Len(Attributes.FieldValue)>

<!--- check for browser type --->
<!--- 
TODO
build generic/universal methods for browser detection and browser 
alternatives for entire UI library
 --->

<cfif CGI.HTTP_USER_AGENT contains "MSIE" or CGI.HTTP_USER_AGENT contains "gecko">
	<cfset bIsGoodBrowser = "1">
<cfelse>
	<cfset bIsGoodBrowser = "0">
</cfif>
<cfsavecontent variable="variables.counterTextHeadContent">
<cfif Attributes.DefaultStyle>
<cfoutput>
	<style type="text/css">
		##dm_ct_container_#Attributes.FormName#_#Attributes.FieldName# {
			width: 100%;
		}
		##dm_ct_text_#Attributes.FormName#_#Attributes.FieldName# {
			font-size: 8px;
			margin-bottom: 0;
			text-align: right;
		}
		##dm_ct_countDown_#Attributes.FormName#_#Attributes.FieldName# {
			border-style: none;
			border-width: 1px;
		}
		##dm_ct_textbox_#Attributes.FormName#_#Attributes.FieldName# {
			margin: 0;
			width: 400px;
		}
	</style>
</cfoutput>
	
<cfif not isdefined("request.dm_counter_text_function_is_already_outputted")>
	<cfset request.dm_counter_text_function_is_already_outputted = true>
	<cfoutput>
	<script type="text/javascript">
	<!--  to hide script contents from old browsers
	function UpdateCounter(FormName, FieldName)
	{
		counter = (window.document.forms[FormName][FieldName].value.length);
		
		if (counter < #Attributes.Counter#)
		{
		<cfif bIsGoodBrowser>
			//eval("dm_ct_countDown_" + FormName + "_" + FieldName).innerText = counter;
			var frmCounterField = "dm_ct_countDown_" + FormName + "_" + FieldName;
			document.getElementById(frmCounterField).innerHTML = counter;
		<cfelse>
			window.document.forms[FormName][FieldName].value = counter;
			oldvalue = window.document.forms[FormName][FieldName].value;
		</cfif>
		}
		else
		{
		<cfif bIsGoodBrowser>
			<!--- (8:Backspace) (45:Insert) (46:Delete) (33-40:Up,Down,Left,Right,PgUp,PgDown,Home,End) --->
			if (!(event.keyCode == "8" || event.keyCode == "46" || (event.keyCode >= "33" && event.keyCode <= "40"))) {
				event.returnValue=false;
			}
			//eval("dm_ct_countDown_" + FormName + "_" + FieldName).innerText = "#Attributes.Counter#";
			var frmCounterField = "dm_ct_countDown_" + FormName + "_" + FieldName;
			document.getElementById(frmCounterField).innerHTML = "#Attributes.Counter#";
		<cfelse>
			if (counter > #Attributes.Counter#) {
					window.document.forms[FormName][FieldName].value = oldvalue;
			}
			window.document.forms[FormName][FieldName].value = "#Attributes.Counter#";
		</cfif>
		}
	}
	// end hiding contents from old browsers  -->
	</script>
	</cfoutput>
</cfif>
</cfif>
</cfsavecontent>
<cfhtmlhead text="#variables.counterTextHeadContent#">

<cfoutput>
	<div id="dm_ct_container_#Attributes.FormName#_#Attributes.FieldName#">
	<cfif bIsGoodBrowser>
		<p id="dm_ct_Text_#Attributes.FormName#_#Attributes.FieldName#"><span id="dm_ct_countDown_#Attributes.FormName#_#Attributes.FieldName#">0</span>/#Attributes.Counter#</p>
	<cfelse>
		<p id="dm_ct_Text_#Attributes.FormName#_#Attributes.FieldName#"><input id="dm_ct_countDown_#Attributes.FormName#_#Attributes.FieldName#" disabled type="text" name="counter" size="#len(Attributes.Counter)#" value="#Attributes.Counter# characters Max">/#Attributes.Counter#</p>
	</cfif>
	
	<textarea id="dm_ct_textbox_#Attributes.FormName#_#Attributes.FieldName#" cols="40" rows="8" name="#ATTRIBUTES.FieldName#" onkeydown="javascript:UpdateCounter('#Attributes.FormName#', '#Attributes.FieldName#')" onkeyup="javascript:UpdateCounter('#Attributes.FormName#', '#Attributes.FieldName#')">#ATTRIBUTES.FieldValue#</textarea>
	</div>

	<script type="text/javascript">
	<!--  to hide script contents from old browsers
		UpdateCounter('#Attributes.FormName#','#Attributes.FieldName#');
	// end hiding contents from old browsers  -->
	</script>


</cfoutput>
<cfsetting enablecfoutputonly="no">


