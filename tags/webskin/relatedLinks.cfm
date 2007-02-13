<cfsetting enablecfoutputonly="yes">
<!------------------------------------------------------------------------
relatedLinks (FarCry Core: webskin tag library)
Copyright Daemon Pty Limited 2002 (http://www.daemon.com.au/)

$Header: /cvs/farcry/core/tags/webskin/relatedLinks.cfm,v 1.7 2003/10/14 23:54:53 brendan Exp $
$Author: brendan $
$Date: 2003/10/14 23:54:53 $
$Name: milestone_3-0-1 $
$Revision: 1.7 $

Contributors:
Brendan Sisson (brendan@daemon.com.au)
Geoff Bowers (modius@daemon.com.au)
Andrew Robertson (andrewr@daemon.com.au)

Description:
Pulls related links for the current object.

Example of Usage From Webskin Template:
<cfif isDefined("stObj.aRelatedIDs") AND NOT arrayisEmpty(stObj.aRelatedIDs)>
	<cfoutput><div class="relatedLinksTitle">Related Links</div></cfoutput>
	<skin:relatedLinks aRelatedIDs="#stObj.aRelatedIDs#" clas="relatedLinks">
</cfif>
------------------------------------------------------------------------->
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">

<!--- required attributes --->
<cfparam name="attributes.aRelatedIDs" type="array">

<!--- optional attributes --->
<cfparam name="attributes.output" default="true">
<cfparam name="attributes.class" default="relatedLinks">
<cfparam name="attributes.r_qlinks" default="r_qlinks">

<!--- get related ids out of array and into a list for looping --->
<cfset relatedids = arraytoList(attributes.aRelatedIDs,",")>

<!--- create query --->
<cfset qRelated = queryNew("objectid, title")>

<!--- get all related links to page --->
<cfloop list="#relatedids#" index="item">
	<cfset error= false>
	<!--- get related item details --->
	<cftry>
		<q4:contentobjectget objectID="#item#" r_stobject="stRelated">
		<!--- check object exists --->
		<cfcatch type="any">
			<!--- write out error in html commments --->
			<cfoutput><!-- Related Links Error: #item# has been removed from the system --></cfoutput>
			<cfset error = true>
			</cfcatch>
	</cftry>
	<cfif not error and structCount(stRelated) gt 0 AND request.mode.lValidStatus CONTAINS stRelated.Status>
		<!--- add row to query --->
		<cfset temp = queryAddRow(qRelated, 1)>
		<cfset temp = querySetCell(qRelated, "objectid", item)>
		<cfset temp = querySetCell(qRelated, "title", stRelated.title)>
	</cfif>
</cfloop>

<!--- check if user wants links to be displayed or just returned in a query --->
<cfif attributes.output>
	<!--- loop over links --->
	<cfloop query="qRelated">
		<!--- check there is an object in query --->
		<cfif len(objectid)>
			<!--- display link --->
			<cfoutput><div class="#attributes.class#"><a href="index.cfm?objectid=#objectid#"></cfoutput>
			<!--- check if there is a title --->
			<cfif len(title)><cfoutput>#title#</cfoutput><cfelse><cfoutput>undefined</cfoutput></cfif>
			<cfoutput></a></div></cfoutput>
		</cfif>
	</cfloop>
<cfelse>
	<!--- return query to calling page --->
	<cfset "caller.#attributes.r_qlinks#" = qRelated>
</cfif>

<cfsetting enablecfoutputonly="no">
