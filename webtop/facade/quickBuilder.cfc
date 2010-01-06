<cfcomponent name="library" displayname="library" hint="Used by the Library for the ajax callbacks" output="false" > 

<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" >
<cfimport taglib="/farcry/core/tags/navajo/" prefix="nj" >

<cffunction name="listTemplates" access="remote" output="true" returntype="void">
 	<cfargument name="typename" required="no" default="" type="string" hint="typename of the webskins to be listed.">

	<cfset var qDisplayTypes = queryNew("blah") />

	<nj:listTemplates typename="#arguments.typename#" prefix="displayPage" r_qMethods="qDisplayTypes">

	<cfif qDisplayTypes.recordCount>
		<cfoutput>
			<select name="displayMethod" id="displayMethod">
				<cfloop query="qDisplayTypes">
				<option value="#qDisplayTypes.methodName#" <cfif qDisplayTypes.methodName eq "displayPageStandard">selected="selected"</cfif>>#qDisplayTypes.displayName#</option>
				</cfloop>
			</select> 		
		</cfoutput>
	<cfelse>
		<cfoutput><div>No Webskins Available</div></cfoutput>
	</cfif>


</cffunction>

</cfcomponent> 

