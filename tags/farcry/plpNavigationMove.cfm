<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/farcry/plpNavigationMove.cfm,v 1.3 2003/07/04 07:59:43 daniela Exp $
$Author: daniela $
$Date: 2003/07/04 07:59:43 $
$Name: b131 $
$Revision: 1.3 $

|| DESCRIPTION || 
Works out where to go next during plp

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in: 
out:
--->
<cfsetting enablecfoutputonly="yes">


<cfif IsDefined("CALLER.FORM.Submit")>
	<cfscript>
		CALLER.thisstep.isComplete = 1;
		CALLER.thisstep.advance = 1;
	</cfscript>

<cfelseif isDefined("CALLER.FORM.submitGoToSpecifiedStep")>
	<!--- user needs to be directed to a specific page --->
	<cfif isNumeric(CALLER.FORM.goToStep)>
		<!--- the plp step number has been passed, force the 'next' page to be this step number --->
		<cfscript>
			CALLER.thisstep.nextstep = CALLER.stPLP.Steps[#goToStep#].name;
		</cfscript>	
	</cfif>
	<!--- move it along to the 'next' step that you have specified --->
	<cfscript>
		CALLER.thisstep.isComplete = 1;
		CALLER.thisstep.advance = 1;
	</cfscript>

<cfelseif isdefined("caller.form.cancel")>
	<!--- try to unlock object --->
	<cftry>
		<cfinvoke component="#application.packagepath#.farcry.locking" method="unlock" returnvariable="unlockRet">
			<cfinvokeargument name="objectId" value="#caller.output.objectid#"/>
			<cfinvokeargument name="typename" value="#caller.output.typename#"/>
		</cfinvoke>
		<cfcatch></cfcatch>
	</cftry>
	
	<!--- if dmHTML update tabs --->
	<cfif caller.output.typename eq "dmHTML">
		<script>
			document.getallbyId.siteEditOverview.className = activeTabClass;
		</script>
	</cfif>
	
	<!--- relocate to cancel location --->
	<cftry>
		<cflocation url="#CALLER.attributes.cancelLocation#" addtoken="no">
		<cfcatch>
			<!--- if no cancel location specified try to go to generic admin page --->
			<cflocation url="#application.url.farcry#/navajo/genericAdmin.cfm?typename=#caller.output.typename#" addtoken="no">
		</cfcatch>
	</cftry>		
<cfelseif isdefined("caller.form.save")>
	<!--- save plp and return to current step --->
	<cfscript>
		CALLER.thisstep.isComplete = 1;
		CALLER.thisstep.nextStep = CALLER.thisstep.name;
		CALLER.thisstep.advance = 1;
	</cfscript>
<cfelseif IsDefined("CALLER.FORM.Back")>
	<cfscript>
		PrevStep = "";
	</cfscript>
	<cfloop index="i" from="1" to="#ArrayLen(CALLER.stPLP.Steps)#">
		<cfscript>
		if (CALLER.thisstep.name EQ CALLER.stPLP.Steps[i].name AND Len(PrevStep)) {
			CALLER.thisstep.nextStep = PrevStep;
		}
		PrevStep = CALLER.stPLP.Steps[i].name;
		</cfscript>
	</cfloop>
	<cfscript>
		CALLER.thisstep.isComplete = 1;
		CALLER.thisstep.advance = 1;
	</cfscript>
<cfelseif IsDefined("CALLER.FORM.QuickNav") AND CALLER.FORM.QuickNav EQ "Yes">
	<cfscript>
		CALLER.thisstep.nextStep = CALLER.FORM.Navigation;
		CALLER.thisstep.advance = 1;
		CALLER.thisstep.isComplete = 1;
	</cfscript>
<cfelseif isdefined("url.step")>
	<cfscript>
		CALLER.thisstep.isComplete = 1;
		CALLER.thisstep.nextStep = url.step;
		CALLER.thisstep.advance = 1;
	</cfscript>
</cfif>

<cfsetting enablecfoutputonly="no">