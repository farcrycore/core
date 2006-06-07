<cfcomponent extends="field" name="array" displayname="array" hint="Used to liase with Array type fields"> 


	<cffunction name="edit" access="public" output="true" returntype="string" hint="This is going to called from ft:object and will always be passed 'typename,stobj,stMetadata,fieldname'.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var stobj = structnew() / >
		
		<cfparam name="arguments.stMetadata.ftLibrarySelectedMethod" default="Selected">
		<cfparam name="arguments.stMetadata.ftLibrarySelectedListClass" default="thumbNailsWrap">
		<cfparam name="arguments.stMetadata.ftLibrarySelectedListStyle" default="">

		<!--- A UUID type MUST have a 'ftJoin' property --->
		<cfif not structKeyExists(stMetadata,"ftJoin")>
			<cfreturn "">
		</cfif>
		
		<!--- Create the Linked Table Type as an object  --->
		<cfset oData = createObject("component",application.types[stMetadata.ftJoin].typepath)>

		<cfsavecontent variable="returnHTML">
		<cfoutput>
			<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="#arguments.stObject[arguments.stMetaData.Name]#" />
			<div id="#arguments.fieldname#_1">
			<cfif Len(arguments.stObject[arguments.stMetaData.Name])>
				<cfif FileExists("#application.path.project#/webskin/#arguments.stMetadata.ftJoin#/#arguments.stMetadata.ftLibrarySelectedMethod#.cfm")>
					<cfset stobj = oData.getData(objectid=#arguments.stObject[arguments.stMetaData.Name]#)>
					<cfinclude template="/farcry/#application.applicationname#/webskin/#arguments.stMetadata.ftJoin#/#arguments.stMetadata.ftLibrarySelectedMethod#.cfm">
				<cfelse>
					#arguments.stObject[arguments.stMetaData.Name]#
				</cfif>
				<a href="##" onclick="new Effect.Fade($('#arguments.fieldname#_1'));Element.remove('#arguments.fieldname#_1');$('#arguments.fieldname#').value = ''; return false;"><img src="#application.url.farcry#/images/crystal/22x22/actions/button_cancel.png" style="width:16px;height:16px;" /></a>
			</cfif>
			</div>
		
			<script type="text/javascript" language="javascript" charset="utf-8">
			function update_#arguments.fieldname#_wrapper(HTML){
				$('#arguments.fieldname#-wrapper').innerHTML = HTML;
						 
			}
			</script>
				
		</cfoutput>	
		</cfsavecontent>
		
 		<cfreturn ReturnHTML>
		
	</cffunction>
	
	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfparam name="arguments.stMetadata.ftLibrarySelectedMethod" default="Selected">
		<cfparam name="arguments.stMetadata.ftLibrarySelectedListClass" default="thumbNailsWrap">
		<cfparam name="arguments.stMetadata.ftLibrarySelectedListStyle" default="">
		
		
		<!--- A UUID type MUST have a 'ftJoin' property --->
		<cfif not structKeyExists(stMetadata,"ftJoin")>
			<cfreturn "">
		</cfif>
				
		<!--- Create the Linked Table Type as an object  --->
		<cfset oData = createObject("component",application.types[stMetadata.ftJoin].typepath)>
		

		<cfsavecontent variable="returnHTML">
		<cfoutput>
			
			<cfif Len(arguments.stObject[arguments.stMetaData.Name])>
				<cfset stobj = oData.getData(objectid=#arguments.stObject[arguments.stMetaData.Name]#)>
				<cfif FileExists("#application.path.project#/webskin/#arguments.stMetadata.ftJoin#/#arguments.stMetadata.ftLibrarySelectedMethod#.cfm")>
					
					<cfinclude template="/farcry/#application.applicationname#/webskin/#arguments.stMetadata.ftJoin#/#arguments.stMetadata.ftLibrarySelectedMethod#.cfm">
				<cfelse>
					#stobj.label#
				</cfif>
			</cfif>
				
		</cfoutput>
		</cfsavecontent>
		
		<cfreturn returnHTML>
	</cffunction>

	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew()>		
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = "">
		<cfset stResult.stError = StructNew()>
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->
		<cfset stResult.value = stFieldPost.Value>
		
		
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>
		
</cfcomponent> 