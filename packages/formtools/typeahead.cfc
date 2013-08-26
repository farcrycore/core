<cfcomponent hint="Type-ahead" extends="join" output="false">
	
	<cfproperty name="ftWatch" default="" hint="The properties in this list are submitted to ajax requests along with the current value. This is in contrast with the normal behaviour of ftWatch, which is to reload the entire field on a change in a watched field." />
	<cfproperty name="ftPlaceholder" default="Type to search" />
	<cfproperty name="ftJoin" required="true" hint="The related content type that this property joins to. Currently TYPEAHEAD only supports one content type, not a list as array and uuid do." />
	<cfproperty name="ftInlineData" default="false" hint="Set to true to put all available options inline. This is only really appropriate for relatively small, static data sets." />
	<cfproperty name="ftAllowCreate" default="true" hint="Set to false to disable the option to create a new object to attach" />
	<cfproperty name="ftValidStatus" default="all" hint="Specify the status filter on the returned objects. As well as an explicit list of statuses, this can also be 'all' or 'mode' (to use the current user's settings)">
	
	<!--- @@examples:
	<p>UUID field:</p>
	<code>
		<cfproperty 
			name="someImage" type="uuid" hint="Related content items." required="no" default="" 
			ftseq="43" ftfieldset="Related Content" ftwizardStep="News Body" ftlabel="One image"
			fttype="typeahead" ftJoin="dmImage" />
	</code>
	
	<p>Array field:</p>
	<code>
		<cfproperty 
			name="multipleImages" type="array" hint="Related content items." required="no" default="" 
			ftseq="44" ftfieldset="Related Content" ftwizardStep="News Body" ftlabel="Many images"
			fttype="typeahead" ftJoin="dmImage" />
	</code>
	
	<p>Inline data:</p>
	<code>
		<cfproperty 
			name="anotherImage" type="uuid" hint="Related content items." required="no" default="" 
			ftseq="45" ftfieldset="Related Content" ftwizardStep="News Body" ftlabel="Another image"
			fttype="typeahead" ftJoin="dmImage" ftInlineData="true" />
	</code>
	 --->
	
	
	<cffunction name="edit" access="public" output="true" returntype="string" hint="his will return a string of formatted HTML text to enable the user to edit the data">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">

		<cfset var html = "" />
		<cfset var createOptions = "" />
		<cfset var lValidStatus = "" />
		
		<cfparam name="arguments.stMetadata.ftWatch" default="" />
		<cfparam name="arguments.stMetadata.ftPlaceholder" default="Type to search" />
		<cfparam name="arguments.stMetadata.ftJoin" />
		<cfparam name="arguments.stMetadata.ftInlineData" default="false" />
		
		<cfparam name="arguments.stMetadata.ftAllowCreate" default="true" />
		<cfif arguments.stMetadata.ftAllowCreate>
			<cfset createOptions = arguments.stMetadata.ftJoin />
		</cfif>
		
		<cfparam name="arguments.stMetadata.ftValidStatus" default="all" />
		<cfswitch expression="#arguments.stMetadata.ftValidStatus#">
			<cfcase value="all"><cfset lValidStatus = "draft,approved,pending" /></cfcase>
			<cfcase value="mode"><cfset lValidStatus = request.mode.lValidStatus /></cfcase>
		</cfswitch>
		
		<cfif listlen(arguments.stMetadata.ftJoin)>
			<cfset arguments.stMetadata.ftJoin = listfirst(arguments.stMetadata.ftJoin) />
		</cfif>
		
		<!--- ftSelectMultiple is used by the library webskins --->
		<cfif not structkeyexists(arguments.stMetadata,"ftSelectMultiple")>
			<cfif arguments.stMetadata.type eq "array">
				<cfset arguments.stMetadata.ftSelectMultiple = true />
				<cfset application.stCOAPI[arguments.typename].stProps[arguments.stMetadata.name].metadata.ftSelectMultiple = true />
			<cfelse>
				<cfset arguments.stMetadata.ftSelectMultiple = false />
				<cfset application.stCOAPI[arguments.typename].stProps[arguments.stMetadata.name].metadata.ftSelectMultiple = false />
			</cfif>
		</cfif>
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		
		<skin:loadJS id="fc-jquery" />
		<skin:loadJS id="typeahead" />
		<skin:loadCSS id="typeahead" />
		
		<cfsavecontent variable="html">
			<cfoutput>
				<div class="multiField">
					<cfif arguments.stMetadata.ftInlineData>
						<input	type="hidden" class="typeahead" style="width:100%;" id="#arguments.fieldname#" name="#arguments.fieldname#" 
								data-typename="#arguments.typename#" 
								data-allowcreate="#arguments.stMetadata.ftAllowCreate#" 
								data-prefix="#left(arguments.fieldname,len(arguments.fieldname)-len(arguments.stMetadata.name))#" 
								data-objectid="#arguments.stObject.objectid#" 
								data-multiple="#arguments.stMetadata.type eq 'array'#" 
								data-watch="#arguments.stMetadata.ftWatch#" 
								data-placeholder="#arguments.stMetadata.ftPlaceholder#" 
								data-value="#convertPropertyToValue(arguments.stMetadata.value,arguments.stMetadata.ftJoin)#" 
								
								data-data="#replace(getResultsAsJSON(typename=arguments.stMetadata.ftJoin,search='',paginate=false,lValidStatus=lValidStatus),'"','&quot;','ALL')#"
								data-createoptions='#getCreatesAsJSON(createOptions=createOptions)#'
								
								value="<cfif arguments.stMetadata.type eq 'array'>#arraytolist(arguments.stMetadata.value)#<cfelse>#arguments.stMetadata.value#</cfif>" />
					<cfelse>
						<input	type="hidden" class="typeahead" style="width:100%;" id="#arguments.fieldname#" name="#arguments.fieldname#" 
								data-typename="#arguments.typename#" 
								data-allowcreate="#arguments.stMetadata.ftAllowCreate#" 
								data-prefix="#left(arguments.fieldname,len(arguments.fieldname)-len(arguments.stMetadata.name))#" 
								data-objectid="#arguments.stObject.objectid#" 
								data-multiple="#arguments.stMetadata.type eq 'array'#" 
								data-watch="#arguments.stMetadata.ftWatch#" 
								data-placeholder="#arguments.stMetadata.ftPlaceholder#" 
								data-value="#convertPropertyToValue(arguments.stMetadata.value,arguments.stMetadata.ftJoin)#" 
								
								data-ajaxurl="#jsstringformat(getAjaxURL(argumentCollection=arguments))#"
								
								value="<cfif arguments.stMetadata.type eq 'array'>#arraytolist(arguments.stMetadata.value)#<cfelse>#arguments.stMetadata.value#</cfif>" />
					</cfif>
					<input type="hidden" id="#arguments.fieldname#-add-type" value="#arguments.stMetadata.ftJoin#" />
				</div>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn html>
	</cffunction>
	
	<cffunction name="ajax" output="false" returntype="string" hint="Response to ajax requests for this formtool">
		<cfargument name="typename" required="true" type="string" hint="The name of the type that this field is part of.">
		<cfargument name="stObject" required="true" type="struct" hint="The object of the record that this field is part of.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		<cfargument name="fieldname" required="true" type="string" hint="This is the name that will be used for the form field. It includes the prefix that will be used by ft:processform.">
		
		<cfset var lValidStatus = "" />
		<cfset var createOptions = "" />
		<cfset var aResult = arraynew(1) />
		<cfset var st = structnew() />
		<cfset var id = "" />
		<cfset var html = "" />
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		
		<cfif isdefined("url.resolvelabels")>
			<cfloop list="#convertPropertyToValue(listtoarray(url.resolvelabels),arguments.stMetadata.ftJoin)#" index="id">
				<cfset st = structnew() />
				<cfset st["id"] = listfirst(id,"|") />
				<cfset st["text"] = listlast(id,"|") />
				
				<skin:view objectid="#st['id']#" typename="#arguments.typename#" webskin="librarySelected" alteranateHTML="#st['text']#" r_html="html" />
				<cfset st["librarySelected"] = trim(html) />
				
				<cfset arrayappend(aResult,st) />
			</cfloop>
			
			<cfcontent type="application/json" variable="#ToBinary( ToBase64( serializeJSON(aResult) ) )#" reset="yes" />
		<cfelse>
			<cfparam name="url.search" />
			<cfparam name="url.page" default="1" />
			<cfparam name="url.#arguments.stMetadata.name#" default="" />
			
			<cfparam name="arguments.stMetadata.ftAllowCreate" default="true" />
			<cfif arguments.stMetadata.ftAllowCreate>
				<cfset createOptions = arguments.stMetadata.ftJoin />
			</cfif>
			
			<cfparam name="arguments.stMetadata.ftValidStatus" default="all" />
			<cfswitch expression="#arguments.stMetadata.ftValidStatus#">
				<cfcase value="all"><cfset lValidStatus = "draft,approved,pending" /></cfcase>
				<cfcase value="mode"><cfset lValidStatus = request.mode.lValidStatus /></cfcase>
			</cfswitch>
			
			<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
			
			<cfcontent type="application/json" variable="#ToBinary( ToBase64( getResultsAsJSON(typename=arguments.stMetadata.ftJoin,search=url.search,page=url.page,excludeList=url[arguments.stMetadata.name],lValidStatus=lValidStatus,createOptions=createOptions) ) )#" reset="yes" />
		</cfif>
		
		<cfreturn "" />
	</cffunction>
	
	<cffunction name="validate" access="public" output="true" returntype="struct" hint="This will return a struct with bSuccess and stError">
		<cfargument name="ObjectID" required="true" type="UUID" hint="The objectid of the object that this field is part of.">
		<cfargument name="Typename" required="true" type="string" hint="the typename of the objectid.">
		<cfargument name="stFieldPost" required="true" type="struct" hint="The fields that are relevent to this field type.">
		<cfargument name="stMetadata" required="true" type="struct" hint="This is the metadata that is either setup as part of the type.cfc or overridden when calling ft:object by using the stMetadata argument.">
		
		<cfset var aField = ArrayNew(1) />
		<cfset var qArrayRecords = queryNew("blah") />
		<cfset var stResult = structNew()>	
		<cfset var i = "" />
		<cfset var lColumn = "" />
		<cfset var qArrayRecordRow = queryNew("blah") />
		<cfset var stArrayData = structNew() />
		<cfset var iColumn = "" />
		<cfset var qCurrentArrayItem = queryNew("blah") />
			
		<cfset stResult.bSuccess = true>
		<cfset stResult.value = "">
		<cfset stResult.stError = StructNew()>
		
		<!--- --------------------------- --->
		<!--- Perform any validation here --->
		<!--- --------------------------- --->
		<!---
		IT IS IMPORTANT TO NOTE THAT THE STANDARD ARRAY TABLE UI, PASSES IN A LIST OF DATA IDS WITH THEIR SEQ
		ie. dataid1:seq1,dataid2:seq2...
		 --->
		
		<cfif len(stFieldPost.value)>
			<!--- Remove any leading or trailing empty list items --->
			<cfif stFieldPost.value EQ ",">
				<cfset stFieldPost.value = "" />
			</cfif>
			<cfif left(stFieldPost.value,1) EQ ",">
				<cfset stFieldPost.value = right(stFieldPost.value,len(stFieldPost.value)-1) />
			</cfif>
			<cfif right(stFieldPost.value,1) EQ ",">
				<cfset stFieldPost.value = left(stFieldPost.value,len(stFieldPost.value)-1) />
			</cfif>	
			
			<cfif arguments.stMetadata.type eq "array">
				<cfquery datasource="#application.dsn#" name="qArrayRecords">
			    SELECT * 
			    FROM #application.dbowner##arguments.typename#_#stMetadata.name#
			    WHERE parentID = '#arguments.objectid#'
			    </cfquery>
			    	
				
				<cfloop list="#stFieldPost.value#" index="i">			
							
					<cfquery dbtype="query" name="qCurrentArrayItem">
				    SELECT * 
				    FROM qArrayRecords
				    WHERE data = '#listFirst(i,":")#'
				    <cfif listLast(i,":") NEQ listFirst(i,":")><!--- SEQ PASSED IN --->
				    	AND seq = '#listLast(i,":")#'
				    </cfif>
				    </cfquery>
				
					<!--- If it is an extended array (more than the standard 4 fields), we return the array as an array of structs --->
					<cfif listlen(qCurrentArrayItem.columnlist) GT 4>
						<cfset stArrayData = structNew() />
						
						<cfloop list="#qCurrentArrayItem.columnList#" index="iColumn">
							<cfif qCurrentArrayItem.recordCount>
								<cfset stArrayData[iColumn] = qCurrentArrayItem[iColumn][1] />
							<cfelse>
								<cfset stArrayData[iColumn] = "" />
							</cfif>
						</cfloop>
						
						<cfset stArrayData.seq = arrayLen(aField) + 1 />
						 
						<cfset ArrayAppend(aField,stArrayData)>
					<cfelse>
						<!--- Otherwise it is just an array of value --->
						<cfset ArrayAppend(aField, listFirst(i,":"))>
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
		
		<cfif arguments.stMetadata.type eq "array">
			<cfset stResult.value = aField>
		<cfelse>
			<cfset stResult.value = stFieldPost.value />
		</cfif>
		
		<!--- ----------------- --->
		<!--- Return the Result --->
		<!--- ----------------- --->
		<cfreturn stResult>
		
	</cffunction>
	
	
	<cffunction name="convertPropertyToValue" output="false" access="private" returntype="string" hint="Convert the array of objectids into the id:text string to use as the input value">
		<cfargument name="value" type="any" required="true" />
		<cfargument name="typename" type="string" required="true" />
		
		<cfset var i = 0 />
		<cfset var result = "" />
		<cfset var st = "" />
		<cfset var q = "" />
		
		<cfif not isarray(arguments.value)>
			<cfset arguments.value = listtoarray(arguments.value) />
		</cfif>
		
		<cfloop from="1" to="#arraylen(arguments.value)#" index="i">
			<cfif listlen(arguments.value[i],"|") eq 2>
				<cfset result = listappend(result,arguments.value[i]) />
			<cfelse>
				<cfif isValid("uuid", arguments.value[i])>
					<cfset st = application.fapi.getContentObject(objectid=arguments.value[i]) />
					<cfset result = listappend(result,"#st.objectid#|#st.label#") />
				</cfif>
			</cfif>
		</cfloop>
		
		<cfreturn result />
	</cffunction>
	
	<cffunction name="getResultsAsJSON" output="false" access="private" returntype="string">
		<cfargument name="typename" type="string" required="true" />
		<cfargument name="search" type="string" required="true" />
		<cfargument name="paginate" type="boolean" required="false" default="true" />
		<cfargument name="page" type="numeric" required="false" default="1" />
		<cfargument name="pageSize" type="numeric" required="false" default="15" />
		<cfargument name="excludeList" type="string" required="false" default="" />
		<cfargument name="lValidStatus" type="string" required="false" default="#request.mode.lValidStatus#" />
		<cfargument name="createOptions" type="string" required="false" default="" />
		
		<cfset var html = "" />
		<cfset var q = "" />
		<cfset var st = structnew() />
		<cfset var aResult = arraynew(1) />
		<cfset var i = 0 />
		
		<cfif structkeyexists(application.stCOAPI[arguments.typename].stProps,"versionID")>
			<cfset q = application.fapi.getContentObjects(typename=arguments.typename,lProperties="objectid,label",status=arguments.lValidStatus,label_like="%#arguments.search#%",objectid_notin=arguments.excludeList,versionid_eq="",orderby="label") />
		<cfelse>
			<cfset q = application.fapi.getContentObjects(typename=arguments.typename,lProperties="objectid,label",status=arguments.lValidStatus,label_like="%#arguments.search#%",objectid_notin=arguments.excludeList,orderby="label") />
		</cfif>
		
		<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
		
		<cfif not arguments.paginate>
			<cfloop query="q">
				<cfset st = structnew() />
				<cfset st["id"] = q.objectid />
				<cfset st["text"] = q.label />
				
				<skin:view objectid="#q.objectid#" typename="#arguments.typename#" webskin="librarySelected" alteranateHTML="#q.label#" r_html="html" />
				<cfset st["librarySelected"] = trim(html) />
				
				<cfset arrayappend(aResult,st) />
			</cfloop>
		<cfelseif (arguments.page - 1) * arguments.pageSize + 1 lte q.recordcount>
			<cfloop from="#(arguments.page - 1) * arguments.pageSize + 1#" to="#min((arguments.page) * arguments.pageSize,q.recordcount)#" index="i">
				<cfset st = structnew() />
				<cfset st["id"] = q.objectid[i] />
				<cfset st["text"] = q.label[i] />
				
				<skin:view objectid="#q.objectid[i]#" typename="#arguments.typename#" webskin="librarySelected" alteranateHTML="#q.label[i]#" r_html="html" />
				<cfset st["librarySelected"] = trim(html) />
				
				<cfset arrayappend(aResult,st) />
			</cfloop>
		</cfif>
		
		<cfloop list="#arguments.createOptions#" index="i">
			<cfset st = structnew() />
			<cfset st["id"] = "_" & i />
			<cfset st["text"] = "Create New " & application.stCOAPI[i].displayname />
			
			<cfset arrayappend(aResult,st) />
		</cfloop>
		
		<cfreturn serializeJSON(aResult) />
	</cffunction>
	
	<cffunction name="getCreatesAsJSON" output="false" access="private" returntype="string">
		<cfargument name="createOptions" type="string" required="true" default="" />
		
		<cfset var st = structnew() />
		<cfset var aResult = arraynew(1) />
		<cfset var i = 0 />
		
		<cfloop list="#arguments.createOptions#" index="i">
			<cfset st = structnew() />
			<cfset st["id"] = "_" & i />
			<cfset st["text"] = "Create New " & application.stCOAPI[i].displayname />
			
			<cfset arrayappend(aResult,st) />
		</cfloop>
		
		<cfreturn serializeJSON(aResult) />
	</cffunction>
	
</cfcomponent>