<cfcomponent name="typeadmin" displayname="Type Admin Component" hint="Supports the ../tags/widgets/typeadmin.cfc custom tag. Not to be used in isolation.">

<!---
environment references (might be nice to clean these up)
	session.dmProfile.locale
	session.dmSec.authentication
	request.dmsec.oAuthorisation
	application.url.farcry
	application.adminBundle[session.dmProfile.locale]
	application.thisCalendar
	application.types

	TODO: please refactoring to make cleaner
 --->

<cffunction name="init" hint="Constructor." access="public" returntype="typeadmin">
	<cfargument name="attributes" type="struct" required="true" displayname="Typeadmin attributes." hint="Structure of attributes for the specific typeadmin page.">
	<cfargument name="stPrefs" type="struct" required="false" displayname="User Preferences" hint="Structure of preferences typically cached in session.typeadmin[typename] scope.">

	<cfset variables.attributes = arguments.attributes>
	<cfset variables.prefs = arguments.stprefs>

	<!--- override debug output --->
	<!--- <cfset attributes.bdebug="true"> --->

	<!--- set default columns, as required --->
	<cfif arrayisempty(variables.attributes.aColumns)>
		<cfset variables.attributes.aColumns=getDefaultColumns()>
	</cfif>
	<!--- set default buttons as required --->
	<cfif arrayisempty(variables.attributes.aButtons)>
		<cfset variables.attributes.aButtons=getDefaultButtons()>
	</cfif>

	<!--- set default prefs --->
	<cfif NOT structKeyExists(variables.prefs, "lCategoryIDs")>
		<cfset structInsert(variables.prefs, "lCategoryIDs", "")>
	</cfif>

	<cfif NOT structKeyExists(variables.prefs, "filter_lkeywords")>
		<cfset structInsert(variables.prefs, "filter_lkeywords", "")>
	</cfif>

	<cfif NOT structKeyExists(variables.prefs, "filter_dateRange")>
		<cfset variables.prefs.filter_dateRange = "">
	</cfif>

	<cfif NOT structKeyExists(variables.prefs, "orderby")>
		<cfset structInsert(variables.prefs, "orderby", attributes.defaultorderby)>
	</cfif>
	<cfif NOT structKeyExists(variables.prefs, "order")>
		<cfset structInsert(variables.prefs, "order", attributes.defaultorder)>
	</cfif>
	<cfif NOT structKeyExists(variables.prefs, "pg")>
		<cfset structInsert(variables.prefs, "pg", 1)>
	</cfif>

	<cfreturn this />
</cffunction>

<cffunction name="setpref">
	<cfargument name="prefkey" required="true">
	<cfargument name="prefvalue" required="true">
	<cfset structUpdate(variables.prefs, arguments.prefkey, arguments.prefvalue)>
	<cfreturn true />
</cffunction>

<cffunction name="setattribute" output="false" access="public" returntype="void">
	<cfargument name="attribkey" required="true" type="string">
	<cfargument name="attribvalue" required="true" type="any">
	<cfset structUpdate(variables.attributes, arguments.attribkey, arguments.attribvalue)>
</cffunction>

<!--- CATEGORY --->
<cffunction name="setCategoryFilter" returntype="void">
	<cfargument name="categoryid">
	<cfset variables.prefs.lcategoryids=listAppend(variables.prefs.lcategoryids, arguments.categoryid)>
	<cfset variables.prefs.lcategoryids=ListDeleteDuplicatesNoCase(variables.prefs.lcategoryids)>
</cffunction>

<cffunction name="deleteCategoryFilter" returntype="void">
	<cfargument name="categoryid" />
	<cfset variables.prefs.lcategoryids=REReplace(variables.prefs.lcategoryids, "#arguments.categoryid#,?", "", "ALL")>
</cffunction>

<!--- KEYWORDS --->
<cffunction name="setKeywordFilter" returntype="void">
	<cfargument name="keyword_field">
	<cfargument name="keyword">
	<cfset variables.prefs.filter_lkeywords = listAppend(variables.prefs.filter_lkeywords, "#arguments.keyword_field#^#arguments.keyword#","~")>
	<cfset variables.prefs.filter_lkeywords = ListDeleteDuplicatesNoCase(variables.prefs.filter_lkeywords,"~")>
</cffunction>

