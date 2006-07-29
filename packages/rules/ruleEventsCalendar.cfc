<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2006, http://www.daemon.com.au $
$Community: FarCry CMS http://www.farcrycms.org $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: $
$Author: $
$Date: $
$Name:  $
$Revision: $

|| DESCRIPTION || 
$Description: 
ruleEventsCalendar (FarCry Core)
Publishing rule for showing Event content items in a month calendar view format.
$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$

--->
<cfcomponent displayname="Event Calendar Rule" extends="rules" 
	hint="Publishing rule for showing Event content items in a month calendar view format.">

<cfproperty name="intro" type="string" hint="Intro text for the event listing" required="no" default="">
<cfproperty name="months" type="numeric" hint="Number of months to show" required="yes" default="1">
<cfproperty name="displayMethod" type="string" hint="Display method to render this event rule with." required="yes" default="displayteaserCalendar">
<cfproperty name="bMatchAllKeywords" hint="Doest the content need to match ALL selected keywords" type="boolean" required="false" default="0">
<cfproperty name="metadata" type="string" hint="A list of category ObjectIDs that the news content is to be drawn from" required="false" default="">

	<cffunction access="public" name="update" output="true">
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="label" required="no" type="string" default="">

		<cfset var stLocal = StructNew()> 
		<cfset var stObj = this.getData(arguments.objectid)> 
<cfsetting enablecfoutputonly="true">
		<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
        <cfimport taglib="/farcry/farcry_core/tags/display/" prefix="display">				
		<cfimport taglib="/farcry/farcry_core/tags/widgets/" prefix="widgets">
		
		<cfparam name="form.bMatchAllKeywords" default="0">
		<cfparam name="bRestrictByCategory" default="0">
		<cfparam name="lSelectedCategoryID" default="">

		<cfif isDefined("form.updateRuleNews")>
			<cfif bRestrictByCategory EQ 0>
				<cfset lSelectedCategoryID = "">
			</cfif>
			<cfset stObj.displayMethod = form.displayMethod>
			<cfset stObj.intro = form.intro>
			<cfset stObj.Months = form.months>
			<cfset stObj.bMatchAllKeywords = form.bMatchAllKeywords>
			<cfset stObj.metadata = lSelectedCategoryID> <!--- must add metadata tree --->
			<q4:contentobjectdata typename="#application.rules.ruleEventsCalendar.rulePath#" stProperties="#stObj#" objectID="#stObj.objectID#">
			<!--- Now assign the metadata --->
			<cfset stLocal.successMessage = "#application.adminBundle[session.dmProfile.locale].updateSuccessful#">
		<cfelse>
			<cfset lSelectedCategoryID = stObj.metadata>
			<cfif stObj.metadata NEQ "">
				<cfset bRestrictByCategory = 1>
			</cfif>
		</cfif>
<cfoutput>
<form name="editform" action="#cgi.script_name#?#cgi.query_string#" method="post" class="f-wrap-2" style="margin-top:-1.5em">
<fieldset><cfif StructKeyExists(stLocal,"successmessage")>
	<p id="fading1" class="fade"><span class="success">#stLocal.successmessage#</span></p></cfif>

	<widgets:displayMethodSelector typeName="dmEvent" prefix="displayTeaser">
	
	<label for="intro"><b>#application.adminBundle[session.dmProfile.locale].introlabel#</b>
		<textarea id="intro" name="intro">#stObj.intro#</textarea><br />
	</label>

	<label for="months"><b>#application.adminBundle[session.dmProfile.locale].monthsToDisplayLabel#</b>
		<input type="text" id="months" name="months" value="#stObj.months#" size="3" maxlength="3"><br />
	</label>
	
	<label for="bRestrictByCategory"><b>#application.adminBundle[session.dmProfile.locale].restrictByCategories#</b>
		<input type="checkbox" id="bRestrictByCategory" name="bRestrictByCategory" value="1"<cfif bRestrictByCategory EQ 1> checked="checked"</cfif> onclick="fShowHide('tglCategory',this.checked);"><br />
	</label>
	<span id="tglCategory" style="display:<cfif bRestrictByCategory>block<cfelse>none</cfif>;">
	<label for="bMatchAllKeywords"><b>#application.adminBundle[session.dmProfile.locale].contentNeedToMatchKeywords#</b>
		<input type="checkbox" id="bMatchAllKeywords" name="bMatchAllKeywords" value="1" <cfif stObj.bMatchAllKeywords>checked="checked"</cfif>><br />
	</label>
	<widgets:categoryAssociation typeName="dmEvents" lSelectedCategoryID="#stObj.metaData#">
	</span>
</fieldset>

<div class="f-submit-wrap">
	<input type="Submit" name="updateRuleNews" value="#application.adminBundle[session.dmProfile.locale].go#" class="f-submit" />		
</div>
	<input type="hidden" name="ruleID" value="#stObj.objectID#">
