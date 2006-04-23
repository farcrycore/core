<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/rules/ruleRandomFact.cfc,v 1.13.2.1 2004/04/22 23:13:55 brendan Exp $
$Author: brendan $
$Date: 2004/04/22 23:13:55 $
$Name: milestone_2-1-2 $
$Revision: 1.13.2.1 $

|| DESCRIPTION || 
Edit handler and execution handler for displaying Random Facts. Option show x number and reduce to specific categories. Fact 
is then shown using its associated display handler.

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in: 
out:
--->
<cfcomponent displayname="Random Fact Rule" extends="rules" hint="">

<cfproperty name="intro" type="string" hint="Intro text for the news listing" required="no" default="">
<cfproperty name="displayMethod" type="string" hint="Display method to render this news rule with." required="yes" default="displayteaserbullets">
<cfproperty name="numItems" hint="The number of items to display per page" type="numeric" required="true" default="1">
<cfproperty name="metadata" type="string" hint="A list of category ObjectIDs that the news content is to be drawn from" required="false" default="">
<cfproperty name="bMatchAllKeywords" hint="Doest the content need to match ALL selected keywords" type="boolean" required="false" default="0">

	<cffunction access="public" name="update" output="true">
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="label" required="no" type="string" default="">
		<cfimport taglib="/farcry/fourq/tags/" prefix="q4">
		<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">
        <cfimport taglib="/farcry/farcry_core/tags/display/" prefix="display">				

		<cfparam name="form.categoryID" default="">
		<cfparam name="form.bMatchAllKeywords" default="0">
		
        <cfparam name="isClosed" default="Yes">
        <cfif isDefined("form.displayHierarchy") OR isDefined("form.apply")>
            <cfset isClosed = "No">
        </cfif>

		<cfset stObj = this.getData(arguments.objectid)> 
		<cfif isDefined("form.updateRuleNews")>
			<cfscript>
				stObj.displayMethod = form.displayMethod;
				stObj.intro = form.intro;
				stObj.numItems = form.numItems;
				stObj.bMatchAllKeywords = form.bMatchAllKeywords;
				stObj.metadata = form.categoryID; //must add metadata tree
			</cfscript>
			<q4:contentobjectdata typename="#application.rules.ruleRandomFact.rulePath#" stProperties="#stObj#" objectID="#stObj.objectID#">
			<!--- Now assign the metadata --->
					
			<cfset message = "Update Successful">
		</cfif>
		<cfif isDefined("message")>
			<div align="center"><strong>#message#</strong></div>
		</cfif>	
		<!--- get the display methods --->
		<nj:listTemplates typename="dmFacts" prefix="displayTeaser" r_qMethods="qDisplayTypes"> 
		<form action="" method="POST">
		<table width="100%" align="center" border="0">
		<input type="hidden" name="ruleID" value="#stObj.objectID#">
		<tr>
			<td width="20%" colspan="1" align="right">
			<b>Display method: </b>
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
					<b>Intro:</b>
				</td> 
				<td>
					<textarea rows="5" cols="50" name="intro">#stObj.intro#</textarea>
				</td>
		</tr>
		<tr>
			<td align="right"><b>Items to show</b></td>
			<td> <input type="text" name="numItems" value="#stObj.numItems#" size="3"></td>
		</tr>
		</table>

        <br><br>

		<display:OpenLayer width="400" title="Restrict By Categories" titleFont="Verdana" titleSize="7.5" isClosed="#isClosed#" border="no">
		<table align="center" border="0">
        <tr>
            <td><b>Does the content need to match ALL the selected Keywords?</b> <input type="checkbox" name="bMatchAllKeywords" value="1" <cfif stObj.bMatchAllKeywords>checked</cfif>></td>
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
		<div align="center"><input class="normalbttnstyle" type="submit" value="go" name="updateRuleNews"></div>
		</form>
			
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
						<cfquery datasource="#arguments.dsn#" name="qGetFacts">
							SELECT DISTINCT type.objectID, type.label
							    FROM tblTemp1, dmFacts type, refCategories refCat1
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
									inner join refcategories refcat#i# on refcat#i-1#.objectid = refcat#i#.objectid
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
			<cfswitch expression="#application.dbtype#">
				<cfcase value="mysql">
					<cfquery datasource="#arguments.dsn#" name="qGetFacts">
						SELECT *
						FROM #application.dbowner#dmFacts fact, tblTemp1
						WHERE fact.status = tblTemp1.Status
						ORDER BY label
					</cfquery>
				</cfcase>

				<cfdefaultcase>
					<cfquery datasource="#arguments.dsn#" name="qGetFacts">
						SELECT *
						FROM #application.dbowner#dmFacts
						WHERE status IN ('#ListChangeDelims(request.mode.lValidStatus,"','",",")#')
						ORDER BY label
					</cfquery>
				</cfdefaultcase>
			</cfswitch>
		</cfif>
	
		<!--- if the intro text exists - append to aInvocations to be output as HTML --->
		<cfif len(stObj.intro)>
			<cfoutput>#stObj.intro#<p></p></cfoutput>
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
				o = createObject("component", application.types.dmFacts.typePath);
				o.getDisplay(qGetFacts.ObjectID, stObj.displayMethod);	
				</cfscript>
				<cfoutput><p></p></cfoutput>
			</cfif>
		</cfloop>
					
	</cffunction> 
</cfcomponent>