<cffunction name="deleteKeywordFilter" returntype="void">
	<cfargument name="keyword">

	<cfset var stLocal = StructNew()>
	<cfset stLocal.iPosition = ListFindNocase(variables.prefs.Filter_lkeywords,arguments.keyword,"~")>
	<cfif stLocal.iPosition>
		<cfset variables.prefs.filter_lkeywords = ListDeleteAt(variables.prefs.filter_lkeywords,stLocal.iPosition,"~")>
	</cfif>
</cffunction>

<!--- DATERANGE --->
<cffunction name="setDateRangeFilter" returntype="void">
	<cfargument name="daterange_field">
	<cfargument name="daterange">
	<cfset variables.prefs.filter_daterange = ListAppend(variables.prefs.filter_daterange,"#arguments.daterange_field#^#arguments.daterange#","~")>
	<!--- <cfoutput>variables.prefs.filter_daterange: #variables.prefs.filter_daterange#<br /></cfoutput> --->
</cffunction>

<cffunction name="deleteDateRangeFilter" returntype="void">
	<cfargument name="daterange_filter">
	<cfset var stLocal = StructNew()>
	<cfset stLocal.iPosition = ListFindNocase(variables.prefs.filter_daterange,arguments.daterange_filter,"~")>
	<cfif stLocal.iPosition>
		<cfset variables.prefs.filter_daterange = ListDeleteAt(variables.prefs.filter_daterange,stLocal.iPosition,"~")>
	</cfif>
</cffunction>


<cffunction name="deleteAllFilter" returntype="void">
	<cfset variables.prefs.lcategoryids = "">
	<cfset variables.prefs.filter_lkeywords = "">
	<cfset variables.prefs.filter_daterange = "">
</cffunction>

<cffunction name="getPrefs" access="public" output="false" returntype="struct" hint="Return structure of all preference settings.">
	<cfreturn variables.prefs />
</cffunction>
<cffunction name="getAttributes" access="public" output="false" returntype="struct" hint="Return structure of all attribute settings.">
	<cfreturn variables.attributes />
</cffunction>

