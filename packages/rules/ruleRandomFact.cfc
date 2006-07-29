<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/rules/ruleRandomFact.cfc,v 1.20.2.2 2006/02/17 05:49:22 daniela Exp $
$Author: daniela $
$Date: 2006/02/17 05:49:22 $
$Name: milestone_3-0-1 $
$Revision: 1.20.2.2 $

|| DESCRIPTION || 
$Description: 
Publishing rule to randomly show a number of fact content items from 
a pool of fact items.  The pool is comprised of those content items 
that match the nominated categories.
$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->

<cfcomponent displayname="Random Fact Rule" extends="rules" 
	hint="Publishing rule to randomly show a number of fact content items from 
		a pool of fact items.  The pool is comprised of those content items that 
		match the nominated categories.">

<cfproperty name="intro" type="string" hint="Intro text for random fact displays.  Can be any combination of content and HTML markup." required="no" default="">
<cfproperty name="displayMethod" type="string" hint="Display method to render fact content items." required="yes" default="displayteaserbullets">
<cfproperty name="numItems" hint="The number of fact items to display." type="numeric" required="true" default="1">
<cfproperty name="metadata" type="string" hint="A list of categories that the fact content pool must match in order to be shown." required="false" default="">
<cfproperty name="bMatchAllKeywords" hint="Does the content need to match ALL selected keywords?" type="boolean" required="false" default="0">

	<cffunction access="public" name="update" output="true">
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="label" required="no" type="string" default="">
		<cfset var stLocal = StructNew()>
		<cfset var stObj = this.getData(arguments.objectid)> 
		
<cfsetting enablecfoutputonly="Yes">		
		<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
        <cfimport taglib="/farcry/farcry_core/tags/display/" prefix="display">				
        <cfimport taglib="/farcry/farcry_core/tags/widgets/" prefix="widgets">

		<cfparam name="form.bMatchAllKeywords" default="0">
		<cfparam name="lSelectedCategoryID" default="">
		<cfparam name="bRestrictByCategory" default="0">
		
		<cfif isDefined("form.updateRuleNews")>
			<cfif bRestrictByCategory EQ 0>
				<cfset lSelectedCategoryID = "">
			</cfif>
			<cfset stObj.displayMethod = form.displayMethod>
			<cfset stObj.intro = form.intro>
			<cfset stObj.numItems = form.numItems>
			<cfset stObj.bMatchAllKeywords = form.bMatchAllKeywords>
			<cfset stObj.metadata = lSelectedCategoryID>
			<q4:contentobjectdata typename="#application.rules.ruleRandomFact.rulePath#" stProperties="#stObj#" objectID="#stObj.objectID#">
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

	<widgets:displayMethodSelector typeName="dmFacts" prefix="displayTeaser">

	<label for="intro"><b>#application.adminBundle[session.dmProfile.locale].introText#</b>
		<textarea id="intro" name="intro">#stObj.intro#</textarea><br />
	</label>

	<label for="numItems"><b>## #application.adminBundle[session.dmProfile.locale].itemsPerPage#</b>
		<input type="text" id="numItems" name="numItems" value="#stObj.numItems#" size="3" maxlength="3"><br />
	</label>

	<label for="bRestrictByCategory"><b>#application.adminBundle[session.dmProfile.locale].restrictByCategories#</b>
		<input type="checkbox" id="bRestrictByCategory" name="bRestrictByCategory" value="1"<cfif bRestrictByCategory EQ 1> checked="checked"</cfif> onclick="fShowHide('tglCategory',this.checked);"><br />
	</label>

	<span id="tglCategory" style="display:<cfif bRestrictByCategory>block<cfelse>none</cfif>;">
	<label for="bMatchAllKeywords"><b>#application.adminBundle[session.dmProfile.locale].contentNeedToMatchKeywords#</b>
		<input type="checkbox" id="bMatchAllKeywords" name="bMatchAllKeywords" value="1" <cfif stObj.bMatchAllKeywords>checked="checked"</cfif>><br />
	</label>
	<widgets:categoryAssociation typeName="dmFacts" lSelectedCategoryID="#stObj.metaData#">
	</span>

<div class="f-submit-wrap">
	<input type="Submit" name="updateRuleNews" value="#application.adminBundle[session.dmProfile.locale].go#" class="f-submit" />		
</div>
	<input type="hidden" name="ruleID" value="#stObj.objectID#">
