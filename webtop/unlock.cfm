<cfprocessingDirective pageencoding="utf-8">

<cfif isdefined("url.objectid")>
	<!--- unlock object --->
	<cfinvoke component="#application.packagepath#.farcry.locking" method="unlock" returnvariable="unlockRet">
		<cfinvokeargument name="objectId" value="#url.objectid#"/>
		<cfinvokeargument name="typename" value="#url.typename#"/>
	</cfinvoke>
	
	<!--- go back to overview page --->
	<cflocation url="#application.url.farcry#/edittabOverview.cfm?objectid=#url.objectid#" addtoken="no">

<cfelse>
	<!--- from dynamic section --->
	<cfscript>
		iDeveloperPermission = application.security.checkPermission(permission="developer");
	</cfscript>
	<cfset count = 0>
	<!--- loop over selected objects --->
	<cfloop list="#form.objectid#" index="object">
		<!--- get object details --->
		<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
		<q4:contentobjectget objectid="#object#" r_stobject="stobj">
		<!--- check locked --->
		<cfif stObj.locked>
			<!--- check if locked by current user --->
			<cfif stObj.lockedby eq "#application.security.getCurrentUserID()#">
				<!--- user can unlock there own objects --->
				<cfset permission = true>
			<cfelse>
				<!--- check if they have permission to unlock other's objects --->

				<cfif iDeveloperPermission eq 1>
					<cfset permission = true>
				<cfelse>
					<cfset permission = false>
					<cfset message = "#application.rb.getResource('security.messages.noPermissionUnlockAll@text','You do not have permission to unlock all content items')#">
				</cfif>
			</cfif>
			<!--- check permission --->
			<cfif permission>
				<cfset count = count +1>
				<!--- unlock object --->
				<cfinvoke component="#application.packagepath#.farcry.locking" method="unlock" returnvariable="unlockRet">
					<cfinvokeargument name="objectId" value="#object#"/>
					<cfinvokeargument name="typename" value="#stObj.typename#"/>
				</cfinvoke>
			</cfif>
		</cfif>
	</cfloop>
	<!--- set return message --->
	<cfif count gt 0>
		<cfset message = "#application.rb.formatRBString("objectsUnlocked",'#count#')#">
	</cfif>
	<!--- return to dynamic page --->
	<cflocation url="#application.url.farcry#/navajo/GenericAdmin.cfm?typename=#stObj.typename#&msg=#message#" addtoken="no">
</cfif>