<cffunction name="getRecordSet" access="public" returntype="query" output="true">
	<cfargument name="dbowner" required="false" default="#application.dbowner#">
	<cfset var recordset="">
	<!--- TODO : THIS NEEDS SOME CLEANING AND REFACTORING --->

	<!--- check for query data, and generate query if needed --->
	<cfif attributes.bFilterCategories AND len(prefs.lCategoryIDs)>
		<!--- if category filter on, query for objects matching the category --->
		<cfset recordset=application.factory.ocategory.getData(lCategoryIDs=prefs.lCategoryIDs,typename=attributes.typename,bMatchAll=0,bHasDescendants=1)>

		<cfif StructKeyExists(application.types[attributes.typename].stprops,"versionid")>
			<cfquery dbtype="query" name="recordset">
			SELECT	*
			FROM	recordset
			WHERE	versionid = ''
				OR	versionid IS NULL
			</cfquery>
		</cfif>

		<!--- if record count is 0 then fake query object --->
		<cfif NOT recordset.recordcount>
			<cfquery datasource="#attributes.datasource#" name="recordset" maxrows="1">
			SELECT 	*, 0 as bHasMultipleVersion
			FROM 	#arguments.dbowner##attributes.typename#
			WHERE 	0 = 1
			</cfquery>
		</cfif>
		<!--- <cfdump var="#recordset#" label="Category Filtered Recordset"> --->
	<cfelseif isDefined("attributes.query")>
		<cfif isQuery(attributes.query)>
			<cfset recordset=attributes.query>
		<cfelse>
			<cfabort showerror="QUERY attribute for cf_typeadmin is not a valid query object.">
		</cfif>
	<cfelse>
		<!--- generic query based on typename --->
		<!--- TODO: ignore longtext columns to improve performance --->
		<cfif StructKeyExists(application.types[attributes.typename].stprops,"versionid")>
			<!--- added by bowden to remove clobs because clob was bombing out later query of queries --->
			<cfswitch expression="#application.dbtype#">
			<cfcase value="ora">
			 <cfquery datasource="#attributes.datasource#" name="qTempCols">
			   SELECT	distinct 'n.'||column_name column_name
			   FROM 	all_tab_columns
			   WHERE	table_name = upper('#attributes.typename#')
			   and		owner||'.' = upper('#arguments.dbowner#')
			   and      data_type not like '%CLOB%'
			 </cfquery>

			 <cfquery datasource="#attributes.datasource#" name="recordset">
			   SELECT	#valueList(qTempCols.column_name)#,
					(SELECT count(d.objectid) FROM #arguments.dbowner##attributes.typename# d WHERE d.versionid = n.objectid) as bHasMultipleVersion
			   FROM 	#arguments.dbowner##attributes.typename# n
			   WHERE	n.versionid = ''
				OR	versionid IS NULL
			   </cfquery>
			</cfcase>
			<cfdefaultcase>
			   <cfquery datasource="#attributes.datasource#" name="recordset">
			   SELECT	n.*,
					(SELECT count(d.objectid) FROM #arguments.dbowner##attributes.typename# d WHERE d.versionid = n.objectid) as bHasMultipleVersion
			   FROM 	#arguments.dbowner##attributes.typename# n
			   WHERE	n.versionid = ''
				OR	versionid IS NULL
			   </cfquery>
			</cfdefaultcase>
			</cfswitch>
		<cfelse>
			<cfquery datasource="#attributes.datasource#" name="recordset">
			SELECT	n.*,0 as bHasMultipleVersion
			FROM 	#arguments.dbowner##attributes.typename# n
			</cfquery>
		</cfif>
	</cfif>

	<cfquery dbtype="query" name="recordset">
	SELECT	DISTINCT *
	FROM	recordset
	</cfquery>

	<!--- filter by daterange --->
	<cfset aDateRange = ListToArray(prefs.filter_daterange,"~")>
	<cfset aDateRangeSQL = ArrayNew(1)>
	<cfloop index="j" from="1" to="#ArrayLen(aDateRange)#">
		<cfset stSQL = StructNew()>
		<cfset stSQL.fieldName = ListFirst(aDateRange[j],"^")>
		<cfset stSQL.datespan = ListLast(aDateRange[j],"^")>
		<cfif ListLen(stSQL.datespan,"-") EQ 2>
			<cfset stSQL.dateFrom = ListFirst(stSQL.datespan,"-")>
			<cfset stSQL.dateTo = ListLast(stSQL.datespan,"-")>
		<cfelse>
			<cfset stSQL.dateFrom = ListFirst(stSQL.datespan,"-")>
			<cfset stSQL.dateTo = "">
		</cfif>
		<cfset ArrayAppend(aDateRangeSQL, stSQL)>
	</cfloop>

	<cfif ArrayLen(aDateRangeSQL)>
		<cfquery dbtype="query" name="recordset">
		SELECT	*
		FROM	recordset
		WHERE	<cfloop index="k" from="1" to="#ArrayLen(aDateRangeSQL)#"><cfif k GT 1> AND </cfif>
				#aDateRangeSQL[k].fieldName# >= <cfqueryparam value="#CreateODBCDate(aDateRangeSQL[k].dateFrom)#" cfsqltype="cf_sql_date"><cfif aDateRangeSQL[k].dateTo NEQ "">
			AND #aDateRangeSQL[k].fieldName# <= <cfqueryparam value="#CreateODBCDate(aDateRangeSQL[k].dateTo)#" cfsqltype="cf_sql_date"></cfif></cfloop>
		</cfquery>
	</cfif>

	<!--- filter by keyword --->
	<cfset aKeyword = ListToArray(prefs.filter_lkeywords,"~")>
	<cfif ArrayLen(aKeyword)>
		<cftry>
		<cfquery dbtype="query" name="recordset">
		SELECT	*
		FROM	recordset
		WHERE 0=0	
		<cfloop index="i" from="1" to="#ArrayLen(aKeyword)#">
			AND #ListFirst(aKeyword[i],"^")# is not null
			AND lower(#ListFirst(aKeyword[i],"^")#) LIKE <cfqueryparam value="%#LCase(ListLast(aKeyword[i],'^'))#%" cfsqltype="cf_sql_varchar"></cfloop>
		</cfquery>
		<cfcatch >
			<cfdump var="#cfcatch#">
			<cfabort>
		</cfcatch>
		</cftry>
	</cfif>

	<!--- reorder query if needed --->
	<cfif len(prefs.orderby)>
		<cfquery dbtype="query" name="recordset">
		SELECT	*
		FROM 	recordset
		ORDER BY #prefs.orderby# #prefs.order#
		</cfquery>
	</cfif>
	<cfset variables.recordset=recordset>
	<cfreturn recordset />
</cffunction>

<cffunction name="getBasePermissions">
	<cfset var stpermissions=structnew()>
	<cfscript>
	// determine base permissions for this user
	// todo: cache permission lookups.. at least remove double up for default button data 20050725 GB
		oAuthorisation=request.dmsec.oAuthorisation;
		stPermissions=structnew();
		stPermissions.iCreate=oAuthorisation.checkPermission(permissionName="#attributes.permissionset#Create",reference="PolicyGroup");
		stPermissions.iDelete=oAuthorisation.checkPermission(permissionName="#attributes.permissionset#Delete",reference="PolicyGroup");
		stPermissions.iRequestApproval=oAuthorisation.checkPermission(permissionName="#attributes.permissionset#RequestApproval",reference="PolicyGroup");
		stPermissions.iApprove=oAuthorisation.checkPermission(permissionName="#attributes.permissionset#Approve",reference="PolicyGroup");
		stPermissions.iEdit=oAuthorisation.checkPermission(permissionName="#attributes.permissionset#Edit",reference="PolicyGroup");
		stPermissions.iDumpTab=oAuthorisation.checkPermission(permissionName="ObjectDumpTab",reference="PolicyGroup");
		stPermissions.iDeveloper=oAuthorisation.checkPermission(reference="policyGroup",permissionName="developer");
	</cfscript>
	<cfreturn stPermissions />
</cffunction>

<cffunction name="getDefaultColumns">
	<cfset var aDefaultColumns=arraynew(1)>
	<cfset var stCol=structnew()>
	<cfset var stPermissions=getBasePermissions()>
	
	<cfparam name="URL.module" default="" type="string" />

	<cfscript>
		//This data structure is used to create the grid columns
		//remember to delimit dynamic expressions ##
		aDefaultColumns=arrayNew(1);
		editobjectURL = "#application.url.farcry#/conjuror/invocation.cfm?objectid=##recordset.objectID[recordset.currentrow]##&typename=#attributes.typename#&ref=typeadmin&module=#url.module#";

		//select
		stCol=structNew();
		stCol.columnType="expression";
		stCol.title="#application.adminBundle[session.dmProfile.locale].select#";
		stCol.value="<input type=""checkbox"" class=""f-checkbox"" name=""objectid"" value=""##recordset.objectid##"" onclick=""setRowBackground(this);"" />";
		stCol.style="text-align: center;";
		//stCol.orderby="";
		arrayAppend(aDefaultColumns,stCol);

		//edit icon
		stCol=structNew();
		stCol.columnType="evaluate";
		stCol.title="#application.adminBundle[session.dmProfile.locale].edit#";
		stCol.value="iif(stPermissions.iEdit eq 1,DE(iif(locked and lockedby neq '##session.dmSec.authentication.userlogin##_##session.dmSec.authentication.userDirectory##',DE('<span style=""color:red"">Locked</span>'),DE('<a href=''#editObjectURL#''><img src=""#application.url.farcry#/images/treeImages/edit.gif"" alt=""#application.adminBundle[session.dmProfile.locale].edit#"" title=""#application.adminBundle[session.dmProfile.locale].edit#""/></a>'))),DE('-'))";
		stCol.style="text-align: center;";
		//stCol.orderby="";
		arrayAppend(aDefaultColumns,stCol);

		//preview
		stCol=structNew();
		stCol.columnType="expression";
		stCol.title="#application.adminBundle[session.dmProfile.locale].view#";
		stCol.value="<a href=""#application.url.webroot#/index.cfm?objectID=##recordset.objectID##&flushcache=1"" target=""_blank""><img src=""#application.url.farcry#/images/treeImages/preview.gif"" alt=""#application.adminBundle[session.dmProfile.locale].view#"" title=""#application.adminBundle[session.dmProfile.locale].view#"" /></a>";
		stCol.style="text-align: center;";
		//stCol.orderby="";
		arrayAppend(aDefaultColumns,stCol);

		//label and edit
		stCol=structNew();
		stCol.columnType="evaluate";
		stCol.title="#application.adminBundle[session.dmProfile.locale].label#";
		stCol.value = "iif(stPermissions.iEdit eq 1,DE(iif(locked and lockedby neq '#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#',DE('##replace(recordset.label[recordset.currentrow],'####','','all')##'),DE('<a href=''#editObjectURL#''>##replace(recordset.label[recordset.currentrow],'####','','all')##</a>'))),DE('##replace(recordset.label[recordset.currentrow],'####','','all')##'))";
		stCol.style="text-align: left;";
		stCol.orderby="label";
		arrayAppend(aDefaultColumns,stCol);

		//datetimelastupdated
		stCol=structNew();
		stCol.columnType="evaluate";
		stCol.title="#application.adminBundle[session.dmProfile.locale].lastUpdatedLC#";
		stCol.value="application.thisCalendar.i18nDateFormat('##datetimelastupdated##',session.dmProfile.locale,application.mediumF)";
		stCol.style="text-align: center;";
		stCol.orderby="datetimelastupdated";
		arrayAppend(aDefaultColumns,stCol);

		//status
		if (structKeyExists(application.types[attributes.typename].stprops, "status")) {
			stCol=structNew();
			stCol.columnType="value";
			stCol.title="#application.adminBundle[session.dmProfile.locale].status#";
			stCol.value="status";
			stCol.style="text-align: center;";
			stCol.orderby="status";
			arrayAppend(aDefaultColumns,stCol);
		}

		//lastupdatedby
		stCol=structNew();
		stCol.columnType="value";
		stCol.title="#application.adminBundle[session.dmProfile.locale].by#";
		stCol.value="lastupdatedby";
		stCol.style="text-align: center;";
		stCol.orderby="lastupdatedby";
		arrayAppend(aDefaultColumns,stCol);
	</cfscript>
	<cfreturn aDefaultColumns />
</cffunction>

<cffunction name="getDefaultButtons">
	<cfset var aDefaultButtons=arraynew(1)>
	<cfset var stbut=structnew()>
	<cfset var stpermissions=getBasePermissions()>
	
	<cfparam name="URL.module" default="" type="string" />
	
	<cfscript>
		//This data structure is used to create the buttons
		//remember to delimit dynamic expressions ##
		aDefaultButtons=arrayNew(1);
		editobjectURL = "#application.url.farcry#/conjuror/invocation.cfm?objectid=##recordset.objectID[recordset.currentrow]##&typename=#attributes.typename#&ref=typeadmin&module=#url.module#";
		// check for base permissions
		oAuthorisation=request.dmsec.oAuthorisation;
		// set bunlock for now, needs to be set if locked objects exist
		bUnlock=true;

		//add, delete, unlock, dump, requestapproval, approve, sendtodraft
		// add button
			stBut=structNew();
			stBut.type="button";
			stBut.name="add";
			stBut.value="#application.adminBundle[session.dmProfile.locale].add#";
			stBut.class="f-submit";
			stBut.onClick="window.location='#application.url.farcry#/conjuror/evocation.cfm?typename=#attributes.typename#&ref=typeadmin&module=#url.module#';";
			stBut.permission="#attributes.permissionset#Create";
			stBut.buttontype="add";
			arrayAppend(aDefaultButtons,stBut);

		// delete object(s)
			stBut=structNew();
			stBut.type="button";
			stBut.name="deleteAction";
			stBut.value="#application.adminBundle[session.dmProfile.locale].delete#";
			stBut.class="f-submit";
			// todo: i18n
			stBut.onClick="if(confirm('Are you sure you wish to delete these objects?')){document['typeadmin']['delete'].value=1;this.form.submit();}";
			stBut.permission="#attributes.permissionset#Delete";
			stBut.buttontype="delete";
			arrayAppend(aDefaultButtons,stBut);

		// check if object uses status
		if (structKeyExists(application.types['#attributes.typename#'].stProps,"status")) {
			// Set status to pending
				stBut=structNew();
				stBut.type="submit";
				stBut.name="status";
				stBut.value="#application.adminBundle[session.dmProfile.locale].requestApproval#";
				stBut.class="f-submit";
				stBut.onClick="";
				stBut.permission="#attributes.permissionset#RequestApproval";
				stBut.buttontype="requestapproval";
				arrayAppend(aDefaultButtons,stBut);
			// set status to approved/draft
				//approve
				stBut=structNew();
				stBut.type="submit";
				stBut.name="status";
				stBut.value="#application.adminBundle[session.dmProfile.locale].approve#";
				stBut.class="f-submit";
				stBut.onClick="";
				stBut.permission="#attributes.permissionset#Approve";
				stBut.buttontype="approve";
				arrayAppend(aDefaultButtons,stBut);
				//send to draft
				stBut=structNew();
				stBut.type="submit";
				stBut.name="status";
				stBut.value="#application.adminBundle[session.dmProfile.locale].sendToDraft#";
				stBut.class="f-submit";
				stBut.onClick="";
				stBut.permission="#attributes.permissionset#Approve";
				stBut.buttontype="sendtodraft";
				arrayAppend(aDefaultButtons,stBut);

		}
		// dump objects
			stBut=structNew();
			stBut.type="submit";
			stBut.name="dump";
			stBut.value="#application.adminBundle[session.dmProfile.locale].dump#";
			stBut.class="f-submit";
			stBut.onClick="";
			stBut.permission="ObjectDumpTab";
			stBut.buttontype="dump";
			arrayAppend(aDefaultButtons,stBut);

		// check if there are locked objects
		if (isdefined("bUnlock")) {
			stBut=structNew();
			stBut.type="Submit";
			stBut.name="unlock";
			stBut.value="#application.adminBundle[session.dmProfile.locale].unlockUC#";
			stBut.class="f-submit";
			stBut.onClick="";
			stBut.permission="";
			stBut.buttontype="unlock";
			arrayAppend(aDefaultButtons,stBut);
		}
	</cfscript>
	<cfreturn aDefaultButtons />
</cffunction>

<!--- pagination methods --->
<cffunction name="getTotalPages" returntype="numeric">
	<cfset var pgtotal=0>
	<cfset pgtotal=ceiling(variables.recordset.recordcount/variables.attributes.numitems)>
	<cfif prefs.pg gt pgtotal>
		<cfset prefs.pg=pgtotal>
	</cfif>
	<cfreturn pgtotal />
</cffunction>

<cffunction name="getStartRow" returntype="numeric">
	<cfset var startrow=0>
	<cfset startrow=(prefs.pg-1)*attributes.numitems+1>
	<cfif startrow lt 1>
		<cfset startrow=1>
	</cfif>
	<cfreturn startrow />
</cffunction>

<cffunction name="getEndRow" returntype="numeric">
	<cfset endrow=getstartrow()+attributes.numitems-1>
	<cfif endrow gt recordset.recordcount>
		<cfset endrow=recordset.recordcount>
	</cfif>
	<cfreturn endrow />
</cffunction>

<cffunction name="panelKeywordFilter">
	
	<cfset var panel="">
	<cfset var qString="">
	<cfset var aKeywordField = ArrayNew(1)>

	<cfif Len(prefs.filter_lkeywords)>
		<cfsavecontent variable="keywordsFilterList">
			<cfoutput><ul></cfoutput>
			<cfloop list="#session.typeadmin[attributes.typename].Filter_lkeywords#" index="i" delimiters="~">
				<cfoutput><li><strong>#ListFirst(i,"^")# : </strong>#ListLast(i,"^")# <a href="#cgi.SCRIPT_NAME#?<cfif len(CGI.QUERY_STRING)>#queryStringDeleteVar('killKeyword')#&</cfif>killKeyword=#i#">Remove</a></li></cfoutput>
		</cfloop>
			<cfoutput></ul></cfoutput>
		</cfsavecontent>
	</cfif>
	<!--- filter by keyword --->
	<!--- todo: accept atributes from typeadmin.cfm --->
	<cfset lSearchableFieldTypes = "nstring,string,uuid">
	<cfset lSearchableFieldName_exclude = "navigation">
	<cfloop collection="#application.types[attributes.typename].stprops#" item="field">
		<cfif ListFindNoCase(lSearchableFieldTypes,application.types[attributes.typename].stprops[field].metadata.type) AND NOT ListFindNoCase(lSearchableFieldName_exclude, field)>
			<cfset ArrayAppend(aKeywordField,field)>
		</cfif>
	</cfloop>

	<cfset ArraySort(aKeywordField,"textnocase","asc")>
	<cfif isdefined("variables.attributes.query") and isQuery(variables.attributes.query) and variables.attributes.query.recordcount>
		<!--- key words should list columns in the query if a custom q1uery has been passed into the tag --->
		<cfsavecontent variable="panel"><cfoutput>
		<b>Properties:</b>
			<select name="keywords_field" id="keywords_field"><cfloop list="#variables.attributes.query.columnlist#" index="x">
				<option value="#x#"<cfif x eq "label"> SELECTED</cfif>>#lcase(x)#</option></cfloop>
			</select>
		<!--- todo: i18n --->
		<b>Keywords:</b>
			<input type="text" name="keywords" id="keywords" />
		<!--- </label> --->
		<input type="submit" name="button_Filter_Keyword" value="Filter" class="f-submit" /></cfoutput>
		</cfsavecontent>	
	<cfelse>
		<cfsavecontent variable="panel"><cfoutput>
		<cfif isDefined("keywordsFilterList")>#keywordsFilterList#</cfif>
		<!--- todo: i18n --->
		<b>Properties:</b>
			<select name="keywords_field" id="keywords_field"><cfloop index="i" from="1" to="#Arraylen(aKeywordField)#">
				<option value="#aKeywordField[i]#"<cfif aKeywordField[i] eq "label"> SELECTED</cfif>>#LCase(aKeywordField[i])#</option></cfloop>
			</select>
		<!--- todo: i18n --->
		<b>Keywords:</b>
			<input type="text" name="keywords" id="keywords" />
		<!--- </label> --->
		<input type="submit" name="button_Filter_Keyword" value="Filter" class="f-submit" /></cfoutput>
		</cfsavecontent>	
	</cfif>
	
	
	<cfreturn panel />
</cffunction>

<cffunction name="panelDateRangeFilter">
	<cfset var panel = "">
	<cfset var dateRangeFilterDisplay = "">
	<cfset var qString="">
	<cfset var aDateRange = ListToArray(prefs.filter_daterange,"~")>

	<cfif ArrayLen(aDateRange)>
		<cfsavecontent variable="dateRangeFilterList"><cfoutput>
		<ul><cfloop index="i" from="1" to="#ArrayLen(aDateRange)#"><cfset strDateSpan = ListLast(aDateRange[i],"^")>
			<li><strong>#ListFirst(aDateRange[i],"^")# : </strong>
				<em>from</em> #DateFormat(ListFirst(strDateSpan,"-"),"dd mmm yyyy")#<cfif ListLen(strDateSpan,"-") EQ 2>
				&nbsp;<em>to</em> #DateFormat(ListLast(strDateSpan,"-"),"dd mmm yyyy")#</cfif>
				<a href="#cgi.SCRIPT_NAME#?killDateRange=#aDateRange[i]#">Remove</a></li></cfloop>
		</ul></cfoutput>
		</cfsavecontent>
	</cfif>

	<!--- filter by daterange --->
	<cfset aDateField = ArrayNew(1)>
	<cfset lSearchableFieldTypes = "date,datetime,timestamp">
	<cfif attributes.bFilterDateRange>
		<cfloop collection="#application.types[attributes.typename].stprops#" item="field">
			<cfif ListFindNoCase(lSearchableFieldTypes,application.types[attributes.typename].stprops[field].metadata.type)>
				<cfset ArrayAppend(aDateField,field)>
			</cfif>
		</cfloop>
	</cfif>

	<cfsavecontent variable="panel"><cfoutput>
		<cfif isDefined("dateRangeFilterList")>#dateRangeFilterList#</cfif>
		<cfif ArrayLen(aDateField)>
		<!--- <label for="daterange"> --->
		<b>Date Field:</b>
		<select name="daterange_field" id="daterange_field"><cfloop index="i" from="1" to="#Arraylen(aDateField)#">
			<option value="#aDateField[i]#">#LCase(aDateField[i])#</option></cfloop>
		</select>

		<b>Date range:</b>
			<input type="text" name="daterange" id="daterange" />
		<!--- </label> --->
		<input type="submit" name="button_Filter_DateRange" value="Filter" class="f-submit" tabindex="12" /><br />
		<em>format yyyy/mm/dd - yyyy/mm/dd</em>
		<cfelse><b>No Date Searchable Fields</b>
		</cfif></cfoutput>
	</cfsavecontent>
	<cfreturn panel />
</cffunction>

<cffunction name="panelCategoryFilter">
	<cfset var panel="">
	<cfset var categoryFilterDisplay="">
	<cfset var qString="">
	<cfset var oTree=application.factory.oTree>
	<cfset var oCat=application.factory.oCategory>
	<cfset var qcatRoot=otree.getRootNode(typename="categories")>
	<cfset var qCats=otree.getDescendants(objectid=qcatroot.objectid)>

	<!--- prep category filter display --->
	<cfif len(prefs.lcategoryids)>
		<cfsavecontent variable="categoryFilterDisplay">
			<cfloop list="#prefs.lcategoryids#" index="i">
				<cfoutput>#oCat.getCategoryNamebyid(categoryid=i)#</cfoutput>
			</cfloop>
		</cfsavecontent>

		<!--- list currently active category filters & delete option --->
		<cfloop collection="#url#" item="tempQString">
			<cfif tempQString NEQ "killCatID">
				<cfset qString = qString & "&#tempQString#=#url[tempQString]#">
			</cfif>
		</cfloop>

		<cfsavecontent variable="categoryFilterList">
			<cfoutput><ul></cfoutput>
			<cfloop list="#session.typeadmin[attributes.typename].lcategoryids#" index="i">
				<cfoutput><li>#oCat.getCategoryNamebyid(categoryid=i)# <a href="#cgi.SCRIPT_NAME#?killCatID=#i#&#qString#">Remove</a></li></cfoutput>
		</cfloop>
			<cfoutput></ul></cfoutput>
		</cfsavecontent>
	</cfif>

	<cfsavecontent variable="panel">
		<cfoutput>
		<cfif isDefined("categoryFilterList")>#categoryFilterList#</cfif>
		<label for="cat"><b>Category Filter</b>
		<select id="cat" name="categoryid"></cfoutput><cfoutput query="qCats">
			<option value="#qCats.objectid#"><cfloop from="1" to="#qCats.nlevel-1#" index="i">- </cfloop>#qCats.objectname#</option></cfoutput><cfoutput>
		</select>
		</label>
		<input type="submit" name="button_Filter_Category" value="Filter" class="f-submit" />
		</cfoutput>
	</cfsavecontent>

	<cfreturn panel />
</cffunction>

<cfscript>
/**
 * Case-insensitive function for removing duplicate entries in a list.
 * Based on dedupe by Raymond Camden
 *
 * @param list 	 List to be modified.
 * @return Returns a list.
 * @author Jeff Howden (jeff@members.evolt.org)
 * @version 1, March 21, 2002
 */
function ListDeleteDuplicatesNoCase(list)
{
  var i = 1;
  var delimiter = ',';
  var returnValue = '';
  if(ArrayLen(arguments) GTE 2)
    delimiter = arguments[2];
  list = ListToArray(list, delimiter);
  for(i = 1; i LTE ArrayLen(list); i = i + 1)
    if(NOT ListFindNoCase(returnValue, list[i], delimiter))
      returnValue = ListAppend(returnValue, list[i], delimiter);
  return returnValue;
}


/**
 * Deletes a var from a query string.
 * Idea for multiple args from Michael Stephenson (michael.stephenson@adtran.com)
 * 
 * @param variable 	 A variable, or a list of variables, to delete from the query string. 
 * @param qs 	 Query string to modify. Defaults to CGI.QUERY_STRING. 
 * @return Returns a string. 
 * @author Nathan Dintenfass (nathan@changemedia.com) 
 * @version 1.1, February 24, 2002 
 */
function queryStringDeleteVar(variable){
	//var to hold the final string
	var string = "";
	//vars for use in the loop, so we don't have to evaluate lists and arrays more than once
	var ii = 1;
	var thisVar = "";
	var thisIndex = "";
	var array = "";
	//if there is a second argument, use that as the query string, otherwise default to cgi.query_string
	var qs = cgi.query_string;
	if(arrayLen(arguments) GT 1)
		qs = arguments[2];
	//put the query string into an array for easier looping
	array = listToArray(qs,"&");		
	//now, loop over the array and rebuild the string
	for(ii = 1; ii lte arrayLen(array); ii = ii + 1){
		thisIndex = array[ii];
		thisVar = listFirst(thisIndex,"=");
		//if this is the var, edit it to the value, otherwise, just append
		if(not listFind(variable,thisVar))
			string = listAppend(string,thisIndex,"&");
	}
	//return the string
	return string;
}

</cfscript>
</cfcomponent>