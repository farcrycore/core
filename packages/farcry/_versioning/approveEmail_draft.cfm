<cfsetting enablecfoutputonly="Yes">

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo" prefix="nj">

<!--- get object details --->
<q4:contentobjectget objectID="#stArgs.objectID#" r_stObject="stObj">

<!--- get navigation parent --->
<nj:treeGetRelations 
	typename="#stObj.typename#"
	objectId="#stObj.objectid#"
	get="parents"
	r_lObjectIds="ParentID"
	bInclusive="1">

<!--- get dmProfile object --->
<cfscript>
o_profile = createObject("component", "#application.packagepath#.types.dmProfile");
stProfile = o_profile.getProfile(userName=stObj.lastupdatedby);
</cfscript>

<!--- send email to lastupdater to let them know object is sent back to draft --->
<cfif stProfile.emailAddress neq "" AND stProfile.bReceiveEmail>

    <cfif session.dmProfile.emailAddress neq "">
        <cfset fromEmail = session.dmProfile.emailAddress>
    <cfelse>
        <cfset fromEmail = stProfile.emailAddress>
    </cfif>

<cfmail to="#stProfile.emailAddress#" from="#fromEmail#" subject="#application.config.general.sitetitle# - Page sent back to Draft">
Hi <cfif len(stProfile.firstName) gt 0>#stProfile.firstName#<cfelse>#stProfile.userName#</cfif>,

Your page "<cfif stObj.title neq "">#stObj.title#<cfelse>undefined</cfif>" has been sent back to draft.

<cfif stArgs.comment neq "">
Comments added on status change:
#stArgs.comment#
</cfif>

You may edit this page by browsing to the following location:

http://#CGI.HTTP_HOST##application.url.farcry#/index.cfm?section=site&rootObjectID=#ParentID#

</cfmail>

</cfif>

<cfsetting enablecfoutputonly="no">