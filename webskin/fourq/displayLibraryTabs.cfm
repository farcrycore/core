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
	
	<skin:loadJS id="fc-jquery" />
	<skin:loadJS id="fc-bootstrap" />
	<skin:loadCSS id="fc-fontawesome" />	
	
	<cfset stMetadata = application.fapi.getPropertyMetadata(typename="#stobj.typename#", property="#url.property#") />

	<!------------------------------------------------------------------------------------------------ 
	Loop over the url and if any url parameters match any formtool metadata (prefix 'ft'), then override the metadata.
	 ------------------------------------------------------------------------------------------------>
	<cfloop collection="#url#" item="md">
		<cfif left(md,2) EQ "ft" AND structKeyExists(stMetadata, md)>
			<cfset stMetadata[md] = url[md] />
		</cfif>
	</cfloop>

	<cfset stMetadata = application.fapi.getFormtool(stMetadata.ftType).prepMetadata(stObject = stobj, stMetadata = stMetadata) />
	
	
	<ft:form>				
	<cfoutput>
	<!-- summary pod with green arrow -->
	<div class="summary-pod" style="margin-bottom: 10px;">
		<div id="librarySummary-#stobj.typename#-#url.property#" style="text-align:center;"></div>
		
		<cfset formAction = application.fapi.getLink(type='#stobj.typename#', objectid='#stobj.objectid#', view='displayLibrarySelected', urlParameters="property=#url.property#&ajaxmode=1") />
		<!---<ft:button value="show selected" renderType="link" type="button" onclick="farcryForm_ajaxSubmission('#request.farcryform.name#','#formAction#')" class="green" />--->

	</div>
	<!-- summary pod end -->
	</cfoutput>
	</ft:form>
	
	<cfif listLen(stMetadata.ftJoin) GT 1>
		<!--- IF WE HAVE SELECTED ITEMS, SHOW THE BUTTON TO VIEW THEM --->
		<cfoutput>

			<div class="tabbable">
				<ul class="nav nav-tabs">    
					<cfloop list="#stMetadata.ftJoin#" index="i">
						<li <cfif listFirst(stMetadata.ftJoin) eq i>class="active"</cfif>><a data-toggle="tab" data-target="tabajax-content" href="#application.url.webtop#/index.cfm?ajaxmode=1&type=#url.type#&objectid=#url.objectid#&view=displayLibrary&property=#url.property#&filterTypename=#i#">#application.fapi.getContentTypeMetadata(i,'displayName',i)#</a></li>
					</cfloop>
				</ul>
				<div>
					<div id="tabajax-content"></div>
				</div>
			</div>

		</cfoutput>
		
		<skin:onReady>
			<cfoutput>
				$j('[data-toggle="tab"]').click(function(e) {
					e.preventDefault();
					$tab = $j(this);
					$j("##tabajax-content").load($tab.attr('href'), function(){
						$tab.tab('show');
					});
				});

				$j('.tabbable .nav-tabs li.active a').click();
				
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
	
	
</cfif>