<cfsetting enablecfoutputonly="true">
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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
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
		<cfset attributes.html = trim(thisTag.generatedContent) />
		<cfset thisTag.GeneratedContent = "" />
	</cfif>
	
	<cfif structKeyExists(attributes, "html") AND len(attributes.html)>
		<cfparam name="request.extJS.stLayout.aItems[itemTotal].contentEl" default="contentEl#randRange(1,9999999)#" />
		
		<cfsavecontent variable="variables.html">
		<cfoutput>
		<div id="#request.extJS.stLayout.aItems[itemTotal].contentEl#" class="x-hidden">
			#attributes.html#
		</div>
		</cfoutput>	
		</cfsavecontent>
		
		<cfset request.extJS.stLayout.aItems[itemTotal].html = variables.html />
	</cfif>
	
	<cfif itemTotal EQ 1>
		<!--- This means it is a top level item and therefore needs to go into the layoutItems array --->
		<cfset arrayAppend(request.extJS.stLayout.aLayoutItems, request.extJS.stLayout.aItems[1]) />
		<cfset ArrayDeleteAt(request.extJS.stLayout.aItems, itemTotal) />	
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