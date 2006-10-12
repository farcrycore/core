<cfcomponent displayname="FormTools" hint="All the methods required to run Farcry Form Tools">


<cfimport prefix="skin" taglib="/farcry/farcry_core/tags/webskin" />
<cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="ft" >


<cffunction name="getCurrentPaginationPage" access="public" output="true" returntype="numeric">
	<cfargument name="paginationID" required="No" type="string" default="" />
	<cfargument name="currentPage" required="No" type="string" default="0" />
	
	
	<cfif arguments.CurrentPage eq 0 or not isNumeric(arguments.currentPage)>
		<cfif isDefined("url.page")>
			<cfset arguments.CurrentPage = url.page>
		<cfelseif isDefined("form.paginationpage")>
			<cfset arguments.CurrentPage = form.paginationpage>		
		</cfif>
	</cfif>
		
	<cfif arguments.paginationID neq ""> <!--- use session key --->
		<cfparam name="session.ftPagination" default="#structNew()#" />
		<cfif not structKeyExists(session.ftPagination, arguments.paginationID)>
			<cfset session.ftPagination[arguments.paginationID] = 1 />
		</cfif>
		

		<cfif arguments.currentPage GT 0 and isNumeric(arguments.CurrentPage)>
			<cfset session.ftPagination[paginationID] = arguments.currentPage />
			
			
		<cfelseif session.ftPagination[paginationID] GT 1><!--- use the last url page after leaving master page --->
			<cfset arguments.CurrentPage = session.ftPagination[paginationID]>
		</cfif>		
		
		
			
	</cfif>	

	<cfif arguments.CurrentPage eq 0 or not isNumeric(arguments.currentPage)>
		<cfset arguments.CurrentPage = 1>
	</cfif>
	
	<cfreturn arguments.currentPage />
		
</cffunction>


