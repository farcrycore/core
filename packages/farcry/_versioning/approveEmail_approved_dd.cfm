<cfsetting enablecfoutputonly="Yes">

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">

<!--- get object details --->
<q4:contentobjectget objectID="#stArgs.objectID#" r_stObject="stObj">

<!--- get dmProfile object --->
<cfscript>
o_profile = createObject("component", "#application.packagepath#.types.dmProfile");
stProfile = o_profile.getProfile(userName=stObj.lastupdatedby);
</cfscript>

<!--- send email to lastupdater to let them know object is approved --->
<cfif stProfile.emailAddress neq "" and stProfile.bReceiveEmail>

    <cfif isdefined("session.dmProfile.emailAddress") and session.dmProfile.emailAddress neq "">
        <cfset fromEmail = session.dmProfile.emailAddress>
    <cfelse>
        <cfset fromEmail = stProfile.emailAddress>
    </cfif>

<cfmail to="#stProfile.emailAddress#" from="#fromEmail#" subject="#application.config.general.sitetitle# - Object Approved">
Hi <cfif len(stProfile.firstName) gt 0>#stProfile.firstName#<cfelse>#stProfile.userName#</cfif>,

Your object "<cfif stObj.title neq "">#stObj.title#<cfelse>undefined</cfif>" has been approved.

<cfif stArgs.comment neq "">
Comments added on status change:
#stArgs.comment#
</cfif>

</cfmail>

</cfif>

<cfsetting enablecfoutputonly="no">