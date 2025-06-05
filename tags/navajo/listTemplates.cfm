<cfsetting enablecfoutputonly="true">
<cfprocessingDirective pageencoding="utf-8">
<!---
listTemplates
 - list templates from webskin

attributes
-> typename
-> prefix
-> path
 --->

<cfparam name="attributes.typename" default="">
<cfparam name="attributes.prefix" default="display">
<cfparam name="attributes.path" default="#structnew()#">
<cfparam name="attributes.r_fullpath" default="fullpath">
<cfparam name="attributes.r_metadata" default="metadata">
<cfparam name="attributes.r_pathname" default="pathname">
<cfparam name="attributes.r_qMethods" default="qMethods">

<cfset qTemplates = queryNew("blah") />

<cfif thistag.executionMode eq "start">

	<cfif isSimpleValue(attributes.path) and len(attributes.path)>
		<cfset attributes.path = {"All":attributes.path} />
	</cfif>

	<!--- if we send in a path then only get templates from that path --->
	<cfif not structIsEmpty(attributes.path)>

		<cfset thistag.stMetadata = {} />

		<cfset oCoapiAdmin = createobject("component", "farcry.core.packages.coapi.coapiadmin") />

		<!--- Extract metadata --->
		<cfset qMethods = queryNew("pathname,fullpath,methodname,displayname")>

		<cfloop collection="#attributes.path#" item="pathName">
			<cfif not directoryExists(attributes.path[pathName])>
				<cfcontinue />
			</cfif>

			<cfdirectory action="LIST" filter="*.cfm" name="qTemplates" directory="#attributes.path[pathName]#">

			<!--- This is to overcome casesensitivity issues on mac/linux machines --->
			<cfquery name="qTemplates" dbtype="query">
				SELECT * FROM qTemplates
				WHERE lower(qTemplates.name) LIKE '#lCase(attributes.prefix)#%'
			</cfquery>

			<cfloop query="qTemplates">
				<cfset methodname = listfirst(qTemplates.name, ".") />
				<cfset thistag.stMetadata[methodname] = oCoapiAdmin.parseWebskinMetadata(template=methodname, path="#qTemplates.directory#/#qTemplates.name#", lProperties="displayname", lDefaults=listfirst(qTemplates.name, ".")) />

				<cfset queryAddRow(qMethods, 1)>
				<cfset querySetCell(qMethods, "pathname", pathName)>
				<cfset querySetCell(qMethods, "fullpath", replace("#qTemplates.directory#/#qTemplates.name#", expandPath("/farcry"), "/farcry"))>
				<cfset querySetCell(qMethods, "methodname", methodname)>
				<cfset querySetCell(qMethods, "displayname", thistag.stMetadata[methodname].displayname)>
			</cfloop>
		</cfloop>
		<cfif qMethods.recordcount eq 0>
			<cfset caller[attributes.r_qMethods] = qTemplates />
			<cfexit method="exittag" />
		</cfif>

		<!--- Reorder List --->
		<cfquery name="qMethods" dbtype="query">
			SELECT *
			FROM qMethods
			ORDER BY DisplayName
		</cfquery>

		<cfset thisTag.qOrdered = qMethods />

	<cfelseif structKeyExists(application.stcoapi, attributes.typename)>

		<cfset qOrderedMethods = duplicate(createObject("component", application.stcoapi[attributes.typename].packagepath).getWebskins(typename="#attributes.typename#", prefix="#attributes.prefix#")) />
		<cfif qOrderedMethods.recordcount eq 0>
			<cfset caller[attributes.r_qMethods] = qOrderedMethods />
			<cfexit method="exittag" />
		</cfif>

		<cfset queryAddColumn(qOrderedMethods, "pathname") />
		<cfset queryAddColumn(qOrderedMethods, "fullpath") />
		<cfloop query="qOrderedMethods">
			<cfset querySetCell(qOrderedMethods, "fullpath", "#qOrderedMethods.directory#/#qOrderedMethods.name#", qOrderedMethods.currentrow) />
		</cfloop>

		<!--- Reorder List --->
		<cfquery name="qOrderedMethods" dbtype="query">
			SELECT *
			FROM qOrderedMethods
			ORDER BY DisplayName
		</cfquery>

		<cfset thisTag.qOrdered = qOrderedMethods />
		<cfset thisTag.stMetadata = application.stCOAPI[attributes.typename].stWebskins />

	<cfelse>

		<cfthrow message="nj:listTemplates requires either `path` or `typename`" />

	</cfif>

	<cfif thisTag.hasEndTag>
		<cfset thisTag.currentrow = 1 />
		<cfset caller[attributes.r_pathname] = thisTag.qOrdered.pathname[thisTag.currentrow] />
		<cfset caller[attributes.r_fullpath] = thisTag.qOrdered.fullpath[thisTag.currentrow] />
		<cfset caller[attributes.r_metadata] = thisTag.stMetadata[thisTag.qOrdered.methodname[thisTag.currentrow]] />
	<cfelse>
		<cfset caller[attributes.r_qMethods] = thisTag.qOrdered />
	</cfif>

<cfelseif thisTag.executionMode eq "end">

	<cfif thisTag.currentrow lt thisTag.qOrdered.recordcount>
		<cfset thisTag.currentrow += 1 />
		<cfset caller[attributes.r_pathname] = thisTag.qOrdered.pathname[thisTag.currentrow] />
		<cfset caller[attributes.r_fullpath] = thisTag.qOrdered.fullpath[thisTag.currentrow] />
		<cfset caller[attributes.r_metadata] = thisTag.stMetadata[thisTag.qOrdered.methodname[thisTag.currentrow]] />
		<cfexit method="loop" />
	</cfif>

	<cfset caller[attributes.r_qMethods] = thisTag.qOrdered />

</cfif>

<cfsetting enablecfoutputonly="false">