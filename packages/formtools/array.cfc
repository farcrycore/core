<cfcomponent extends="field" name="array" displayname="array" hint="Used to liase with Array type fields"> 


	<cfimport taglib="/farcry/farcry_core/tags/webskin/" prefix="ws" >


	<cffunction name="edit" access="public" output="true" returntype="string" hint="This is going to called from ft:object and will always be passed 'typename,stobj,stMetadata,fieldname'.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObj" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfparam name="arguments.stMetadata.ftEditClass" default="">
		
		<cfset t = createObject("component",application.types[arguments.typename].typepath)>
		<cfset q = t.getArrayFieldAsQuery(objectid="#stObj.ObjectID#", Typename="#arguments.typename#", Fieldname="#stMetadata.Name#", ftLink="#stMetadata.ftLink#")>
	
		<cfset tftLink = createObject("component",application.types[stMetadata.ftLink].typepath)>

		<cfsavecontent variable="returnHTML">
		<cfoutput>
				
			<input type="hidden" id="#arguments.fieldname#" name="#arguments.fieldname#" value="#ValueList(q.ObjectID)#" />
			<cfif q.RecordCount>
				<ul id="#arguments.fieldname#list" class="#arguments.stMetadata.ftEditClass#" <cfif q.RecordCount GT 1>style="cursor:move;"</cfif>>
					<cfloop query="q">
						<li id="itemid_#q.objectid#">
							<cfif isDefined("stMetadata.ftArrayListLabel")>
								<cfinvoke component="#tftLink#" method="#stMetadata.ftArrayListLabel#">
									<cfinvokeargument name="objectID" value="#q.objectid#">
								</cfinvoke>
							<cfelseif isDefined("stMetadata.ftArrayListField")>
								#evaluate("q.#stMetadata.ftArrayListField#")#
							<cfelse>
								#q.objectid#
							</cfif>
							
							<a onclick="new Effect2.Fade($('itemid_#q.objectid#'));Element.remove('itemid_#q.objectid#');$('#arguments.fieldname#').value = Sortable.sequence('#arguments.fieldname#list'); return false;" href="##">[delete]</a>
						</li>
					</cfloop>
				</ul>
			</cfif>

			<cfif q.RecordCount>
				<script type="text/javascript" language="javascript" charset="utf-8">
				// <![CDATA[
				  Sortable.create('#arguments.fieldname#list',
				  {ghosting:false,constraint:false,hoverclass:'over',
				    onChange:function(element){$('#arguments.fieldname#').value = Sortable.sequence('#arguments.fieldname#list')},
				    
				  });
				// ]]>
				</script>
			</cfif>
				
		</cfoutput>
		</cfsavecontent>
		
		<cfif not isDefined("Request.renderedJSScriptaculous")>
			<cfsavecontent variable="JS">
				<cfoutput>
					<script src="#application.url.webroot#/js/scriptaculous/lib/prototype.js" type="text/javascript"></script>
					<script src="#application.url.webroot#/js/scriptaculous/src/scriptaculous.js" type="text/javascript"></script>
				</cfoutput>
			</cfsavecontent>
		
		
			<cfhtmlhead text="#JS#">
			<cfset Request.renderedJSScriptaculous = 1>
		</cfif>
		
		
		<cfreturn returnHTML>
		
	</cffunction>
	
	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObj" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">


		<cfparam name="arguments.stMetadata.ftEditClass" default="">
		
		<cfset t = createObject("component",application.types[arguments.typename].typepath)>
		<cfset q = t.getArrayFieldAsQuery(objectid="#stObj.ObjectID#", Typename="#arguments.typename#", Fieldname="#stMetadata.Name#", ftLink="#stMetadata.ftLink#")>
	
		<cfset tftLink = createObject("component",application.types[stMetadata.ftLink].typepath)>

		<cfsavecontent variable="returnHTML">
		<cfoutput>
				
			
			<cfif q.RecordCount>
				<ul id="#arguments.fieldname#list" class="#arguments.stMetadata.ftEditClass#">
					<cfloop query="q">
						<li id="itemid_#q.objectid#">
							<cfif isDefined("stMetadata.ftArrayListLabel")>
								<cfinvoke component="#tftLink#" method="#stMetadata.ftArrayListLabel#">
									<cfinvokeargument name="objectID" value="#q.objectid#">
								</cfinvoke>
							<cfelseif isDefined("stMetadata.ftArrayListField")>
								#evaluate("q.#stMetadata.ftArrayListField#")#
							<cfelse>
								#q.objectid#
							</cfif>
							
						</li>
					</cfloop>
				</ul>
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
		
		<cfset aField = ArrayNew(1)>				
		<cfloop list="#stFieldPost.value#" index="i">
			<cfset ArrayAppend(aField,i)>
		</cfloop>
		
		<cfset stResult.value = aField>
				

		
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>
		
</cfcomponent> 