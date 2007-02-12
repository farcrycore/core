<cfcomponent extends="field" name="list" displayname="list" hint="Field component to liase with all list field types"> 


	<!--- import tag libraries --->
	<cfimport taglib="/farcry/farcry_core/tags/widgets/" prefix="widgets" />
	<cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="ft" />
	

	<cffunction name="init" access="public" returntype="farcry.farcry_core.packages.formtools.list" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>

	
	<cffunction name="edit" access="public" output="false" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />

		<cfparam name="arguments.stMetadata.ftList" default="">
		<cfparam name="arguments.stMetadata.ftRenderType" default="dropdown">
		<cfparam name="arguments.stMetadata.ftSelectMultiple" default="false">
		<cfparam name="arguments.stMetadata.ftClass" default="">
		<cfparam name="arguments.stMetadata.ftstyle" default="">		
		<cfparam name="arguments.stMetadata.ftListData" default="" />
		
		
		<cfif len(arguments.stMetadata.ftListData) >
			<cfparam name="arguments.stMetadata.ftListDataTypename" default="#arguments.typename#" />
			
			<cfif structKeyExists(application.types, arguments.typename)>
				<cfset oList = createObject("component", application.types[arguments.stMetadata.ftListDataTypename].packagePath) />
			<cfelse>
				<cfset oList = createObject("component", application.rules[arguments.stMetadata.ftListDataTypename].packagePath) />
			</cfif>
			
			<cfinvoke component="#oList#" method="#arguments.stMetadata.ftListData#" returnvariable="arguments.stMetadata.ftList" />
		</cfif>
		

		<cfif len(arguments.stMetadata.ftList)>
			<cfswitch expression="#arguments.stMetadata.ftRenderType#">
				
				<cfcase value="dropdown">								
					<cfsavecontent variable="html">
						
						<cfoutput><select id="#arguments.fieldname#" name="#arguments.fieldname#" class="formList #arguments.stMetadata.ftClass#" style="#arguments.stMetadata.ftStyle#"<cfif arguments.stMetadata.ftSelectMultiple> multiple="multiple"</cfif>></cfoutput>
						<cfloop list="#arguments.stMetadata.ftList#" index="i">
							<cfoutput><option value="#ListFirst(i,":")#"<cfif listFindNoCase(arguments.stMetadata.value,#ListFirst(i,":")#)> selected="selected"</cfif>>#ListLast(i , ":")#</option></cfoutput>
						</cfloop>
						<cfoutput></select></cfoutput>
						
					</cfsavecontent>					
				</cfcase>
				
				<cfcase value="checkbox">
					<cfsavecontent variable="html">
						
						<cfoutput>
							<div class="fieldsection optional">
								<div class="fieldwrap">
									<cfloop list="#arguments.stMetadata.ftList#" index="i">
										<input type="checkbox" name="#arguments.fieldname#" class="formCheckbox" id="#arguments.fieldname#" value="#ListFirst(i,":")#"<cfif listFindNoCase(arguments.stMetadata.value,listFirst(i, ":"))> checked="checked"</cfif> />										
										<!--- <label class="fieldsectionlabel" class="fieldsectionlabel" for="#arguments.fieldname#">#ListLast(i , ":")#</label> --->
										<!--- MPS: styles aren't working so we are removing label for now until we have time to look at the css --->
										#ListLast(i , ":")#
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
									<cfloop list="#arguments.stMetadata.ftList#" index="i">
										<input type="radio" name="#arguments.fieldname#" id="#arguments.fieldname#" class="formCheckbox" value="#ListFirst(i,":")#"<cfif listFindNoCase(arguments.stMetadata.value,listFirst(i, ":"))> checked="checked"</cfif> />
										<!--- <label class="fieldsectionlabel" class="fieldsectionlabel" for="#arguments.fieldname#">#ListLast(i , ":")#</label> --->
										<!--- MPS: styles aren't working so we are removing label for now until we have time to look at the css --->
										#ListLast(i , ":")#
										<br class="fieldsectionbreak" />
									</cfloop>												
								</div>
							</div>
						</cfoutput>
									
					</cfsavecontent>
				</cfcase>
				
				<cfdefaultcase></cfdefaultcase>
					
			</cfswitch>
		</cfif>

		<cfreturn html />

	</cffunction>
	
	
	<cffunction name="display" access="public" output="true" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfparam name="arguments.stMetadata.ftList" default="" />
		<cfsavecontent variable="html">
			<cfloop list="#arguments.stMetadata.ftList#" index="i">			
				<cfif ListFirst(i,":") EQ arguments.stMetadata.value>
					<cfoutput>#ListLast(i,":")#</cfoutput>
				</cfif>
			</cfloop>
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
		<cfset stResult.value = "#arguments.stFieldPost.Value#">
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