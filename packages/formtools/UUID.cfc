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
				<input type="text" id="#arguments.fieldname#" name="#arguments.fieldname#" value="#arguments.stObject[arguments.stMetaData.Name]#" />
				<cfif Len(arguments.stObject[arguments.stMetaData.Name])>
					<cfif FileExists("#application.path.project#/webskin/#arguments.stMetadata.ftJoin#/#arguments.stMetadata.ftLibrarySelectedMethod#.cfm")>
						<cfset stobj = oData.getData(objectid=i)>
						<cfinclude template="/farcry/#application.applicationname#/webskin/#arguments.stMetadata.ftJoin#/#arguments.stMetadata.ftLibrarySelectedMethod#.cfm">
					<cfelse>
						#i#
					</cfif>

				</cfif>
			
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
		
		<!--- We need to get the Array Field Items as a query --->
		<cfset o = createObject("component",application.types[arguments.typename].typepath)>
		<cfset q = o.getArrayFieldAsQuery(objectid="#arguments.stObject.ObjectID#", Typename="#arguments.typename#", Fieldname="#stMetadata.Name#", ftJoin="#stMetadata.ftJoin#")>
	
		<!--- Create the Linked Table Type as an object  --->
		<cfset oData = createObject("component",application.types[stMetadata.ftJoin].typepath)>

		<cfsavecontent variable="returnHTML">
		<cfoutput>
				
			<cfset ULID = "#arguments.fieldname#_list">
			
			<cfif q.RecordCount>
				<ul id="#ULID#" class="#arguments.stMetadata.ftLibrarySelectedListClass#" style="#arguments.stMetadata.ftLibrarySelectedListStyle#">
					<cfloop query="q">
						<li id="#arguments.fieldname#_#q.objectid#">
							
							<div>
							<cfif FileExists("#application.path.project#/webskin/#arguments.stMetadata.ftJoin#/#arguments.stMetadata.ftLibrarySelectedMethod#.cfm")>
								<cfset stobj = oData.getData(objectid=q.ObjectID)>
								<cfinclude template="/farcry/#application.applicationname#/webskin/#arguments.stMetadata.ftJoin#/#arguments.stMetadata.ftLibrarySelectedMethod#.cfm">
							<cfelse>
								<cfif isDefined("q.label") AND len(q.label)>#q.Label#<cfelse>#q.ObjectID#</cfif>
							</cfif>
							</div>
													
						</li>
					</cfloop>
				</ul>
			</cfif>

				
		</cfoutput>
		</cfsavecontent>
		
		<cfreturn returnHTML>
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
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->
		
		
		<cfset aField = ArrayNew(1)>				
		<cfloop list="#stFieldPost.value#" index="i">
			<cfset ArrayAppend(aField,i)>
		</cfloop>
		
		<cfif not len(arguments.typename)>
			<cfset q4 = createObject("component","farcry.fourq.fourq")>
			<cfset arguments.typename = q4.findType(objectid=arguments.objectid)>
		</cfif>
		
		
		<cfset oPrimary = createObject("component",application.types[arguments.Typename].typepath)>
		<cfset variables.tableMetadata = createobject('component','farcry.fourq.TableMetadata').init() />
		<cfset tableMetadata.parseMetadata(md=getMetadata(oPrimary)) />		
		<cfset stFields = variables.tableMetadata.getTableDefinition() />
		<cfset o = createObject("component","farcry.fourq.gateway.dbGateway").init(dsn=application.dsn,dbowner="")>
		<cfset aProps = o.createArrayTableData(tableName=Typename & "_" & arguments.stMetadata.name,objectid=arguments.ObjectID,tabledef=stFields[arguments.stMetadata.name].Fields,aprops=aField)>


		<cfset stResult.value = aField>

		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>
		
</cfcomponent> 