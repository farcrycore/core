<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/farcry/plpNavigationButtons.cfm,v 1.8 2005/09/02 05:43:00 guy Exp $
$Author: guy $
$Date: 2005/09/02 05:43:00 $
$Name: milestone_3-0-1 $
$Revision: 1.8 $

|| DESCRIPTION || 
$Description: Displays plp navigation (previous/next.dropdown)$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: callingform,onClick,bDropDown,cancelEvent$
$out:$
--->
<cfsetting enablecfoutputonly="yes">

<cfprocessingDirective pageencoding="utf-8">

<cfparam name="attributes.callingform" default="editform">
<cfparam name="ATTRIBUTES.onClick" default="">
<cfparam name="ATTRIBUTES.bDropDown" default="true">
<!--- initialise optional value for when cancel button is clicked --->
<cfparam name="attributes.cancelEvent" default="">

	<cfoutput>
	<!-- Begin : PLP Navigation Buttons -->
	<div id="PLPMoveButtons" style="margin-top:10px; text-align : center;">
	</cfoutput>

	<!--- as long as we're not the first step, enable back button --->
	<cfif Caller.thisstep.name NEQ CALLER.stPLP.Steps[1].name>
		<cf_dmButton name="Back" value="&lt;&lt; #application.adminBundle[session.dmProfile.locale].Back#" width="80" onClick="#ATTRIBUTES.onClick#">
	<cfelse>
		<cf_dmButton name="Back" value="&lt;&lt; #application.adminBundle[session.dmProfile.locale].Back#" width="80" onClick="#ATTRIBUTES.onClick#" disabled="true">
	</cfif>
	
	
	<cfoutput><input type="hidden" name="QuickNav"></cfoutput>
	<cfif attributes.bDropDown>
		<cfoutput><select name="Navigation" onchange="javascript:window.document.forms.#attributes.callingform#.QuickNav.value='yes';#ATTRIBUTES.onClick#;submit()" class="formfield">
		<!--- abs to order things above 9 in the plp --->
		<cfloop index="i" from="1" to="#ArrayLen(CALLER.stPLP.Steps)#">
			<option value="#CALLER.stPLP.Steps[i].name#"<cfif CALLER.thisstep.name EQ CALLER.stPLP.Steps[i].name> selected="selected"</cfif>>#CALLER.stPLP.Steps[i].name#</option>
		</cfloop>
		<!--- /abs --->
		</select></cfoutput>
	</cfif>

<cfif Caller.thisstep.name NEQ CALLER.stPLP.Steps[#arraylen(CALLER.stPLP.Steps)# -1].name>
	<cf_dmButton name="Submit" value="#application.adminBundle[session.dmProfile.locale].nextUC# &gt;&gt;" width="80" onClick="#ATTRIBUTES.onClick#">
<cfelse>
	<cf_dmButton name="Submit" value="#application.adminBundle[session.dmProfile.locale].finish# &gt;&gt;" width="80" onClick="#ATTRIBUTES.onClick#">
</cfif>
	<cfoutput>
	<br><br>
	<cf_dmButton name="Save" value="#application.adminBundle[session.dmProfile.locale].save#" width="80">

	<cfif attributes.cancelEvent neq "">
		<input type="button" value="#application.adminBundle[session.dmProfile.locale].cancel#" width="80" onClick="document.location.href='#attributes.cancelEvent#'" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';">
	<cfelse>
		<!--- if dmHTML run synchTab function --->
		<cfif isdefined("caller.output.typename") and caller.output.typename eq "dmHTML">
			<cf_dmButton name="Cancel" value="#application.adminBundle[session.dmProfile.locale].cancel#" width="80" onClick="parent.synchTab('editFrame','activesubtab','subtab','siteEditOverview');parent.synchTitle('Overview')">
		<cfelse>
			<cf_dmButton name="Cancel" value="#application.adminBundle[session.dmProfile.locale].cancel#" width="80">
		</cfif>
	</cfif>
	
	</div>
	<!-- END : PLP Navigation Buttons -->
	</cfoutput>
	
<cfsetting enablecfoutputonly="No">
