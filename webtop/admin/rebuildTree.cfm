<cfif StructIsEmpty(form)>

	<cfsetting enablecfoutputonly="Yes" requesttimeout="600">
	
	<cfprocessingDirective pageencoding="utf-8">
	
	<!--- set up page header --->
	<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
	<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />

	<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">
	
	<sec:CheckPermission error="true" permission="AdminCOAPITab">
		<cfset dsn = "#application.dsn#" />
		<!--- get types that use nested tree --->
	    <cfquery name="qTypeNames" datasource="#dsn#">
	        select distinct typename from #application.dbowner#nested_tree_objects order by typename
	    </cfquery>
		
	    <cfif qTypeNames.recordCount eq 0>
	        <cfoutput>
	            #apapplication.rb.getResource("noTreeItemsBadBlurb")#
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
	</sec:CheckPermission>
<cfelse>
	 <cfscript>
		nNodes = application.factory.oTree.rebuildTree("#form.typename#");
	</cfscript> 
	<cfoutput>
		<cfif nNodes gt 0>
			Number of nodes processed: #nNodes#
		<cfelse>
			Tree was not found for typename (default dmNavigation)
		</cfif>
	</cfoutput>
</cfif>