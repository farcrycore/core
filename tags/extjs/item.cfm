<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname:  --->
<!--- @@description:  This is the child tag of the <extjs:layout> used to generate extjs layouts. By nesting item tags <extjs:item> within a layout tag, allows the developer to build a rich application layout. --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<cfif thistag.executionMode eq "Start">
	
	<cfparam name="attributes.aItems" default="#arrayNew(1)#" />
	<cfparam name="attributes.id" default="itemID#randRange(1,9999999)#" />
	<cfparam name="attributes.container" default="" />	
	
<!--- 	<cfif isdefined("attributes.title") AND attributes.title EQ "Approval & Work Flow">
		<cfoutput>#getbasetaglist()#</cfoutput>
		<cfabort showerror="debugging" />
	</cfif> --->
	
	<cfset arrayAppend(request.extJS.stLayout.aItems, attributes) />

</cfif>


<cfif thistag.executionMode eq "End">
		
	<cfset itemTotal = arrayLen(request.extJS.stLayout.aItems)>
	
	<cfif len(trim(thisTag.generatedContent))>
		<cfparam name="request.extJS.stLayout.aItems[itemTotal].contentEl" default="contentEl#randRange(1,9999999)#" />
		
		<cfsavecontent variable="html">
		<cfoutput>
		<div id="#request.extJS.stLayout.aItems[itemTotal].contentEl#" class="x-hide-display">
			#thisTag.generatedContent#
		</div>
		</cfoutput>	
		</cfsavecontent>
		
		<cfset thisTag.GeneratedContent = "" />
		
		<cfset request.extJS.stLayout.aItems[itemTotal].html = html />
		
	</cfif>
	
	<cfif itemTotal EQ 1>
		<!--- This means it is a top level item and therefore needs to go into the layoutItems array --->
		<cfset arrayAppend(request.extJS.stLayout.aLayoutItems, request.extJS.stLayout.aItems[1]) />
	<cfelse>
		<!--- This means it is a sub item and therefore needs to go into its parent item list --->
		<cfset stCurrentItem = request.extJS.stLayout.aItems[itemTotal] />	
		<cfset ArrayDeleteAt(request.extJS.stLayout.aItems, itemTotal) />	
		<cfset arrayAppend(request.extJS.stLayout.aItems[itemTotal-1].aItems, stCurrentItem) />
	</cfif>
	
	
	
	

<!--- 	
	
	<cfset thisTag.GeneratedContent = "" />
	<cfset parenttagdata = structNew() />
	<cfset ancestorlist = getbasetaglist()>
	<cfloop from="1" to="#listlen(ancestorlist)#" index="i">
		
		<cfif ListValueCountNoCase(ancestorlist, "cf_item") GT 1>
			<cfset parenttagdata = getbasetagdata("cf_item", 2) />
			<cfbreak />
		</cfif>
        <cfif ListGetAt(ancestorlist,i) EQ "cf_layout">
			<cfset parenttagdata = getbasetagdata("cf_layout") />
			<cfbreak />
		</cfif>
    </cfloop>
			

		
	
	
	<cfparam name="parenttagdata.aItems" default="#arrayNew(1)#" />
	<cfset arrayAppend(parenttagdata.aItems, attributes) /> --->
	
</cfif>



<cfsetting enablecfoutputonly="false" />