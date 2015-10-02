<cfcomponent displayname="FormTools" hint="All the methods required to run Farcry Form Tools">


<cfimport prefix="skin" taglib="/farcry/core/tags/webskin" />
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >


<cffunction name="getCurrentPaginationPage" access="public" output="true" returntype="numeric">
	<cfargument name="paginationID" required="No" type="string" default="" />
	<cfargument name="currentPage" required="No" type="string" default="0" />
	
	
	<cfif arguments.CurrentPage eq 0 or not isNumeric(arguments.currentPage)>
		<cfif structKeyExists(url,"page#arguments.paginationID#")>
			<cfset arguments.CurrentPage = url["page#arguments.paginationID#"]>
		<cfelseif structKeyExists(form, "paginationpage#arguments.paginationID#")>
			<cfset arguments.CurrentPage = form["paginationpage#arguments.paginationID#"]>		
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
	
	<cfargument name="bCheckVersions" required="No" type="boolean" default="false" hint="should be true when called from objectadmin or any use for admin purpose" />	
	<cfargument name="paginationID" required="No" type="string" default="" />	
	<cfargument name="CurrentPage" required="No" type="numeric" default="0" />
	<cfargument name="RecordsPerPage" required="No" type="numeric" default="10" />
	<cfargument name="PageLinksShown" required="No" type="numeric" default="5" />
	<cfargument name="cacheTimeSpan" required="No" type="numeric" default="0" hint="duration in days, need non empty argument paginationID to work, recommendation: use createTimeSpan" />
	
	<cfargument name="aCategoryFilters" required="No" type="array" default="#arrayNew(1)#" />
	<cfargument name="dsn" required="No" type="string" default="" />


	<cfset var PrimaryPackage = "" />
	<cfset var PrimaryPackagePath = "" />

	<cfset var stReturn = structNew() />
	<cfset var qFormToolRecordset = '' />
	<cfset var recordcount = '' />

	<cfset var i = "">
	<cfset var l_sqlCatIds = "">

	<cfset var qCountName = "">
	<cfset var qName = "">
	<cfset var bQueryCached = "">
	<cfset var qrecordcount = "">
	<cfset var theSQLTop = "">
	<cfset var toprow = "">
	<cfset var getRecords = "">

	
	<cfset var bHasStatus = false />	
	<cfset var bHasVersionID = false />
	
	<cfset var thisDiff = 0 /><!--- var used if recordcount/RecordsPerPage remainder is not 0, occurs at the end of pagination --->

	<cfif not len(arguments.dsn)>
		<cfset arguments.dsn = application.dsn_read /><!--- NOTE: the read dsn should allow temporary table creation --->
	</cfif>

	<cfif arguments.sqlColumns eq "objectid">
		<cfset arguments.sqlColumns = "tbl.objectid">
	</cfif>
	
	<cfif listlen(arguments.lCategories)>
		<cfloop list="#arguments.lCategories#" index="i">
			<cfset arrayAppend(aCategoryFilters, i) />
		</cfloop>
	</cfif>
	
	<cfif arrayLen(arguments.aCategoryFilters)>
		<cfloop from="1" to="#arrayLen(arguments.aCategoryFilters)#" index="i">
			<cfif arguments.aCategoryFilters[i] neq ''>
				<cfset l_sqlCatIds = listAppend(l_sqlCatIds,arguments.aCategoryFilters[i])>
			</cfif>
		</cfloop>
	</cfif>
	
	<cfif structKeyExists(application.types, arguments.typename)>
		<cfset PrimaryPackage = application.types[arguments.typename] />
		<cfset PrimaryPackagePath = application.types[arguments.typename].typepath />
	<cfelse>
		<cfset PrimaryPackage = application.rules[arguments.typename] />
		<cfset PrimaryPackagePath = application.rules[arguments.typename].rulepath />
	</cfif>

	<cfset arguments.identityColumn = "tbl." & arguments.identityColumn>
	
	<cfset arguments.currentPage = getCurrentPaginationPage(paginationID=arguments.paginationID,CurrentPage=arguments.CurrentPage) />


	<!---
	DETERMINE IF TYPE HAS STATUS AND VERSIONID TO ENUSRE WE DO NOT GET DUPLICATES.
	 --->
	<cfif structKeyExists(PrimaryPackage.stProps, "status")>
		<cfset bHasStatus = true />
	</cfif>
	<cfif structKeyExists(PrimaryPackage.stProps, "versionid")>
		<cfset bHasVersionID = true />
	</cfif>
	
	<cfloop list="#arguments.sqlColumns#" index="i">
		<cfif NOT FindNoCase("tbl.", i) AND i NEQ "*">
			<cfif not StructKeyExists(primaryPackage.stprops, i)>
				<cfset arguments.sqlColumns = ListDeleteAt(arguments.sqlColumns, listFindNoCase(arguments.sqlColumns,i))>
			</cfif>
		</cfif>
	</cfloop>
	
	<!--- Ensure  if objectID provided in columns names prefixed it with tbl. --->
 	<cfif arguments.sqlColumns neq "*">	
		<cfif arguments.sqlColumns neq 'tbl.ObjectID'>
			<cfif listFindNoCase(arguments.sqlColumns,"ObjectID")>
				<cfset arguments.sqlColumns = ListDeleteAt(arguments.sqlColumns, listFindNoCase(arguments.sqlColumns,"ObjectID"))>
			</cfif>		
			<cfset arguments.sqlColumns="tbl.ObjectID," & sqlColumns>
		</cfif>
		
		<cfif arguments.bCheckVersions AND bHasStatus AND NOT listContainsNoCase(arguments.sqlColumns, "status") >
			<cfset arguments.sqlColumns = listAppend(arguments.sqlColumns, "status") />
		</cfif>
		
		<cfif arguments.bCheckVersions AND bHasVersionID AND NOT listContainsNoCase(arguments.sqlColumns, "versionid") >
			<cfset arguments.sqlColumns = listAppend(arguments.sqlColumns, "versionid") />
		</cfif>
	<cfelse>
		<cfset arguments.sqlColumns="tbl.*">
	</cfif>

	<cfif RecordsPerPage GT 0><!--- Start if pagination  --->

		<cfif NOT len(arguments.sqlWhere)>
			<cfset arguments.sqlWhere = "0=0" />
		</cfif>
		
		<cfif arguments.cacheTimeSpan GT 0 and arguments.paginationID neq "">	
			<cfset qCountName = "q" & replace(arguments.paginationID,"-","","ALL") &"_count">
			<cfset qName = "qcache" & replace(arguments.paginationID,"-","","ALL") & arguments.RecordsPerPage & "_" & arguments.CurrentPage>
			<cfset bQueryCached = 1>
		<cfelse>
			<cfset qCountName = "qrecordcount">
			<cfset qName = "qFormToolRecordset">
			<cfset arguments.cacheTimeSpan = 0>
			<cfset bQueryCached = 0>
		</cfif>
		
		<!--- Find out how many results there will be --->
		<cfif bHasVersionID>
			<cfquery name="#qCountName#" datasource="#arguments.dsn#" cachedwithin="#arguments.cacheTimeSpan#">
				SELECT COUNT(objectid) as CountAll
				from (
					<!--- Return the objectid's of matching approved/draft-only content --->
					SELECT tbl.objectid
					FROM #arguments.typename# tbl 			
					WHERE #preserveSingleQuotes(arguments.SqlWhere)#
					<cfif l_sqlCatIds neq "">
						AND objectid in (
						    select distinct objectid 
						    from refCategories 
						    where categoryID in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#l_sqlCatIds#" />)
						    )				
					</cfif>
					AND (tbl.versionid = '' OR tbl.versionid IS NULL)
					
					UNION
					
					<!--- Return the approved objectid of matching editable-draft content --->
					SELECT tbl.versionid as objectid
					FROM #arguments.typename# tbl
					WHERE #preserveSingleQuotes(arguments.SqlWhere)#
					<cfif l_sqlCatIds neq "">
						AND objectid in (
						    select distinct objectid 
						    from refCategories 
						    where categoryID in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#l_sqlCatIds#" />)
						    )				
					</cfif>
					and versionid<>''
				) joined
			</cfquery>
		<cfelse>
			<cfquery name="#qCountName#" datasource="#arguments.dsn#" cachedwithin="#arguments.cacheTimeSpan#">
				SELECT count(distinct tbl.objectid) as CountAll 
				FROM #arguments.typename# tbl 			
				WHERE #preserveSingleQuotes(arguments.SqlWhere)#
				<cfif l_sqlCatIds neq "">
					AND objectid in (
					    select distinct objectid 
					    from refCategories 
					    where categoryID in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#l_sqlCatIds#" />)
					    )				
				</cfif>
			</cfquery>
		</cfif>
		
		<cfif bQueryCached>
			<cfset qrecordcount = evaluate("q" & replace(arguments.paginationID,"-","","ALL") &"_count")>
		</cfif>
		
		<cfset theSQLTop = arguments.CurrentPage * arguments.recordsPerPage>
		
		<cfif qrecordcount.CountAll mod  RecordsPerPage neq 0 and theSQLTop GT qrecordcount.CountAll>
			<cfset thisDiff = RecordsPerPage - (qrecordcount.CountAll mod  arguments.RecordsPerPage)>
		</cfif>		

		<!------------------------------
		DETERMINE THE TOTAL PAGES
		 ------------------------------>
		<cfif isNumeric(qrecordcount.countAll) AND qrecordcount.countAll GT 0>
			<cfset stReturn.TotalPages = ceiling(qrecordcount.countAll / arguments.RecordsPerPage)>
		<cfelse>
			<cfset stReturn.TotalPages = 0>
		</cfif>
			
		<cfif findnocase("MSSQL",application.dbtype)>
	
			
			<cfquery name="#qName#" datasource="#arguments.dsn#" cachedwithin="#arguments.cacheTimeSpan#">
	
			IF OBJECT_ID('tempdb..##thetops') IS NOT NULL 	drop table ##thetops
			CREATE TABLE ##thetops (objectID varchar(40), myint int IDENTITY(1,1) NOT NULL);
			
			INSERT INTO ##thetops (objectID)
			SELECT TOP #theSQLTop# tbl.objectid
			FROM #arguments.typename# tbl
			<cfif bHasVersionID>
				WHERE objectid in (
					SELECT tbl.objectid
					FROM #arguments.typename# tbl 			
					WHERE #preserveSingleQuotes(arguments.SqlWhere)#
					<cfif l_sqlCatIds neq "">
						AND objectid in (
						    select distinct objectid 
						    from refCategories 
						    where categoryID in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#l_sqlCatIds#" />)
						    )				
					</cfif>
					AND (tbl.versionid = '' OR tbl.versionid IS NULL)
					
					UNION
					
					SELECT tbl.versionid as objectid
					FROM #arguments.typename# tbl
					WHERE #preserveSingleQuotes(arguments.SqlWhere)#
					<cfif l_sqlCatIds neq "">
						AND objectid in (
						    select distinct objectid 
						    from refCategories 
						    where categoryID in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#l_sqlCatIds#" />)
						    )				
					</cfif>
					and versionid<>''
				)
			<cfelse>			
				WHERE #preserveSingleQuotes(arguments.SqlWhere)#
				<cfif l_sqlCatIds neq "">
					AND objectid in (
					    select distinct objectid 
					    from refCategories 
					    where categoryID in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#l_sqlCatIds#" />)
					    )				
				</cfif>
			</cfif>
			<cfif len(trim(arguments.sqlOrderBy))>
				ORDER BY #preserveSingleQuotes(arguments.sqlOrderBy)#
			</cfif>
			
			<cfif arguments.sqlColumns neq "tbl.objectID">
				SELECT #arguments.sqlColumns#
				<cfif bHasversionID and arguments.bCheckVersions>
					,(SELECT count(d.objectid) FROM #arguments.typename# d WHERE d.versionid = tbl.objectid) as bHasMultipleVersion
				</cfif>
				FROM #arguments.typename# tbl
				inner join  ##thetops t on tbl.objectid = t.objectid collate Latin1_general_CI_AS where t.myint >  ((select count(*) from ##thetops) - #arguments.RecordsPerPage-thisDiff#)
				
				<cfif len(trim(arguments.sqlOrderBy))>
					ORDER BY #preserveSingleQuotes(arguments.sqlOrderBy)#
				</cfif>
			<cfelse>
				SELECT objectID
				<cfif bHasversionID and arguments.bCheckVersions>
					,(SELECT count(d.objectid) FROM #arguments.typename# d WHERE d.versionid = t.objectid) as bHasMultipleVersion
				</cfif>		
				FROM ##thetops t where t.myint >  ((select count(*) from ##thetops) - #arguments.RecordsPerPage-thisDiff#)
			</cfif>
			
			drop table ##thetops
							
			</cfquery>
			<cfif bQueryCached>
				<cfset qFormToolRecordset = evaluate("qcache" & replace(arguments.paginationID,"-","","ALL") & arguments.RecordsPerPage & "_" & arguments.CurrentPage)>
			</cfif>
		
			<!------------------------------
			IF THE CURRENT PAGE IS GREATER THAN THE TOTAL PAGES, REDO THE RECORDSET FOR PAGE 1
			 ------------------------------>		
			<cfif arguments.CurrentPage GT stReturn.TotalPages and arguments.CurrentPage GT 1>
				
				<cfset arguments.currentPage = getCurrentPaginationPage(paginationID=arguments.paginationID,CurrentPage=1) />
			
				<cfif bHasVersionID>
					<cfquery name="qrecordcount" datasource="#arguments.dsn#" cachedwithin="#arguments.cacheTimeSpan#">
						SELECT count(distinct objectid) as CountAll
						from (
							<!--- Return the objectid's of matching approved/draft-only content --->
							SELECT tbl.objectid
							FROM #arguments.typename# tbl 			
							WHERE #preserveSingleQuotes(arguments.SqlWhere)#
							<cfif l_sqlCatIds neq "">
								AND objectid in (
								    select distinct objectid 
								    from refCategories 
								    where categoryID in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#l_sqlCatIds#" />)
								    )				
							</cfif>
							AND (tbl.versionid = '' OR tbl.versionid IS NULL)
							
							UNION
							
							<!--- Return the approved objectid of matching editable-draft content --->
							SELECT tbl.versionid as objectid
							FROM #arguments.typename# tbl
							WHERE #preserveSingleQuotes(arguments.SqlWhere)#
							<cfif l_sqlCatIds neq "">
								AND objectid in (
								    select distinct objectid 
								    from refCategories 
								    where categoryID in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#l_sqlCatIds#" />)
								    )				
							</cfif>
							and versionid<>''
						) joined
					</cfquery>
				<cfelse>
					<cfquery name="qrecordcount" datasource="#arguments.dsn#" cachedwithin="#arguments.cacheTimeSpan#">
						SELECT count(distinct tbl.objectid) as CountAll 
						FROM #arguments.typename# tbl 			
						WHERE #preserveSingleQuotes(arguments.SqlWhere)#
						<cfif l_sqlCatIds neq "">
							AND objectid in (
							    select distinct objectid 
							    from refCategories 
							    where categoryID in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#l_sqlCatIds#" />)
							    )				
						</cfif>
					</cfquery>
				</cfif>
				
			
				<cfif qrecordcount.CountAll mod  RecordsPerPage neq 0 and theSQLTop GT qrecordcount.CountAll>
					<cfset thisDiff = RecordsPerPage - (qrecordcount.CountAll mod  arguments.RecordsPerPage)>
				</cfif>
			
				
							
				<cfquery name="qFormToolRecordset" datasource="#arguments.dsn#">
	
				IF OBJECT_ID('tempdb..##thetops') IS NOT NULL 	drop table ##thetops
				CREATE TABLE ##thetops (objectID varchar(40), myint int IDENTITY(1,1) NOT NULL);
				
				INSERT INTO ##thetops (objectID)
				SELECT TOP #theSQLTop# tbl.objectid
				FROM #arguments.typename# tbl
				<cfif bHasVersionID>
					WHERE objectid in (
						SELECT COALESCE(NULLIF(tbl.versionid,''),tbl.objectid)
						FROM #arguments.typename# tbl 			
						WHERE #preserveSingleQuotes(arguments.SqlWhere)#
						<cfif l_sqlCatIds neq "">
							AND objectid in (
							    select distinct objectid 
							    from refCategories 
							    where categoryID in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#l_sqlCatIds#" />)
							    )				
						</cfif>
					)
				<cfelse>			
					WHERE #preserveSingleQuotes(arguments.SqlWhere)#
					<cfif l_sqlCatIds neq "">
						AND objectid in (
						    select distinct objectid 
						    from refCategories 
						    where categoryID in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#l_sqlCatIds#" />)
						    )				
					</cfif>
				</cfif>
				<cfif len(trim(arguments.sqlOrderBy))>
					ORDER BY #preserveSingleQuotes(arguments.sqlOrderBy)#
				</cfif>
				
				<cfif arguments.sqlColumns neq "tbl.objectID">
					SELECT #arguments.sqlColumns#
					<cfif bHasversionID and arguments.bCheckVersions>
						,(SELECT count(d.objectid) FROM #arguments.typename# d WHERE d.versionid = tbl.objectid) as bHasMultipleVersion
					</cfif>
					FROM #arguments.typename# tbl
					inner join  ##thetops t on tbl.objectid = t.objectid collate Latin1_general_CI_AS where t.myint >  ((select count(*) from ##thetops) - #arguments.RecordsPerPage-thisDiff#)
					
					<cfif len(trim(arguments.sqlOrderBy))>
						ORDER BY #preserveSingleQuotes(arguments.sqlOrderBy)#
					</cfif>
				<cfelse>
					SELECT objectID
					<cfif bHasversionID and arguments.bCheckVersions>
						,(SELECT count(d.objectid) FROM #arguments.typename# d WHERE d.versionid = t.objectid) as bHasMultipleVersion
					</cfif>
					FROM ##thetops t where t.myint >  ((select count(*) from ##thetops) - #arguments.RecordsPerPage-thisDiff#)
				</cfif>
				
				drop table ##thetops
								
				</cfquery>
			</cfif>			
			
			<cfif isNumeric(qrecordcount.countAll) AND qrecordcount.countAll GT 0>
				<cfset stReturn.TotalPages = ceiling(qrecordcount.countAll / arguments.RecordsPerPage)>
			<cfelse>
				<cfset stReturn.TotalPages = 0>
			</cfif>
		<cfelse><!--- Everything Else --->

			<cfif arguments.currentpage GT stReturn.totalPages>
				<cfset arguments.currentpage = 1>
			</cfif>
			<cfset toprow = ((arguments.currentpage * arguments.RecordsPerPage)- arguments.RecordsPerPage) >
			
			
			
			<cfif bHasVersionID>
				<cfquery name="qrecordcount" datasource="#arguments.dsn#" cachedwithin="#arguments.cacheTimeSpan#">
					SELECT count(distinct objectid) as CountAll
					from (
						<!--- Return the objectid's of matching editable-draft content or approved/draft-only content --->
						SELECT COALESCE(NULLIF(tbl.versionid,''),tbl.objectid) as objectid
						FROM #arguments.typename# tbl 			
						WHERE #preserveSingleQuotes(arguments.SqlWhere)#
						<cfif l_sqlCatIds neq "">
							AND objectid in (
							    select distinct objectid 
							    from refCategories 
							    where categoryID in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#l_sqlCatIds#" />)
							    )				
						</cfif>
					) joined
				</cfquery>
			<cfelse>
				<cfquery name="qrecordcount" datasource="#arguments.dsn#" cachedwithin="#arguments.cacheTimeSpan#">
					SELECT count(distinct tbl.objectid) as CountAll 
					FROM #arguments.typename# tbl 			
					WHERE #preserveSingleQuotes(arguments.SqlWhere)#
					<cfif l_sqlCatIds neq "">
						AND objectid in (
						    select distinct objectid 
						    from refCategories 
						    where categoryID in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#l_sqlCatIds#" />)
						    )				
					</cfif>
				</cfquery>
			</cfif>

			<cfquery name="qFormToolRecordset" datasource="#arguments.dsn#">
			SELECT #arguments.sqlColumns#
				<cfif bHasversionID>
					,(SELECT count(d.objectid) FROM #arguments.typename# d WHERE d.versionid = tbl.objectid) as bHasMultipleVersion
				</cfif> 
			FROM 
				#arguments.typename# tbl
				inner join
				(
					SELECT	objectid
					FROM 	#arguments.typename#
					
					WHERE #preserveSingleQuotes(arguments.SqlWhere)#
					<cfif l_sqlCatIds neq "">
						AND objectid IN (
							SELECT DISTINCT objectid
							FROM refCategories
							WHERE categoryID IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#l_sqlCatIds#" />)
						)
					</cfif>
					
					<cfif bHasVersionID> 
							AND (versionid = '' OR versionid IS NULL)
							
						UNION
						
						SELECT	versionID
						FROM 	#arguments.typename# tbl
						
						WHERE #preserveSingleQuotes(arguments.SqlWhere)#
						<cfif l_sqlCatIds neq "">
							AND objectid IN (
								SELECT DISTINCT objectid
								FROM refCategories
								WHERE categoryID IN (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#l_sqlCatIds#" />)
							)
						</cfif>
							
							AND versionid <> ''
					</cfif>
				) filter
				on tbl.objectid=filter.objectid
			
			<cfif len(trim(arguments.sqlOrderBy))>
				ORDER BY #preserveSingleQuotes(arguments.sqlOrderBy)#
			</cfif>

			<cfif application.dbtype NEQ "ora"> <!--- record limiting for everyone else --->
				LIMIT #arguments.RecordsPerPage# OFFSET #toprow#
			</cfif>
			
			</cfquery>


	
			
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
		<cfif NOT len(arguments.sqlWhere)>
			<cfset arguments.sqlWhere = "0=0" />
		</cfif>
	
		<cfquery name="getRecords" datasource="#arguments.dsn#">		
				SELECT #arguments.sqlColumns# 
				FROM #arguments.typename# tbl 
				<cfif arguments.SqlWhere neq ''>WHERE #preserveSingleQuotes(arguments.SqlWhere)#</cfif>
				<cfif l_sqlCatIds neq "">
							AND objectid in (
							    select distinct objectid 
							    from refCategories 
							    where categoryID in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#l_sqlCatIds#" />)
							    )				
				</cfif>	
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
	
	
	<cfset var PrimaryPackage = "" />
	<cfset var PrimaryPackagePath = "" />	

	<cfset var arResult = arrayNew(1) />
	<cfset var stPropsQueries = structNew()>
	<cfset var qArrayData = queryNew("parentID, data") />
	<cfset var lObjectIDs = "" />
	<cfset var tmpSt = structNew()>
	<cfset var i = "">
	<cfset var arPropName = "">


	<cfif structKeyExists(application.types, arguments.typename)>
		<cfset PrimaryPackage = application.types[arguments.typename] />
		<cfset PrimaryPackagePath = application.types[arguments.typename].typepath />
	<cfelse>
		<cfset PrimaryPackage = application.rules[arguments.typename] />
		<cfset PrimaryPackagePath = application.rules[arguments.typename].rulepath />
	</cfif>


	<!--- get array property if requested --->
	<cfif lArrayProps neq "">
		
		<!--- DO WE ONLY WANT ONE ROW? or ALL OF THEM --->
		<cfset lObjectIDs = valueList(arguments.recordset.objectId)>	

		<cfloop list="#lArrayProps#" index="arPropName">
			<!--- get all relational items id of all instances and store in a struct with the property name as a the key  --->
			<cfif len(lObjectIDs)>
				<cfquery datasource="#application.dsn#" name="qArrayData">
					select parentID, data from #arguments.typename#_#arPropName#
					where parentID in (<cfqueryparam cfsqltype="cf_sql_varchar" list="true" value="#lObjectIDs#" />)
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
			<cfif structKeyExists(PrimaryPackage.stProps,i) and PrimaryPackage.stProps[i].metadata.type NEQ "array">
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
	<cfargument name="dsn" default="" type="string" hint="Datasource name." />
	<cfargument name="dbowner" default="" type="string" hint="Database owner." />

	
	<cfset var PrimaryPackage = "" />
	<cfset var PrimaryPackagePath = "" />	
	
	
	<cfset var i = "" />
	<cfset var j = "" />
	<cfset var key = "" />
	<cfset var aTmp = arrayNew(1) />
	<cfset var stTmp = structNew() />
	<cfset var st = structNew() />
	<cfset var qArrayData = queryNew("data") />
	<cfset var stResult=structNew() />
	
	<cfif not len(arguments.dsn)>
		<cfset arguments.dsn = application.dsn_read />
	</cfif>
	<cfif not len(arguments.dbowner)>
		<cfset arguments.dbowner = application.dbowner_read />
	</cfif>
	
	<cfif structKeyExists(application.types, arguments.typename)>
		<cfset PrimaryPackage = application.types[arguments.typename] />
		<cfset PrimaryPackagePath = application.types[arguments.typename].typepath />
	<cfelse>
		<cfset PrimaryPackage = application.rules[arguments.typename] />
		<cfset PrimaryPackagePath = application.rules[arguments.typename].rulepath />
	</cfif>

	<cfset stTmp.typename = arguments.typename />
	
	<cfloop list="#arguments.recordset.columnlist#" index="i">
		<cfif structkeyexists(PrimaryPackage.stProps, i)>
			<cfif PrimaryPackage.stProps[i].metadata.type NEQ "array">
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
	<cfargument name="dsn" default="" type="string" hint="Datasource name." />
	<cfargument name="dbowner" default="" type="string" hint="Database owner." />

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

	<cfset var pos = "">
	<cfset var item = "">
	<cfset var itemTypename = "">
	<cfset var itemData = "">
	<cfset var q4 = "">

	<cfif arrayLen(aField)>
		
		<cfloop from="1" to="#arrayLen(aField)#" index="pos" >
			<cfif isStruct(aField[pos])>
				<cfset itemTypename = aField[pos].typename />
				<cfset itemData = aField[pos].data />
			<cfelse>
				<!--- TODO: MJB use query on array table to get all the typenames in 1 go.  --->
				<cfset q4 = createObject("component", "farcry.core.packages.fourq.fourq")>
				<cfset itemTypename = q4.findType(objectid=aField[pos])>
				<cfset itemData = aField[pos] />
			</cfif>
			
			<cfif len(itemTypename) and structKeyExists(application.types, itemTypename)>
				
				<cftry>
					<cfset oData = createObject("component", application.types[itemTypename].typePath) />
					<cfcatch><cfdump var="#itemTypename#"><cfdump var="#aField[pos]#"><cfabort></cfcatch>
				</cftry>
				<cfset stData = oData.getData(objectID=itemData) />	
				
	
				<!--- Use the label as the item value. --->
				<cfif len(arguments.Webskin)>
					<cfset item = oData.getView(objectid="#stData.objectid#", template="#arguments.Webskin#", alternateHTML="#stData.label#") />
				<cfelse>
					<cfset item = stData.label />
				</cfif>
				
				<cfif not item eq "(incomplete)">
					<!--- add the link if requested --->
					<cfif arguments.bIncludeLink>
						<cfsavecontent variable="item">							
							<skin:buildLink objectid="#itemData#"><cfoutput>#item#</cfoutput></skin:buildLink>
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
				</cfif>
			</cfif>
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

</cfcomponent>