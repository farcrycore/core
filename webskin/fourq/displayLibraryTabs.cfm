<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: Display Library Tabs --->
<!--- @@description:   --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<!--- @@cacheStatus:-1 --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />


<cfif application.fapi.isLoggedIn()>
	
	<cfparam name="url.fieldname" default="fc#Replace(stObj.objectid,'-','','all')##url.property#" />
	
	<skin:loadJS id="jquery" />
	<skin:loadJS id="jquery-ui" />
	<skin:loadCSS id="jquery-ui" />	
	
	<cfset stMetadata = application.fapi.getPropertyMetadata(typename="#stobj.typename#", property="#url.property#") />

	
	<!------------------------------------------------------------------------------------------------ 
	Loop over the url and if any url parameters match any formtool metadata (prefix 'ft'), then override the metadata.
	 ------------------------------------------------------------------------------------------------>
	<cfloop collection="#url#" item="md">
		<cfif left(md,2) EQ "ft" AND structKeyExists(stMetadata, md)>
			<cfset stMetadata[md] = url[md] />
		</cfif>
	</cfloop>

	<cfset stMetadata = application.fapi.getFormtool(stMetadata.type).prepMetadata(stObject = stobj, stMetadata = stMetadata) />
	
	<admin:header title="Library Selector" style="width:100%;height:100%">		
	
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
					<!---<li><a href="###i#" >#application.fapi.getContentTypeMetadata(i,'displayName',i)#</a></li>--->
					<li><a href="#application.fapi.getWebroot()#/index.cfm?ajaxmode=1&type=#url.type#&objectid=#url.objectid#&view=displayLibrary&property=#url.property#&filterTypename=#i#">#application.fapi.getContentTypeMetadata(i,'displayName',i)#</a></li>
				</cfloop>
			</ul>
		<!---	<cfloop list="#stMetadata.ftJoin#" index="i">
				<div id="#i#">
					<h3>#i#</h3>
					<skin:view stobject="#stobj#" webskin="displayLibrary" />
				</div>
			</cfloop>--->

		</div>	
		</cfoutput>
		
		<skin:onReady>
			<cfoutput>
				
				$j("##tabs").tabs({
					
				});
			</cfoutput>
		</skin:onReady>	
	<cfelse>
		<skin:view stobject="#stobj#" webskin="displayLibrary" />
	</cfif>	
	
	<skin:onReady>
		<cfoutput>
			fcForm.selections.init('#stobj.typename#','#url.property#','#url.fieldname#');
		</cfoutput>
	</skin:onReady>	
	
	<admin:footer>
	
</cfif>