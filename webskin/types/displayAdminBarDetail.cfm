<!--- @@viewBinding: any --->

<cfsetting enablecfoutputonly="true" />



<!--- Import Tag Libraries --->
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />
<cfimport taglib="/farcry/core/tags/security" prefix="sec" />

<!--- Set tray state --->
<cfset session.fc.trayWebskin = "displayAdminBarDetail" />


<!--- Only show if the user is logged in --->
<cfif application.fapi.isLoggedIn()>
	
	<skin:onReady>
	<cfoutput>
	$j('##show-hidden').click(function(){
		$fc.traySwitch('displayAdminBarHidden');
	});
	$j('##show-summary').click(function(){
		$fc.traySwitch('displayAdminBarSummary');
	});
	
	<cfif stObj.typename neq "farCOAPI">
		$j('##edit-object').click(function(){
			$fc.editTrayObject('#stObj.typename#', '#stObj.objectid#');
		});
	</cfif>
	</cfoutput>
	</skin:onReady>
	
	<cfoutput>
	<div class="tray-detail" style="display:block;margin-left:15px;margin-right:15px;overflow:visible !important;position:relative;border:1px solid ##B5B5B5;border-width:1px 1px 0px 1px;background-color:##E5E5E5;">
		<div style="display:block;padding:0;border-top:1px solid ##FFFFFF;">
			<div style="">
	</cfoutput>
	
	
	
	
	<!--- If the url points to a type webskin, we need to determine the content type. --->
	<cfif stObj.typename eq "farCOAPI">
		<cfset contentTypename = stobj.name />
	<cfelse>
		<cfset contentTypename = stobj.typename />
	</cfif>
	
	
	
	<grid:div style="float:left;margin-right:15px;">
		<cfoutput>
		<ul id="tray-actions">	
			<li><a id="show-hidden"><span class="ui-icon" style="background-image:url(#application.url.webtop#/facade/icon.cfm?icon=toggletray&size=16);">&nbsp;</span>Hide tray</a></li>
			<li><a id="show-summary"><span class="ui-icon ui-icon-carat-2-n-s" style="float:left;">&nbsp;</span>Hide details of <strong>#application.fapi.getContentTypeMetadata(typename='#contentTypename#', md='displayName', default='#contentTypename#')#</strong></a></li>
			<cfif stObj.typename neq "farCOAPI">
				<li><a id="edit-object"><span class="ui-icon ui-icon-pencil" style="float:left;">&nbsp;</span>Edit</a></li>
			</cfif>
			<li><a href="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addValues='updateapp=1')#"><span class="ui-icon ui-icon-refresh" style="float:left;">&nbsp;</span>Update App</a></li>
			<li><a href="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addValues='logout=1')#"><span class="ui-icon ui-icon-power" style="float:left;">&nbsp;</span>Logout</a></li>
		</ul>
		</cfoutput>
	</grid:div>	
	
	<grid:div style="float:left;width:50%;">
		<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="secureTrayDetails" bIgnoreSecurity="true" stParam="#form#" />
	</grid:div>	
		

	
	<grid:div style="float:right;">
		
		<cfoutput>
			<ul>
			
				<cfif request.mode.flushcache>
					<li>
						<a href="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', removevalues="", addvalues='flushcache=0')#">
							<span class="ui-icon ui-icon-circle-close">&nbsp;</span>Cache OFF
						</a>
					</li>
				<cfelse>
					<li>
						<a href="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', removevalues="", addvalues='flushcache=1')#">
							<span class="ui-icon ui-icon-circle-check">&nbsp;</span>Cache ON
						</a>
					</li>
				</cfif>
				
				
				<cfif request.mode.showdraft>		
					<li>
						<a href="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='flushcache=1&showdraft=0')#" >
							<span class="ui-icon ui-icon-circle-check">&nbsp;</span>Drafts ON
						</a>
					</li>
				<cfelse>
					<li>
						<a href="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='flushcache=0&showdraft=1')#">
							<span class="ui-icon ui-icon-circle-close">&nbsp;</span>Drafts OFF
						</a>
					</li>
				</cfif>
				
				
				<cfif request.mode.design and request.mode.showcontainers gt 0>	
					<li>
						<a href="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='designmode=0')#">
							<span class="ui-icon ui-icon-circle-check">&nbsp;</span>Rules ON
						</a>
					</li>
				<cfelse>
					<li>
						<a href="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='designmode=1')#" >
							<span class="ui-icon ui-icon-circle-close">&nbsp;</span>Rules OFF
						</a>
					</li>
				</cfif>		
				
													
				<cfif findNoCase("bDebug=1", "#cgi.HTTP_REFERER#")>
					<li>
						<a href="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='bDebug=0')#">
							<span class="ui-icon ui-icon-circle-check">&nbsp;</span>Debug ON
						</a>
					</li>
				<cfelse>
					<li>
						<a href="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='bDebug=1')#" >
							<span class="ui-icon ui-icon-circle-close">&nbsp;</span>Debug OFF
						</a>
					</li>
				</cfif>	
													
				<cfif request.mode.traceWebskins EQ 1>
					<li>
						<a href="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='tracewebskins=0')#">
							<span class="ui-icon ui-icon-circle-check">&nbsp;</span>Webskin Tracer ON
						</a>
					</li>
				<cfelse>
					<li>
						<a href="#application.fapi.fixURL(url='#cgi.HTTP_REFERER#', addvalues='tracewebskins=1')#" >
							<span class="ui-icon ui-icon-circle-close">&nbsp;</span>Webskin Tracer OFF
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

<cfsetting enablecfoutputonly="false" />