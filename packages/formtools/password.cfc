

<cfcomponent extends="field" name="password" displayname="password" hint="Used to liase with password type fields"> 

	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

	
		<cfsavecontent variable="html">
			<cfoutput>
				<table>
				<tr>
					<th>Current Password: </th>
					<td><input type="text" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#arguments.stMetadata.value#" class="#arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" /></td>
				</tr>
				<tr>
					<th>New Password: </th>
					<td><input type="password" name="#arguments.fieldname#New" id="#arguments.fieldname#New" value="" class="#arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" /></td>
				</tr>
				<tr>
					<th>Confirm New Password: </th>
					<td><input type="password" name="#arguments.fieldname#Confirm" id="#arguments.fieldname#Confirm" value="" class="#arguments.stMetadata.ftclass#" style="#arguments.stMetadata.ftstyle#" /></td>
				</tr>
				</table>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		
		<cfsavecontent variable="html">
			<cfoutput><a href="##" onclick="alert('#arguments.stMetadata.value#');">****************</a></cfoutput>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="ObjectID" required="true" type="UUID" hint="The objectid of the object that this field is part of.">
		<cfargument name="Typename" required="true" type="string" hint="the typename of the objectid.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>		
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = "">
		<cfset stResult.stError = StructNew()>
		
		<cfset o = createObject("component",application.types['#arguments.Typename#'].typepath)>
		<cfset st = o.getData(objectid=arguments.objectid)>
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->

		<cfset stResult.value = st[arguments.stMetadata.name]>
		
		<cfif arguments.stFieldPost.value EQ st[arguments.stMetadata.name]>
			<cfif len(arguments.stFieldPost.stSupporting.New) AND arguments.stFieldPost.stSupporting.New EQ arguments.stFieldPost.stSupporting.Confirm>
				<cfset stResult.value = arguments.stFieldPost.stSupporting.New>
			</cfif>		
		</cfif>
		
		
		
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>

</cfcomponent> 


<!--- 			db.boolean = "INT";
			db.date = "DATETIME";
			db.numeric = "NUMERIC";
			db.string = "VARCHAR(255)";
			db.nstring = "VARCHAR(255)";
			db.uuid = "VARCHAR(50)";
			db.variablename = "VARCHAR(64)";
			db.color = "VARCHAR(20)";
			db.email = "VARCHAR(255)";
			db.longchar = "LONGTEXT";	
			 --->