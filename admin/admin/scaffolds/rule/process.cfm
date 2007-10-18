<cfif structkeyexists(form,"generateRuleLatest") and form.generateRuleLatest>
	
	<!--- Generate webskin --->
	<cfset values = structnew() />
	<cfset values.projectname = application.ApplicationName />
	<cfset values.typename = url.typename />
	<cfset values.displayname = application.stCOAPI[url.typename].displayname />
	
	<cfif not directoryexists("#application.path.project#/webskin/ruleLatest#url.typename#")>
		<cfdirectory action="create" directory="#application.path.project#/webskin/ruleLatest#url.typename#" />
	</cfif>
	
	<cffile action="read" file="#application.path.core#/admin/admin/scaffolds/rule/latest_rule.txt" variable="content" />
	<cfset content = substitute(content,values) />
	<cffile action="write" file="#application.path.project#/packages/rules/ruleLatest#url.typename#.cfc" output="#content#" />
	
	<cffile action="read" file="#application.path.core#/admin/admin/scaffolds/rule/latest_execute.txt" variable="content" />
	<cfset content = substitute(content,values) />
	<cffile action="write" file="#application.path.project#/webskin/ruleLatest#url.typename#/execute.cfm" output="#content#" />
	
	<cfoutput>
		<p class="success">"List latest" rule created</p>
	</cfoutput>

</cfif>

<cfif structkeyexists(form,"generateRuleSelected") and form.generateRuleSelected>
	
	<!--- Generate webskin --->
	<cfset values = structnew() />
	<cfset values.projectname = application.ApplicationName />
	<cfset values.typename = url.typename />
	<cfset values.displayname = application.stCOAPI[url.typename].displayname />
	
	<cfif not directoryexists("#application.path.project#/webskin/ruleSelected#url.typename#")>
		<cfdirectory action="create" directory="#application.path.project#/webskin/ruleSelected#url.typename#" />
	</cfif>
	
	<cffile action="read" file="#application.path.core#/admin/admin/scaffolds/rule/selected_rule.txt" variable="content" />
	<cfset content = substitute(content,values) />
	<cffile action="write" file="#application.path.project#/packages/rules/ruleSelected#url.typename#.cfc" output="#content#" />
	
	<cffile action="read" file="#application.path.core#/admin/admin/scaffolds/rule/selected_execute.txt" variable="content" />
	<cfset content = substitute(content,values) />
	<cffile action="write" file="#application.path.project#/webskin/ruleSelected#url.typename#/execute.cfm" output="#content#" />
	
	<cfoutput>
		<p class="success">"List selected" rule created</p>
	</cfoutput>

</cfif>