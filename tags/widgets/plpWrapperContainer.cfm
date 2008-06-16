<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
<farcry:deprecated message="widgets tag library is deprecated; please use formtools." />

<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
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
		<cfoutput><li class="li-prev"><a href="#plpActionURL("prev")#">#application.rb.getResource("Back")#</a></li></cfoutput>
	</cfif>

	<!--- Next button --->
	<cfif stepNext>
		<cfoutput><li class="li-next"><a href="#plpActionURL("next")#">#application.rb.getResource("NextUC")#</a></li></cfoutput>
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
		
		<cfoutput><a href="#plpActionURL("step:#arrayLen(caller.stPLP.Steps)#")#">#application.rb.getResource("save")#</a></cfoutput>
		
		<!--- <cfif stepComplete>
			<cfoutput></a></cfoutput>
		</cfif> --->
		
		<cfoutput></li></cfoutput>

		<!--- Cancel button --->
		<cfoutput><li class="li-cancel"></cfoutput>
		
		<cfif stepCancel>
			<cfoutput><a href="#plpActionURL("cancel")#"></cfoutput>
		</cfif>
		
		<cfoutput>#application.rb.getResource("cancel")#</cfoutput>
		
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
