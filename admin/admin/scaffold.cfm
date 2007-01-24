<cfsetting enablecfoutputonly="yes">

<cfparam name="URL.typename" default="" />

<!--- check permissions --->
<cfif NOT request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminCOAPITab")>	
	<admin:permissionError>
	<cfabort>
</cfif>

<cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="ft" >



<ft:processForm Action="Create Now">

	
<cffunction name="genDocument" returntype="string">
	<cfargument name="docProps" type="struct" required="true" />
	<cfargument name="typeName" type="string" required="true" />
	<cfargument name="projectName" type="string" required="true" />
	<cfargument name="projectDir" type="string" required="true" />
	
	<cfset var result = "">
	<cfset var fullpath = "">
	<cfset var docContent = docProps.content />
	<cfset var stTypeProperties = structNew() />
	<cfset var lColumnList = "" />
	<cfset var lSortableColumns = "" />
	<cfset var lFilterFields = "" />
	
	
	<cfset docProps.filename = replaceNoCase(docProps.filename,"[TYPENAME]",lcase(typeName)) />
	<cfset docProps.package = replaceNoCase(docProps.package,"[TYPENAME]",lcase(typeName)) />
	
	
	<cfset docContent = replaceNoCase(docContent, "[PROJECTNAME]", projectName, "all") />
	<cfset docContent = replaceNoCase(docContent, "[TYPENAME]", typeName, "all") />
	
	 <!--- set the values of ColumnList, SortableColumns and lFilterFields. If none are checked default to label --->
	<cfset stTypeProperties = getTypeProperties(form.sTypeName) />
	<cfloop list="#structKeyList(stTypeProperties)#" index="key">
		
		<!--- user wants this property in the ColumnList of objectAdmin --->
		<cfif structKeyExists(form, "#key#_columnList")>
			<cfset lColumnList = listAppend(lColumnList, key) />
		</cfif>
		
		<!--- user wants this property in the SortableColumns of objectAdmin --->
		<cfif structKeyExists(form, "#key#_sortableColumns")>
			<cfset lSortableColumns = listAppend(lSortableColumns, key) />		
		</cfif>
		
		<!--- user wants this property in the lFilterFields of objectAdmin --->
		<cfif structKeyExists(form, "#key#_filterFields")>
			<cfset lFilterFields = listAppend(lFilterFields, key) />		
		</cfif>				
		
	</cfloop>
	<cfif NOT len(lColumnList)>
		<cfset lColumnList = "label" />
	</cfif>
	<cfif NOT len(lSortableColumns)>
		<cfset lSortableColumns = "label" />
	</cfif>
	<cfif NOT len(lFilterFields)>
		<cfset lFilterFields = "label" />
	</cfif>		
	
	<cfset docContent = replaceNoCase(docContent, "[COLUMNLIST]", lColumnList, "all") />
	<cfset docContent = replaceNoCase(docContent, "[SORTABLECOLUMNS]", lSortableColumns, "all") />
	<cfset docContent = replaceNoCase(docContent, "[FILTERFIELDS]", lFilterFields, "all") />
	
	
	<cfset fullpath = "#projectDir##docProps.package#">

	<cfif not directoryExists("#fullpath#")>
		<cfdirectory action="create" directory="#fullpath#">
	</cfif>
	
	<cfif fileExists("#fullpath#/#docProps.filename#")>
		<cfset result="<p>#docProps.filename# already exists in #fullpath#/#docProps.filename#</p>">
	<cfelse>
		<cftry>
			<cffile action="write" file="#fullpath#/#docProps.filename#" output="#trim(docContent)#" >
			<cfset result="<p>CREATED: #fullpath#/#docProps.filename#</p>">
			
			<cfcatch type="any">
				<cfset result="<p>ERROR CREATING: #fullpath#/#docProps.filename#</p>">
			</cfcatch>
		</cftry>
	</cfif>

	<cfreturn result>
</cffunction>	
	
	
	
	
	<cfif structKeyExists(form, "scaffold")>

		<cfloop list="#form.scaffold#" index="FilePath">

			
			<!--- define folder path --->
			<cfset docProps = getScaffoldProps(filePath="#FilePath#") />	
			<cfset result = genDocument(docProps,url.typename, application.applicationname,application.path.PROJECT)>
			
			<cfoutput>#result#</cfoutput>
		</cfloop>
	
		
	</cfif>
</ft:processForm>

<ft:processForm Action="Cancel" Exit="true" />


