




<cfcomponent extends="field" name="list" displayname="list" hint="Field component to liase with all list field types"> 

	<cfimport taglib="/farcry/farcry_core/tags/widgets/" prefix="widgets">
	<cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="ft" >
	
	<cffunction name="init" access="public" returntype="farcry.farcry_core.packages.formtools.list" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="false" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfparam name="arguments.stMetadata.ftList" default="">
		<cfparam name="arguments.stMetadata.ftRenderType" default="dropdown">
		<cfparam name="arguments.stMetadata.ftSelectMultiple" default="false">
		

		<cfif len(arguments.stMetadata.ftList)>
			<cfswitch expression="#arguments.stMetadata.ftRenderType#">
				
				<cfcase value="dropdown">
								
					<cfsavecontent variable="html">
						<cfoutput><select id="#arguments.fieldname#" name="#arguments.fieldname#" <cfif arguments.stMetadata.ftSelectMultiple> multiple="true"</cfif>></cfoutput>
							<cfloop list="#arguments.stMetadata.ftList#" index="i">
								<cfoutput><option value="#ListFirst(i,":")#" <cfif listFindNoCase(arguments.stMetadata.value,#ListFirst(i,":")#)>selected</cfif>>#ListLast(i , ":")#</option></cfoutput>
							</cfloop>
							<cfoutput></select></cfoutput>
						</cfsavecontent>
					</cfcase>
					
					<cfcase value="checkbox">
						<cfsavecontent variable="html">
							
							<cfoutput>
								<cfloop list="#arguments.stMetadata.ftList#" index="i">
									
									<div class="fieldsection optional">
										<div class="fieldwrap">
										<input type="checkbox" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#ListFirst(i,":")#" <cfif listFindNoCase(arguments.stMetadata.value,i)>checked</cfif> />
										<label class="fieldsectionlabel" class="fieldsectionlabel" for="#arguments.fieldname#">#ListLast(i , ":")#</label>
										</div>
										<br class="fieldsectionbreak" />
									</div>
									
								</cfloop>												
							</cfoutput>
										
						</cfsavecontent>
					</cfcase>
					
					<cfcase value="radio">
						<cfsavecontent variable="html">
							
							<cfoutput>
								<cfloop list="#arguments.stMetadata.ftList#" index="i">
									
										
										<input type="radio" name="#arguments.fieldname#" id="#arguments.fieldname#" value="#ListFirst(i,":")#" <cfif listFindNoCase(arguments.stMetadata.value,i)>checked</cfif> />
										<label class="fieldsectionlabel" class="fieldsectionlabel" for="#arguments.fieldname#">#ListLast(i , ":")#</label>
										<br />
									
									
								</cfloop>												
							</cfoutput>
										
						</cfsavecontent>
					</cfcase>
					
				</cfswitch>
			<cfelse>
				<cfset html = "" />
			</cfif>
			<cfreturn html>
		</cffunction>
	
		<cffunction name="display" access="public" output="true" returntype="string" hint="This will return a string of formatted HTML text to display.">
			<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
			<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
			<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
			<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
			
	
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
	
	
	
