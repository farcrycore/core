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
	<cfparam name="form.refererURL" default="#cgi.http_referer#" />
	<cfset domainLoc = findNoCase(cgi.http_host, form.refererURL) />
	<cfif domainLoc GT 0>
		<cfset form.refererURL = mid(form.refererURL, find("/",form.refererURL,domainLoc), len(form.refererURL) ) />
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
	<div class="tray-detail" style="display:block;margin-left:15px;margin-right:15px;overflow:visible !important;position:relative;border:1px solid ##B5B5B5;border-width:1px 1px 0px 1px;background-color:##e9f5fe;">
		<div style="display:block;padding:0;border-top:1px solid ##FFFFFF;">
			<div style="">
	</cfoutput>
	
	
	<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="secureTrayStatus" bIgnoreSecurity="true" stParam="#form#" />
	
	<cfoutput>
	<table class="layout" style="width:100%;">
	<tr>
		<td style="vertical-align:top;width:100px;">
			<ul id="tray-actions">	
				
				<li><a id="show-hidden" href="##"><span class="ui-icon" style="background-image:url('#application.fapi.getIconURL(icon='toggletray', size=16)#')">&nbsp;</span>Hide tray</a></li>
				<li><a href="#application.fapi.fixURL(url='#application.url.webtop#', removevalues="")#"><span class="ui-icon ui-icon-carat-2-n-s" style="float:left;">&nbsp;</span>Webtop</a></li>
				<!---<cfif stObj.typename neq "farCOAPI">
					<li><a id="edit-object" href="##"><span class="ui-icon ui-icon-pencil" style="float:left;">&nbsp;</span>Edit</a></li>
				</cfif>--->
				<li>
					<a href="#application.fapi.fixURL(url='#form.refererURL#', removevalues="", addvalues='updateapp=#application.updateappkey#')#">
						<span class="ui-icon ui-icon-refresh" style="float:left;">&nbsp;</span>Update App
					</a>
				</li>
				<li>
					<a href="#application.fapi.fixURL(url='#form.refererURL#', removevalues="", addvalues='logout=1')#">
						<span class="ui-icon ui-icon-power" style="float:left;">&nbsp;</span>Logout
					</a>
				</li>
			</ul>		
		</td>
		
		<cfif stObj.typename neq "farCOAPI">
			<td style="vertical-align:top;width:100px;">
				<ul id="tray-actions">
					<li>
						<a id="edit-object" href="##">
							<span class="ui-icon ui-icon-pencil" style="float:left;">&nbsp;</span>Edit
						</a>
					</li>
					<li>
						<a id="flush-object" href="#application.fapi.fixURL(url='#form.refererURL#', removevalues='', addvalues='rebuild=page')#">
							<span class="ui-icon ui-icon-arrowrefresh-1-s" style="float:left;">&nbsp;</span>Rebuild Page
						</a>
					</li>
					<li>
						<a id="flush-all" href="#application.fapi.fixURL(url='#form.refererURL#', removevalues='', addvalues='rebuild=all')#" onclick="return confirm('This will clear the cache for the entire website. Are you sure you want to continue?')">
							<span class="ui-icon ui-icon-refresh" style="float:left;">&nbsp;</span>Rebuild All
						</a>
					</li>
				</ul>
			</td>
		</cfif>
		
		<td style="vertical-align:top;" class="tray-details">
			<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="secureTrayDetails" bIgnoreSecurity="true" stParam="#form#" />
		</td>
		<td style="vertical-align:top;width:200px;">
			<table class="layout" style="width:100%;">
			<tr>
				<td style="vertical-align:top;">
	
					<ul id="page-actions-toggle">
						
						<!--- NO CACHING AVAILABLE WHEN  --->
						<cfif request.mode.showdraft OR request.mode.design OR findNoCase("bDebug=1", "#form.refererURL#") OR findNoCase("bDebug/1", "#form.refererURL#") OR (findNoCase("tracewebskins=1", "#form.refererURL#") OR findNoCase("tracewebskins/1", "#form.refererURL#"))>
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
										location.href='#application.fapi.fixURL(url='#form.refererURL#', removevalues='', addvalues='flushcache=0')#';
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
										location.href='#application.fapi.fixURL(url='#form.refererURL#', removevalues='', addvalues='flushcache=1')#';
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
									location.href='#application.fapi.fixURL(url='#form.refererURL#', addvalues='showdraft=0')#';
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
									location.href='#application.fapi.fixURL(url='#form.refererURL#', addvalues='showdraft=1')#';
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
									location.href='#application.fapi.fixURL(url='#form.refererURL#', addvalues='designmode=0')#';
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
									location.href='#application.fapi.fixURL(url='#form.refererURL#', addvalues='designmode=1')#';
									return false;
								});
							</skin:onReady>
						</cfif>		
						
					</ul>
									
				</td>
				<td style="vertical-align:top;">
		
					<ul id="page-actions-request">
						<cfif findNoCase("bDebug=1", "#form.refererURL#") OR findNoCase("bDebug/1", "#form.refererURL#")>
							<li>
								<a id="tray-bDebug" name="tray-bDebug" title="Turn OFF Debugging" href="##">
									<input type="checkbox" checked=checked /> Debug
								</a>
							</li>
							<skin:onReady>
								$j('##tray-bDebug').click(function() {
									location.href='#application.fapi.fixURL(url='#form.refererURL#', addvalues='bDebug=0')#';
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
									location.href='#application.fapi.fixURL(url='#form.refererURL#', addvalues='bDebug=1')#';
									return false;
								});
							</skin:onReady>
						</cfif>	
															
						<cfif findNoCase("tracewebskins=1", "#form.refererURL#") OR findNoCase("tracewebskins/1", "#form.refererURL#")>
							<li>
								<a id="tray-tracewebskins" name="tray-tracewebskins" title="Turn OFF Webskin Tracing" href="##">
									<input type="checkbox" checked=checked /> Tracer
								</a>
							</li>
							<skin:onReady>
								$j('##tray-tracewebskins').click(function() {
									location.href='#application.fapi.fixURL(url='#form.refererURL#', addvalues='tracewebskins=0')#';
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
									location.href='#application.fapi.fixURL(url='#form.refererURL#', addvalues='tracewebskins=1')#';
									return false;
								});
							</skin:onReady>
						</cfif>	
					
					</ul>					
				</td>
			</tr>
			</table>
			<div style="padding:10px;font-size:10px;border-top:1px solid ##CECECE;">Page Speed: #url.totalTickCount# seconds</div>
		</td>
		
	</tr>
	</table>
	
	</cfoutput>

</cfif>

<cfsetting enablecfoutputonly="false" />