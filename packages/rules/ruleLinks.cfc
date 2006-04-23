<cfcomponent displayname="External Links Rule" extends="rules" hint="Method for displaying dmLink objects">

<cfproperty name="intro" type="string" hint="Intro text for the link listing" required="no" default="">
<cfproperty name="displayMethod" type="string" hint="Display method to render this link rule with." required="yes" default="displayteaser">
<cfproperty name="numItems" hint="The number of items to display per page" type="numeric" required="true" default="5">
<cfproperty name="numPages" hint="The number of pages of links to display at most" type="numeric" required="true" default="1">
<cfproperty name="bArchive" hint="Display links as an archive" type="boolean" required="true" default="0">
<cfproperty name="bMatchAllKeywords" hint="Does the content need to match ALL selected keywords" type="boolean" required="false" default="0">
<cfproperty name="metadata" type="string" hint="A list of category ObjectIDs that the links content is to be drawn from" required="false" default="">

	<cffunction access="public" name="update" output="true">
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="label" required="no" type="string" default="">
		<cfset var stLocal = StructNew()> 
		<cfset var stObj = this.getData(arguments.objectid)> 

<cfsetting enablecfoutputonly="true">
		<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
        <cfimport taglib="/farcry/farcry_core/tags/display/" prefix="display">				
        <cfimport taglib="/farcry/farcry_core/tags/widgets/" prefix="widgets">
        
		<cfparam name="form.bArchive" default="0">
		<cfparam name="form.bMatchAllKeywords" default="0">
		<cfparam name="lSelectedCategoryID" default="">
		<cfparam name="bRestrictByCategory" default="0">

		<cfif isDefined("form.updateRuleLinks")>
			<cfif bRestrictByCategory EQ 0>
				<cfset lSelectedCategoryID = "">
			</cfif>
			<cfset stObj.displayMethod = form.displayMethod>
			<cfset stObj.intro = form.intro>
			<cfset stObj.numItems = form.numItems>
			<cfset stObj.numPages = form.numPages>
			<cfset stObj.bArchive = form.bArchive>
			<cfset stObj.bMatchAllKeywords = form.bMatchAllKeywords>
			<cfset stObj.metadata = lSelectedCategoryID>
			<!--- must add metadata tree --->

			<q4:contentobjectdata typename="#application.rules.ruleLinks.rulePath#" stProperties="#stObj#" objectID="#stObj.objectID#">
			<!--- Now assign the metadata --->					
			<cfset stLocal.successMessage = "#application.adminBundle[session.dmProfile.locale].updateSuccessful#">
		<cfelse>
			<cfset lSelectedCategoryID = stObj.metadata>
			<cfif stObj.metadata NEQ "">
				<cfset bRestrictByCategory = 1>
			</cfif>
		</cfif>

		<!--- get the display methods --->
		<nj:listTemplates typename="dmLink" prefix="displayTeaser" r_qMethods="qDisplayTypes"> 
<cfoutput>
<form name="editform" action="#cgi.script_name#?#cgi.query_string#" method="post" class="f-wrap-2" style="margin-top:-1.5em">
<fieldset><cfif StructKeyExists(stLocal,"successmessage")>
	<p id="fading1" class="fade"><span class="success">#stLocal.successmessage#</span></p></cfif>
	
	<widgets:displayMethodSelector typeName="dmLink" prefix="displayTeaser">

	<label for="intro"><b>#application.adminBundle[session.dmProfile.locale].introlabel#</b>
		<textarea id="intro" name="intro">#stObj.intro#</textarea><br />
	</label>
	
	<label for="numItems"><b>## #application.adminBundle[session.dmProfile.locale].itemsPerPage#</b>
		<input type="text" id="numItems" name="numItems" value="#stObj.numItems#" size="3" maxlength="3"><br />
	</label>
	
	<label for="bArchive"><b>#application.adminBundle[session.dmProfile.locale].displayAsArchive#</b>
		<input type="checkbox" id="bArchive" name="bArchive" value="1"<cfif stObj.bArchive> checked="checked"</cfif>><br />
	</label>

	<label for="numPages"><b>#application.adminBundle[session.dmProfile.locale].maxArchivePages#</b>
		<input type="text" id="numPages" name="numPages" value="#stObj.numPages#" size="3" maxlength="3"><br />
	</label>

	<label for="bRestrictByCategory"><b>#application.adminBundle[session.dmProfile.locale].restrictByCategories#</b>
		<input type="checkbox" id="bRestrictByCategory" name="bRestrictByCategory" value="1"<cfif bRestrictByCategory EQ 1> checked="checked"</cfif> onclick="fShowHide('tglCategory',this.checked);"><br />
	</label>
	<span id="tglCategory" style="display:<cfif bRestrictByCategory>block<cfelse>none</cfif>;">
	<label for="bMatchAllKeywords"><b>#application.adminBundle[session.dmProfile.locale].contentNeedToMatchKeywords#</b>
		<input type="checkbox" id="bMatchAllKeywords" name="bMatchAllKeywords" value="1" <cfif stObj.bMatchAllKeywords>checked="checked"</cfif>><br />
	</label>
	<widgets:categoryAssociation typeName="dmLinks" lSelectedCategoryID="#stObj.metaData#">
	</span>

<div class="f-submit-wrap">
	<input type="Submit" name="updateRuleLinks" value="#application.adminBundle[session.dmProfile.locale].go#" class="f-submit" />		
