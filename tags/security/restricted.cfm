<cfsetting enablecfoutputonly="true" />

<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag...">
</cfif>


<cfparam name="attributes.permission" />
<cfparam name="attributes.objectID" default="" />
<cfparam name="attributes.error" default="#application.adminBundle[session.dmProfile.locale].noPageViewPermissions#" />

<cfif thistag.ExecutionMode EQ "Start">
	<cfset permitted = 0>
	
	<cfloop list="#attributes.Permission#" index="i">
		<cfif application.security.oRole.checkPermission(permission=i,object=attributes.objectid)>
			<cfset permitted = 1>
		</cfif>
	</cfloop>	

	<cfif permitted NEQ "1">
		<cfoutput>#attributes.error#</cfoutput>
		<cfexit>
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="false" />



