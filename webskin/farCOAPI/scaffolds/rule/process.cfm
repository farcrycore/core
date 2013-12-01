<cfif structkeyexists(form,"generateRuleLatest") and form.generateRuleLatest>
	
	<!--- Generate webskin --->
	<cfset values = structnew() />
	<cfset values.projectname = application.ApplicationName />
	<cfset values.typename = url.scaffoldtypename />
	<cfset values.displayname = application.stCOAPI[url.scaffoldtypename].displayname />
	
	<cfif not directoryexists("#application.path.project#/webskin/ruleLatest#url.scaffoldtypename#")>
		<cfdirectory action="create" directory="#application.path.project#/webskin/ruleLatest#url.scaffoldtypename#" />
	</cfif>
	
	<cffile action="read" file="#application.path.core#/webskin/farCOAPI/scaffolds/rule/latest_rule.txt" variable="content" />
	<cfset content = substitute(content,values) />
	<cffile action="write" file="#application.path.project#/packages/rules/ruleLatest#url.scaffoldtypename#.cfc" output="#content#" mode="664" />
	
	<cffile action="read" file="#application.path.core#/webskin/farCOAPI/scaffolds/rule/latest_execute.txt" variable="content" />
	<cfset content = substitute(content,values) />
	<cffile action="write" file="#application.path.project#/webskin/ruleLatest#url.scaffoldtypename#/execute.cfm" output="#content#" mode="664" />
	
	<cfoutput>
		<p class="success">"List latest" rule created</p>
	</cfoutput>

</cfif>

<cfif structkeyexists(form,"generateRuleSelected") and form.generateRuleSelected>
	
	<!--- Generate webskin --->
	<cfset values = structnew() />
	<cfset values.projectname = application.ApplicationName />
	<cfset values.typename = url.scaffoldtypename />
	<cfset values.displayname = application.stCOAPI[url.scaffoldtypename].displayname />
	
	<cfif not directoryexists("#application.path.project#/webskin/ruleSelected#url.scaffoldtypename#")>
		<cfdirectory action="create" directory="#application.path.project#/webskin/ruleSelected#url.scaffoldtypename#" />
	</cfif>
	
	<cffile action="read" file="#application.path.core#/webskin/farCOAPI/scaffolds/rule/selected_rule.txt" variable="content" />
	<cfset content = substitute(content,values) />
	<cffile action="write" file="#application.path.project#/packages/rules/ruleSelected#url.scaffoldtypename#.cfc" output="#content#" mode="664" />
	
	<cffile action="read" file="#application.path.core#/webskin/farCOAPI/scaffolds/rule/selected_execute.txt" variable="content" />
	<cfset content = substitute(content,values) />
	<cffile action="write" file="#application.path.project#/webskin/ruleSelected#url.scaffoldtypename#/execute.cfm" output="#content#" mode="664" />
	
	<cfoutput>
		<p class="success">"List selected" rule created</p>
	</cfoutput>

</cfif>