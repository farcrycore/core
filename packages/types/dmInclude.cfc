
<cfcomponent extends="types" displayname="dmInclude handler " hint="Include files">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->
<cfproperty name="title" type="string" hint="Meaningful reference title for include file" required="no" default=""> 
<cfproperty name="teaser" type="string" hint="A brief description of the nature of the include file" required="no" default="">  
<cfproperty name="displayMethod" type="string" hint="" required="No" default=""> 
<cfproperty name="include" type="string" hint="The name of the include file" required="No" default=""> 
<cfproperty name="status" type="string" hint="Status of file - draft or approved" required="No" default=""> 
<cfproperty name="commentlog" type="string" hint="Workflow comment log." required="no" default="">

<!--- Object Methods --->

<cffunction name="edit" access="public">
	<cfargument name="objectid" required="yes" type="UUID">
	
	<!--- getData for object edit --->
	<cfset stObj = this.getData(arguments.objectid)>
	<cfset stArgs = arguments> <!--- hack to make arguments available to included file --->
	<cfinclude template="_dmInclude/edit.cfm">
</cffunction>

<cffunction access="public" name="getIncludes" returntype="query" hint="returns a single column query (column name 'include') of available includes.">
	<!--- TODO : can't hardcode path --->
	<cfset includePath = application.path.project & "/templates/dmInclude">
	<cfif NOT directoryExists(includePath)>
		<cfdirectory action="create" directory="#includePath#"> 
	</cfif>
	<cfdirectory directory="#includePath#" name="qDir" filter="*.cfm" sort="name">
	<cfset qIncludes = queryNew("include,includeAlias")>
	<cfset thisRow = 1>
	<cfloop query="qDir">
		<cfset newRow  = queryAddRow(qIncludes, 1)>
		<Cfset includeAlias = left(qDir.name, len(qDir.name)-4)>
		<cfset newCell = querySetCell(qIncludes,"include","#qDir.name#",thisRow)>
		<cfset newCell = querySetCell(qIncludes,"includeAlias","#includeAlias#",thisRow)>
		<cfset thisRow = thisRow + 1>
	</cfloop>
	
	<cfreturn qIncludes>	
</cffunction>

	
</cfcomponent>