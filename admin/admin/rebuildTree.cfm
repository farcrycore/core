<cfif StructIsEmpty(form)>

	<cfsetting enablecfoutputonly="Yes" requesttimeout="600">
	
	<cfprocessingDirective pageencoding="utf-8">
	
	<!--- check permissions --->
	<cfscript>
		iCOAPITab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminCOAPITab");
	</cfscript>
	
	<!--- set up page header --->
	<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
	<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">
	
	<cfif iCOAPITab eq 1>
		<cfset dsn = "#application.dsn#" />
		<!--- get types that use nested tree --->
	    <cfquery name="qTypeNames" datasource="#dsn#">
	        select distinct typename from #application.dbowner#nested_tree_objects order by typename
	    </cfquery>
		
	    <cfif qTypeNames.recordCount eq 0>
	        <cfoutput>
	            #application.adminBundle[session.dmProfile.locale].noTreeItemsBadBlurb#
	        </cfoutput>
	    <cfelse>
			<!--- show form --->
	        <cfset defaultType = 'dmNavigation' />
	        <cfoutput>
	            <div class="formtitle"></div>
	            <p>
	               Use this function if you want to rebuild the tree from scratch using only the parent/child relationship as the basis.
	            </p>
	            <form action="rebuildTree.cfm" method="post" onSubmit="return confirm('Are you sure you want to rebuild the tree?')">
	                Select the typename of the tree to be rebuilt:
	                <select name="typename">
	                    <cfloop query="qTypeNames">
	                        <option value="#qTypeNames.typename#" <cfif qTypeNames.typename eq defaultType>selected</cfif>>#qTypeNames.typename#</option>
	                    </cfloop>
	                </select>
	                <br />
	                <input type="submit" name="submit" value="Rebuild The Tree?">
	            </form>
	
	        </cfoutput>
	 	</cfif>
	</cfif>
<cfelse>
	 <cfscript>
		nNodes = request.factory.oTree.rebuildTree("#form.typename#");
	</cfscript> 
	<cfoutput>
		<cfif nNodes gt 0>
			Number of nodes processed: #nNodes#
		<cfelse>
			Tree was not found for typename (default dmNavigation)
		</cfif>
	</cfoutput>
</cfif>