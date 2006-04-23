<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/webskin/multiPageTOC.cfm,v 1.3 2005/01/27 15:37:43 brendan Exp $
$Author: brendan $
$Date: 2005/01/27 15:37:43 $
$Name: milestone_2-3-2 $
$Revision: 1.3 $

|| DESCRIPTION || 
$DESCRIPTION: Shows a table of contents for navigation objects having multiple pages$

|| DEVELOPER ||
$DEVELOPER:Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: objectid (objectid of current template)$ 
$in: display (optional - boolean for displaying standard output or just return query)$ 
$in: class (optional - css class used for divs for display)$ 
$in: r_qLinks (optional - variable for return query)$ 
--->

<cfsetting enablecfoutputonly="yes">

<cfimport taglib="/farcry/fourq/tags" prefix="q4">

<!--- required attributes --->
<cfparam name="attributes.objectId">

<!--- optional attributes --->
<cfparam name="attributes.display" default="true">
<cfparam name="attributes.class" default="multiPage">
<cfparam name="attributes.r_qlinks" default="r_qlinks">

<!--- get nav parent details --->
<cfscript>
	o = createObject("component", application.types.dmNavigation.typePath);
	qParent = o.getParent(objectid=attributes.objectid);
</cfscript>
<q4:contentobjectget objectID="#qParent.objectid#" r_stobject="stParent">

<!--- create query --->
<cfset qPages = queryNew("objectid, title")>

<!--- get all pages under nav parent --->
<cfloop from="1" to="#arrayLen(stParent.aObjectIds)#" index="item">
	<cfset error= false>
	<!--- get page details --->
	<cftry>
		<q4:contentobjectget objectID="#stParent.aObjectIds[item]#" r_stobject="stPage">

		<!--- check object exists --->
		<cfcatch type="any">
			<!--- write out error in html commments --->
			<cfoutput><cfdump var="#cfcatch#"></cfoutput>
			<cfset error = true>
		</cfcatch>
	</cftry>
	<cfif not error AND request.mode.lValidStatus CONTAINS stPage.Status>
		<!--- add row to query --->
		<cfset temp = queryAddRow(qPages, 1)>
		<cfset temp = querySetCell(qPages, "objectid", stParent.aObjectIds[item])>
		<cfset temp = querySetCell(qPages, "title", stPage.title)>
	</cfif>
</cfloop>

<!--- check if user wants links to be displayed or just returned in a query --->
<cfif attributes.display>
	<!--- loop over pages --->
	<cfloop query="qPages">
		<!--- check there is an object in query --->
		<cfif len(objectid)>
			<cfoutput><div class="#attributes.class#"></cfoutput>
			<!--- check not current page, if so don't link --->
			<cfif objectid neq attributes.objectId>
				<!--- display link --->
				<cfoutput><a href="#application.url.conjurer#?objectid=#objectid#"></cfoutput>
			</cfif>
			<!--- check if there is a title --->
			<cfif len(title)><cfoutput>#title#</cfoutput><cfelse><cfoutput>undefined</cfoutput></cfif>
			<!--- check not current page, if so don't link --->
			<cfif objectid neq attributes.objectId>
				<cfoutput></a></cfoutput>
			</cfif>
			<cfoutput></div></cfoutput>
		</cfif>
	</cfloop>
<cfelse>
	<!--- return query to calling page --->
	<cfset "caller.#attributes.r_qlinks#" = qPages>
</cfif>

<cfsetting enablecfoutputonly="no">