<cfsetting enablecfoutputonly="Yes">

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">

<!--- get object details --->
<q4:contentobjectget objectID="#stArgs.objectID#" r_stObject="stObj">

<!--- check if underlying draft --->
<cfif IsDefined("stObj.versionID") and stObj.versionID neq "">
	<cfquery datasource="#application.dsn#" name="qHasDraft">
		SELECT objectID,status 
		FROM #application.dbowner##stObj.typename# 
		WHERE objectid = '#stObj.versionID#' 
	</cfquery>
	<cfset child = qHasDraft.objectid>
<cfelse>
	<cfset child = stobj.objectid>
</cfif>

<!--- get navigation parent --->
<nj:treeGetRelations 
	typename="#stObj.typename#"
	objectId="#child#"
	get="parents"
	r_lObjectIds="ParentID"
	bInclusive="1">
			
<!--- get list of approvers for this object --->
<cfinvoke component="#application.packagepath#.farcry.workflow" method="getObjectApprovers" returnvariable="stApprovers">
	<cfinvokeargument name="objectID" value="#stArgs.objectID#"/>
</cfinvoke>

<cfloop collection="#stApprovers#" item="item">
    <cfif stApprovers[item].emailAddress neq "" AND stApprovers[item].bReceiveEmail>

    <cfif session.dmProfile.emailAddress neq "">
        <cfset fromEmail = session.dmProfile.emailAddress>
    <cfelse>
        <cfset fromEmail = stApprovers[item].emailAddress>
    </cfif>

<!--- send email alerting them to object is waiting approval  --->
<cfmail to="#stApprovers[item].emailAddress#" from="#fromEmail#" subject="#application.config.general.sitetitle# - Page Approval Request">
Hi <cfif len(stApprovers[item].firstName) gt 0>#stApprovers[item].firstName#<cfelse>#stApprovers[item].userName#</cfif>,

Page "<cfif stObj.title neq "">#stObj.title#<cfelse>undefined</cfif>" is awaiting your approval.

You may approve/decline this page by browsing to the following location:

http://#CGI.HTTP_HOST##application.url.farcry#/index.cfm?section=site&rootObjectID=#ParentID#

<cfif stArgs.comment neq "">
Comments added on status change:
#stArgs.comment#
</cfif>

</cfmail>

    </cfif>
</cfloop>

<cfsetting enablecfoutputonly="no">