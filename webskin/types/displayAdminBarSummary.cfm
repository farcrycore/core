<!--- @@viewBinding: any --->
<!--- @@viewStack: fragment --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />

<cfset session.fc.trayWebskin = "displayAdminBarSummary" />

<!--- Only show if the user is logged in --->
<cfif application.fapi.isLoggedIn()>
	
	<!--- Need to strip out the domain name from the referer reference --->
	<cfset refererURL = cgi.http_referer />
	<cfset domainLoc = findNoCase(cgi.http_host, refererURL) />
	<cfif domainLoc GT 0>
		<cfset refererURL = mid(refererURL, find("/",refererURL,domainLoc), len(refererURL) ) />
	</cfif>
	
	
	<!--- If the url points to a type webskin, we need to determine the content type. --->
	<cfif stObj.typename eq "farCOAPI">
		<cfset contentTypename = stobj.name />
	<cfelse>
		<cfset contentTypename = stobj.typename />
	</cfif>	
	
	
	<skin:onReady>
	<cfoutput>	
	$j('##show-hidden').click(function(){
		$fc.traySwitch('displayAdminBarHidden');
	});
	$j('##show-detail').click(function(){
		$fc.traySwitch('displayAdminBarDetail');
	});
	
	<cfif stObj.typename neq "farCOAPI">
		$j('##edit-object').click(function(){
			$fc.editTrayObject('#stObj.typename#', '#stObj.objectid#');
		});
	</cfif>
	</cfoutput>
	</skin:onReady>
	
	
	<cfoutput>
	<div class="tray-summary" style="display:block;margin-left:15px;margin-right:15px;overflow:visible !important;position:relative;border:1px solid ##B5B5B5;border-width:1px 1px 0px 1px;background-color:##E5E5E5;">
		<div style="display:block;padding:0;border-top:1px solid ##FFFFFF;">
			<div style="">
	</cfoutput>
	
		<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="secureTrayStatus" bIgnoreSecurity="true" stParam="#form#" />
	
		<grid:div style="float:left;margin-right:5px;">
			<cfoutput>
			<ul id="tray-actions">	
				<li><a id="show-hidden"><span class="ui-icon" style="background-image:url(#application.fapi.getIconURL(icon='toggletray', size=16)#);">&nbsp;</span>Hide Tray</a></li>
				<li><a id="show-detail"><span class="ui-icon ui-icon-carat-2-n-s" style="float:left;">&nbsp;</span>Show details</a></li>
				<cfif stObj.typename neq "farCOAPI">
					<li><a id="edit-object"><span class="ui-icon ui-icon-pencil" style="float:left;">&nbsp;</span>Edit</a></li>
				</cfif>
			</ul>
			</cfoutput>
		</grid:div>
	
		<grid:div style="float:right;">
			
			<cfoutput>
			<ul id="tray-actions">
				
				<cfif request.mode.flushcache>
					<li>
						<a href="#application.fapi.fixURL(url='#refererURL#', removevalues="", addvalues='flushcache=0')#">
							<input type="checkbox" name="tray-flushcache" /> Caching
						</a>
					</li>
				<cfelse>
					<li>
						<a href="#application.fapi.fixURL(url='#refererURL#', removevalues="", addvalues='flushcache=1')#">
							<input type="checkbox" name="tray-flushcache" checked=checked /> Caching
						</a>
					</li>
				</cfif>
				
				
				<cfif request.mode.showdraft>		
					<li>
						<a href="#application.fapi.fixURL(url='#refererURL#', addvalues='showdraft=0')#" >
							<input type="checkbox" name="tray-showdraft" checked=checked /> Drafts
						</a>
					</li>
				<cfelse>
					<li>
						<a href="#application.fapi.fixURL(url='#refererURL#', addvalues='showdraft=1')#">
							<input type="checkbox" name="tray-showdraft" /> Drafts
						</a>
					</li>
				</cfif>
				
				
				<cfif request.mode.design and request.mode.showcontainers gt 0>	
					<li>
						<a href="#application.fapi.fixURL(url='#refererURL#', addvalues='designmode=0')#">
							<input type="checkbox" name="tray-designmode" checked=checked /> Rules
						</a>
					</li>
				<cfelse>
					<li>
						<a href="#application.fapi.fixURL(url='#refererURL#', addvalues='designmode=1')#" >
							<input type="checkbox" name="tray-designmode" /> Rules
						</a>
					</li>
				</cfif>
				
			
			</ul>
			</cfoutput>
		</grid:div>
	
	
	<cfoutput>
		
			</div>
			<br style="clear:both;" />
		</div>
	</div>
	</cfoutput>
	
</cfif>