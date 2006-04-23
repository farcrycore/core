
<cfcomponent displayname="Event Rule" extends="rules" hint="Method for displaying dmEvent objects">

<cfproperty name="intro" type="string" hint="Intro text for the event listing" required="no" default="">
<cfproperty name="displayMethod" type="string" hint="Display method to render this event rule with." required="yes" default="displayteaser">
<cfproperty name="numItems" hint="The number of items to display per page" type="numeric" required="true" default="5">
<cfproperty name="numPages" hint="The number of pages of news articles to display at most" type="numeric" required="true" default="1">
<cfproperty name="bArchive" hint="Display News as an archive" type="boolean" required="true" default="0">
<cfproperty name="bMatchAllKeywords" hint="Doest the content need to match ALL selected keywords" type="boolean" required="false" default="0">
<cfproperty name="metadata" type="string" hint="A list of category ObjectIDs that the news content is to be drawn from" required="false" default="">

	<cffunction access="public" name="update" output="true">
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="label" required="no" type="string" default="">
		<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
		<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">
        <cfimport taglib="/farcry/farcry_core/tags/display/" prefix="display">				

		<cfparam name="form.bArchive" default="0">
		<cfparam name="form.bMatchAllKeywords" default="0">
		<cfparam name="form.categoryID" default="">
		

		
        <cfparam name="isClosed" default="Yes">
        <cfif isDefined("form.categoryid") OR isDefined("form.apply")>
            <cfset isClosed = "No">
        </cfif>

		<cfset stObj = this.getData(arguments.objectid)> 
		<cfif isDefined("form.updateRuleNews")>
			<cfscript>
				stObj.displayMethod = form.displayMethod;
				stObj.intro = form.intro;
				stObj.numItems = form.numItems;
				stObj.numPages = form.numPages;
				stObj.bArchive = form.bArchive;
				stObj.bMatchAllKeywords = form.bMatchAllKeywords;
				stObj.metadata = form.categoryID; //must add metadata tree
			</cfscript>
			<q4:contentobjectdata typename="#application.rules.ruleEvents.rulePath#" stProperties="#stObj#" objectID="#stObj.objectID#">
			<!--- Now assign the metadata --->
					
			<cfset message = "#application.adminBundle[session.dmProfile.locale].updateSuccessful#">
		</cfif>
				
		<cfif isDefined("message")>
			<div align="center"><strong>#message#</strong></div>
		</cfif>	
		<!--- get the display methods --->
		<nj:listTemplates typename="dmEvent" prefix="displayTeaser" r_qMethods="qDisplayTypes"> 
		<form action="" method="POST">
		<table width="100%" align="center" border="0">
		<input type="hidden" name="ruleID" value="#stObj.objectID#">
		<tr>
			<td width="20%" colspan="1" align="right">
			<b>#application.adminBundle[session.dmProfile.locale].displayMethodLabel# </b>
			</td>
			<td>
			<select name="displayMethod" size="1" class="field">
				<cfloop query="qDisplayTypes">
					<option value="#methodName#" <cfif methodName is stObj.displayMethod>selected</cfif>>#displayName#</option>
				</cfloop>
			</select>
			</td>
		</tr>
		<tr>
				<td align="right">
					<b>#application.adminBundle[session.dmProfile.locale].introLabel#</b>
				</td> 
				<td>
					<textarea rows="5" cols="50" name="intro">#stObj.intro#</textarea>
				</td>
		</tr>
		<tr>
			<td align="right"><b>#application.adminBundle[session.dmProfile.locale].itemsPerPage#</b></td>
			<td> <input type="text" name="numItems" value="#stObj.numItems#" size="3"></td>
		</tr>
		<tr>
			<td colspan="2"><b>#application.adminBundle[session.dmProfile.locale].displayAsArchive#</b> <input type="checkbox" name="bArchive" value="1" <cfif stObj.bArchive>checked</cfif>></td>
		</tr>
		<tr>
			<td colspan="2"><b>#application.adminBundle[session.dmProfile.locale].maxArchivePages#</b>  <input type="text" name="numPages" value="#stObj.numPages#" size="3"></td>
		</tr>	
		</table>

        <br><br>

		<display:OpenLayer width="400" title="#application.adminBundle[session.dmProfile.locale].restrictByCategories#" titleFont="Verdana" titleSize="7.5" isClosed="#isClosed#" border="no">
		<table align="center" border="0">
        <tr>
            <td><b>#application.adminBundle[session.dmProfile.locale].contentNeedToMatchKeywords#</b> <input type="checkbox" name="bMatchAllKeywords" value="1" <cfif stObj.bMatchAllKeywords>checked</cfif>></td>
        </tr>
        <tr>
            <td>&nbsp;</td>
        </tr>
		<tr>
			<td id="Tree">
   				<cfinvoke  component="#application.packagepath#.farcry.category" method="displayTree">
    				<cfinvokeargument name="bShowCheckBox" value="true"> 
   					<cfinvokeargument name="lselectedCategories" value="#stObj.metaData#">	
    			</cfinvoke>
			</td>
		</tr>
    	</table>
		</display:OpenLayer>
		<div align="center"><input class="normalbttnstyle" type="submit" value="#application.adminBundle[session.dmProfile.locale].go#" name="updateRuleNews"></div>
		</form>
			
	</cffunction> 
	
	<cffunction name="getDefaultProperties" returntype="struct" access="public">
		<cfscript>
			stProps=structNew();
			stProps.objectid = createUUID();
			stProps.label = '';
			stProps.displayMethod = 'displayteaserbullet';
			stProps.numPages = 1;
			stProps.numItems = 5;
			stProps.bArchive = 0;
			stProps.bMatchAllKeywords = 0;
			stProps.metadata = '';
		</cfscript>	
		<cfreturn stProps>
	</cffunction>  

	<cffunction access="public" name="execute" output="true">
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="dsn" required="false" type="string" default="#application.dsn#">
		<cfparam name="request.mode.lValidStatus" default="approved">
		<cfset stObj = this.getData(arguments.objectid)> 
		
		<cfif application.dbtype eq "mysql">
			<!--- create temp table for status --->
			<cfquery datasource="#arguments.dsn#" name="temp">
				DROP TABLE IF EXISTS tblTemp1
			</cfquery>
			<cfquery datasource="#arguments.dsn#" name="temp2">
				create temporary table `tblTemp1`
					(
					`Status`  VARCHAR(50) NOT NULL
					)
			</cfquery>
			<cfloop list="#request.mode.lValidStatus#" index="i">
				<cfquery datasource="#arguments.dsn#" name="temp3">
					INSERT INTO tblTemp1 (Status) 
					VALUES ('#replace(i,"'","","all")#')
				</cfquery>
			</cfloop>
		</cfif>
		
		<!--- If Archive: Get Maximum Rows in New Table --->
		<cfif stObj.bArchive>	
			<cfquery datasource="#arguments.dsn#" name="qGetCount">
			SELECT objectID
			FROM #application.dbowner#dmEvent
			ORDER by startDate ASC
			</cfquery>
			<cfset maximumRows = qGetCount.recordcount>
		<cfelse>
			<cfset maximumRows = stObj.numItems>
		</cfif>
		
		<!--- check if filtering by categories --->
		<cfif NOT trim(len(stObj.metadata)) EQ 0>
			<!--- show by categories --->
			<cfswitch expression="#application.dbtype#">
				<cfcase value="mysql">
					<cfif stObj.bMatchAllKeywords>
						<!--- must match all categories --->
						<cfquery datasource="#arguments.dsn#" name="qGetEvents" maxrows="#maximumRows#">
							SELECT DISTINCT type.objectID, type.publishDate,type.startDate, type.label
							    FROM tblTemp1, dmEvent type, refCategories refCat1
							<!--- if more than one category make join for each --->
							<cfif listLen(stObj.metadata) gt 1>
								<cfloop from="2" to="#listlen(stObj.metadata)#" index="i">
								    , refCategories refCat#i#
								</cfloop>
							</cfif>
							WHERE 1=1
								<!--- loop over each category and make sure item has all categories --->
								<cfloop from="1" to="#listlen(stObj.metadata)#" index="i">
									AND refCat#i#.categoryID = '#listGetAt(stObj.metadata,i)#'
									AND refCat#i#.objectId = type.objectId
								</cfloop>
								AND type.status = tblTemp1.Status
								AND publishdate <= #now()#
								AND expirydate >= #now()#
							ORDER BY type.startDate ASC, type.label ASC
						</cfquery>
					<cfelse>
						<!--- doesn't need to match all categories --->
						<cfquery datasource="#arguments.dsn#" name="qGetEvents" maxrows="#maximumRows#">
							SELECT DISTINCT type.objectID, type.publishDate,type.startDate, type.label
							FROM tblTemp1, refCategories refCat, dmEvent type
							WHERE refCat.objectID = type.objectID
								AND refCat.categoryID IN ('#ListChangeDelims(stObj.metadata,"','",",")#')
								AND type.status = tblTemp1.Status
								AND publishdate <= #now()#
								AND expirydate >= #now()#
							ORDER BY type.startDate ASC, type.label ASC
						</cfquery>
					</cfif>
				</cfcase>

				<cfdefaultcase>
					<cfif stObj.bMatchAllKeywords>
						<!--- must match all categories --->
						<cfquery datasource="#arguments.dsn#" name="qGetEvents" maxrows="#maximumRows#">
							SELECT DISTINCT type.objectID, type.publishDate,type.startDate, type.label
							FROM refCategories refcat1
							<!--- if more than one category make join for each --->
							<cfif listLen(stObj.metadata) gt 1>
								<cfloop from="2" to="#listlen(stObj.metadata)#" index="i">
									inner join refcategories refcat#i# on refcat#i-1#.objectid = refcat#i#.objectid
								</cfloop>
							</cfif>
							JOIN dmEvent type ON refcat1.objectID = type.objectID
							WHERE 1=1
								<!--- loop over each category and make sure item has all categories --->
								<cfloop from="1" to="#listlen(stObj.metadata)#" index="i">
									AND refCat#i#.categoryID = '#listGetAt(stObj.metadata,i)#'
								</cfloop>
								AND type.status IN ('#ListChangeDelims(request.mode.lValidStatus,"','",",")#')
								AND publishdate <= #now()#
								AND expirydate >= #now()#
							ORDER BY type.startDate ASC, type.label ASC
						</cfquery>
					<cfelse>
						<!--- doesn't need to match all categories --->
						<cfquery datasource="#arguments.dsn#" name="qGetEvents" maxrows="#maximumRows#">
							SELECT DISTINCT type.objectID, type.publishDate,type.startDate, type.label
							FROM refObjects refObj
							JOIN refCategories refCat ON refObj.objectID = refCat.objectID
							JOIN dmEvent type ON refObj.objectID = type.objectID
							WHERE refObj.typename = 'dmEvent'
								AND refCat.categoryID IN ('#ListChangeDelims(stObj.metadata,"','",",")#')
								AND type.status IN ('#ListChangeDelims(request.mode.lValidStatus,"','",",")#')
								AND publishdate <= #now()#
								AND expirydate >= #now()#
							ORDER BY type.startDate ASC, type.label ASC
						</cfquery>
					</cfif>
				</cfdefaultcase>
			</cfswitch>
		<cfelse>
			<!--- don't filter on categories --->
			<cfswitch expression="#application.dbtype#">
				<cfcase value="mysql">
					<cfquery datasource="#arguments.dsn#" name="qGetEvents" maxrows="#maximumRows#">
						SELECT *
						FROM #application.dbowner#dmEvent events, tblTemp1
						WHERE events.status = tblTemp1.Status
							AND publishdate <= #now()#
							AND expirydate >= #now()#
						ORDER BY startDate ASC
					</cfquery>
				</cfcase>

				<cfdefaultcase>
					<cfquery datasource="#arguments.dsn#" name="qGetEvents" maxrows="#maximumRows#">
						SELECT *
						FROM #application.dbowner#dmEvent
						WHERE status IN ('#ListChangeDelims(request.mode.lValidStatus,"','",",")#')
							AND publishdate <= #now()#
							AND expirydate >= #now()#
						ORDER BY startDate ASC
					</cfquery>
				</cfdefaultcase>
			</cfswitch>
		</cfif>
	
		<cfif NOT stObj.bArchive>
			<cfif len(trim(stObj.intro)) AND qGetEvents.recordCount>
				<cfset tmp = arrayAppend(request.aInvocations,stObj.intro)>
			</cfif>
			<!--- loop over display methods --->
			<cfloop query="qGetEvents">
				<cfscript>
				 	stInvoke = structNew();
					stInvoke.objectID = qGetEvents.objectID;
					stInvoke.typename = application.types.dmEvent.typePath;
					stInvoke.method = stObj.displayMethod;
					arrayAppend(request.aInvocations,stInvoke);
				</cfscript>
			</cfloop>
			
		<cfelse>
			<cfparam name="url.pgno" default="1">

			<!--- Get Number of Pages --->
			<cfset iNumberOfPages = Ceiling(qGetEvents.recordcount / stobj.numitems)>
			<!--- Check URL.pageno --->
			<cfif url.pgno GT iNumberOfPages OR url.pgno GT stobj.numpages>
				<cfset url.pgno = 1>
			</cfif>						
			<!--- Check Number of Pages --->
			<cfif iNumberOfPages GT stobj.numpages>
				<cfset iNumberOfPages = stobj.numpages>
			</cfif>
			<!--- Get Query Start and End Numbers --->
			<cfset startrow = (url.pgno - 1) * stobj.numitems + 1>
			<cfset endrow = min(startrow + stobj.numitems - 1, qGetEvents.recordcount)>

			<!--- Output Page Numbers --->
			<cfif iNumberOfPages GT 1>
				<!--- save pagination output to variable --->
				<cfsavecontent variable="pageNums">
					<cfoutput>
					<div align="center" class="newsArchive">
					<cfif url.pgno NEQ 1>
						<a class="newsArchive" href="#Application.URL.conjurer#?objectID=#url.objectID#&pgno=#(url.pgno-1)#">Previous Page</a>&nbsp;&nbsp;
					</cfif>
					<cfloop index="i" from="1" to="#iNumberOfPages#">
					<cfif i NEQ url.pgno></cfif><a class="newsArchive" href="#Application.URL.conjurer#?objectID=#url.objectID#&pgno=#i#">#i#</a><cfif i NEQ url.pgno><a class="newsArchive" href="#Application.URL.conjurer#?objectID=#url.objectID#&pgno=#i#"></a></cfif>
					</cfloop>
					<cfif url.pgno NEQ iNumberOfPages>
						&nbsp;&nbsp;<a class="newsArchive" href="#Application.URL.conjurer#?objectID=#url.objectID#&pgno=#(url.pgno+1)#">Next Page</a>
					</cfif>
					</div>
					<br>
					</cfoutput>
				</cfsavecontent>
				<!--- append pagination output to Invocations array --->
				<cfset arrayAppend(request.aInvocations,pageNums)>
			</cfif>
			
			<!--- Loop Through News and Display --->
			<cfloop query="qGetEvents" startrow="#startrow#" endrow="#endrow#">
				<cfscript>
				 	stInvoke = structNew();
					stInvoke.objectID = qGetEvents.objectID;
					stInvoke.typename = application.types.dmEvent.typePath;
					stInvoke.method = stObj.displayMethod;
					arrayAppend(request.aInvocations,stInvoke);
				</cfscript>
			</cfloop>
			
			<!--- Output Page Numbers --->
			<cfif iNumberOfPages GT 1>
				<!--- save pagination output to variable --->
				<cfsavecontent variable="pageNums2">
					<cfoutput>
					<br>
					<div align="center" class="newsArchive">
					<cfif url.pgno NEQ 1>
						<a class="newsArchive" href="#Application.URL.conjurer#?objectID=#url.objectID#&pgno=#(url.pgno-1)#">Previous Page</a>&nbsp;&nbsp;
					</cfif>
					<cfloop index="i" from="1" to="#iNumberOfPages#">
					<cfif i NEQ url.pgno></cfif><a class="newsArchive" href="#Application.URL.conjurer#?objectID=#url.objectID#&pgno=#i#">#i#</a><cfif i NEQ url.pgno><a class="newsArchive" href="#Application.URL.conjurer#?objectID=#url.objectID#&pgno=#i#"></a></cfif>
					</cfloop>
					<cfif url.pgno NEQ iNumberOfPages>
						&nbsp;&nbsp;<a class="newsArchive" href="#Application.URL.conjurer#?objectID=#url.objectID#&pgno=#(url.pgno+1)#">Next Page</a>
					</cfif>
					</div>				
					</cfoutput>
				</cfsavecontent>
				<!--- append pagination output to Invocations array --->
				<cfset arrayAppend(request.aInvocations,pageNums2)>
			</cfif>
			
		</cfif>
		
	</cffunction> 

</cfcomponent>