<cffunction name="getRecordset" access="public" output="false" returntype="struct">
	<cfargument name="typename" required="No" type="string" default="" />
	<cfargument name="identityColumn" required="No" type="string" default="ObjectID" />
	<cfargument name="sqlColumns" required="No" type="string" default="tbl.ObjectID" />
	<cfargument name="sqlWhere" required="No" type="string" default="" />
	<cfargument name="sqlOrderBy" required="No" type="string" default="label" />
	<cfargument name="lCategories" required="No" type="string" default="" />
	
	<cfargument name="paginationID" required="No" type="string" default="" />	
	<cfargument name="CurrentPage" required="No" type="numeric" default="0" />
	<cfargument name="RecordsPerPage" required="No" type="numeric" default="10" />
	<cfargument name="PageLinksShown" required="No" type="numeric" default="5" />
	
	<cfset var stReturn = structNew() />
	<cfset var qFormToolRecordset = '' />
	<cfset var recordcount = '' />
	<cfset arguments.identityColumn = "tbl." & arguments.identityColumn>
	


	<cfset arguments.currentPage = getCurrentPaginationPage(paginationID=arguments.paginationID,CurrentPage=arguments.CurrentPage) />

	<!--- Ensure  if objectID provided in columns names prefixed it with tbl. --->
 	<cfif arguments.sqlColumns neq "*">	
		<cfif arguments.sqlColumns neq 'tbl.ObjectID'>
			<cfif listFindNoCase(arguments.sqlColumns,"ObjectID")>
				<cfset arguments.sqlColumns = ListDeleteAt(arguments.sqlColumns, listFindNoCase(arguments.sqlColumns,"ObjectID"))>
			</cfif>		
			<cfset arguments.sqlColumns="tbl.ObjectID," & sqlColumns>
		</cfif>
	<cfelse>
		<cfset arguments.sqlColumns="tbl.*">
	</cfif>


	<cfset arguments.lCategories = listQualify(arguments.lCategories,"'")>

	<cfif RecordsPerPage GT 0><!--- Start if pagination  --->

		<cfif NOT len(arguments.sqlWhere)>
			<cfset arguments.sqlWhere = "0=0" />
		</cfif>

		<cfset theSQLTop = arguments.CurrentPage * arguments.recordsPerPage>

		
			<cfquery name="qFormToolRecordset" datasource="#application.dsn#">

			IF OBJECT_ID('tempdb..##thetops') IS NOT NULL 	drop table ##thetops
			CREATE TABLE ##thetops (objectID varchar(40), myint int IDENTITY(1,1) NOT NULL)
			
				
			INSERT ##thetops (objectID)
			SELECT TOP #theSQLTop# tbl.objectid
			FROM #arguments.typename# tbl 
			
			<cfif arguments.lCategories neq ''>
				WHERE objectid in (
				    select distinct objectid 
				    from refCategories 
				    where categoryID in (#preserveSingleQuotes(arguments.lCategories)#)
				    )
				AND #preserveSingleQuotes(arguments.SqlWhere)#
			<cfelse>
				WHERE #preserveSingleQuotes(arguments.SqlWhere)#
			</cfif>
			<cfif len(arguments.sqlOrderBy)>
				ORDER BY #arguments.sqlOrderBy#
			</cfif>
			
			
			SELECT #arguments.sqlColumns#
			FROM #arguments.typename# tbl
			inner join  ##thetops t on tbl.objectid = t.objectid where t.myint > ((select count(*) from ##thetops) - #arguments.recordsPerPage#)
			
			
			drop table ##thetops
							
			</cfquery>
				
			
			<cfquery name="qrecordcount" datasource="#application.dsn#">
			SELECT count(distinct tbl.objectid) as CountAll 
			FROM #arguments.typename# tbl 
			
			<cfif arguments.lCategories neq ''>
				WHERE objectid in (
				    select distinct objectid 
				    from refCategories 
				    where categoryID in (#preserveSingleQuotes(arguments.lCategories)#)
				    )
				AND #preserveSingleQuotes(arguments.SqlWhere)#
			<cfelse>
				WHERE #preserveSingleQuotes(arguments.SqlWhere)#
			</cfif>
			</cfquery>
			
						
			<!---<cfstoredproc procedure="sp_selectview_bycat" datasource="#application.dsn#" result="spresult">
			    <cfprocresult name="q" resultset="1">
			    <cfprocresult name="qrecordcount" resultset="2">
			    
			    <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="TableName"  value="#arguments.typename#">
			    <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="Columns" value="#arguments.sqlColumns#">
			    <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="GroupNumber" value="#arguments.CurrentPage#">
			    <cfprocparam type="In"  cfsqltype="CF_SQL_VARCHAR" dbvarname="GroupSize" value="#arguments.recordsPerPage#">
			    <cfprocparam type="In" cfsqltype="CF_SQL_LONGVARCHAR" dbvarname="SqlWhere" value="#arguments.SqlWhere#">
			    <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="SqlOrderBy" value="#arguments.sqlOrderBy#">
			    <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="lCategories" value="#preserveSingleQuotes(arguments.lCategories)#">
			</cfstoredproc> --->
		

		<!------------------------------
		DETERMINE THE TOTAL PAGES
		 ------------------------------>
		<cfif isNumeric(qrecordcount.countAll) AND qrecordcount.countAll GT 0>
			<cfset stReturn.TotalPages = ceiling(qrecordcount.countAll / arguments.RecordsPerPage)>
		<cfelse>
			<cfset stReturn.TotalPages = 0>
		</cfif>
			
		<!------------------------------
		IF THE CURRENT PAGE IS GREATER THAN THE TOTAL PAGES, REDO THE RECORDSET FOR PAGE 1
		 ------------------------------>		
		<cfif arguments.CurrentPage GT stReturn.TotalPages and arguments.CurrentPage GT 1>
			
			<cfset arguments.currentPage = getCurrentPaginationPage(paginationID=arguments.paginationID,CurrentPage=1) />
			
			
			
			<cfquery name="qFormToolRecordset" datasource="#application.dsn#" result="qRes">
											
			IF OBJECT_ID('tempdb..##thetops') IS NOT NULL 	drop table ##thetops
			CREATE TABLE ##thetops (objectID varchar(40), myint int IDENTITY(1,1) NOT NULL)
			
			INSERT ##thetops (objectID)
			SELECT TOP #theSQLTop# tbl.objectid
			FROM #arguments.typename# tbl 
			
			<cfif arguments.lCategories neq ''>
				WHERE objectid in (
				    select distinct objectid 
				    from refCategories 
				    where categoryID in (#preserveSingleQuotes(arguments.lCategories)#)
				    )
				AND #preserveSingleQuotes(arguments.SqlWhere)#
			<cfelse>
				WHERE #preserveSingleQuotes(arguments.SqlWhere)#
			</cfif>
			<cfif len(arguments.sqlOrderBy)>
				ORDER BY #preserveSingleQuotes(arguments.sqlOrderBy)#
			</cfif>
			
			
			
			SELECT #arguments.sqlColumns#
			FROM #arguments.typename# tbl
			inner join  ##thetops t on tbl.objectid = t.objectid where t.myint > ((select count(*) from ##thetops) - #arguments.recordsPerPage#)
			
			
			drop table ##thetops
							
			</cfquery>
		
			<cfquery name="qrecordcount" datasource="#application.dsn#" result="qRes">
			SELECT count(distinct tbl.objectid)
			FROM #arguments.typename# tbl 
			
			<cfif arguments.lCategories neq ''>
				WHERE objectid in (
				    select distinct objectid 
				    from refCategories 
				    where categoryID in (#preserveSingleQuotes(arguments.lCategories)#)
				    )
				AND #preserveSingleQuotes(arguments.SqlWhere)#
			<cfelse>
				WHERE #preserveSingleQuotes(arguments.SqlWhere)#
			</cfif>
			</cfquery>
			
			
						
			<!---
			<!--- query --->
			<cfstoredproc procedure="sp_selectview_bycat" datasource="#application.dsn#">
			    <cfprocresult name="q" resultset="1">
			    <cfprocresult name="qrecordcount" resultset="2">
			    
			    <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="TableName"  value="#arguments.typename#">
			    <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="Columns" value="#arguments.sqlColumns#">
			    <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="GroupNumber" value="#arguments.CurrentPage#">
			    <cfprocparam type="In"  cfsqltype="CF_SQL_VARCHAR" dbvarname="GroupSize" value="#arguments.recordsPerPage#">
			    <cfprocparam type="In" cfsqltype="CF_SQL_LONGVARCHAR" dbvarname="SqlWhere" value="#arguments.SqlWhere#">
			    <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="SqlOrderBy" value="#arguments.sqlOrderBy#">
			    <cfprocparam type="In" cfsqltype="CF_SQL_VARCHAR" dbvarname="lCategories" value="#preserveSingleQuotes(arguments.lCategories)#">
			</cfstoredproc> --->
		</cfif>			
		
		<cfif isNumeric(qrecordcount.countAll) AND qrecordcount.countAll GT 0>
			<cfset stReturn.TotalPages = ceiling(qrecordcount.countAll / arguments.RecordsPerPage)>
		<cfelse>
			<cfset stReturn.TotalPages = 0>
		</cfif>
			
		
		<!--- NOW THAT WE HAVE OUR QUERY, POPULATE THE RETURN STRUCTURE --->
		<cfset stReturn.q = qFormToolRecordset />
		<cfset stReturn.countAll = qrecordcount.countAll />
		<cfset stReturn.CurrentPage = arguments.CurrentPage />
		
		
		<cfset stReturn.Startpage = 1>
		<cfset stReturn.PageLinksShown = min(arguments.PageLinksShown, stReturn.TotalPages)>
		
		
		
		<cfif stReturn.CurrentPage + int(stReturn.PageLinksShown / 2) - 1 GTE stReturn.TotalPages>
			<cfset stReturn.StartPage = stReturn.TotalPages - stReturn.PageLinksShown + 1>
		<cfelseif stReturn.CurrentPage + 1 GT stReturn.PageLinksShown>
			<cfset stReturn.StartPage = stReturn.CurrentPage - int(stReturn.PageLinksShown / 2)>
		</cfif>
		
		
		
		<cfset stReturn.Endpage = stReturn.StartPage + stReturn.PageLinksShown - 1>
			
		<cfset stReturn.RecordsPerPage = arguments.RecordsPerPage />
		<!--- end of pagination  --->
	<cfelse>
		<cfquery name="getRecords" datasource="#application.dsn#">		
				SELECT #arguments.sqlColumns# FROM #arguments.typename# tbl 
				<cfif arguments.lCategories neq ''>
					, refCategories cat where cat.objectId = tbl.ObjectID
				<cfelse>
					where 0=0
				</cfif>
				<cfif arguments.SqlWhere neq ''>AND #arguments.SqlWhere#</cfif>
				<cfif arguments.lCategories neq ''>	AND cat.categoryID in(#preserveSingleQuotes(arguments.lCategories)#)</cfif>
				<cfif arguments.sqlOrderBy neq ''>ORDER BY #arguments.sqlOrderBy#</cfif>
		</cfquery>
		<cfset stReturn.q = getRecords />
		<cfset stReturn.countAll = getRecords.recordcount />
	</cfif>
	
	
	
	<cfset stReturn.typename = arguments.typename />
	<cfreturn stReturn />
</cffunction>

<cffunction name="getRecordSetObjectStructures" access="public" output="false" returntype="Array" hint="This function accepts a recordset and will return a Faux Farcry Array of Object Structure that will enable it to run through ft:object without requiring a getData.">

	<cfargument name="recordset" type="query" required="true">
	<cfargument name="typename" type="string" required="false" default="">	
	<cfargument name="lArrayProps" type="string" required="false" default="">

	<cfset var arResult = arrayNew(1) />
	<cfset var stPropsQueries = structNew()>
	<cfset var qArrayData=queryNew("parentID, data") />
	<cfset var lObjectIDs="" />
	
	<cfset stResult.typename = arguments.typename />
	
	<!--- get array property if requested --->
	<cfif lArrayProps neq "">
		
		<!--- DO WE ONLY WANT ONE ROW? or ALL OF THEM --->
		<cfset lObjectIDs = valueList(arguments.recordset.objectId)>	
	
		
		<cfloop list="#lArrayProps#" index="arPropName">
			<!--- get all relational items id of all instances and store in a struct with the property name as a the key  --->
			<cfif len(lObjectIDs)>
				<cfquery datasource="#application.dsn#" name="qArrayData">
					select parentID, data from #arguments.typename#_#arPropName#
					where parentID in (#listQualify(lObjectIDs,"'")#)
					order by parentID, seq
				</cfquery>
			</cfif>
			<cfif qarraydata.recordcount>
				<cfsilent>
					<cfoutput query="qArrayData" group="parentID">
						<cfif not structKeyExists(stPropsQueries,parentID)>
							<cfset stPropsQueries[parentID] = structNew() />
						</cfif>				
						<cfset stPropsQueries[parentID][arPropName] = arrayNew(1)>
						<cfoutput>
							<cfset arrayAppend(stPropsQueries[parentID][arPropName],data)>
						</cfoutput>
					</cfoutput>
				</cfsilent>
			<cfelse>
				<cfif not structKeyExists(stPropsQueries,parentID)>
					<cfset stPropsQueries[parentID] = structNew() />
				</cfif>				
				<cfset stPropsQueries[parentID][arPropName] = arrayNew(1)>
			</cfif>
		</cfloop>
	
	</cfif>
	

	
	<cfloop query="arguments.recordset">
	
		<cfset tmpSt = structNew()>
		<cfset tmpSt.typeName = arguments.typename>
		<cfloop list="#arguments.recordset.columnlist#" index="i">	
			<cfif structKeyExists(application.types[arguments.typename].stProps,i) and application.types[arguments.typename].stProps[i].metadata.type NEQ "array">
				<cfset tmpSt[i] = arguments.recordset[i][arguments.recordset.currentRow]>			
			</cfif>
		</cfloop>
		
		<cfif not structIsEmpty(stPropsQueries)>
			<cfloop collection="#stPropsQueries[recordset.objectID]#" item="arPropName">
				<cfset tmpSt[arPropName] = stPropsQueries[recordset.objectID][arPropName]>
			</cfloop>
		</cfif>
		<cfset arrayAppend(arResult,tmpSt) />
	</cfloop>
	<cfreturn arResult />
</cffunction>


<cffunction name="getRecordsetObject" access="public" output="false" returntype="struct" hint="This function accepts a recordset and will return a Faux Farcry Object Structure that will enable it to run through ft:object without requiring a getData.">
	<cfargument name="recordset" type="query" required="true" hint="Resultset to process." />
	<cfargument name="row" type="numeric" required="true" hint="Specific row number to return." />
	<cfargument name="typename" type="string" required="true" hint="Typename of the content." />
	<cfargument name="larrayprops" type="string" required="false" default="" hint="List of array properties to return." />
	<cfargument name="bFormToolMetadata" type="boolean" default="true" hint="Convert content item to form tool metadata; else leave as a simple structure.">
	<cfargument name="dsn" default="#application.dsn#" type="string" hint="Datasource name." />
	<cfargument name="dbowner" default="#application.dbowner#" type="string" hint="Database owner." />
	
	<cfset var i = "" />
	<cfset var j = "" />
	<cfset var key = "" />
	<cfset var aTmp = arrayNew(1) />
	<cfset var stTmp = structNew() />
	<cfset var st = structNew() />
	<cfset var qArrayData = queryNew("data") />
	<cfset var stResult=structNew() />

	<cfset stTmp.typename = arguments.typename />
	
	<cfloop list="#arguments.recordset.columnlist#" index="i">
		<cfif structkeyexists(application.types[arguments.typename].stProps, i)>
			<cfif application.types[arguments.typename].stProps[i].metadata.type NEQ "array">
				<cfset stTmp[i] = arguments.recordset[i][row] />
			<cfelse>
				
				<cfif listContains(arguments.larrayprops, i)>	
					
					<cfset stTmp[i] = arrayNew(1) />
												
					<cfset key = i>
						
					<!--- getdata for array properties --->
					<cfquery datasource="#arguments.dsn#" name="qArrayData">
		  			select data from #arguments.dbowner##tablename#_#key#
					where parentID = '#arguments.recordset.objectID[arguments.row]#'
					order by seq
					</cfquery>
	
					<cfset aTmp = arrayNew(1) />
						<cfloop from="1" to="#qArrayData.recordcount#" index="j">
						<cfset ArrayAppend(aTmp, qArrayData.data[j])>
					</cfloop>
					<cfset stTmp[key] = aTmp>
																
				</cfif>
			</cfif>
		</cfif>
	</cfloop>
	
	<cfif arguments.bFormToolMetadata>
		<ft:object stobject="#stTmp#" typename="#arguments.typename#" lFields="#structKeyList(stTmp)#" lExcludeFields="" bIncludeSystemProperties="true" format="display" includeFieldSet="false" r_stFields="stResult" />
	<cfelse>
		<cfset stResult=stTmp />
	</cfif>
	
	<cfreturn stResult />
</cffunction>

<cffunction name="getRecordsetObjectArray" access="public" output="false" returntype="array" hint="Accepts a recordset and returns an array of faux Farcry content object structures that can be used with ft:object without requiring a getData()">
	<cfargument name="recordset" type="query" required="true" hint="Resultset to process." />
	<cfargument name="typename" type="string" required="true" hint="Typename of the content." />
	<cfargument name="larrayprops" type="string" required="false" default="" hint="List of array properties to return." />
	<cfargument name="bFormToolMetadata" type="boolean" default="true" hint="Convert content item to form tool metadata; else leave as a simple structure.">
	<cfargument name="dsn" default="#application.dsn#" type="string" hint="Datasource name." />
	<cfargument name="dbowner" default="#application.dbowner#" type="string" hint="Database owner." />
	<cfset var aResult=arrayNew(1) />
	<cfloop query="arguments.recordset">
		<cfset arrayAppend(aResult, getRecordsetObject(row=arguments.recordset.currentrow, recordset=arguments.recordset, typename=arguments.typename, larrayprops=arguments.larrayprops, dsn=arguments.dsn, dbowner=arguments.dbowner, bformtoolmetadata=arguments.bformtoolmetadata)) />
	</cfloop>
	<cfreturn aResult />
</cffunction>

<cffunction name="ArrayListGenerate" access="public" output="true" returntype="string">
	
	<cfargument name="aField" required="true" type="array" hint="Array of structs that include the data and typename." />
	<cfargument name="listType" required="false" type="string" default="none" />
	<cfargument name="Webskin" required="false" type="string" default="" />
	<cfargument name="bIncludeLink" required="false" type="boolean" default="false" />
	
		
	<cfset var oData = "" />
	<cfset var stData = structNew() />
	<cfset var result = "" />
	
	
	<cfif arrayLen(aField)>
		
		<cfloop from="1" to="#arrayLen(aField)#" index="pos" >
			<cfif isStruct(aField[pos])>
				<cfset itemTypename = aField[pos].typename />
				<cfset itemData = aField[pos].data />
			<cfelse>
				<!--- TODO: MJB use query on array table to get all the typenames in 1 go.  --->
				<cfset q4 = createObject("component", "farcry.fourq.fourq")>
				<cfset itemTypename = q4.findType(objectid=aField[pos])>
				<cfset itemData = aField[pos] />
			</cfif>
			
			<cftry><cfset oData = createObject("component", application.types[itemTypename].typePath) /><cfcatch><cfdump var="#itemTypename#"><cfdump var="#aField[pos]#"><cfabort></cfcatch></cftry>
			<cfset stData = oData.getData(objectID=itemData) />	
			

			<!--- Use the label as the item value. --->
			<cfif len(arguments.Webskin)>
				<cfset item = oData.getView(objectid="#stData.objectid#", template="#arguments.Webskin#", alternateHTML="#stData.label#") />
			<cfelse>
				<cfset item = stData.label />
			</cfif>
						
			<!--- add the link if requested --->
			<cfif arguments.bIncludeLink>
				<cfsavecontent variable="item">							
					<skin:buildlink objectid="#itemData#"><cfoutput>#item#</cfoutput></skin:buildlink>
				</cfsavecontent>
			</cfif>
			
			<!--- If in a list, then append with li tags otherwise append to list --->
			<cfswitch expression="#arguments.listType#">
			<cfcase value="unordered,ordered">
				<cfset result = "#result#<li>#item#</li>" />
			</cfcase>
			<cfdefaultcase>
				<cfset result= listAppend(result, item) />
			</cfdefaultcase>
			</cfswitch>
			
		</cfloop>
		
		<cfif arguments.listType EQ "unordered">
			<cfset result = "<ul>#result#</ul>" />
		</cfif>
		<cfif arguments.listType EQ "ordered">
			<cfset result = "<ol>#result#</ol>" />
		</cfif>
	</cfif>
	
	<cfreturn result />

</cffunction>

<cffunction name="ImageAutoGenerateBeforeSave" access="public" output="true" returntype="struct">
	<cfargument name="stProperties" required="yes" type="struct">
	<cfargument name="stFields" required="yes" type="struct">
		

	<cfset oImage = createobject("component", "farcry.farcry_core.packages.formtools.image") />

	<cfloop list="#StructKeyList(arguments.stFields)#" index="i">

		<cfif structKeyExists(arguments.stFields[i].metadata, "ftType") AND arguments.stFields[i].metadata.ftType EQ "Image" >

			<cfif structKeyExists(arguments.stFormPost, i) AND structKeyExists(arguments.stFormPost[i].stSupporting, "CreateFromSource") AND ListFirst(arguments.stFormPost[i].stSupporting.CreateFromSource)>	
			
				<!--- Make sure a ftSourceField --->
				<cfparam name="arguments.stFields.#i#.metadata.ftSourceField" default="sourceImage" />
				
				<cfset sourceFieldName = arguments.stFields[i].metadata.ftSourceField />
				
				<!--- IS THE SOURCE IMAGE PROVIDED? --->
				<cfif structKeyExists(arguments.stProperties, sourceFieldName) AND len(arguments.stProperties[sourceFieldName])>
													

					<cfparam name="arguments.stFields['#i#'].metadata.ftDestination" default="#application.config.image.StandardImageURL#">		
					<cfparam name="arguments.stFields['#i#'].metadata.ftImageWidth" default="#application.config.image.StandardImageWidth#">
					<cfparam name="arguments.stFields['#i#'].metadata.ftImageHeight" default="#application.config.image.StandardImageHeight#">
					<cfparam name="arguments.stFields['#i#'].metadata.ftAutoGenerateType" default="FitInside">
					<cfparam name="arguments.stFields['#i#'].metadata.ftPadColor" default="##ffffff">
					
					<cfset stArgs = StructNew() />
					<cfset stArgs.Source = "#application.path.project#/www#arguments.stProperties[sourceFieldName]#" />
					<cfset stArgs.Destination = "#application.path.project#/www#arguments.stFields['#i#'].metadata.ftDestination#" />
					<cfset stArgs.Width = "#arguments.stFields['#i#'].metadata.ftImageWidth#" />
					<cfset stArgs.Height = "#arguments.stFields['#i#'].metadata.ftImageHeight#" />
					<cfset stArgs.AutoGenerateType = "#arguments.stFields['#i#'].metadata.ftAutoGenerateType#" />
					<cfset stArgs.padColor = "#arguments.stFields['#i#'].metadata.ftpadColor#" />
				
												
					<cfset stGenerateImageResult = oImage.GenerateImage(Source="#stArgs.Source#", Destination="#stArgs.Destination#", Width="#stArgs.Width#", Height="#stArgs.Height#", AutoGenerateType="#stArgs.AutoGenerateType#", padColor="#stArgs.padColor#") />
					
					<cfif stGenerateImageResult.bSuccess>
						<cfset stProperties['#i#'] = "#arguments.stFields['#i#'].metadata.ftDestination#/#stGenerateImageResult.filename#" />
					</cfif>
				
				</cfif>
									
			</cfif>

		</cfif>

	</cfloop>
	
	<cfreturn stProperties />
	
</cffunction>
</cfcomponent> 