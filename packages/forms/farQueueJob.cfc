<cfcomponent extends="forms" displayname="Task Queue Job">
	
	<cfproperty ftSeq="1" ftLabel="Job Type" name="jobType" type="varchar" />
	<cfproperty ftSeq="2" ftLabel="Job Owner" name="jobOwner" type="varchar" />
	<cfproperty ftSeq="3" ftLabel="Job Status" name="jobStatus" type="varchar" />
	<cfproperty ftSeq="4" ftLabel="Task Count" name="taskCount" type="numeric" ftType="integer" />
	<cfproperty ftSeq="5" ftLabel="Result Count" name="resultCount" type="numeric" ftType="integer" />
	<cfproperty ftSeq="6" ftLabel="Latest Task Processed" name="datetimeLatest" type="datetime" />
	
	
	<cffunction name="ftDisplayJobOwner" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var stProfile = "" />
		
		<cfif len(arguments.stMetadata.value)>
			<cfset stProfile = application.fapi.getContentType(typename="dmProfile").getProfile(username=arguments.stMetadata.value) />
			
			<cfsavecontent variable="html"><cfoutput>
				<cfif len(stProfile.firstname) or len(stProfile.lastname)><span title="#arguments.stMetadata.value#">#stProfile.firstname# #stProfile.lastname#</span><cfelse>#arguments.stMetadata.value#</cfif>
			</cfoutput></cfsavecontent>
		<cfelse>
			<cfset html = "Anonymous" />
		</cfif>
		
		<cfreturn html>
	</cffunction>
	
</cfcomponent>