<ft:form>

	<cfoutput>
	<p>WHICH SCAFFOLDS WOULD YOU LIKE TO CREATE</p>
	
	<h3>CUSTOM ADMIN</h3>
	<cfset q = getScaffolds(scaffoldPath="/customAdmin") />
	<table border="1">
	<cfloop query="q">
		<cfset stScaffoldProps = getScaffoldProps(filePath="#q.Directory#/#q.Name#") />
		<tr>
			<td><input type="checkbox" name="scaffold" value="#q.Directory#/#q.Name#" /></td>
			<td>
				<strong>#stScaffoldProps.label#</strong><br />
				#stScaffoldProps.description#
			</td>
		</tr>
	</cfloop>
	</table>
	
	<h3>CUSTOM LISTS</h3>
	<cfset q = getScaffolds(scaffoldPath="/customadmin/customLists") />
	
	<table border="1">
	<cfloop query="q">
		<cfset stScaffoldProps = getScaffoldProps(filePath="#q.Directory#/#q.Name#") />
		<tr>
			<td><input type="checkbox" name="scaffold" value="#q.Directory#/#q.Name#" /></td>
			<td>
				<strong>#stScaffoldProps.label#</strong><br />
				#stScaffoldProps.description#
			</td>
		</tr>
	</cfloop>
	</table>
	
	<h3>CUSTOM RULES</h3>
	<cfset q = getScaffolds(scaffoldPath="/rules") />
	<table border="1">
	<cfloop query="q">
		<cfset stScaffoldProps = getScaffoldProps(filePath="#q.Directory#/#q.Name#") />
		<tr>
			<td><input type="checkbox" name="scaffold" value="#q.Directory#/#q.Name#" /></td>
			<td>
				<strong>#stScaffoldProps.label#</strong><br />
				#stScaffoldProps.description#
			</td>
		</tr>
	</cfloop>
	</table>
	
	
	<h3>CUSTOM WEBSKINS</h3>
	<cfset q = getScaffolds(scaffoldPath="/webskin") />
	<table border="1">
	<cfloop query="q">
		<cfset stScaffoldProps = getScaffoldProps(filePath="#q.Directory#/#q.Name#") />
		<tr>
			<td><input type="checkbox" name="scaffold" value="#q.Directory#/#q.Name#" /></td>
			<td>
				<strong>#stScaffoldProps.label#</strong><br />
				#stScaffoldProps.description#
			</td>
		</tr>
	</cfloop>
	</table>
	
	
	<h1>Type Properties</h1>
	<cfset stTypeProperties = getTypeProperties(URL.typename) />
	
	<input type="hidden" name="sTypeName" id="sTypeName" value="#URL.typeName#" />
	<table border="1" cellpadding="5">
		<tr>
			<th>Property Name</th>
			<th>Column List</th>
			<th>Sortable Columns</th>
			<th>Filter Fields</th>
		</tr>
		
		<cfloop list="#structKeyList(stTypeProperties)#" index="key">
			
			<!--- we're not interested in array types --->
			<cfif stTypeProperties[key].type NEQ "array">
				
				<tr>
					<td>#stTypeProperties[key].name#</td>
					<td><input type="checkbox" name="#stTypeProperties[key].name#_columnList" id="#stTypeProperties[key].name#_columnList" value="1" /></td>
					<td><input type="checkbox" name="#stTypeProperties[key].name#_sortableColumns" id="#stTypeProperties[key].name#_sortableColumns" value="1" /></td>
					<td><input type="checkbox" name="#stTypeProperties[key].name#_filterFields" id="#stTypeProperties[key].name#_filterFields" value="1" /></td>
				</tr>
				
			</cfif>
			
		</cfloop>
	
	</table>


	
<!--- 	<cfabort>
	
	<input type="checkbox" name="scaffold" value="customAdmin" /> Custom Admin<br />
	<input type="checkbox" name="scaffold" value="webskin" /> Webskins<br />
	<input type="checkbox" name="scaffold" value="rule" /> Rule<br /> --->
 

	<div class="formsection">
		<ft:farcrybutton value="Create Now" />	
		<ft:farcrybutton value="Cancel" />
	</div>
	</cfoutput>
