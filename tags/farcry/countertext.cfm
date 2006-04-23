<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/farcry/countertext.cfm,v 1.4 2005/06/22 05:39:26 guy Exp $
$Author: guy $
$Date: 2005/06/22 05:39:26 $
$Name: milestone_3-0-0 $
$Revision: 1.4 $

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

<cfif Attributes.DefaultStyle>
	<cfif NOT isdefined("request.dm_counter_text_function_is_already_outputted")>
	<cfset request.dm_counter_text_function_is_already_outputted = true>
	<cfoutput>
	<script type="text/javascript">
	<!--  to hide script contents from old browsers
	function UpdateCounter(FormName, FieldName) {
		counter = (window.document.forms[FormName][FieldName].value.length);
		if (counter < #Attributes.Counter#){
		<cfif bIsGoodBrowser>
			objCounter = document.getElementById("dm_ct_countDown_" + FormName + "_" + FieldName);
			objCounter.innerText = counter;
			objCounter.innerHTML = counter;
		<cfelse>
			window.document.forms[FormName][FieldName].value = counter;
			oldvalue = window.document.forms[FormName][FieldName].value;
		</cfif>
		} else {
		<cfif bIsGoodBrowser>
			<!--- (8:Backspace) (45:Insert) (46:Delete) (33-40:Up,Down,Left,Right,PgUp,PgDown,Home,End) --->
			if (!(event.keyCode == "8" || event.keyCode == "46" || (event.keyCode >= "33" && event.keyCode <= "40"))) {
				event.returnValue=false;
			}
			objCounter = document.getElementById("dm_ct_countDown_" + FormName + "_" + FieldName);
			objCounter.innerText = "#Attributes.Counter#";
			objCounter.innerHTML = "#Attributes.Counter#";
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

<cfoutput>
	
	<div id="dm_ct_container_#Attributes.FormName#_#Attributes.FieldName#">
	<textarea id="dm_ct_textbox_#Attributes.FormName#_#Attributes.FieldName#" cols="40" rows="5" name="#ATTRIBUTES.FieldName#" onkeydown="javascript:UpdateCounter('#Attributes.FormName#', '#Attributes.FieldName#')" onkeyup="javascript:UpdateCounter('#Attributes.FormName#', '#Attributes.FieldName#')">#ATTRIBUTES.FieldValue#</textarea>
	<cfif bIsGoodBrowser>
		<p id="dm_ct_Text_#Attributes.FormName#_#Attributes.FieldName#"><span id="dm_ct_countDown_#Attributes.FormName#_#Attributes.FieldName#">0</span>/#Attributes.Counter#</p>
	<cfelse>
		<p id="dm_ct_Text_#Attributes.FormName#_#Attributes.FieldName#"><input id="dm_ct_countDown_#Attributes.FormName#_#Attributes.FieldName#" disabled type="text" name="counter" size="#len(Attributes.Counter)#" value="#Attributes.Counter# characters Max">/#Attributes.Counter#</p>
	</cfif>
	</div>
	

	<script type="text/javascript">
	<!--  to hide script contents from old browsers
		UpdateCounter('#Attributes.FormName#','#Attributes.FieldName#');
	// end hiding contents from old browsers  -->
	</script>


</cfoutput>
<cfsetting enablecfoutputonly="no">


