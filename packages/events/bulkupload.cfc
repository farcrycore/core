<cfcomponent displayname="Bulk Upload" hint="Bulk upload tasks" output="false" persistent="false">
	
	
	<cffunction name="upload" access="public" output="false" returntype="void">
		<cfargument name="taskID" type="string" required="true" />
		<cfargument name="jobID" type="string" required="true" />
		<cfargument name="action" type="string" required="true" />
		<cfargument name="ownedBy" type="string" required="true" />
		<cfargument name="details" type="any" required="true" />
		
		<cfset var stResult = structnew() />
		<cfset var o = application.fapi.getContentType(typename=arguments.details.typename,singleton=true) />
		<cfset var stObject = o.getData(objectid=arguments.taskID) />
		<cfset var thisfield = "" />
		<cflog file="debug" text="move file">
		<!--- copy file up --->
		<cfset stObject[arguments.details.targetfield] = application.fc.lib.cdn.ioMoveFile(
			source_location="temp",
			source_file=arguments.details.tempfile,
			dest_location="images",
			dest_file=application.stCOAPI[arguments.details.typename].stProps[arguments.details.targetfield].metadata.ftDestination & "/" & listlast(arguments.details.tempfile,"/"),
			nameconflict="makeunique"
		) />
		<cflog file="debug" text="set defaults">
		<!--- set defaults --->
		<cfloop collection="#arguments.details.defaults#" item="thisfield">
			<cfset stObject[thisfield] = arguments.details.defaults[thisfield] />
		</cfloop>
		<cflog file="debug" text="create object">
		<!--- save --->
		<cfset stObject = o.createFromUpload(stProperties=stObject,user=arguments.ownedBy,uploadfield=arguments.details.targetfield) />
		<cflog file="debug" text="close task">
		<cfset stResult["message"] = "Content created">
		<cfset stResult["task"] = duplicate(arguments.details) />
		<cfset stResult["objectID"] = stObject.objectid />
		
		<cfset application.fc.lib.tasks.addResult(result=stResult) />
	</cffunction>
	
</cfcomponent>