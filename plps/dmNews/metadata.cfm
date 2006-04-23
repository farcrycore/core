<cfsetting enablecfoutputonly="no">
<cfimport taglib="/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/tags" prefix="tags">
<cfimport taglib="/farcry/tags/navajo/" prefix="nj">


<cfscript>
	/*this page has a number of different form postings. establishing what action to take
	based on the form submitted*/ 
	if (isDefined("form.apply"))
		action = 'updateMetadata';
	else
		action = 'normal';
	thisstep.isComplete = 0;
	thisstep.name = stplp.currentstep;	
</cfscript>

<cfswitch expression="#action#">
	<cfcase value="updateMetaData">
		<cfif isDefined("FORM.categoryID")>
			<cfinvoke  component="#application.packagepath#.farcry.category" method="assignCategories"
 returnvariable="stStatus">
				<cfinvokeargument name="objectID" value="#output.objectID#"/>
				<cfinvokeargument name="lCategoryIDs" value="#form.categoryID#"/>
				<cfinvokeargument name="dsn" value="#application.dsn#"/>
			</cfinvoke>
			<cfset message = stStatus.message>
		</cfif>
	</cfcase>
	<cfdefaultcase>
		<tags:plpNavigationMove>
	</cfdefaultcase>
</cfswitch>		

<cfif NOT thisstep.isComplete>

<cfoutput><div class="FormSubTitle">#output.label#</div></cfoutput>
<div class="FormTitle">Metadata</div>

<div class="FormTableClear">
	<cfinvoke component="#application.packagepath#.farcry.category" method="displayTree" objectID="#output.objectID#"/>
</div>

<div class="FormTableClear">
<form action="#cgi.script_name#?#cgi.query_string#" method="post" name="editform">
	<tags:PLPNavigationButtons>
</form>
</div>

<cfdump var="#output#">
<cfelse>	
	<tags:plpUpdateOutput>
</cfif>



