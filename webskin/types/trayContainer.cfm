<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />

<!--- 
<cfset session.fc.trayWebskin = "trayContainer" />
 --->

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
	<script><!--- dummy --->
	<cfoutput>	
	
	<cfparam name="cookie.farcryTrayState" default="minimised">
	<cfparam name="cookie.farcryTrayPosition" default="bottom">
	
	<cfset farcryTrayClass = "">
	<cfif cookie.farcryTrayState eq "expanded">
		<cfset farcryTrayClass = farcryTrayClass & "farcryTrayExpanded">
	<cfelse>
		<cfset farcryTrayClass = farcryTrayClass & "farcryTrayMinimised">
	</cfif>
	<cfif cookie.farcryTrayPosition eq "top">
		<cfset farcryTrayClass = farcryTrayClass & " farcryTrayTop">
	<cfelse>
		<cfset farcryTrayClass = farcryTrayClass & " farcryTrayBottom">
	</cfif>

	
	// restore tray state and position
	$j("##farcryTray").attr("class", "#farcryTrayClass#");

	// show/hide tray
	$j(".farcryTrayTitlebar").click(function(){
		var $f = $j("##farcryTray");
		if ($f.hasClass("farcryTrayMinimised")) {
			$j(".farcryTrayBody").slideDown(function(){
				$f.removeClass("farcryTrayMinimised").addClass("farcryTrayExpanded");
			});
			document.cookie = "farcryTrayState=expanded;expires=" + new Date(2050,1,1).toGMTString() + ";path=/";
		}
		else {
			$j(".farcryTrayBody").slideUp(function(){
				$f.removeClass("farcryTrayExpanded").addClass("farcryTrayMinimised");
			});
			document.cookie = "farcryTrayState=minimised;expires=" + new Date(2050,1,1).toGMTString() + ";path=/";
		}
	});

	// swap docking position
	$j("##farcryTray-dock").click(function(){
		var $f = $j("##farcryTray");
		var $c = $j(".farcryTrayContainer");
		
		$f.removeClass("farcryTrayContextMenuVisible");	
		
		if ($f.hasClass("farcryTrayBottom")) {
			$c.slideUp(function(){
				$f.removeClass("farcryTrayBottom").addClass("farcryTrayTop");
				$c.slideDown();
			});
			document.cookie = "farcryTrayPosition=top;expires=" + new Date(2050,1,1).toGMTString() + ";path=/";
		}
		else {
			$c.slideUp(function(){
				$f.removeClass("farcryTrayTop").addClass("farcryTrayBottom");
				$c.slideDown();
			});
			document.cookie = "farcryTrayPosition=bottom;expires=" + new Date(2050,1,1).toGMTString() + ";path=/";
		}
		return false;
	});

	
	// show menu on click
	$j(".farcryTrayOptions").click(function(){
		$j("##farcryTray").toggleClass("farcryTrayContextMenuVisible");	
		return false;
	});
	// hide menu on mouse out
	$j(".farcryTrayOptions, .farcryTrayContextMenu").hover(function(){
		if ($j("##farcryTray").hasClass("farcryTrayContextMenuVisible")) {
			clearTimeout(farcryTrayContextMenuTimer);
		}
	}, function(){
		farcryTrayContextMenuTimer = setTimeout(function(){
			$j("##farcryTray").removeClass("farcryTrayContextMenuVisible");	
		}, 500);
	});
	// cancel menu event bubbling on context menu and tray buttons
	$j(".farcryTrayContextMenu, .farcryTrayButtons").click(function(event){
		event.stopImmediatePropagation();
	});

	
	<cfif stObj.typename neq "farCOAPI">
		$j('##farcryTray-edit').click(function(){
			$fc.editTrayObject('#stObj.typename#', '#stObj.objectid#');
		});
	</cfif>
	
	</cfoutput>
	</script><!--- dummy --->
	</skin:onReady>
	
	
	<cfoutput>
	<div class="farcryTrayContainer">
		<div class="farcryTrayTitlebar">
			<div class="farcryTrayLogo" title="Click to expand/collapse the FarCry tray">
				<img src="#application.url.webtop#/css/tray/tray-farcry-logo.png" border="0" />
			</div>
			<div class="farcryTrayTitle">

			<!--- content item status --->
			<cfif structKeyExists(stobj,"status")>

					<!--- If the url points to a type webskin, we need to determine the content type. --->
					<cfif stObj.typename eq "farCOAPI">
						<cfset contentTypename = stobj.name />
					<cfelse>
						<cfset contentTypename = stobj.typename />
					</cfif>
	
					<cfset trayStatus = stobj.status>
					<cfset trayContentType = application.fapi.getContentTypeMetadata(typename='#contentTypename#', md='displayName', default='#stobj.typename#')>
					<cfset trayLastUpdated = application.fapi.prettyDate(stobj.dateTimeLastUpdated)>
					<cfset trayLastUpdatedPrecise = dateFormat(stobj.dateTimeLastUpdated,'dd mmm yyyy') & " " & timeFormat(stobj.dateTimeLastUpdated,'hh:mm tt')>
					<cfset trayUpdatedBy = application.fapi.getContentType("dmProfile").getProfile(stobj.lastupdatedby).label>


					
					<cfswitch expression="#stobj.status#">
					<cfcase value="draft">

						<cfset trayStatus = "<strong>Draft</strong>">
						
