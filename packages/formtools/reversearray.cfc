<cfcomponent extends="field" name="reversearray" displayname="reversearray" hint="Field component to liase with all list field types"> 

	<!--- import tag libraries --->
	<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
	
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.reversearray" output="false" hint="Returns a copy of this initialised object">
		
		<cfreturn this>
	</cffunction>

	<cffunction name="edit" access="public" output="false" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var qObjects = "" />
		<cfset var oPrimary = "" />
		<cfset var libraryData = "" />
		<cfset var qLibraryList = "" />
		<cfset var qCurrentlyAssigned = "" />

		<cfparam name="arguments.stMetadata.ftRenderType" default="dropdown" />
		<cfparam name="arguments.stMetadata.ftSelectMultiple" default="false" />
		<cfparam name="arguments.stMetadata.ftClass" default="" />
		<cfparam name="arguments.stMetadata.ftstyle" default="" />
		<cfparam name="arguments.stMetadata.ftJoin" />
		<cfparam name="arguments.stMetadata.ftJoinProperty" />
		<cfparam name="arguments.stMetadata.ftFirstListLabel" default="-- SELECT --">
		
		<cfif structkeyexists(arguments.stMetadata, "ftLibraryData") AND len(arguments.stMetadata.ftLibraryData)>	
			<cfset oPrimary = application.fapi.getContentType(arguments.typename) />
			
			<!--- use ftlibrarydata method from primary content type --->
			<cfif structkeyexists(oPrimary, arguments.stMetadata.ftLibraryData)>
				<cfinvoke component="#oPrimary#" method="#arguments.stMetadata.ftLibraryData#" returnvariable="libraryData">
					<cfinvokeargument name="primaryID" value="#arguments.stobject.objectid#" />
				</cfinvoke>					
				
				<cfif isStruct(libraryData)>
					<cfset qLibraryList = libraryData.q>
				<cfelse>
					<cfset qLibraryList = libraryData />
				</cfif>		
			</cfif>
		<cfelse>
			<!--- if nothing exists to generate library data then cobble something together --->
			<cfquery datasource="#application.dsn#" name="qLibraryList">
				select		o.objectid,o.label
				from		#application.dbowner##arguments.stMetadata.ftJoin# o
				order by	o.label
			</cfquery>
		</cfif>		
		
		<cfquery datasource="#application.dsn#" name="qCurrentlyAssigned">
		SELECT distinct parentID as objectid
		FROM #application.dbowner##arguments.stMetadata.ftJoin#_#arguments.stMetadata.ftJoinProperty#
		WHERE data = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stObject.objectid#" />
		</cfquery>
		
		
		<cfswitch expression="#arguments.stMetadata.ftRenderType#">
			
			<cfcase value="dropdown,list">								
				<cfsavecontent variable="html">
					<cfif qLibraryList.recordCount>
						<cfoutput><select id="#arguments.fieldname#" name="#arguments.fieldname#" class="selectInput #arguments.stMetadata.ftClass#" style="#arguments.stMetadata.ftStyle#"<cfif arguments.stMetadata.ftSelectMultiple> multiple="multiple"</cfif>></cfoutput>
						<cfif len(arguments.stMetadata.ftFirstListLabel)>
							<cfoutput><option value="">#arguments.stMetadata.ftFirstListLabel#</option></cfoutput>
						</cfif>					
						<cfloop query="qLibraryList">
							<cfoutput><option value="#qLibraryList.objectid#" <cfif listFindNoCase(valueList(qCurrentlyAssigned.objectid),qLibraryList.objectID)> selected</cfif>>#qLibraryList.label#</option></cfoutput>
						</cfloop>
						<cfoutput></select></cfoutput>
					<cfelse>
						<cfoutput><input type="hidden" name="#arguments.fieldname#" value=""><em>No options available.</em></cfoutput>
					</cfif>
					<cfoutput><br style="clear: both;"/></cfoutput>
				</cfsavecontent>					
			</cfcase>
			
			<cfcase value="checkbox">
				<cfsavecontent variable="html">
					
					<cfoutput>
						<div class="fieldsection optional">
							<div class="fieldwrap">
								<cfset tmpCount=0>
								<cfloop query="qLibraryList">
									<input type="checkbox" name="#arguments.fieldname#" class="checkboxInput #IIF(qLibraryList.recordcount eq currentrow ,DE(" #arguments.stMetadata.ftClass#"),DE(""))#" id="#arguments.fieldname#" value="#qLibraryList.objectid#" <cfif listFindNoCase(valueList(qCurrentlyAssigned.objectid),qLibraryList.objectID)> checked="checked"</cfif> />										
									#label#
									<br class="fieldsectionbreak" />
								</cfloop>
							</div>										
						</div>																					
					</cfoutput>
								
				</cfsavecontent>
			</cfcase>
			
			<cfcase value="radio">
				<cfsavecontent variable="html">
					
					<cfoutput>
						<div class="fieldsection optional">
							<div class="fieldwrap">
								<cfloop query="qLibraryList">
									<input type="radio" name="#arguments.fieldname#" id="#arguments.fieldname#"  class="formCheckbox #IIF(qLibraryList.recordcount eq currentrow,DE(" #arguments.stMetadata.ftClass#"),DE(""))#" value="#qLibraryList.objectid#" <cfif listFindNoCase(valueList(qCurrentlyAssigned.objectid),qLibraryList.objectID)> checked="checked"</cfif> />
									<br class="fieldsectionbreak" />
								</cfloop>												
							</div>
						</div>
					</cfoutput>
								
				</cfsavecontent>
			</cfcase>
			
			<cfdefaultcase></cfdefaultcase>
				
		</cfswitch>

		<cfreturn html />

	</cffunction>
	
	<cffunction name="display" access="public" output="true" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var i = "" />
		<cfset var html = "" />
		<cfset var oList = "" />
		
		<cfparam name="arguments.stMetadata.ftJoin" />
		<cfparam name="arguments.stMetadata.ftJoinProperty" />
		
		<cfquery datasource="#application.dsn#" name="qObjects">
			select		o.objectid,o.label,op.data
			from		#application.dbowner##arguments.stMetadata.ftJoin# o
						inner join
						#application.dbowner##arguments.stMetadata.ftJoin#_#arguments.stMetadata.ftJoinProperty# op
						on o.objectid=op.parentid
			where		op.data = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.stObject.objectid#" />
			order by	o.label
		</cfquery>
			
		<cfloop query="qObjects">			
			<cfif len(data)>
				<cfset html = listappend(html,label) />
			</cfif>
		</cfloop>
		
		<cfreturn html>
	</cffunction>
	
	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="ObjectID" required="true" type="UUID" hint="The objectid of the object that this field is part of.">
		<cfargument name="Typename" required="true" type="string" hint="the typename of the objectid.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var stResult = structNew() />
		<cfset var qObjects = "" />
		<cfset var o = "" />
		<cfset var stObject = "" />
		
		<cfparam name="arguments.stMetadata.ftJoin" />
		<cfparam name="arguments.stMetadata.ftJoinProperty" />
		
		<cfset stResult.bSuccess = true />
		<cfset stResult.value = "#arguments.stFieldPost.Value#" />
		<cfset stResult.stError = StructNew() />
		
		<!--- Update objects --->
		<cfset o = createObject("component", application.stcoapi[arguments.stMetadata.ftJoin].packagePath) />
		
		<cfquery datasource="#application.dsn#" name="qObjects">
			select		o.objectid,o.label,op.data,op.seq
			from		#application.dbowner##arguments.stMetadata.ftJoin# o
						left outer join
						#application.dbowner##arguments.stMetadata.ftJoin#_#arguments.stMetadata.ftJoinProperty# op
						on o.objectid=op.parentid and op.data = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.objectid#" />
			order by	o.label
		</cfquery>
		
		<cfloop query="qObjects">
			<cfset stObject = o.getData(qObjects.objectid[currentrow]) />
			<cfif len(data) and not listcontains(arguments.stFieldPost.value,qObjects.objectid[currentrow])>
				<cfset arraydeleteat(stObject[arguments.stMetadata.ftJoinProperty],seq) />
				<cfset o.setData(stObject) />
			<cfelseif not len(data) and listcontains(arguments.stFieldPost.value,qObjects.objectid[currentrow])>
				<cfset arrayappend(stObject[arguments.stMetadata.ftJoinProperty],arguments.objectid) />
				<cfset o.setData(stObject) />
			</cfif>
		</cfloop>
					
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>
	
</cfcomponent>