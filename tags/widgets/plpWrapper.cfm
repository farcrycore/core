<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
<farcry:deprecated message="widgets tag library is deprecated; please use formtools." />

<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: $
$Author:  $
$Date: $
$Name:  $
$Revision: $

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
	
	<cfif arguments.action EQ "Cancel">
		<cfset returnURL = returnURL & "document.forms.#attributes.callingform#.submit();">
	<cfelse>
		<cfset returnURL = returnURL & "document.forms.#attributes.callingform#.buttonSubmit.click();">
	</cfif>

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
		<cfif application.types[caller.output.typename].bCustomType>
			<cfset iconTypename = "custom">
		<cfelse>
			<cfset iconTypename = "#Right(caller.output.typename,len(caller.output.typename)-2)#">
		</cfif>
		<cfoutput>
		<div id="plp-wrap">			
			<div class="pagination">
				<ul>#variables.paginationButtons#</ul>
			</div>
			<h1><img src="#application.url.farcry#/images/icons/#iconTypename#.png" alt="#iconTypename#" />#caller.output.label#</h1>			
			<div id="plp-nav">
				<ul>
		</cfoutput>

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
			<cfoutput><a href="#plpActionURL("cancel")#" onclick="return fPLPCancelConfirm();"></cfoutput>
		</cfif>
		
		<cfoutput>#application.rb.getResource("cancel")#</cfoutput>
		
		<cfif stepCancel>
			<cfoutput></a></cfoutput>
		</cfif>
		
		<cfoutput></li></cfoutput>
		
		<cfoutput>
				</ul>
			</div>

			<div id="plp-content">
		</cfoutput>
	</cfcase>
<!--- /PLP Wrapper Start --->

<!--- PLP Wrapper End --->
	<cfcase value="end">
		<cfoutput>
			</div>
			
			<hr class="clear hidden" />
			
			<div class="pagination pg-bot">
				<ul>#variables.paginationButtons#</ul>
			</div>
		
		</div>
		</cfoutput>
	</cfcase>
<!--- /PLP Wrapper End --->
</cfswitch>

<!--- confirm cancel function --->
<cfoutput>
	<script type="text/javascript">
		function fPLPCancelConfirm(){
			return window.confirm("Changes made will not be saved.\nDo you still wish to Cancel?");
		}
	</script>
</cfoutput>

<cfsetting enablecfoutputonly="no">