</ft:form>



	<cffunction name="getScaffolds" returntype="query" access="public" output="false" hint="Returns a query of all available webskins. Search through project first, then any library's that have been included.">
		<cfargument name="scaffoldPath" required="true" type="string">
		
		<cfset var qResult=queryNew("name,directory,size,type,datelastmodified,attributes,mode") />
		<cfset var qLibResult=queryNew("name,directory,size,type,datelastmodified,attributes,mode") />
		<cfset var qDupe=queryNew("name,directory,size,type,datelastmodified,attributes,mode") />
		<cfset var FullScaffoldPath = "" />
		<cfset var library="" />
		<cfset var col="" />

		<!--- check project webskins --->
		<cfset FullScaffoldPath = ExpandPath("/farcry/#application.applicationname#/scaffolds#scaffoldPath#") />
		<cfif directoryExists(FullScaffoldPath)>
			<cfdirectory action="list" directory="#FullScaffoldPath#" name="qResult" filter="*.txt" sort="asc" />
		</cfif>
	
		<!--- check library webskins --->
		<cfif structKeyExists(application, "lFarcryLib") and Len(application.lFarcryLib)>

			<cfloop list="#application.lFarcryLib#" index="library">
				<cfset FullScaffoldPath=ExpandPath("/farcry/farcry_lib/#library#/scaffolds#scaffoldPath#") />
				
				<cfif directoryExists(FullScaffoldPath)>
					<cfdirectory action="list" directory="#FullScaffoldPath#" name="qLibResult" filter="*.txt" sort="asc" />

					<cfloop query="qLibResult">
						<cfquery dbtype="query" name="qDupe">
						SELECT * FROM qResult
						WHERE lower(name) = '#lcase(qLibResult.name)#'
						</cfquery>
						
						<cfif NOT qDupe.Recordcount>
							<cfset queryaddrow(qresult,1) />
							<cfloop list="#qlibresult.columnlist#" index="col">
								<cfset querysetcell(qresult, col, qlibresult[col][1]) />
							</cfloop>
						</cfif>
						
					</cfloop>
				</cfif>	
				
			</cfloop>
			
		</cfif>
		
		<!--- check core scaffolds --->
		<cfset FullScaffoldPath=ExpandPath("/farcry/farcry_core/admin/admin/scaffolds#scaffoldPath#") />
		
		<cfif directoryExists(FullScaffoldPath)>
			<cfdirectory action="list" directory="#FullScaffoldPath#" name="qCoreResult" filter="*.txt" sort="asc" />
			
			
			<cfloop query="qCoreResult">
				<cfquery dbtype="query" name="qDupe">
				SELECT * FROM qResult
				WHERE lower(name) = '#lCase(qCoreResult.name)#'
				</cfquery>
				
				<cfif NOT qDupe.Recordcount>
					<cfset queryaddrow(qresult,1) />
					<cfloop list="#qlibresult.columnlist#" index="col">
						<cfset querysetcell(qresult, col, qCoreResult[col][1]) />
					</cfloop>
				</cfif>
				
			</cfloop>
					
								
		</cfif>
		
					
 		<cfquery dbtype="query" name="qResult">
		SELECT * FROM qResult
		ORDER BY name
		</cfquery>

		<cfreturn qresult />
	</cffunction>
	
		
	<cffunction name="getScaffoldProps" returntype="struct" output="true" hint="return package, filename and content from scaffold file">
		<cfargument name="filePath" required="true" />
		
		<cfset var stResult = structNew() />
		<cfset var startPos = "" />
		<cfset var endPos = "" />
		

		<!--- EXTRACT THE SCAFFOLD METADATA --->
		<cffile action="read" file="#arguments.filePath#" variable="fileContent" />

		<cfset startPos = findNocase("<scaffold>", fileContent) />
		<cfset endPos = findNocase("</scaffold>", fileContent) />
				
		
				
		<cfif startPos neq 0 and endPos neq 0>
			<cfset endPos = endPos + len("</scaffold>") />
			<cfset scaffoldString = mid(fileContent, startPos, endPos-startPos) />
	
			<cfxml variable="ScaffXML">
			  <cfoutput>#scaffoldString#</cfoutput>
			</cfxml>
			
			<cfset tmpXmlnode = XmlSearch(ScaffXML, "/scaffold/label") />
			<cfif arraylen(tmpXmlnode) gt 0>
				<cfset stResult.label = tmpXmlnode[1].XmlText />
			<cfelse>
				<cfset stResult.label = "not found" />
			</cfif>
			
			<cfset tmpXmlnode = XmlSearch(ScaffXML, "/scaffold/description") />	
			<cfif arraylen(tmpXmlnode) gt 0>
				<cfset stResult.description = tmpXmlnode[1].XmlText />
			<cfelse>
				<cfset stResult.description = "not found" />
			</cfif>
			
			<cfset tmpXmlnode = XmlSearch(ScaffXML, "/scaffold/filename") />
			<cfif arraylen(tmpXmlnode) gt 0>
				<cfset stResult.filename = tmpXmlnode[1].XmlText />
			<cfelse>
				<cfset stResult.filename = "not found" />
			</cfif>
			
			<cfset tmpXmlnode = XmlSearch(ScaffXML, "/scaffold/package") />	
			<cfif arraylen(tmpXmlnode) gt 0>
				<cfset stResult.package = tmpXmlnode[1].XmlText />
			<cfelse>
				<cfset stResult.package = "not found" />
			</cfif>
	
			<cfset stResult.content = replace(fileContent,scaffoldString,"") />
		</cfif>	
				
		<cfreturn stResult />
	</cffunction>
	
	
	<cffunction name="getTypeProperties" access="private" output="false" returntype="struct" hint="Introspect the current 'type' and return a structure of properties so the user can decide what to use in the scaffolding">
		<cfargument name="typeName" type="string" required="true" hint="Typename to introspect" />
		
		<cfscript>
	
			var stReturn = structNew();
			var oCustomType = "";
			var oTypeMetadata = "";
			
			oCustomType = createObject("component", "farcry.#application.applicationName#.packages.types.#arguments.typeName#");	//instantiate the custom type to introspect
			oTypeMetadata = createObject("component", "farcry.fourq.TableMetadata").init();	//instansiate the Fourq class to access introspection methods
			oTypeMetadata.parseMetadata(md=getMetadata(oCustomType));	//generate the metadata
			stReturn = oTypeMetadata.getTableDefinition();	//retrieve the generated metadata
		
			return stReturn;
		
		</cfscript>
		
	</cffunction>
	
	
<cfsetting enablecfoutputonly="no">