</form></cfoutput>			
<cfsetting enablecfoutputonly="true">
	</cffunction> 
	
	<cffunction name="getDefaultProperties" returntype="struct" access="public">
		<cfscript>
			stProps=structNew();
			stProps.objectid = createUUID();
			stProps.label = '';
			stProps.displayMethod = 'displayteaserCalendar';
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
		
		<!--- check if filtering by categories --->
		<cfif NOT trim(len(stObj.metadata)) EQ 0>
			<!--- show by categories --->
			<cfswitch expression="#application.dbtype#">
				<cfcase value="mysql">
					<cfif stObj.bMatchAllKeywords>
						<!--- must match all categories --->
						<cfquery datasource="#arguments.dsn#" name="qGetEvents">
							SELECT DISTINCT type.objectID, type.publishDate, type.label, type.title, type.location, type.startDate, type.endDate
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
						<cfquery datasource="#arguments.dsn#" name="qGetEvents">
							SELECT DISTINCT type.objectID, type.publishDate, type.label, type.title, type.location, type.startDate, type.endDate
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
						<cfquery datasource="#arguments.dsn#" name="qGetEvents">
							SELECT DISTINCT type.objectID, type.publishDate, type.label, type.title, type.location, type.startDate, type.endDate
							FROM refCategories refcat1
							<!--- if more than one category make join for each --->
							<cfif listLen(stObj.metadata) gt 1>
								<cfloop from="2" to="#listlen(stObj.metadata)#" index="i">
									inner join refCategories refcat#i# on refcat#i-1#.objectid = refcat#i#.objectid
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
						<cfquery datasource="#arguments.dsn#" name="qGetEvents">
							SELECT DISTINCT type.objectID, type.publishDate, type.label, type.title, type.location, type.startDate, type.endDate
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
					<cfquery datasource="#arguments.dsn#" name="qGetEvents">
						SELECT *
						FROM #application.dbowner#dmEvent events, tblTemp1
						WHERE events.status = tblTemp1.Status
							AND publishdate <= #now()#
							AND expirydate >= #now()#
						ORDER BY startDate ASC
					</cfquery>
				</cfcase>

				<cfdefaultcase>
					<cfquery datasource="#arguments.dsn#" name="qGetEvents">
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
	
		<cfif len(trim(stObj.intro)) AND qGetEvents.recordCount>
			<cfset tmp = arrayAppend(request.aInvocations,stObj.intro)>
		</cfif>
		<cfif qGetEvents.recordcount>
		<cfset stInvoke = structNew()>
				
		<cfloop query="qGetEvents">
			<cfset tmpObjectId = qGetEvents.objectId>
			<cfset tmpTitle = qGetEvents.title>
			<cfset tmpLocation = qGetEvents.location>
			<cfset tmpStartDate = qGetEvents.startDate>
			<cfset tmpEndDate = qGetEvents.endDate>
			
			<!--- if expiry date loop through each day of event --->
			<cfif year(qGetEvents.endDate) neq 2050>
				<cfloop from="0" to="#dateDiff('d',qGetEvents.startDate,qGetEvents.endDate)#" index="day">
					<cfset tmp = createUUID()>
					<cfset stInvoke.stEvents[tmp] = structNew()>
					<cfset stInvoke.stEvents[tmp].eventDate =  dateadd("d",day,tmpStartDate)>
					<cfset stInvoke.stEvents[tmp].objectid = tmpObjectId>
					<cfset stInvoke.stEvents[tmp].title = tmpTitle>
					<cfset stInvoke.stEvents[tmp].location = tmpLocation>
					<cfset stInvoke.stEvents[tmp].startDate = tmpStartDate>
					<cfset stInvoke.stEvents[tmp].endDate = tmpEndDate>
				</cfloop>
			<cfelse>
				<!--- no expiry so just use start date --->
				<cfset tmp = createUUID()>
				<cfset stInvoke.stEvents[tmp] = structNew()>
				<cfset stInvoke.stEvents[tmp].eventDate =  tmpStartDate>
				<cfset stInvoke.stEvents[tmp].objectid = tmpObjectId>
				<cfset stInvoke.stEvents[tmp].title = tmpTitle>
				<cfset stInvoke.stEvents[tmp].location = tmpLocation>
				<cfset stInvoke.stEvents[tmp].startDate = tmpStartDate>
				<cfset stInvoke.stEvents[tmp].endDate = tmpEndDate>
			</cfif>
		</cfloop>
		<cfscript>
			stInvoke.objectID = qGetEvents.objectID;
			stInvoke.typename = application.types.dmEvent.typePath;
			stInvoke.method = stObj.displayMethod;
			stInvoke.months = stObj.months;
			arrayAppend(request.aInvocations,stInvoke);
		</cfscript>
		</cfif>					
	</cffunction> 

</cfcomponent>