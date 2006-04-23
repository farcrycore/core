<cfsetting enablecfoutputonly="Yes">

<cfimport taglib="/farcry/fourq/tags/" prefix="q4">

<!--- get object details --->
<q4:contentobjectget objectID="#stArgs.objectID#" r_stObject="stObj">

<!--- get list of approvers for this object --->
<cfinvoke component="#application.packagepath#.farcry.workflow" method="getNewsApprovers" returnvariable="stApprovers">
	<cfinvokeargument name="objectID" value="#stArgs.objectID#" />
</cfinvoke>

<cfloop collection="#stApprovers#" item="user">
    <cfif stApprovers[user].emailAddress neq "" AND stApprovers[user].bReceiveEmail>

    <cfif isdefined("session.dmProfile.emailAddress") and session.dmProfile.emailAddress neq "">
        <cfset fromEmail = session.dmProfile.emailAddress>
    <cfelse>
        <cfset fromEmail = stApprovers[user].emailAddress>
    </cfif>

<!--- send email alerting them to object is waiting approval  --->
<cfmail to="#stApprovers[user].emailAddress#" from="#fromEmail#" subject="#application.config.general.sitetitle# - Object Approval Request">
Hi <cfif len(stApprovers[user].firstName) gt 0>#stApprovers[user].firstName#<cfelse>#stApprovers[user].userName#</cfif>,

Object "<cfif stObj.title neq "">#stObj.title#<cfelse>undefined</cfif>" is awaiting your approval.

You may approve/decline this object by browsing to the following location:

http://#CGI.HTTP_HOST##application.url.farcry#/index.cfm?section=dynamic&objectID=#stArgs.objectID#&status=pending

<cfif stArgs.comment neq "">
Comments added on status change:
#stArgs.comment#
</cfif>

</cfmail>

    </cfif>
</cfloop>

<cfsetting enablecfoutputonly="no">