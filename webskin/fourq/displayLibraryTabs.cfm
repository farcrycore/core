

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />


<cfif application.fapi.isLoggedIn()>
		
	<skin:loadJS id="jquery" />
	<skin:loadJS id="jquery-ui" />
	<skin:loadCSS id="jquery-ui" />	
	
	<cfset stMetadata = application.fapi.getPropertyMetadata(typename="#stobj.typename#", property="#url.property#") />
		
	
	

	<admin:header title="Library Selector">		
	
	<ft:form>				
	<cfoutput>
	<!-- summary pod with green arrow -->
	<div class="summary-pod" style="width:100%;">
		<span id="librarySummary-#stobj.typename#-#url.property#" style="text-align:center;width:100%;"><p>&nbsp;</p></span>
		
		<cfset formAction = application.fapi.getLink(type='#stobj.typename#', objectid='#stobj.objectid#', view='displayLibrarySelected', urlParameters="property=#url.property#&ajaxmode=1") />
		<!---<ft:button value="show selected" renderType="link" type="button" onclick="farcryForm_ajaxSubmission('#request.farcryform.name#','#formAction#')" class="green" />--->

	</div>
	<!-- summary pod end -->
	</cfoutput>
	</ft:form>
	
	<cfif listLen(stMetadata.ftJoin) GT 1>
		<!--- IF WE HAVE SELECTED ITEMS, SHOW THE BUTTON TO VIEW THEM --->
		<cfoutput>
		<div id="tabs">
			<ul>
				<cfloop list="#stMetadata.ftJoin#" index="i">
					<li><a href="/index.cfm?ajaxmode=1&type=#url.type#&objectid=#url.objectid#&view=displayLibrary&property=#url.property#&filterTypename=#i#">#application.fapi.getContentTypeMetadata(i,'displayName',i)#</a></li>
				</cfloop>
			</ul>
		</div>	
		</cfoutput>
		
		<skin:onReady>
			<cfoutput>$j("##tabs").tabs();</cfoutput>
		</skin:onReady>	
	<cfelse>
		<skin:view stobject="#stobj#" webskin="displayLibrary" />
	</cfif>	
	

	
	<admin:footer>
	
</cfif>