<!--- 
							<grid:div class="webtopOverviewStatusBox" style="background-color:##C0FFFF;text-align:center;border-bottom:1px solid ##B5B5B5;margin-bottom:3px;">
								<cfoutput>
									DRAFT: last updated <a id="webtop-overview-lastupdated" title="#dateFormat(stobj.dateTimeLastUpdated,'dd mmm yyyy')# #timeFormat(stobj.dateTimeLastUpdated,'hh:mm tt')#">#application.fapi.prettyDate(stobj.dateTimeLastUpdated)#</a>.
									<skin:toolTip selector="##webtop-overview-lastupdated">Last updated on #dateFormat(stobj.dateTimeLastUpdated,'dd mmm yyyy')# at #timeFormat(stobj.dateTimeLastUpdated,'hh:mm tt')#</skin:toolTip>
									
									<cfif structKeyExists(stobj, "versionID") AND len(stobj.versionID)>
										(<skin:buildLink objectid="#stobj.versionID#" view="#stParam.view#" bodyView="#stParam.bodyView#" linktext="show approved" urlParameters="showdraft=0" />)
									</cfif>
								</cfoutput>
							</grid:div>
 --->
						
					</cfcase>
					<cfcase value="pending">

						<cfset trayStatus = "<em>Pending</em>">
						
<!--- 
							<grid:div class="webtopOverviewStatusBox" style="background-color:##FFE0C0;text-align:center;border-bottom:1px solid ##B5B5B5;margin-bottom:3px;">
								<cfoutput>
									PENDING: awaiting approval since <a id="webtop-overview-lastupdated" title="#dateFormat(stobj.dateTimeLastUpdated,'dd mmm yyyy')# #timeFormat(stobj.dateTimeLastUpdated,'hh:mm tt')#">#application.fapi.prettyDate(stobj.dateTimeLastUpdated)#</a>.
									<skin:toolTip selector="##webtop-overview-lastupdated">Last updated on #dateFormat(stobj.dateTimeLastUpdated,'dd mmm yyyy')# at #timeFormat(stobj.dateTimeLastUpdated,'hh:mm tt')#</skin:toolTip>
									
									<cfif structKeyExists(stobj, "versionID") AND len(stobj.versionID)>
										(<skin:buildLink objectid="#stobj.versionID#" view="#stParam.view#" bodyView="#stParam.bodyView#" linktext="show approved" urlParameters="showdraft=0" />)
									</cfif>
								</cfoutput>
							</grid:div>
 --->


					</cfcase>
					<cfcase value="approved">

						<cfset trayStatus = "Approved">

