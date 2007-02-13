<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/widgets/plpWrapperContainer.cfm,v 1.2 2005/09/09 07:29:21 pottery Exp $
$Author: pottery $
$Date: 2005/09/09 07:29:21 $
$Name: milestone_3-0-1 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: Displays plp header and footer $


|| DEVELOPER ||
$Developer: Ben Bishop (ben@daemon.com.au) $

|| ATTRIBUTES ||
$in:$
$out:$
--->

<cfsetting enablecfoutputonly="yes">

<cfprocessingDirective pageencoding="utf-8">

<cfparam name="attributes.callingForm" default="editform">
<cfparam name="attributes.onclick" default="">
<cfparam name="variables.stepPrev" default="true">
<cfparam name="variables.stepNext" default="true">
<cfparam name="variables.stepComplete" default="true">
<cfparam name="variables.stepCancel" default="true">
<cfparam name="attributes.bShowSideSteps" default="false">

<cfif (caller.thisstep.name EQ caller.stPLP.steps[1].name)>
	<cfset variables.stepPrev = false>
</cfif>

<cfif (caller.thisstep.name EQ caller.stPLP.steps[#arrayLen(caller.stPLP.steps)# - 1].name)>
	<cfset variables.stepNext = false>
</cfif>

<cffunction name="plpActionURL" returntype="string" hint="create the plpaction url">
	<cfargument name="action" required="true">
	<cfargument name="onclick" required="false" default="">

	<cfset var returnURL = "javascript:document.forms.#attributes.callingform#.plpAction.value='#arguments.action#';">
	<cfif Trim(arguments.onclick) NEQ "">
		<cfset returnURL = returnURL & "#attributes.onclick#;">
	</cfif>
	
	<cfset returnURL = returnURL & "document.forms.#attributes.callingform#.buttonSubmit.click();">

	<cfreturn returnURL>
</cffunction>

<!--- Pagination buttons (for top and bottom) --->
<cfsavecontent variable="variables.paginationButtons">
	<!--- Previous button --->
	<cfif stepPrev>
		<cfoutput><li class="li-prev"><a href="#plpActionURL("prev")#">#application.adminBundle[session.dmProfile.locale].Back#</a></li></cfoutput>
	</cfif>

	<!--- Next button --->
	<cfif stepNext>
		<cfoutput><li class="li-next"><a href="#plpActionURL("next")#">#application.adminBundle[session.dmProfile.locale].NextUC#</a></li></cfoutput>
	</cfif>
</cfsavecontent>

<!--- Display --->
<cfswitch expression="#thistag.executionmode#">
	<cfcase value="start">
		<cfoutput>
		<div id="plp-wrap">			
			<div class="pagination">
				<ul>#variables.paginationButtons#</ul>
			</div>
			<h1>#caller.output.label#</h1>			
		</cfoutput>
		<cfoutput>			
			<div id="plp-content">
		</cfoutput>
	</cfcase>
<!--- /PLP Wrapper Start --->

<!--- PLP Wrapper End --->
	<cfcase value="end">
		<cfoutput>
			</div>

			<div class="pagination pg-bot">
				<ul>#variables.paginationButtons#</ul>
			</div>
			
			<div id="plp-nav">
				<ul>
		</cfoutput>
		<cfif attributes.bShowSideSteps>
			<cfloop index="i" from="1" to="#arrayLen(caller.stPLP.Steps)#">
				<cfif NOT caller.stPLP.Steps[i].bFinishPLP>
					<cfoutput><li><a href="#plpActionURL("step:#i#")#"></cfoutput>
					
					<cfif caller.thisstep.name eq caller.stPLP.Steps[i].name>
						<cfoutput><strong></cfoutput>
					</cfif>
					
					<cfoutput>#caller.stPLP.Steps[i].name#</cfoutput>
					
					<cfif caller.thisstep.name eq caller.stPLP.Steps[i].name>
						<cfoutput></strong></cfoutput>
					</cfif>
					
					<cfoutput></a></li></cfoutput>
				</cfif>
			</cfloop>
		</cfif>
		<!--- Complete button --->
		<cfoutput><li class="li-complete"></cfoutput>
		
		<!--- <cfif stepComplete>
			<cfoutput><a href="#plpActionURL("complete")#"></cfoutput>
		</cfif> --->
		
		<cfoutput><a href="#plpActionURL("step:#arrayLen(caller.stPLP.Steps)#")#">#application.adminBundle[session.dmProfile.locale].save#</a></cfoutput>
		
		<!--- <cfif stepComplete>
			<cfoutput></a></cfoutput>
		</cfif> --->
		
		<cfoutput></li></cfoutput>

		<!--- Cancel button --->
		<cfoutput><li class="li-cancel"></cfoutput>
		
		<cfif stepCancel>
			<cfoutput><a href="#plpActionURL("cancel")#"></cfoutput>
		</cfif>
		
		<cfoutput>#application.adminBundle[session.dmProfile.locale].cancel#</cfoutput>
		
		<cfif stepCancel>
			<cfoutput></a></cfoutput>
		</cfif>
		
		<cfoutput></li></cfoutput>
		
		<cfoutput>
				</ul>
			</div>
			<hr class="clear hidden" />
			
			
		
		</div>
		</cfoutput>
	</cfcase>
<!--- /PLP Wrapper End --->
</cfswitch>

<cfsetting enablecfoutputonly="no">
