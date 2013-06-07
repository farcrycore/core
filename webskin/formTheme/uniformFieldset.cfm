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
<!--- @@displayname: Render a form fieldset --->
<!--- @@description: Renders the fieldset with correct classes  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag...">
</cfif>

<cfparam name="attributes.legend" default=""><!--- The legend of the fieldset if required. --->
<cfparam name="attributes.style" default=""><!--- The style to apply to the fieldset. --->
<cfparam name="attributes.helpTitle" default=""><!--- The helping title for the fieldset. --->
<cfparam name="attributes.helpSection" default=""><!--- The helping text for the fieldset. --->


<cfif thistag.ExecutionMode eq "start">
	<!--- Do Nothing --->
</cfif>



<cfif thistag.ExecutionMode eq "end">

	<cfset innerHTML = "" />
	<cfif len(thisTag.generatedContent)>
		<cfset innerHTML = thisTag.generatedContent />
		<cfset thisTag.generatedContent = "" />
	</cfif>
	
	<cfoutput><fieldset class="fieldset" style="#trim(attributes.style)#"></cfoutput>
	
	<cfif len(attributes.legend)>
		<cfoutput><h2 class="legend">#trim(attributes.legend)#</h2></cfoutput>
	</cfif>
	
	<cfif len(attributes.helpSection)>
		<cfoutput>
        	<div class="helpsection">
				<cfif len(attributes.helpTitle)>
					<h4>#attributes.helpTitle#</h4>
				</cfif>
				<p>#attributes.helpSection#</p>
			</div>	
        </cfoutput>
	</cfif>
	
	<cfoutput>#innerHTML#</cfoutput>	
	
	<cfoutput></fieldset></cfoutput>
</cfif>

