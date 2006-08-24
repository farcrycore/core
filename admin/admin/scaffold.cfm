<cfsetting enablecfoutputonly="yes">


<!--- check permissions --->
<cfif NOT request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminCOAPITab")>	
	<admin:permissionError>
	<cfabort>
</cfif>

<cfimport taglib="/farcry/farcry_core/tags/formtools/" prefix="ft" >



<ft:processForm Action="Create Now">

<!---<cfdirectory action="list" directory="#application.path.core#/admin/admin/scaffolds" filter="*.txt" name="qScaffolds" />

<cfloop query="qScaffolds">
	
	<cffile action="read" file="#application.path.core#/admin/admin/scaffolds/customadmin.txt" variable="customAdmin">
	<cfset customAdmin = replaceNoCase(customAdmin, "[PROJECTNAME]", "#application.applicationname#", "all") />
	<cfset customAdmin = replaceNoCase(customAdmin, "[TYPENAME]", "#url.typename#", "all") />
	
	<cfif not directoryExists("#application.path.project#/customadmin")>
		<cfdirectory action="create" directory="#application.path.project#/customadmin">
	</cfif>
	<cfif fileExists("#application.path.project#/customadmin/#url.typename#.xml")>
		<cfoutput><p>#url.typename#.xml already exists in #application.path.project#/customadmin</p></cfoutput>
	<cfelse>
		<cffile action="write" file="#application.path.project#/customadmin/#url.typename#.xml" output="#customadmin#" >
		<cfoutput><p>CREATED: #application.path.project#/customadmin/#url.typename#.xml</p></cfoutput>
	</cfif>
