
<cfcomponent displayname="News Rule" extends="rules" hint="">

<cfproperty name="intro" type="string" hint="Intro text for the news listing" required="yes" default="">
<cfproperty name="displayMethod" type="string" hint="Display method to render this news rule with." required="yes" default="displayteaserbullets">
<cfproperty name="numItems" hint="The number of items to display per page" type="numeric" required="true" default="5">
<cfproperty name="numPages" hint="The number of pages of news articles to display at most" type="numeric" required="true" default="1">
<cfproperty name="bArchive" hint="Display News as an archive" type="boolean" required="true" default="0">
<cfproperty name="bMatchAllKeywords" hint="Doest the content need to match ALL selected keywords" type="boolean" required="false" default="0">
<cfproperty name="metadata" type="string" hint="A list of category ObjectIDs that the news content is to be drawn from" required="false" default="">

	
	<cffunction access="public" name="update" output="true">
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="label" required="no" type="string" default="">
		<cfimport taglib="/fourq/tags/" prefix="q4">
		<cfimport taglib="/farcry/tags/navajo/" prefix="nj">
				
		<cfparam name="form.bArchive" default="0">
		<cfparam name="form.bMatchAllKeywords" default="0">
		<cfparam name="form.categoryID" default="">
		
		<cfset stObj = this.getData(arguments.objectid)> 
		<cfif isDefined("form.updateRuleNews")>
			<cfscript>
				stObj.displayMethod = form.displayMethod;
				stObj.intro = form.intro;
				stObj.numItems = form.numItems;
				stObj.bArchive = form.bArchive;
				stObj.bMatchAllKeywords = form.bMatchAllKeywords;
				stObj.metadata = form.categoryID; //must add metadata tree
			</cfscript>
			<q4:contentobjectdata typename="#application.packagepath#.rules.rulenews" stProperties="#stObj#" objectID="#stObj.objectID#">
			<!--- Now assign the metadata --->
					
			<cfset message = "Update Successful">
		</cfif>
		<cfif isDefined("message")>
			<div align="center"><strong>#message#</strong></div>
		</cfif>	
		<!--- get the display methods --->
		<nj:listTemplates typename="dmNews" prefix="displayTeaser" r_qMethods="qDisplayTypes"> 
		<form action="" method="post">
		<table width="100%" align="center" >
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
			<td align="right"><b>Items per page</b></td>
			<td> <input type="text" name="numItems" value="#stObj.numItems#" size="3"></td>
		</tr>
		<!--- <tr>
			<td><b>Display as an Archive?</b></td>
			<td><input type="checkbox" name="bArchive" value="1"></td>
		</tr>
		<tr>
			<td><b>How many pages would you like in the archive at most?</b></td>
			<td> <input type="text" name="numPages" value="" size="3"></td>
		</tr>	
		<tr>
			<td><b>Does the content need to match ALL the selected Keywords?</b></td>
			<td> <input type="checkbox" name="bMatchAllKeywords"></td>
		</tr> --->	
		<tr>
			<td colspan="2" align="center">
				<p><b>Select Meta Data to draw news from</b></p>
				<cfinvoke  component="#application.packagepath#.farcry.category" method=			"displayTree">
					<cfinvokeargument name="bIsForm" value="False"> 
					<cfinvokeargument name="lGetCategories" value="#stObj.metaData#">	
				</cfinvoke>

			</td>
		</tr>
		<tr>
			<td colspan="2" align="center">
				<input class="normalbttnstyle" type="submit" value="go" name="updateRuleNews">
			</td>
		</tr>
		</table>
		
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
		<cfset lStatus = "#ListChangeDelims(request.mode.lValidStatus,"','",",")#">
		
		<cfset stObj = this.getData(arguments.objectid)> 
		
		<cfif NOT trim(len(stObj.metadata)) EQ 0>
			<cfscript>
				sql = "select type.*
				from refObjects refObj 
				join refCategories refCat ON refObj.objectID = refCat.objectID
				join dmNews type ON refObj.objectID = type.objectID  
				where refObj.typename = 'dmNews' AND refCat.categoryID IN 		('#ListChangeDelims(stObj.metadata,"','",",")#') AND type.status IN ('#lStatus#') ORDER by type.publishDate DESC ";
			</cfscript>	
		<cfelse>
			<cfscript>
				sql = 'SELECT TOP ' & stObj.numItems & ' * FROM dmNews WHERE status IN (''#lStatus#'') order by publishDate DESC';
			</cfscript>
		</cfif> 
	
		
		<cfquery datasource="#arguments.dsn#" name="qGetNews">
			#preserveSingleQuotes(sql)#
		</cfquery> 
		
		<cfif NOT stObj.bArchive>
			<cfif len(trim(stObj.intro)) AND qGetNews.recordCount>
				<cfset tmp = arrayAppend(request.aInvocations,stObj.intro)>
			</cfif>
			<cfoutput query="qGetNews">
				<cfscript>
				 	stInvoke = structNew();
					stInvoke.objectID = qGetNews.objectID;
					stInvoke.typename = "dmNews";
					stInvoke.method = stObj.displayMethod;
					arrayAppend(request.aInvocations,stInvoke);
				</cfscript>
			</cfoutput>
		</cfif>
		
	</cffunction> 

</cfcomponent>