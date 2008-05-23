<cfsetting enablecfoutputonly="true" />

<cfparam name="application.stfarcrygrid" default="#structNew()#" />
<cfparam name="application.stfarcrygrid.cols" default="24" />

<cfparam name="request.stfarcrygrid" default="#structNew()#" />
<cfparam name="request.stfarcrygrid.aCols" default="#arrayNew(1)#" />
<cfparam name="request.stfarcrygrid.iCols" default="0" />


<cfif not arrayLen(request.stfarcrygrid.aCols)>
	<cfset stDefaultCol = structNew() />
	<cfset stDefaultCol.maxCols = application.stfarcrygrid.cols />
	<cfset stDefaultCol.totalUsed = 0 />
	<cfset arrayAppend(request.stfarcrygrid.aCols, stDefaultCol) />
</cfif>


<cfif thistag.executionMode eq "Start">
	<!--- layout div attributes --->
	<cfparam name="attributes.span" default="#application.stfarcrygrid.cols#" />
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
	

	<cfset request.stfarcrygrid.iCols = request.stfarcrygrid.iCols + 1 />
	<cfset variables.startCol = request.stfarcrygrid.iCols />
	
	<!--- LAST ITEM IN THE ARRAY IS THE CURRENT GRID ITEM --->
	<cfset stCol = duplicate(request.stfarcrygrid.aCols[arrayLen(request.stfarcrygrid.aCols)]) />
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
	


	<cfset request.stfarcrygrid.aCols[arrayLen(request.stfarcrygrid.aCols)] = stCol />

	
	<!--- ADD AN ARRAY ITEM FOR ANY CHILDREN IN CASE THEIR ARE ANY --->
 	<cfset stChild = structNew() />
	<cfset stChild.maxCols = attributes.span />
	<cfset stChild.totalUsed = 0 />
	<cfset arrayAppend(request.stfarcrygrid.aCols, stChild) />
	
</cfif>



<cfif thistag.executionMode eq "End">

	<cfset arrayDeleteAt(request.stfarcrygrid.aCols, arrayLen(request.stfarcrygrid.aCols)) />
	
	
	<cfset innerHTML = trim(thisTag.GeneratedContent) />
	<cfset thistag.GeneratedContent = "" />
	
	<!--- LAYOUT DIV --->
	<cfif variables.startCol EQ request.stfarcrygrid.iCols>
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
		
	<cfif variables.startCol EQ request.stfarcrygrid.iCols>
		<!--- ie. no children, so close both --->
		<cfoutput></div></div></cfoutput>
	<cfelse>
		<!--- children so we only have the 1 div to close --->
		<cfoutput></div></cfoutput>
	</cfif>

	
	<cfif attributes.bLast>
		<cfoutput><br class="clearer" /></cfoutput>	

		<cfset request.stfarcrygrid.aCols[arrayLen(request.stfarcrygrid.aCols)].totalUsed = 0 />

	</cfif>
	
</cfif>


