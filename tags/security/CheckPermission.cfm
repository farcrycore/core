<cfsetting enablecfoutputonly="true" />

<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag...">
</cfif>


<cfparam name="attributes.permission" default="" />
<cfparam name="attributes.permissionName" default ="" />

<cfparam name="attributes.reference" default="">
<cfparam name="attributes.objectID" default="" />

<cfparam name="attributes.error" default="false" />
<cfparam name="attributes.errormessage" default="#application.adminBundle[session.dmProfile.locale].noPageViewPermissions#" />

<cfif thistag.ExecutionMode EQ "Start">
	<cfset permitted = 0>
	
	<cfif len(attributes.permissionname)>
		<cfset attributes.permission = attributes.permissionname />
	<cfelseif not len(attributes.permission)>
		<cfthrow message="Permission or permissionname must be passed into the CheckPermission tag" />
	</cfif>
	
	<cfif isvalid("uuid",attributes.reference)>
		<cfset attributes.objectid = attributes.reference />
	<cfelseif not isvalid("uuid",attributes.objectid)>
		<cfthrow message="ObjectID or reference (depreciated) must be passed into the CheckPermission tag" />
	</cfif>
	
	<cfloop list="#attributes.Permission#" index="perm">
		<cfif application.security.checkPermission(permission=perm,object=attributes.objectid)>
			<cfset permitted = 1>
		</cfif>
	</cfloop>	

	<cfif permitted NEQ "1">
		<cfif attributes.error>
			<cfoutput>#attributes.errormessage#</cfoutput>
		</cfif>
		<cfexit />
	</cfif>
</cfif>

<cfsetting enablecfoutputonly="false" />



