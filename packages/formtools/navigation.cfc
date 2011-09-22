<!--- @@description:
	<p>Different rendering options to output a representation of the site navigation tree</p> --->

<!--- @@examples:
	<p>Basic</p>
	<code>
	<cfproperty
 			ftSeq="15"
 			ftFieldset="Navigation"
 			name="navigationPoint"
	 		type="text"
	 		hint="navigation point"
	 		required="false"
	 		default=""
	 		ftLabel="Navigation"
 			ftType="navigation"
			ftDepth="4"
			ftAlias="home"
			ftIncludeRoot="true" />
	</code> 
--->

<cfcomponent extends="field" name="navigation" displayname="navigation" hint="Field component to liase with all navigation field types"> 
	
	<cfproperty name="ftAlias" required="false" default="" hint="A valid nav alias to begin the tree from" />
	<cfproperty name="ftLegend" required="false" default="" options="dropdown,prototype,jquery" hint="A legend for the fieldset" />
	
	<!--- import tag libraries --->
	<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >

		
	<cffunction name="init" access="public" returntype="farcry.core.packages.formtools.navigation" output="false" hint="Returns a copy of this initialised object">
		<cfreturn this>
	</cffunction>
	
	<cffunction name="edit" access="public" output="false" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfset var navid = "" />
		<cfset var lSelectedNaviIDs = "" />
		<cfset var i = "" />
		<cfset var html = "" />
		<cfset var lCategoryBranch = "" />
		<cfset var CategoryName = "" />
		<cfset var oNav = createObject("component",application.stCOAPI.dmNavigation.packagepath) />
		<cfset var stNav = structnew() />
		<cfset var rootID = "" />
		
		<cfparam name="arguments.stMetadata.ftAlias" default="" type="string" />
		<cfparam name="arguments.stMetadata.ftLegend" default="" type="string" />
		
		<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />
		
		<cfif structkeyexists(arguments.stMetadata,"ftWatch") and len(arguments.stObject[arguments.stMetadata.ftWatch])>
			<cfset rootID = arguments.stObject[arguments.stMetadata.ftWatch] />
		<cfelseif structKeyExists(application.navid, arguments.stMetadata.ftAlias)>
			<cfset rootID = application.navid[arguments.stMetadata.ftAlias] >
		<cfelse>
			<cfset rootID = application.navid['root'] >
		</cfif>

		<cfset stNav = oNav.getData(objectid=rootID) />

		<cfif isArray(arguments.stObject['#arguments.stMetadata.name#'])>
			<cfset lSelectedNaviIDs = arrayToList(arguments.stObject['#arguments.stMetadata.name#']) />
		<cfelse>
			<cfset lSelectedNaviIDs = arguments.stObject['#arguments.stMetadata.name#'] />
		</cfif>
		
		<cfset rootNodeText = stNav.label />
		
		<cfreturn editDropdownTree(typename,stObject,stMetadata,fieldname,lSelectedNaviIDs,rootID) />
	</cffunction>
	
	<cffunction name="editDropdownTree" access="public" output="false" returntype="string" hint="Returns the edit UI for the dropdown">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		<cfargument name="lSelectedNavIDs" required="true" type="string" hint="The selected nodes">
		<cfargument name="rootid" required="true" type="string" hint="The root node">
		
		<cfset var html = "" />
		<cfset var oTree = createObject("component", "#application.packagepath#.farcry.tree") />
		<cfset var qNodes = querynew("empty") />
		<cfset var rootlevel = -1 />
		
		<cfparam name="arguments.stMetadata.ftSelectMultiple" default="true" type="boolean" />
		<cfparam name="arguments.stMetadata.ftSelectSize" default="5" type="numeric" />
		<cfparam name="arguments.stMetadata.ftDropdownFirstItem" default="-- Select --" type="string" />
		<cfparam name="arguments.stMetadata.ftDepth" default="4" />
		<cfparam name="arguments.stMetadata.ftIncludeRoot" default="false" />
		
		<cfset qNodes = oTree.getDescendants(dsn=application.dsn, objectid=arguments.rootid,depth=arguments.stMetadata.ftDepth,bIncludeSelf=arguments.stMetadata.ftIncludeRoot) />
		
		<cfsavecontent variable="html">
			<cfoutput>
				<select id="#arguments.fieldname#" name="#arguments.fieldname#" class="selectInput #arguments.stMetadata.ftClass#" style="#arguments.stMetadata.ftStyle#"<cfif arguments.stMetadata.ftSelectMultiple> multiple="multiple"</cfif>>
					<option value="">#arguments.stMetadata.ftDropdownFirstItem#</option>
			</cfoutput>
			
			<cfloop query="qNodes">
				<cfif rootlevel eq -1><cfset rootlevel = qNodes.nlevel /></cfif>
				<cfoutput><option value="#objectid#"<cfif listFindNoCase(arguments.stMetadata.value, objectid) or arguments.stMetadata.value eq objectid> selected="selected"</cfif>>#RepeatString("-&nbsp;", qNodes.nlevel-rootlevel)##qNodes.objectName#</option></cfoutput>
			</cfloop>
			
			<cfoutput></select><input type="hidden" name="#arguments.fieldname#" value=""><br style="clear: both;"/></cfoutput>
		</cfsavecontent>
		
		<cfreturn html />
	</cffunction>
	
	<cffunction name="display" access="public" output="false" returntype="string" hint="This will return a string of formatted HTML text to display.">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var stNav = structNew() />
		
		<cfif len(arguments.stmetadata.value)>
			<cfset stNav = createobject("component", application.types.dmnavigation.typepath).getdata(objectid=arguments.stmetadata.value) />
			<cfset html=stNav.title />
		<cfelse>
			<cfset html="No navigation folder defined.">
		</cfif>
		
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