</fieldset>
</form></cfoutput>
<cfsetting enablecfoutputonly="no">
	</cffunction>
	
	<cffunction name="getDefaultProperties" returntype="struct" access="public">
		<cfscript>
			stProps=structNew();
			stProps.objectid = createUUID();
			stProps.label = '';
			stProps.displayMethod = 'displayteaser';
			stProps.numItems = 1;
			stProps.metadata = '';
		</cfscript>	
		<cfreturn stProps>
	</cffunction>  

	<cffunction access="public" name="execute" output="true">
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="dsn" required="false" type="string" default="#application.dsn#">
		<cfparam name="request.mode.lValidStatus" default="approved">
				
		<cfset stObj = this.getData(arguments.objectid)> 
		<!--- check if filtering by categories --->
		<cfif NOT trim(len(stObj.metadata)) EQ 0>
			<!--- show by categories --->
			<cfswitch expression="#application.dbtype#">
				<cfcase value="mysql">
					<cfif stObj.bMatchAllKeywords>
						<!--- must match all categories --->
						<cfquery datasource="#arguments.dsn#" name="qGetFacts">
							SELECT DISTINCT type.objectID, type.label
							    FROM dmFacts type, refCategories refCat1
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
						<cfquery datasource="#arguments.dsn#" name="qGetFacts">
							SELECT DISTINCT type.objectID, type.label
							FROM tblTemp1, refCategories refCat, dmFacts type
							WHERE refCat.objectID = type.objectID
								AND refCat.categoryID IN ('#ListChangeDelims(stObj.metadata,"','",",")#')
								AND type.status = tblTemp1.Status
							ORDER BY type.label ASC
						</cfquery>
					</cfif>
				</cfcase>

				<cfdefaultcase>
					<cfif stObj.bMatchAllKeywords>
						<!--- must match all categories --->
						<cfquery datasource="#arguments.dsn#" name="qGetFacts">
							SELECT DISTINCT type.objectID, type.label
							FROM refCategories refcat1
							<!--- if more than one category make join for each --->
							<cfif listLen(stObj.metadata) gt 1>
								<cfloop from="2" to="#listlen(stObj.metadata)#" index="i">
									inner join refCategories refcat#i# on refcat#i-1#.objectid = refcat#i#.objectid
								</cfloop>
							</cfif>
							JOIN dmFacts type ON refcat1.objectID = type.objectID
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
						<cfquery datasource="#arguments.dsn#" name="qGetFacts">
							SELECT DISTINCT type.objectID, type.label
							FROM refObjects refObj
							JOIN refCategories refCat ON refObj.objectID = refCat.objectID
							JOIN dmFacts type ON refObj.objectID = type.objectID
							WHERE refObj.typename = 'dmFacts'
								AND refCat.categoryID IN ('#ListChangeDelims(stObj.metadata,"','",",")#')
								AND type.status IN ('#ListChangeDelims(request.mode.lValidStatus,"','",",")#')
							ORDER BY type.label ASC
						</cfquery>
					</cfif>
				</cfdefaultcase>
			</cfswitch>
		<cfelse>
			<!--- don't filter on categories --->
			<cfquery datasource="#arguments.dsn#" name="qGetFacts">
				SELECT *
				FROM #application.dbowner#dmFacts
				WHERE status IN ('#ListChangeDelims(request.mode.lValidStatus,"','",",")#')
				ORDER BY label
			</cfquery>
		</cfif>
	
		<!--- if the intro text exists - append to aInvocations to be output as HTML --->
		<cfif len(stObj.intro) AND qGetFacts.recordCount>
			<cfset tmp = arrayAppend(request.aInvocations,stObj.intro)>
		</cfif>
		
		<!--- get random numbers --->
		<cfset lRandom = "">
		<Cfset counter = 0>
		
		<cfloop condition="#counter# lte #stObj.numItems#">
			<cfset random = randrange(1,qGetFacts.recordcount)>
			<!--- check if first number in list --->
			<cfif listlen(lRandom)>
				<!--- check if number not already in list --->
				<cfif not listfind(lRandom, random)>
					<!--- append number to list --->
					<cfset lRandom = lRandom & "," & random>
					<!--- update counter --->
					<cfset counter = counter + 1>
					<!--- check if all recordcords have been accounted for --->
					<cfif counter eq qGetFacts.recordcount or counter eq stObj.numItems>
						<cfbreak>
					</cfif>
				</cfif>
			<cfelse>
				<!--- add number to list --->
				<cfset lRandom = random>
				<cfset counter = 1>
				<!--- check if all recordcords have been accounted for --->
				<cfif counter eq qGetFacts.recordcount or counter eq stObj.numItems>
					<cfbreak>
				</cfif>
			</cfif>
		</cfloop>
				
		<!--- Loop Through facts and Display --->
		<cfloop query="qGetFacts">
			<!--- check if fact is in random selection, if so display it --->
			<cfif listfind(lRandom,currentrow)>
				<cfscript>
				 	stInvoke = structNew();
					stInvoke.objectID = qGetFacts.objectID;
					stInvoke.typename = application.types.dmFacts.typePath;
					stInvoke.method = stObj.displayMethod;
					arrayAppend(request.aInvocations,stInvoke);
				</cfscript>
			</cfif>
		</cfloop>
					
	</cffunction> 
</cfcomponent>