</cfloop> --->
	
	
	
	<cfif structKeyExists(form, "scaffold")>
		<cfif listContainsNoCase(form.scaffold, "CustomAdmin")>
					
			<cffile action="read" file="#application.path.core#/admin/admin/scaffolds/customadmin.txt" variable="customAdmin">
			<cfset customAdmin = replaceNoCase(customAdmin, "[PROJECTNAME]", "#application.applicationname#", "all") />
			<cfset customAdmin = replaceNoCase(customAdmin, "[TYPENAME]", "#url.typename#", "all") />
			
			<cfif not directoryExists("#application.path.project#/customadmin")>
				<cfdirectory action="create" directory="#application.path.project#/customadmin">
			</cfif>
			<cfif fileExists("#application.path.project#/customadmin/#url.typename#.xml")>
				<cfoutput><p>#url.typename#.xml already exists in #application.path.project#/customadmin</p></cfoutput>
			<cfelse>
				<cffile action="write" file="#application.path.project#/customadmin/#url.typename#.xml" output="#customadmin#" >
				<cfoutput><p>CREATED: #application.path.project#/customadmin/#url.typename#.xml</p></cfoutput>
			</cfif>
			
			
			
			<cffile action="read" file="#application.path.core#/admin/admin/scaffolds/typeadmin.txt" variable="typeadmin">
			<cfset typeadmin = replaceNoCase(typeadmin, "[PROJECTNAME]", "#application.applicationname#", "all") />
			<cfset typeadmin = replaceNoCase(typeadmin, "[TYPENAME]", "#url.typename#", "all") />
			
			<cfif not directoryExists("#application.path.project#/customadmin/customLists")>
				<cfdirectory action="create" directory="#application.path.project#/customadmin/customLists">
			</cfif>
			<cfif fileExists("#application.path.project#/customadmin/customLists/#url.typename#.cfm")>
				<cfoutput><p>#url.typename#.cfm already exists in #application.path.project#/customadmin/customLists</p></cfoutput>
			<cfelse>
				<cffile action="write" file="#application.path.project#/customadmin/customLists/#url.typename#.cfm" output="#typeadmin#" >
				<cfoutput><p>CREATED: #application.path.project#/customadmin/customLists/#url.typename#.cfm</p></cfoutput>
			</cfif>
		</cfif>
		
		<cfif listContainsNoCase(form.scaffold, "Webskin")>
			
			<cfif not directoryExists("#application.path.project#/webskin/#url.typename#")>
				<cfdirectory action="create" directory="#application.path.project#/webskin/#url.typename#">
			</cfif>
			
			<cffile action="read" file="#application.path.core#/admin/admin/scaffolds/displayPageStandard.txt" variable="displayPageStandard">			
			<cfset displayPageStandard = replaceNoCase(displayPageStandard, "[PROJECTNAME]", "#application.applicationname#", "all") />
			<cfset displayPageStandard = replaceNoCase(displayPageStandard, "[TYPENAME]", "#url.typename#", "all") />


			<cfif fileExists("#application.path.project#/webskin/#url.typename#/displayPageStandard.cfm")>
				<cfoutput><p>displayPageStandard already exists in #application.path.project#/webskin/#url.typename#</p></cfoutput>
			<cfelse>
				<cffile action="write" file="#application.path.project#/webskin/#url.typename#/displayPageStandard.cfm" output="#displayPageStandard#" >
				<cfoutput><p>CREATED: #application.path.project#/webskin/#url.typename#/displayPageStandard.cfm</p></cfoutput>
			</cfif>
			
			
			<cffile action="read" file="#application.path.core#/admin/admin/scaffolds/displayTeaserStandard.txt" variable="displayTeaserStandard">
			<cfset displayTeaserStandard = replaceNoCase(displayTeaserStandard, "[PROJECTNAME]", "#application.applicationname#", "all") />
			<cfset displayTeaserStandard = replaceNoCase(displayTeaserStandard, "[TYPENAME]", "#url.typename#", "all") />
			
			<cfif fileExists("#application.path.project#/webskin/#url.typename#/displayTeaserStandard.cfm")>
				<cfoutput><p>displayTeaserStandard already exists in #application.path.project#/webskin/#url.typename#</p></cfoutput>
			<cfelse>
				<cffile action="write" file="#application.path.project#/webskin/#url.typename#/displayTeaserStandard.cfm" output="#displayTeaserStandard#" >
				<cfoutput><p>CREATED: #application.path.project#/webskin/#url.typename#/displayTeaserStandard.cfm</p></cfoutput>
			</cfif>
			
		</cfif>
		
		<cfif listContainsNoCase(form.scaffold, "Rule")>
			
			<cffile action="read" file="#application.path.core#/admin/admin/scaffolds/rule.txt" variable="rule">			
			<cfset rule = replaceNoCase(rule, "[PROJECTNAME]", "#application.applicationname#", "all") />
			<cfset rule = replaceNoCase(rule, "[TYPENAME]", "#url.typename#", "all") />
			
			<cfif not directoryExists("#application.path.project#/packages/rules")>
				<cfdirectory action="create" directory="#application.path.project#/packages/rules">
			</cfif>
				
			<cfif fileExists("#application.path.project#/packages/rules/rule#url.typename#.cfc")>
				<cfoutput><p>rule#url.typename#.cfc already exists in #application.path.project#/packages/rules</p></cfoutput>
			<cfelse>
				<cffile action="write" file="#application.path.project#/packages/rules/rule#url.typename#.cfc" output="#rule#" >
				<cfoutput><p>CREATED: #application.path.project#/packages/rules/rule#url.typename#.cfc</p></cfoutput>
			</cfif>		
			
		</cfif>
	</cfif>
</ft:processForm>


<ft:form>

	<cfoutput>
	<p>WHICH SCAFFOLDS WOULD YOU LIKE TO CREATE</p>
	
	<input type="checkbox" name="scaffold" value="CustomAdmin" /> Custom Admin<br />
	<input type="checkbox" name="scaffold" value="Webskin" /> Webskins<br />
	<input type="checkbox" name="scaffold" value="Rule" /> Rule<br />

	
	<div class="formsection">
		<ft:farcrybutton value="Create Now" />	
		<ft:farcrybutton value="Cancel" />
	</div>
	</cfoutput>
</ft:form>


<cfsetting enablecfoutputonly="no">