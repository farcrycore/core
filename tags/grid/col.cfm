<cfsetting enablecfoutputonly="true" />
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
<!--- @@displayname: Grid Column --->
<!--- @@description: Used to define a column of your grid.  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<cfparam name="application.stFarCryGrid" default="#structNew()#" />
<cfparam name="application.stFarCryGrid.cols" default="24" />

<cfparam name="request.stFarCryGrid" default="#structNew()#" />
<cfparam name="request.stFarCryGrid.aCols" default="#arrayNew(1)#" />
<cfparam name="request.stFarCryGrid.iCols" default="0" />


<cfif not arrayLen(request.stFarCryGrid.aCols)>
	<cfset stDefaultCol = structNew() />
	<cfset stDefaultCol.maxCols = application.stFarCryGrid.cols />
	<cfset stDefaultCol.totalUsed = 0 />
	<cfset arrayAppend(request.stFarCryGrid.aCols, stDefaultCol) />
</cfif>


<cfif thistag.executionMode eq "Start">
	<!--- layout div attributes --->
	<cfparam name="attributes.span" default="#application.stFarCryGrid.cols#" />
	<cfparam name="attributes.pct" default="0" />
	<cfparam name="attributes.bLast" default="false" />
	<cfparam name="attributes.prepend" default="0" />
	<cfparam name="attributes.append" default="0" />
	<cfparam name="attributes.push" default="0" />
	<cfparam name="attributes.pull" default="0" />
	<cfparam name="attributes.bAllowOverflow" default="false" /><!--- By default the css will set overflow-x to hidden. This fixes the problem where IE6 adds an extra 3px margin to two columns that are floated up against each other. --->
	
	<!--- Content div attributes. --->
	<cfparam name="attributes.id" default="" />
	<cfparam name="attributes.class" default="" />
	<cfparam name="attributes.style" default="" />
	<cfparam name="attributes.bLayoutOnly" default="false" /><!--- option to not include the content div --->
	

	<cfset request.stFarCryGrid.iCols = request.stFarCryGrid.iCols + 1 />
	<cfset variables.startCol = request.stFarCryGrid.iCols />
	
	<!--- LAST ITEM IN THE ARRAY IS THE CURRENT GRID ITEM --->
	<cfset stCol = duplicate(request.stFarCryGrid.aCols[arrayLen(request.stFarCryGrid.aCols)]) />
	<cfset stCol.id = attributes.id />
	
	<cfif  stCol.totalUsed GT stCol.maxCols >
		<cfabort showerror="Too May Columns have been defined." />
	</cfif>

	<cfif isNumeric(attributes.pct) AND attributes.pct GT 0 AND attributes.pct LTE 100>
		<cfset attributes.span = Ceiling(stCol.maxCols * (attributes.pct/100)) />
	</cfif>
	
	<cfif (stCol.totalUsed + attributes.span) GT stCol.maxCols>
		
		<cfset attributes.span = stCol.maxCols - stCol.totalUsed />
	</cfif>
	
	<cfset stCol.totalUsed = stCol.totalUsed + attributes.span + attributes.prepend + attributes.append />
	
	
	<cfif stCol.totalUsed EQ stCol.maxCols>
		<cfset attributes.bLast = true />
	</cfif>
	


	<cfset request.stFarCryGrid.aCols[arrayLen(request.stFarCryGrid.aCols)] = stCol />

	
	<!--- ADD AN ARRAY ITEM FOR ANY CHILDREN IN CASE THEIR ARE ANY --->
 	<cfset stChild = structNew() />
	<cfset stChild.maxCols = attributes.span />
	<cfset stChild.totalUsed = 0 />
	<cfset arrayAppend(request.stFarCryGrid.aCols, stChild) />
	
</cfif>



<cfif thistag.executionMode eq "End">

	<cfset arrayDeleteAt(request.stFarCryGrid.aCols, arrayLen(request.stFarCryGrid.aCols)) />
	
	
	<cfset innerHTML = trim(thisTag.GeneratedContent) />
	<cfset thistag.GeneratedContent = "" />
	
	<!--- LAYOUT DIV --->
	<cfif variables.startCol EQ request.stFarCryGrid.iCols>
		<!--- ie. no children so any id, class or style is placed on the fg-content --->
		<cfoutput>
			<div class="fg-layout span-#attributes.span# <cfif attributes.bLast>last</cfif> <cfif attributes.prepend GT 0>prepend-#attributes.prepend#</cfif> <cfif attributes.append GT 0>append-#attributes.append#</cfif> <cfif attributes.push GT 0>push-#attributes.push#</cfif> <cfif attributes.pull GT 0>pull-#attributes.pull#</cfif>" <cfif attributes.bAllowOverflow>style="overflow-x: visible;"</cfif>>			
				<div <cfif len(attributes.id)>id="#attributes.id#"</cfif> class="fg-content #attributes.class#" <cfif len(attributes.style)>style="#attributes.style#"</cfif>></cfoutput>
	<cfelse>
		<!--- We have children so any id, class or style is placed on the fg-layout. --->
		<cfoutput>
			<div <cfif len(attributes.id)>id="#attributes.id#"</cfif> class="fg-layout #attributes.class# span-#attributes.span# <cfif attributes.bLast>last</cfif> <cfif attributes.prepend GT 0>prepend-#attributes.prepend#</cfif> <cfif attributes.append GT 0>append-#attributes.append#</cfif> <cfif attributes.push GT 0>push-#attributes.push#</cfif> <cfif attributes.pull GT 0>pull-#attributes.pull#</cfif>" style="<cfif attributes.bAllowOverflow>overflow-x: visible;</cfif>#attributes.style#">
		</cfoutput>
	
	</cfif>
		<cfif len(innerHTML)>
			<cfoutput>#innerHTML#</cfoutput>
		<cfelse>
			<cfoutput>&nbsp;</cfoutput>
		</cfif>		
		
	<cfif variables.startCol EQ request.stFarCryGrid.iCols>
		<!--- ie. no children, so close both --->
		<cfoutput></div></div></cfoutput>
	<cfelse>
		<!--- children so we only have the 1 div to close --->
		<cfoutput></div></cfoutput>
	</cfif>

	
	<cfif attributes.bLast>
		<cfif application.fapi.getDocType().type eq "xhtml" >
			<cfoutput><br class="clearer" /></cfoutput>	
		<cfelse>
			<cfoutput><br class="clearer"></cfoutput>
		</cfif>

		<cfset request.stFarCryGrid.aCols[arrayLen(request.stFarCryGrid.aCols)].totalUsed = 0 />

	</cfif>
	
</cfif>


