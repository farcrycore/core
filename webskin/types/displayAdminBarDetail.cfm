<cfsetting enablecfoutputonly="true" />
<cfsetting showdebugoutput="false" />

<!--- @@viewBinding: any --->




<!--- Import Tag Libraries --->
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<!--- Set tray state --->
<cfset session.fc.trayWebskin = "displayAdminBarDetail" />


<!--- Only show if the user is logged in --->
<cfif application.fapi.isLoggedIn()>
	
	<!--- Need to strip out the domain name from the referer reference --->
	<cfset refererURL = cgi.http_referer />
	<cfset domainLoc = findNoCase(cgi.http_host, refererURL) />
	<cfif domainLoc GT 0>
		<cfset refererURL = mid(refererURL, find("/",refererURL,domainLoc), len(refererURL) ) />
	</cfif>
	


	
	
	<skin:onReady>
	<cfoutput>
		$j('##show-hidden').click(function(){
			$fc.traySwitch('displayAdminBarHidden');
			return false;
		});
		
		<cfif stObj.typename neq "farCOAPI">
			$j('##edit-object').click(function(){
				$fc.editTrayObject('#stObj.typename#', '#stObj.objectid#');
				return false;
			});
		</cfif>
	</cfoutput>
	</skin:onReady>
	
	
	
	<cfoutput>
	<div class="tray-detail" style="display:block;margin-left:15px;margin-right:15px;overflow:visible !important;position:relative;border:1px solid ##B5B5B5;border-width:1px 1px 0px 1px;background-color:##E5E5E5;">
		<div style="display:block;padding:0;border-top:1px solid ##FFFFFF;">
			<div style="">
	</cfoutput>
	
	
	<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="secureTrayStatus" bIgnoreSecurity="true" stParam="#form#" />
	
	
	<grid:div style="float:left;margin-right:15px;">
		<cfoutput>
		<ul id="tray-actions">	
				
			<li><a id="show-hidden" href="##"><span class="ui-icon" style="background-image:url('#application.fapi.getIconURL(icon='toggletray', size=16)#')">&nbsp;</span>Hide tray</a></li>
			<li><a href="#application.fapi.fixURL(url='#application.url.webtop#', removevalues="")#"><span class="ui-icon ui-icon-carat-2-n-s" style="float:left;">&nbsp;</span>Webtop</a></li>
			<!---<cfif stObj.typename neq "farCOAPI">
				<li><a id="edit-object" href="##"><span class="ui-icon ui-icon-pencil" style="float:left;">&nbsp;</span>Edit</a></li>
			</cfif>--->
			<li>
				<a href="#application.fapi.fixURL(url='#refererURL#', removevalues="", addvalues='updateapp=#application.updateappkey#')#">
					<span class="ui-icon ui-icon-refresh" style="float:left;">&nbsp;</span>Update App
				</a>
			</li>
			<li>
				<a href="#application.fapi.fixURL(url='#refererURL#', removevalues="", addvalues='logout=1')#">
					<span class="ui-icon ui-icon-power" style="float:left;">&nbsp;</span>Logout
				</a>
			</li>
		</ul>
		</cfoutput>
	</grid:div>	
		
	<cfif stObj.typename neq "farCOAPI">
		<grid:div style="float:left;margin-right:15px;">
			<cfoutput>
			<ul id="tray-actions">				
				<li>
					<a id="edit-object" href="##">
						<span class="ui-icon ui-icon-pencil" style="float:left;">&nbsp;</span>Edit
					</a>
				</li>	
			</ul>
			</cfoutput>
		</grid:div>	
	</cfif>
	
	<grid:div style="float:left;width:50%;" class="tray-details">
		<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="secureTrayDetails" bIgnoreSecurity="true" stParam="#form#" />
	</grid:div>	
		

	
	<grid:div style="float:right;">
		<cfoutput>
			<ul id="page-actions-request">
				<cfif findNoCase("bDebug=1", "#refererURL#") OR findNoCase("bDebug/1", "#refererURL#")>
					<li>
						<a id="tray-bDebug" name="tray-bDebug" title="Turn OFF Debugging" href="##">
							<input type="checkbox" checked=checked /> Debug
						</a>
					</li>
					<skin:onReady>
						$j('##tray-bDebug').click(function() {
							location.href='#application.fapi.fixURL(url='#refererURL#', addvalues='bDebug=0')#';
							return false;
						});
					</skin:onReady>
				<cfelse>
					<li>
						<a id="tray-bDebug" name="tray-bDebug" title="Turn ON Debugging" href="##">
							<input type="checkbox" /> Debug
						</a>
					</li>
					<skin:onReady>
						$j('##tray-bDebug').click(function() {
							location.href='#application.fapi.fixURL(url='#refererURL#', addvalues='bDebug=1')#';
							return false;
						});
					</skin:onReady>
				</cfif>	
													
				<cfif findNoCase("tracewebskins=1", "#refererURL#") OR findNoCase("tracewebskins/1", "#refererURL#")>
					<li>
						<a id="tray-tracewebskins" name="tray-tracewebskins" title="Turn OFF Webskin Tracing" href="##">
							<input type="checkbox" checked=checked /> Tracer
						</a>
					</li>
					<skin:onReady>
						$j('##tray-tracewebskins').click(function() {
							location.href='#application.fapi.fixURL(url='#refererURL#', addvalues='tracewebskins=0')#';
							return false;
						});
					</skin:onReady>
				<cfelse>
					<li>
						<a id="tray-tracewebskins" name="tray-tracewebskins" title="Turn ON Webskin Tracing" href="##">
							<input type="checkbox" /> Tracer
						</a>
					</li>
					<skin:onReady>
						$j('##tray-tracewebskins').click(function() {
							location.href='#application.fapi.fixURL(url='#refererURL#', addvalues='tracewebskins=1')#';
							return false;
						});
					</skin:onReady>
				</cfif>	
			
			</ul>
		</cfoutput>
	</grid:div>

	<grid:div style="float:right;">
		<cfoutput>
			<ul id="page-actions-toggle">
				
				<!--- NO CACHING AVAILABLE WHEN  --->
				<cfif request.mode.showdraft OR request.mode.design OR findNoCase("bDebug=1", "#refererURL#") OR findNoCase("bDebug/1", "#refererURL#") OR request.mode.traceWebskins>
					<li>
						<a title="Caching is not Available when viewing drafts, in design mode, tracing webskins or in debug mode.">
							<input type="checkbox" name="tray-flushcache" disabled=true /> <span style="text-decoration: line-through;">Caching</span>
						</a>
					</li>				
				<cfelse>
					<cfif request.mode.flushcache>
						<li>
							<a id="tray-flushcache" name="tray-flushcache" title="Turn ON caching" href="##">
								<input type="checkbox" /> Caching 
							</a>
						</li>
						<skin:onReady>
							$j('##tray-flushcache').click(function() {
								location.href='#application.fapi.fixURL(url='#refererURL#', removevalues='', addvalues='flushcache=0')#';
								return false;
							});
						</skin:onReady>
					<cfelse>
						<li>
							<a id="tray-flushcache" name="tray-flushcache" title="Turn OFF caching" href="##">
								<input type="checkbox" checked=checked /> Caching
							</a>
						</li>
						<skin:onReady>
							$j('##tray-flushcache').click(function() {
								location.href='#application.fapi.fixURL(url='#refererURL#', removevalues='', addvalues='flushcache=1')#';
								return false;
							});
						</skin:onReady>
					</cfif>
				</cfif>
				
				
				<cfif request.mode.showdraft>		
					<li>
						<a id="tray-showdraft" name="tray-showdraft" title="Turn OFF drafts" href="##" >
							<input type="checkbox" checked=checked /> Drafts
						</a>
					</li>
					<skin:onReady>
						$j('##tray-showdraft').click(function() {
							location.href='#application.fapi.fixURL(url='#refererURL#', addvalues='showdraft=0')#';
							return false;
						});
					</skin:onReady>
				<cfelse>
					<li>
						<a id="tray-showdraft" name="tray-showdraft" title="Turn ON drafts" href="##">
							<input type="checkbox" /> Drafts
						</a>
					</li>
					<skin:onReady>
						$j('##tray-showdraft').click(function() {
							location.href='#application.fapi.fixURL(url='#refererURL#', addvalues='showdraft=1')#';
							return false;
						});
					</skin:onReady>
				</cfif>
				
				
				<cfif request.mode.design and request.mode.showcontainers gt 0>	
					<li>
						<a id="tray-designmode" name="tray-designmode" title="Hide Rules" href="##">
							<input type="checkbox" name="tray-designmode" checked=checked /> Rules
						</a>
					</li>
					<skin:onReady>
						$j('##tray-designmode').click(function() {
							location.href='#application.fapi.fixURL(url='#refererURL#', addvalues='designmode=0')#';
							return false;
						});
					</skin:onReady>
				<cfelse>
					<li>
						<a id="tray-designmode" name="tray-designmode" title="Show Rules" href="##">
							<input type="checkbox" name="tray-designmode" /> Rules
						</a>
					</li>
					<skin:onReady>
						$j('##tray-designmode').click(function() {
							location.href='#application.fapi.fixURL(url='#refererURL#', addvalues='designmode=1')#';
							return false;
						});
					</skin:onReady>
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

<cfsetting enablecfoutputonly="false" />