<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Check permission --->
<!--- @@description: Permission check of the four types of permission (webskin, object, type, general), i.e. will permit if any of the specified permissions are granted --->

<cfif not thistag.HasEndTag>
	<cfabort showerror="Does not have an end tag...">
</cfif>

<!--- General "I don't want to figure out the right permission attribute" attribute --->
<cfparam name="attributes.permission" default="" />

<!--- Four kinds of permission --->
<cfparam name="attributes.typepermission" default="" />
<cfparam name="attributes.type" default="" />

<cfparam name="attributes.generalpermission" default="" />

<cfparam name="attributes.objectpermission" default="" />
<cfparam name="attributes.objectID" default="" />

<cfparam name="attributes.webskinpermission" default="" />

<cfparam name="attributes.error" default="false" />
<cfparam name="attributes.errormessage" default="You don't have permission to view this page" />

<cfif thistag.ExecutionMode EQ "Start">
	<cfset permitted = 0>
	
	<!--- Get permissionname for backwards compatability and make sure a permission attribute was passed --->
	<cfif structkeyexists(attributes,"permissionname")>
		<cfset attributes.permission = attributes.permissionname />
	<cfelseif not len(attributes.permission) and not len(attributes.typepermission) and not len(attributes.generalpermission) and not len(attributes.objectpermission) and not len(attributes.webskinpermission)>
		<cfthrow message="A permission attribute must be passed into the CheckPermission tag" />
	</cfif>
	
	<!--- Get reference for backwards compatability --->
	<cfif structkeyexists(attributes,"reference") and isvalid("uuid",attributes.reference)>
		<cfset attributes.objectid = attributes.reference />
	<cfelseif len(attributes.objectid) and not isvalid("uuid",attributes.objectid)>
		<cfthrow message="ObjectID or reference (depreciated) must be a valid uuid" />
	</cfif>
	
	<!--- If the vanilla "permission" attribute was used, figure out which permission type was meant --->
	<cfif len(attributes.permission) and not len(attributes.typepermission) and not len(attributes.generalpermission) and not len(attributes.objectpermission) and not len(attributes.webskinpermission)>
		<cfif len(attributes.type)>
			<cfset attributes.typepermission = attributes.permission />
		<cfelseif len(attributes.objectid)>
			<cfset attributes.objectpermission = attributes.permission />
		<cfelse>
			<cfset attributes.generalpermission = attributes.permission />
		</cfif>
	<cfelseif len(attributes.typepermission) and not len(attributes.type)>
		<cfthrow message="Type attribute must be provided when checking a type permission" />
	<cfelseif len(attributes.objectpermission) and not isvalid("uuid",attributes.objectid)>
		<cfthrow message="ObjectID attribute must be provided when checking an object permission" />
	</cfif>
	
	<!--- Check general permissions --->
	<cfloop list="#attributes.generalpermission#" index="perm">
		<cfif application.security.checkPermission(permission=perm)>
			<!--- Permission granted - skip straight to content --->
			<cfexit method="exittemplate" />
		</cfif>
	</cfloop>
	
	<!--- Check object permissions --->
	<cfloop list="#attributes.objectpermission#" index="perm">
		<cfif application.security.checkPermission(permission=perm,object=attributes.objectid)>
			<!--- Permission granted - skip straight to content --->
			<cfexit method="exittemplate" />
		</cfif>
	</cfloop>
	
	<!--- Check type permissions --->
	<cfloop list="#attributes.typepermission#" index="perm">
		<cfif application.security.factory.permission.permissionExists("#attributes.type##perm#")>
			<cfif application.security.checkPermission(permission="#attributes.type##perm#")>
				<!--- Permission granted - skip straight to content --->
				<cfexit method="exittemplate" />
			</cfif>
		<cfelseif application.security.checkPermission(permission="generic#perm#")>
			<!--- Permission granted - skip straight to content --->
			<cfexit method="exittemplate" />
		</cfif>
	</cfloop>
	
	<!--- Check webskin permissions --->
	<cfloop list="#attributes.webskinpermission#" index="perm">
		<cfif application.security.checkPermission(webskin=perm)>
			<!--- Permission granted - skip straight to content --->
			<cfexit method="exittemplate" />
		</cfif>
	</cfloop>

	<!--- If we get to this point, no permissions were granted - throw an error and exit the tag --->
	<cfif attributes.error>
		<!--- Translate and output error message --->
		<cfoutput>#application.rb.getResource("general.errors.#rereplace(attributes.errormessage,'[^\w]','','ALL')#",attributes.errormessage)#</cfoutput>
	</cfif>
	<cfexit />
</cfif>

<cfsetting enablecfoutputonly="false" />