</div>
<input type="hidden" name="ruleID" value="#stObj.objectID#">
</fieldset>
</form></cfoutput>
<cfsetting enablecfoutputonly="false">			
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

		<!--- If Archive: Get Maximum Rows in New Table --->
		<cfif stObj.bArchive>	
			<cfquery datasource="#arguments.dsn#" name="qGetCount">
			SELECT objectID
			FROM #application.dbowner#dmLink
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
						<cfquery datasource="#arguments.dsn#" name="qGetLinks" maxrows="#maximumRows#">
							SELECT DISTINCT type.objectID, type.label
							    FROM dmLink type, refCategories refCat1
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
								AND type.status IN ('#ListChangeDelims(request.mode.lValidStatus,"','",",")#')
							ORDER BY type.label ASC
						</cfquery>
					<cfelse>
						<!--- doesn't need to match all categories --->
						<cfquery datasource="#arguments.dsn#" name="qGetLinks" maxrows="#maximumRows#">
							SELECT DISTINCT type.objectID, type.label
							FROM refCategories refCat, dmLink type
							WHERE refCat.objectID = type.objectID
								AND refCat.categoryID IN ('#ListChangeDelims(stObj.metadata,"','",",")#')
								AND type.status IN ('#ListChangeDelims(request.mode.lValidStatus,"','",",")#')
							ORDER BY type.label ASC
						</cfquery>
					</cfif>
				</cfcase>
				<cfdefaultcase>
					<cfif stObj.bMatchAllKeywords>
						<!--- must match all categories --->
						<cfquery datasource="#arguments.dsn#" name="qGetLinks" maxrows="#maximumRows#">
							SELECT DISTINCT type.objectID, type.label
							FROM refCategories refcat1
							<!--- if more than one category make join for each --->
							<cfif listLen(stObj.metadata) gt 1>
								<cfloop from="2" to="#listlen(stObj.metadata)#" index="i">
									inner join refCategories refcat#i# on refcat#i-1#.objectid = refcat#i#.objectid
								</cfloop>
							</cfif>
							JOIN dmLink type ON refcat1.objectID = type.objectID
							WHERE 1=1
								<!--- loop over each category and make sure item has all categories --->
								<cfloop from="1" to="#listlen(stObj.metadata)#" index="i">
									AND refCat#i#.categoryID = '#listGetAt(stObj.metadata,i)#'
								</cfloop>
								AND type.status IN ('#ListChangeDelims(request.mode.lValidStatus,"','",",")#')
							ORDER BY type.label ASC
						</cfquery>
					<cfelse>
						<!--- doesn't need to match all categories --->
						<cfquery datasource="#arguments.dsn#" name="qGetLinks" maxrows="#maximumRows#">
							SELECT DISTINCT type.objectID, type.label
							FROM refObjects refObj
							JOIN refCategories refCat ON refObj.objectID = refCat.objectID
							JOIN dmLink type ON refObj.objectID = type.objectID
							WHERE refObj.typename = 'dmLink'
								AND refCat.categoryID IN ('#ListChangeDelims(stObj.metadata,"','",",")#')
								AND type.status IN ('#ListChangeDelims(request.mode.lValidStatus,"','",",")#')
							ORDER BY type.label ASC
						</cfquery>
					</cfif>
				</cfdefaultcase>
			</cfswitch>
		<cfelse>
			<!--- don't filter on categories --->
			<cfquery datasource="#arguments.dsn#" name="qGetLinks" maxrows="#maximumRows#">
				SELECT *
				FROM #application.dbowner#dmLink
				WHERE status IN ('#ListChangeDelims(request.mode.lValidStatus,"','",",")#')
				ORDER BY label
			</cfquery>
		</cfif>
	
		<cfif NOT stObj.bArchive>
			<cfif len(trim(stObj.intro)) AND qGetLinks.recordCount>
				<cfset tmp = arrayAppend(request.aInvocations,stObj.intro)>
			</cfif>
			<!--- loop over display methods --->
			<cfloop query="qGetLinks">
				<cfscript>
				 	stInvoke = structNew();
					stInvoke.objectID = qGetLinks.objectID;
					stInvoke.typename = application.types.dmLink.typePath;
					stInvoke.method = stObj.displayMethod;
					arrayAppend(request.aInvocations,stInvoke);
				</cfscript>
			</cfloop>
			
		<cfelse>
			<cfparam name="url.pgno" default="1">

			<!--- Get Number of Pages --->
			<cfset iNumberOfPages = Ceiling(qGetLinks.recordcount / stobj.numitems)>
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
			<cfset endrow = min(startrow + stobj.numitems - 1, qGetLinks.recordcount)>

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
					<cfif i NEQ url.pgno><a class="newsArchive" href="#Application.URL.conjurer#?objectID=#url.objectID#&pgno=#i#"></cfif>#i#<cfif i NEQ url.pgno></a></cfif>
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
			
			<!--- Loop Through Links and Display --->
			<cfloop query="qGetLinks" startrow="#startrow#" endrow="#endrow#">
				<cfscript>
				 	stInvoke = structNew();
					stInvoke.objectID = qGetLinks.objectID;
					stInvoke.typename = application.types.dmLink.typePath;
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
					<cfif i NEQ url.pgno><a class="newsArchive" href="#Application.URL.conjurer#?objectID=#url.objectID#&pgno=#i#"></cfif>#i#<cfif i NEQ url.pgno></a></cfif>
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