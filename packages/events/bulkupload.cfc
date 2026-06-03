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
		<cfset var securefile = false />
		<cfset var destinationLocation = "images">

		<cfif application.fapi.getPropertyMetadata(typename=details.typename, property=details.targetfield, md="ftType", default="image") eq "file">
			<cfset securefile = application.fapi.getPropertyMetadata(typename=details.typename, property=details.targetfield, md="ftSecure", default=false)>
			<cfif isBoolean(securefile) AND securefile eq true>
				<cfset destinationLocation = "privatefiles">
			<cfelse>
				<cfset destinationLocation = "publicfiles">
			</cfif>
		</cfif>

		<cfif structkeyexists(arguments.details,"directValue") and len(arguments.details.directValue)>
			<!--- Direct-to-S3: the object is already in its final CDN location
			      (presigned at sign time). No temp file to copy — just record the
			      value. createFromUpload below still resizes the S3-resident file. --->
			<cfset stObject[arguments.details.targetfield] = arguments.details.directValue />
		<cfelse>
			<!--- copy file up. ftLocation is passed so the file formtool honours an
			      explicit location override (image ignores it and always uses "images"),
			      keeping the local path consistent with the direct-S3 sign location. --->
			<cfset stResult = application.formtools[application.fapi.getPropertyMetadata(stObject.typename, arguments.details.targetfield, "ftType")].oFactory.handleFileLocal(
				typename = stObject.typename,
				objectid = stObject.objectid,
				existingFile = "",
				localFile = application.fc.lib.cdn.ioGetFileLocation(location="temp", file=arguments.details.tempfile,bRetrieve="true").path,
				destination = application.fapi.getPropertyMetadata(stObject.typename, arguments.details.targetfield, "ftDestination"),
				secure = application.fapi.getPropertyMetadata(stObject.typename, arguments.details.targetfield, "ftSecure", false),
				location = application.fapi.getPropertyMetadata(stObject.typename, arguments.details.targetfield, "ftLocation", ""),
				status = structKeyExists(stObject, "status") ? stObject.status : "approved",
				allowedExtensions = application.fapi.getPropertyMetadata(stObject.typename, arguments.details.targetfield, "ftAllowedExtensions"),
				sizeLimit = application.fapi.getPropertyMetadata(stObject.typename, arguments.details.targetfield, "ftSizeLimit", 0),
				bArchive = false
			) />
			<cfif not stResult.bSuccess>
				<cflog file="bulkupload" text="Could not handle #arguments.details.tempfile#: #stResult.stError.message#" />
				<creturn "" />
			</cfif>
			<cfset stObject[arguments.details.targetfield] = stResult.value />
		</cfif>
		<cfset stResult = {} />

		<!--- call additional function to support cloudinary plugin --->
		<cfset arguments.details.stObject = stObject />
		<cfset application.fc.lib.events.announce(component="bulkupload",eventName="uploadfilecopied",stParams=arguments) />

		<!--- set defaults --->
		<cfloop collection="#arguments.details.defaults#" item="thisfield">
			<cfset stObject[thisfield] = arguments.details.defaults[thisfield] />
		</cfloop>
		
		<!--- save --->
		<cfset stObject = o.createFromUpload(stProperties=stObject,user=arguments.ownedBy,uploadfield=arguments.details.targetfield) />
		
		<cfset stResult["message"] = "Content created">
		<cfset stResult["objectID"] = stObject.objectid />
		
		<cfset application.fc.lib.tasks.addResult(result=stResult) />
	</cffunction>
	
</cfcomponent>
