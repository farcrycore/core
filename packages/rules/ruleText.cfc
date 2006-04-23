<!--- Author: Gavin Stewart
         Date: 28/06/2005 
	  Purpose:
--->
<cfcomponent displayname="Text Rule" extends="rules" hint="Rule for listing Case Studies">

<!--- rule object properties --->
<cfproperty name="title" type="string" hint="Title for text dispay" required="no" default="">
<cfproperty name="text" type="longchar" hint="text to be displayed" required="yes" default="">

<!--- pseudo import tag library --->
<cfimport prefix="q4" taglib="/farcry/fourq/tags">

<cffunction name="update" output="true">
	<cfargument name="objectID" required="Yes" type="uuid" default="">
	<cfargument name="label" required="no" type="string" default="">
	
	<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">
	<cfimport taglib="/farcry/farcry_core/tags/widgets" prefix="widgets">

	<cfparam name="form.title" default="">
	<cfparam name="form.text" default="">
	
	
	<cfset stObj = this.getData(arguments.objectid)>
	<!--- save submitted data --->
	<cfif isDefined("form.submit")>
	
		<cfscript>
			stObj.title = form.title;
			stObj.text = form.text;
		</cfscript>
		<q4:contentobjectdata typename="#application.rules.ruleText.rulePath#" stProperties="#stObj#" objectID="#stObj.objectID#">
		<!--- Now assign the metadata --->
		<cfset message = "#application.adminBundle[session.dmProfile.locale].updateSuccessful#">
	</cfif>
	<cfif isDefined("message")>
		<div align="center"><strong>#message#</strong></div>
	</cfif>
				
	<!--- form --->
	<form action="" method="POST">
	<table width="100%" align="center" border="0">
		<input type="hidden" name="ruleID" value="#stObj.objectID#">
		<tr>
			<td align="right"><b>Title</b></td>
			<td> <input type="text" name="title" value="#stObj.title#"></td>
		</tr>
    	</table>
    	<textarea name="text" cols="50" rows="15">#stObj.text#</textarea>
		<div align="center"><input class="normalbttnstyle" type="submit" value="#application.adminBundle[session.dmProfile.locale].go#" name="submit"></div>
	</form>
</cffunction>
	
<cffunction name="execute" hint="displays the text Rule on the page" output="false" returntype="void">
	<cfargument name="objectID" required="Yes" type="uuid" default="">
	<cfargument name="dsn" required="false" type="string" default="#application.dsn#">
		<cfset var stObj = getData(arguments.objectid)> 
		<cfset var blurb = "">
		
		<cfif trim(len(stObj.title))>
			<cfset blurb = "<h2>#stObj.title#</h2>">
		</cfif>
		<cfset blurb = "#blurb##stObj.text#">
		
		<cfif len(trim(blurb))>
			<cfset tmp = arrayAppend(request.aInvocations,blurb)>
		</cfif>
	</cffunction>
</cfcomponent>

