
<cfcomponent displayname="Rules Object" bAbstract="true" extends="fourq.fourq" hint="Rules is an abstract class that contains">
	<cfproperty name="objectID" type="uuid">
	<cfproperty name="label" type="string" default="">
	
	<cffunction access="public" name="update" output="true">
		<cfargument name="label" required="no" type="string" default="">
		<cfoutput><p>#arguments[1]# : No Parameters required</cfoutput>
	</cffunction> 
	
	<cffunction access="public" name="execute" output="true">
		<cfargument name="label" required="no" type="string" default="">
		<cfoutput><p>#arguments[1]# : No execute method specified</cfoutput>
	</cffunction>  
	
	<cffunction access="public" name="getRules" returntype="query" hint="returns a single column query (column name 'rulename') of available rules. Assumes that rule names are rule*.cfc">
		<cfdirectory directory="#GetDirectoryFromPath(GetCurrentTemplatePath())#" name="qDir" filter="rule*.cfc" sort="name">
		<cfset qRules = queryNew("rulename")>
		<cfset thisRow = 1>
		<cfloop query="qDir">
			<cfif NOT name IS "rules.cfc"> <!--- Rules.cfc is the abstract class --->
				<cfset newRow  = queryAddRow(qRules, 1)>
				<Cfset rulename = left(qDir.name, len(qDir.name)-4)>
				<cfset newCell = querySetCell(qRules,"rulename","#rulename#",thisRow)>
				<cfset thisRow = thisRow + 1>
			</cfif>
		</cfloop>
		<cfoutput>
		</cfoutput>
		<cfreturn qRules>	
	</cffunction>
	
</cfcomponent>