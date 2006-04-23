<cfcomponent displayname="XML Feed Publishing Rule" extends="rules" hint="Displays an XML feed within a container">

<cfproperty name="feedName" type="string" hint="A useful name for this feed" required="No" default="">
<cfproperty name="XMLFeedURL" type="string" hint="The location of the feed (URL)" required="yes" default="">
<cfproperty name="intro" type="string" hint="An introduction to this feed" required="no" default="">
<cfproperty name="maxRecords" type="numeric" hint="The maximum number of records to return to the user" required="no" default="20">
	
	<cffunction access="public" name="update" output="true">
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="label" required="no" type="string" default="">
		<cfimport taglib="/fourq/tags/" prefix="q4">
		<cfimport taglib="/farcry/tags/navajo/" prefix="nj">

		<cfset stObj = this.getData(arguments.objectid)> 
				
		<cfif isDefined("form.updateRuleXMLFeed")>
			<cfscript>
				stObj.feedName = form.feedName;
				stObj.XMLFeedURL = form.XMLFeedURL; 
				stObj.intro = form.intro;
				stObj.maxRecords = form.maxRecords;
			</cfscript>
			<q4:contentobjectdata typename="#application.packagepath#.rules.ruleXMLFeed" stProperties="#stObj#" objectID="#stObj.objectID#">
			<cfset message = "Update Successful">
		</cfif>
		<cfif isDefined("message")>
			<div align="center"><strong>#message#</strong></div>
		</cfif>			
		<form action="" method="post">
		<table width="100%" >
		<input type="hidden" name="ruleID" value="#stObj.objectID#">
		<tr>
			<td align="right">
				<strong>Feed Name</strong>
			</td>
			<td>
				<input class="field" type="text" name="feedName" value="#stObj.feedName#">
			</td>
		</tr>
		<tr>
			<td align="right" >
				<strong>XML Feed Intro</strong>
			</td>
			<td>
				<textarea  class="field" cols="50" name="intro" rows="5">#stObj.intro#</textarea>
			</td>
		</tr>
		<tr>
			<td align="right" >
				<strong>Max number of records to return</strong>
			</td>		
			<td>
				<select name="maxRecords">
				<cfloop from="1" to="200" index="i">
					<option value="#i#" <cfif i EQ stObj.maxRecords>Selected</cfif>>#i#</option>
				</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td align="right" >
				<strong>XML Feed Location</strong>
			</td>
			<td>
				<input  class="field" type="text" name="xmlFeedURL" size="50" value="#stObj.xmlFeedURL#">
			</td>
		</tr>
		<tr>
			<td colspan="2" align="center"><input class="normalbttnstyle" type="submit" value="go" name="updateRuleXMLFeed"></td>
		</tr>
		</table>
		
		</form>
	</cffunction> 
	

	<cffunction access="public" name="execute" output="true">
		<cfargument name="objectID" required="Yes" type="uuid" default="">
		<cfargument name="dsn" required="false" type="string" default="#application.dsn#">
		<!--- assumes existance of request.navid  --->
		<cfparam name="request.navid">
		<cfparam name="cfhttp.filecontent" default="">
		
		<cfset stObj = this.getData(arguments.objectid)> 
		
		<cftry>
			<cfhttp url="#stObj.xmlFeedURL#" method="get" throwonerror="yes" timeout="10" />
			<cfcatch>
				<!--- Do nothing just at the moment --->
			</cfcatch>
		</cftry>
				
		<cftry>
			<cfset qXMLContent = parseRDF(cfhttp.filecontent)>
			<cfif qXMLContent.recordCount GT 0>
			<cfset html = "<table class='table'><tr><td>#stObj.intro#</td></tr>">
			<cfoutput query="qXMLContent" maxrows="#stObj.maxRecords#">
				<cfscript>
				html = html & '<tr>';
				html = html & '<td><a href="'&qXMLContent.link&'">'&qXMLContent.title&'</a>&nbsp' & dateformat(qXMLContent.datetimecreated,"dd-mmm-yyyy")&'<br>';
				html = html & qXMLContent.excerpt & '</td></tr>';
				</cfscript>
			</cfoutput>
			<cfset html = html & "</table>">
			<cfset tmp = arrayAppend(request.aInvocations,html)>
			</cfif>
			<cfcatch>
				<!--- Do Nada at the moment --->
			</cfcatch>
		</cftry>
		
	</cffunction> 

	<cffunction name="HTMLStripper" hint="Strips HTML from a string">
	<cfargument name="string" type="string" hint="The String to be stripped" required="true">
	<cfscript>
		modsummary = REReplaceNoCase(string, "<[^>]*>", "", "all");
		// need a regex to strip incomplete HTML from end of summary.  this will do for now GB
		modsummary = REreplacenocase(modsummary, "<table .*$", "", "all");
		modsummary = REreplacenocase(modsummary, "<a .*$", "", "all");
		modsummary = REreplacenocase(modsummary, "<td .*$", "", "all");
		modsummary = REreplacenocase(modsummary, "<tr .*$", "", "all");
		modsummary = REreplacenocase(modsummary, "<img .*$", "", "all");
		modsummary = REreplacenocase(modsummary, "<font .*$", "", "all");
		modsummary = REreplacenocase(modsummary, "<p .*$", "", "all");
		modsummary = REreplacenocase(modsummary, "/images.*>", "", "all");
		modsummary = REreplacenocase(modsummary, "<$", "", "all");
		modsummary = replacenocase(modsummary, "&nbsp;", " ", "all");
		modsummary = replacenocase(modsummary, "&##160;", " ", "all"); //nbsp
		modsummary = replacenocase(modsummary, "&amp;", "&", "all");
		modsummary = replacenocase(modsummary, "&##8217;", "'", "all"); // smart apost
		modsummary = replacenocase(modsummary, "&##174;", "(R)", "all"); // rego
		modsummary = replacenocase(modsummary, "&##8482;", "(tm)", "all"); // tm
	
	</cfscript>
	<cfreturn modSummary>
	</cffunction>

	
	<cffunction name="parseRDF">
	<cfargument name="xmlFeedRaw" required="Yes">
	<cfargument name="blogid" required="No" default="wide">
	
	<cfset var xmlFeed = xmlParse(arguments.xmlFeedRaw)>
	<cfset var aItems = ArrayNew(1)>
	<cfset var ItemDate = "">
	<cfset var q = QueryNew("itemid, title, excerpt, link,datetimecreated")>
	
	<!--- convert array result into qFeed query format --->
	<cfscript>
	aItems = xmlFeed['rdf:RDF'].XMLChildren;
	 for (i=1; i LTE ArrayLen(aItems); i=i+1) {
	// loop over item entries to build feed
		 if (aItems[i].XmlName eq "item") {
		QueryAddRow(q);
		QuerySetCell(q, "itemid", "NULL"); // do we need this? set to NULL for now
		for (j=1; j LTE ArrayLen(aItems[i].XmlChildren); j=j+1) {
			switch(aItems[i].XmlChildren[j].XmlName) {
			case "title": {
			  QuerySetCell(q, "title", aItems[i].XmlChildren[j].xmltext);
			  break; }
			case "description": {
			  QuerySetCell(q, "excerpt", 
			  left(HTMLStripper(aItems[i].XmlChildren[j].xmltext), "500"));
			  break; }
			case "link": {
				QuerySetCell(q, "link", aItems[i].XmlChildren[j].xmltext);
				break; }
			case "dc:subject": {
				break; }
			case "dc:creator": {
				break; }
			case "dc:date": {
				itemdate = aItems[i].XmlChildren[j].xmltext;
				itemdate = left(itemdate, 10);
				itemdate = createODBCDate(itemdate);
				QuerySetCell(q, "datetimecreated", itemdate);
				break; }
	  		}
			}
			}
			}
	</cfscript>
	<cfreturn q>
	</cffunction>


</cfcomponent>