<!--- 
							<grid:div class="webtopOverviewStatusBox" style="background-color:##C0FFC0;text-align:center;border-bottom:1px solid ##B5B5B5;margin-bottom:3px;">
								<cfoutput>
									APPROVED: <a id="webtop-overview-lastupdated" title="#dateFormat(stobj.dateTimeLastUpdated,'dd mmm yyyy')# #timeFormat(stobj.dateTimeLastUpdated,'hh:mm tt')#">#application.fapi.prettyDate(stobj.dateTimeLastUpdated)#</a>.
									<skin:toolTip selector="##webtop-overview-lastupdated"
										configuration="position:'bottom center',relative:true" style="width:300px;">Last updated on #dateFormat(stobj.dateTimeLastUpdated,'dd mmm yyyy')# at #timeFormat(stobj.dateTimeLastUpdated,'hh:mm tt')#</skin:toolTip>
									
									<cfif structKeyExists(stobj,"versionID") AND structKeyExists(stobj,"status") AND stobj.status EQ "approved">
										<cfset qDraft = createObject("component", "#application.packagepath#.farcry.versioning").checkIsDraft(objectid=stobj.objectid,type=stobj.typename)>
										<cfif qDraft.recordcount>
											(<skin:buildLink objectid="#qDraft.objectid#" view="#stParam.view#" bodyView="#stParam.bodyView#" linktext="show draft" urlParameters="showdraft=1" />)
										</cfif>
									</cfif>	
								</cfoutput>
							</grid:div>
 --->
							
					</cfcase>
					</cfswitch>


					<span id="farcryTray-status">#trayStatus#</span> <span id="farcryTray-contentType">#trayContentType#</span>
					<span class="farcryTraySeparator">|</span>
					Updated <span id="farcryTray-lastUpdated" title="#trayLastUpdatedPrecise#">#trayLastUpdated#</span>
					by <span id="farcryTray-updatedBy">#trayUpdatedBy#</span>

				</cfif>	
				
			</div>

			<div class="farcryTrayContextMenu">
				<div class="farcryTrayContextMenuBody">
					<ul>
						<li><a id="farcryTray-dock" href="##"><span class="ui-icon ui-icon-carat-2-n-s"></span>Switch tray position</a></li>	
						<li class="farcryTrayContextMenuSeparator"></li>
						<li><a href="#application.fapi.fixURL(url='#form.refererURL#', removevalues='', addvalues='rebuild=page')#"><span class="ui-icon ui-icon-arrowrefresh-1-s"></span>Rebuild Page</a></li>
						<li><a href="#application.fapi.fixURL(url='#form.refererURL#', removevalues='', addvalues='rebuild=all')#" onclick="return confirm('This will clear the cache for the entire website.\nAre you sure you want to continue?');"><span class="ui-icon ui-icon-refresh"></span>Rebuild Site</a></li>
						<li class="farcryTrayContextMenuSeparator"></li>
						<li><a href="#application.fapi.fixURL(url='#form.refererURL#', removevalues="", addvalues='updateapp=#application.updateappkey#')#" onclick="return confirm('This will restart entire website and may take up to a few minutes.\nAre you sure you want to continue?');"><span class="ui-icon ui-icon-trash"></span>Update Application</a></li>
						<li class="farcryTrayContextMenuSeparator"></li>
						<cfif findNoCase("bDebug=1", "#form.refererURL#") OR findNoCase("bDebug/1", "#form.refererURL#")>
							<li><a class="farcryTrayMenuSelected" href="#application.fapi.fixURL(url='#form.refererURL#', addvalues='bDebug=0')#"><span class="ui-icon ui-icon-wrench"></span>Debug Mode</a></li>
						<cfelse>
							<li><a href="#application.fapi.fixURL(url='#form.refererURL#', addvalues='bDebug=1')#"><span class="ui-icon ui-icon-wrench"></span>Debug Mode</a></li>
						</cfif>
						<cfif findNoCase("profile=1", "#form.refererURL#") OR findNoCase("profile/1", "#form.refererURL#")>
							<li><a class="farcryTrayMenuSelected" href="#application.fapi.fixURL(url='#form.refererURL#', addvalues='profile=0')#"><span class="ui-icon ui-icon-battery-3"></span>Profiler</a></li>
						<cfelse>
							<li><a href="#application.fapi.fixURL(url='#form.refererURL#', addvalues='profile=1')#"><span class="ui-icon ui-icon-battery-3"></span>Profiler</a></li>
						</cfif>
						<cfif findNoCase("tracewebskins=1", "#form.refererURL#") OR findNoCase("tracewebskins/1", "#form.refererURL#")>
							<li><a class="farcryTrayMenuSelected" href="#application.fapi.fixURL(url='#form.refererURL#', addvalues='tracewebskins=0')#"><span class="ui-icon ui-icon-note"></span>Webskin Tracer</a></li>
						<cfelse>
							<li><a href="#application.fapi.fixURL(url='#form.refererURL#', addvalues='tracewebskins=1')#"><span class="ui-icon ui-icon-note"></span>Webskin Tracer</a></li>
						</cfif>
					</ul>
				</div>			
			</div>

			<div class="farcryTrayOptions"></div>
			
			<div class="farcryTrayButtons">
				<a id="farcryTray-edit" href="##"><span class="ui-icon ui-icon-pencil"></span>Edit</a>
				<cfif request.mode.design and request.mode.showcontainers gt 0>	
					<a id="farcryTray-rules" class="farcryTrayButtonSelected" href="#application.fapi.fixURL(url='#form.refererURL#', addvalues='designmode=0')#" title="Showing rules (click to turn off)"><span class="ui-icon ui-icon-copy"></span>Rules</a>
				<cfelse>
					<a id="farcryTray-rules" href="#application.fapi.fixURL(url='#form.refererURL#', addvalues='designmode=1')#" title="Hiding rules (click to turn on)"><span class="ui-icon ui-icon-copy"></span>Rules</a>
				</cfif>
				<cfif request.mode.showdraft>		
					<a id="farcryTray-caching" class="farcryTrayButtonSelected" href="#application.fapi.fixURL(url='#form.refererURL#', addvalues='showdraft=0')#" title="Showing drafts (click to turn off)"><span class="ui-icon ui-icon-document"></span>Drafts</a>
				<cfelse>
					<a id="farcryTray-caching" href="#application.fapi.fixURL(url='#form.refererURL#', addvalues='showdraft=1')#" title="Hiding Drafts (click to turn on)"><span class="ui-icon ui-icon-document"></span>Drafts</a>
				</cfif>
				<cfif request.mode.showdraft OR request.mode.design OR findNoCase("bDebug=1", "#form.refererURL#") OR findNoCase("bDebug/1", "#form.refererURL#") OR (findNoCase("tracewebskins=1", "#form.refererURL#") OR findNoCase("tracewebskins/1", "#form.refererURL#"))>
					<a id="farcryTray-caching" class="farcryTrayButtonDisabled" title="Caching is disabled when showing drafts, rules, debugging or webskin tracer"><span class="ui-icon ui-icon-script"></span>Caching</a>
				<cfelse>
					<cfif request.mode.flushcache>				
						<a id="farcryTray-caching" href="#application.fapi.fixURL(url='#form.refererURL#', removevalues='', addvalues='flushcache=0')#" title="Showing latest pages (click to show cached)"><span class="ui-icon ui-icon-script"></span>Caching</a>
					<cfelse>
						<a id="farcryTray-caching" class="farcryTrayButtonSelected" href="#application.fapi.fixURL(url='#form.refererURL#', removevalues='', addvalues='flushcache=1')#" title="Showing cached pages (click to show latest)"><span class="ui-icon ui-icon-script"></span>Caching</a>
					</cfif>
				</cfif>
			</div>

		</div>
		<div class="farcryTrayBody">
			<div class="farcryTrayBodyMenu">
				<ul>
					<li><a href="#application.fapi.fixURL(url='#application.url.webtop#', removevalues="")#"><span class="ui-icon ui-icon-calculator"></span>Webtop</a></li>
					<li><a href="#application.fapi.fixURL(url='#form.refererURL#', removevalues="", addvalues='logout=1')#"><span class="ui-icon ui-icon-power"></span>Logout</a></li>
				</ul>
			</div>

			<div class="farcryTrayBodyContent">
	</cfoutput>

		<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="#session.fc.trayWebskin#" bIgnoreSecurity="true" stParam="#form#" />

<!--- 
	
		<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="trayStandard" bIgnoreSecurity="true" stParam="#form#" />
	
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
 --->
	
	
	<cfoutput>
			<div class="farcryTrayClear"></div>
			</div>
		</div>
	</div>
	</cfoutput>
	
</cfif>

<cfsetting enablecfoutputonly="false" />