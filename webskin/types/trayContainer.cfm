<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/grid" prefix="grid" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<!--- 
<cfset session.fc.trayWebskin = "trayContainer" />
 --->

<!--- Only show if the user is logged in --->
<cfif application.fapi.isLoggedIn()>

	<cfparam name="url.totalTickCount" default="--">

	<!--- Need to strip out the domain name from the referer reference --->
	<cfset refererURL = cgi.http_referer />
	<cfset domainLoc = findNoCase(cgi.http_host, refererURL) />
	<cfif domainLoc GT 0>
		<cfset refererURL = mid(refererURL, find("/",refererURL,domainLoc), len(refererURL) ) />
	</cfif>

	<cfif NOT structKeyExists(form, "refererURL")>
		<cfset form.refererURL = refererURL>
	</cfif>
	
	
	<!--- If the url points to a type webskin, we need to determine the content type. --->
	<cfif stObj.typename eq "farCOAPI">
		<cfset contentTypename = stobj.name />
	<cfelse>
		<cfset contentTypename = stobj.typename />
	</cfif>	
	

	<skin:onReady>
	<cfoutput>	
	
	<cfparam name="cookie.FARCRYTRAYSTATE" default="minimised">
	<cfparam name="cookie.FARCRYTRAYPOSITION" default="bottom">
	<cfparam name="cookie.FARCRYTRAYHIDDEN" default="false">
	
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
	<cfif cookie.farcryTrayHidden eq "true">
		<cfset farcryTrayClass = farcryTrayClass & " farcryTrayHidden">
	</cfif>

	
	// restore tray state and position
	$j("##farcryTray").attr("class", "#farcryTrayClass#");

	// expand/minimise tray
	$j(".farcryTrayTitlebar").click(function(){
		var $f = $j("##farcryTray");
		if ($f.hasClass("farcryTrayHidden")) {
			$f.removeClass("farcryTrayHidden");
			document.cookie = "FARCRYTRAYHIDDEN=false;expires=" + new Date(2050,1,1).toGMTString() + ";path=/";
		}
		else
		{
			if ($f.hasClass("farcryTrayMinimised")) {
				$j(".farcryTrayBody").slideDown(function(){
					$f.removeClass("farcryTrayMinimised").addClass("farcryTrayExpanded");
				});
				document.cookie = "FARCRYTRAYSTATE=expanded;expires=" + new Date(2050,1,1).toGMTString() + ";path=/";
			}
			else {
				$j(".farcryTrayBody").slideUp(function(){
					$f.removeClass("farcryTrayExpanded").addClass("farcryTrayMinimised");
				});
				document.cookie = "FARCRYTRAYSTATE=minimised;expires=" + new Date(2050,1,1).toGMTString() + ";path=/";
			}
		}
		return false;
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
			document.cookie = "FARCRYTRAYPOSITION=top;expires=" + new Date(2050,1,1).toGMTString() + ";path=/";
		}
		else {
			$c.slideUp(function(){
				$f.removeClass("farcryTrayTop").addClass("farcryTrayBottom");
				$c.slideDown();
			});
			document.cookie = "FARCRYTRAYPOSITION=bottom;expires=" + new Date(2050,1,1).toGMTString() + ";path=/";
		}
		return false;
	});

	// hide tray
	$j("##farcryTray-hide").click(function(){
		var $f = $j("##farcryTray");
		$f.addClass("farcryTrayHidden");
		$f.removeClass("farcryTrayContextMenuVisible");	
		$j(".farcryTrayBody").attr("style","");
		document.cookie = "FARCRYTRAYHIDDEN=true;expires=" + new Date(2050,1,1).toGMTString() + ";path=/";
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
	// cancel menu event bubbling on context menu, tray buttons and titlebar status link
	$j(".farcryTrayContextMenu, .farcryTrayButtons, .farcryTrayStatusLink").click(function(event){
		event.stopImmediatePropagation();
	});

	
	<cfif stObj.typename neq "farCOAPI">
		$j('##farcryTray-edit').click(function(){
			$fc.editTrayObject('#stObj.typename#', '#stObj.objectid#');
			return false;
		});
	</cfif>
	
	</cfoutput>
	</skin:onReady>
	
	
	<cfoutput>
	<div class="farcryTrayContainer">
		<div class="farcryTrayTitlebar">
			<div class="farcryTrayLogo" title="<admin:resource key='tray.expandcollapse@hint'>Click to expand/collapse the FarCry tray</admin:resource>">
				<img src="#application.url.webtop#/css/tray/tray-farcry-logo.png" border="0" />
			</div>
			<div class="farcryTrayTitle">

			<!--- content item status --->
			<cfif structKeyExists(stobj,"status")>

					<!--- if the url points to a type webskin, we need to determine the content type. --->
					<cfif stObj.typename eq "farCOAPI">
						<cfset contentTypename = stobj.name />
					<cfelse>
						<cfset contentTypename = stobj.typename />
					</cfif>
	
					<cfset trayStatus = application.fapi.getResource(key='tray.status.#stobj.status#@label',default=stobj.status) />
					<cfset trayIcon = "none">
					<cfset trayStatusLink = "">
					<cfset trayContentType = application.fapi.getResource(key='coapi.#contentTypename#@label',default=application.fapi.getContentTypeMetadata(typename='#contentTypename#', md='displayName', default='#stobj.typename#')) />
					
					<cfset aUpdatedValues = arraynew(1) />
					<cfset arrayappend(aUpdatedValues,dateFormat(stobj.dateTimeLastUpdated,'dd mmm yyyy') & " " & timeFormat(stobj.dateTimeLastUpdated,'hh:mm tt')) />
					<cfset arrayappend(aUpdatedValues,application.fapi.prettyDate(stobj.dateTimeLastUpdated)) />
					<cfset arrayappend(aUpdatedValues,application.fapi.getContentType("dmProfile").getProfile(stobj.lastupdatedby).label) />

					<!--- set up object status info --->
					<cfswitch expression="#stobj.status#">
					<cfcase value="draft">
						<cfset trayStatus = "<strong>#application.fapi.getResource('workflow.constants.draft@label','Draft')#</strong>">
						<cfset trayIcon = "alert">
						<cfif structKeyExists(stobj, "versionID") AND len(stobj.versionID)>
							<cfset trayStatusLink = "<a class='farcryTrayStatusLink' href='#application.fc.lib.esapi.encodeForHTMLAttribute(application.fapi.fixURL(url='#form.refererURL#', addvalues='showdraft=0'))#'>#application.fapi.getResource(key='tray.button.showapproved@label',default='Show Approved')#</a>">
						</cfif>
					</cfcase>
					<cfcase value="pending">
						<cfset trayStatus = "<em>#application.fapi.getResource('workflow.constants.pending@label','Pending')#</em>">
						<cfset trayIcon = "alert">
						<cfif structKeyExists(stobj, "versionID") AND len(stobj.versionID)>
							<cfset trayStatusLink = "<a class='farcryTrayStatusLink' href='#application.fc.lib.esapi.encodeForHTMLAttribute(application.fapi.fixURL(url='#form.refererURL#', addvalues='showdraft=0'))#'>#application.fapi.getResource(key='tray.button.showapproved@label',default='Show Approved')#</a>">
						</cfif>
					</cfcase>
					<cfcase value="approved">
						<cfset trayStatus = "#application.fapi.getResource('workflow.constants.approved@label','Approved')#">
						<cfset trayIcon = "check">
						<cfif structKeyExists(stobj,"versionID") AND structKeyExists(stobj,"status") AND stobj.status EQ "approved">
							<cfset qDraft = application.factory.oVersioning.checkIsDraft(objectid=stobj.objectid,type=stobj.typename)>
							<cfif qDraft.recordcount>
								<cfset trayStatusLink = "<a class='farcryTrayStatusLink' href='#application.fc.lib.esapi.encodeForHTMLAttribute(application.fapi.fixURL(url='#form.refererURL#', addvalues='showdraft=1'))#'>#application.fapi.getResource(key='tray.button.showdraft@label',default='Show Draft')#</a>">
							</cfif>
						</cfif>	
					</cfcase>
					</cfswitch>
					
					<span class="ui-icon ui-icon-#trayIcon#" style="float: left; margin-top: 7px; margin-right: 3px;"></span><span id="farcryTray-status">#trayStatus#</span> <span id="farcryTray-contentType">#trayContentType#</span>
					#trayStatusLink#
					<span class="farcryTraySeparator">|</span>
					<admin:resource key="tray.information.updated@label" variables="#aUpdatedValues#">Updated <span id="farcryTray-lastUpdated" title="{1}">{2}</span> by <span id="farcryTray-updatedBy">{3}</span></admin:resource>

				</cfif>	
				
			</div>

			<div class="farcryTrayContextMenu">
				<div class="farcryTrayContextMenuBody">
					<ul>
						<li><a id="farcryTray-dock" href="##"><span class="ui-icon ui-icon-carat-2-n-s"></span><admin:resource key='tray.button.switchtrayposition@label'>Switch Tray Position</admin:resource></a></li>	
						<li><a id="farcryTray-hide" href="##"><span class="ui-icon ui-icon-carat-2-e-w"></span><admin:resource key='tray.button.hidetray@label'>Hide Tray</admin:resource></a></li>	
						<li class="farcryTrayContextMenuSeparator"></li>
						<li><a href="#application.fc.lib.esapi.encodeForHTMLAttribute(application.fapi.fixURL(url='#form.refererURL#', addvalues='rebuild=page'))#"><span class="ui-icon ui-icon-arrowrefresh-1-s"></span><admin:resource key='tray.button.rebuildpage@label'>Rebuild Page</admin:resource></a></li>
						<li><a href="#application.fc.lib.esapi.encodeForHTMLAttribute(application.fapi.fixURL(url='#form.refererURL#', addvalues='rebuild=all'))#" onclick='return confirm("#(application.fapi.getResource(key='tray.button.rebuildsite@confirmtext',default='This will clear the cache for the entire website.\nAre you sure you want to continue?'))#");'><span class="ui-icon ui-icon-refresh"></span><admin:resource key='tray.button.rebuildsite@label'>Rebuild Site</admin:resource></a></li>
						<li class="farcryTrayContextMenuSeparator"></li>
						<li><a href="#application.fc.lib.esapi.encodeForHTMLAttribute(application.fapi.fixURL(url='#form.refererURL#', addvalues='updateapp=#application.updateappkey#'))#" onclick='return confirm("#(application.fapi.getResource(key='tray.button.updateapplication@confirmtext',default='This will restart the entire website and may take up to a few minutes.\nAre you sure you want to continue?'))#");'><span class="ui-icon ui-icon-trash"></span><admin:resource key='tray.button.updateapplication@label'>Update Application</admin:resource></a></li>
						<li class="farcryTrayContextMenuSeparator"></li>
						<cfif findNoCase("bDebug=1", "#form.refererURL#") OR findNoCase("bDebug/1", "#form.refererURL#")>
							<li><a class="farcryTrayMenuSelected" href="#application.fc.lib.esapi.encodeForHTMLAttribute(application.fapi.fixURL(url='#form.refererURL#', addvalues='bDebug=0'))#"><span class="ui-icon ui-icon-wrench"></span><admin:resource key='tray.button.toggledebugmode@label'>Debug Mode</admin:resource></a></li>
						<cfelse>
							<li><a href="#application.fc.lib.esapi.encodeForHTMLAttribute(application.fapi.fixURL(url='#form.refererURL#', addvalues='bDebug=1'))#"><span class="ui-icon ui-icon-wrench"></span><admin:resource key='tray.button.toggledebugmode@label'>Debug Mode</admin:resource></a></li>
						</cfif>
						<cfif findNoCase("profile=1", "#form.refererURL#") OR findNoCase("profile/1", "#form.refererURL#")>
							<li><a class="farcryTrayMenuSelected" href="#application.fc.lib.esapi.encodeForHTMLAttribute(application.fapi.fixURL(url='#form.refererURL#', addvalues='profile=0'))#"><span class="ui-icon ui-icon-battery-3"></span><admin:resource key='tray.button.toggleprofiler@label'>Profiler</admin:resource></a></li>
						<cfelse>
							<li><a href="#application.fc.lib.esapi.encodeForHTMLAttribute(application.fapi.fixURL(url='#form.refererURL#', addvalues='profile=1'))#"><span class="ui-icon ui-icon-battery-3"></span><admin:resource key='tray.button.toggleprofiler@label'>Profiler</admin:resource></a></li>
						</cfif>
						<cfif findNoCase("tracewebskins=1", "#form.refererURL#") OR findNoCase("tracewebskins/1", "#form.refererURL#")>
							<li><a class="farcryTrayMenuSelected" href="#application.fc.lib.esapi.encodeForHTMLAttribute(application.fapi.fixURL(url='#form.refererURL#', addvalues='tracewebskins=0'))#"><span class="ui-icon ui-icon-note"></span><admin:resource key='tray.button.toggletracer@label'>Webskin Tracer</admin:resource></a></li>
						<cfelse>
							<li><a href="#application.fc.lib.esapi.encodeForHTMLAttribute(application.fapi.fixURL(url='#form.refererURL#', addvalues='tracewebskins=1'))#"><span class="ui-icon ui-icon-note"></span><admin:resource key='tray.button.toggletracer@label'>Webskin Tracer</admin:resource></a></li>
						</cfif>
					</ul>
				</div>			
			</div>

			<div class="farcryTrayOptions"></div>
			
			<div class="farcryTrayButtons">
				<a id="farcryTray-edit" href="##"><span class="ui-icon ui-icon-pencil"></span><admin:resource key='tray.button.edit@label'>Edit</admin:resource></a>
				<cfif request.mode.design and request.mode.showcontainers gt 0>	
					<a id="farcryTray-rules" class="farcryTrayButtonSelected" href="#application.fc.lib.esapi.encodeForHTMLAttribute(application.fapi.fixURL(url='#form.refererURL#', addvalues='designmode=0'))#" title="<admin:resource key='tray.button.hiderules@hint'>Showing rules (click to turn off)</admin:resource>"><span class="ui-icon ui-icon-copy"></span><admin:resource key='tray.button.hiderules@label'>Rules</admin:resource></a>
				<cfelse>
					<a id="farcryTray-rules" href="#application.fc.lib.esapi.encodeForHTMLAttribute(application.fapi.fixURL(url='#form.refererURL#', addvalues='designmode=1'))#" title="<admin:resource key='tray.button.showrules@hint'>Hiding rules (click to turn on)</admin:resource>"><span class="ui-icon ui-icon-copy"></span><admin:resource key='tray.button.showrules@label'>Rules</admin:resource></a>
				</cfif>
				<cfif request.mode.showdraft>		
					<a id="farcryTray-caching" class="farcryTrayButtonSelected" href="#application.fc.lib.esapi.encodeForHTMLAttribute(application.fapi.fixURL(url='#form.refererURL#', addvalues='showdraft=0'))#" title="<admin:resource key='tray.button.hidedrafts@hint'>Showing drafts (click to turn off)</admin:resource>"><span class="ui-icon ui-icon-document"></span><admin:resource key='tray.button.hidedrafts@label'>Drafts</admin:resource></a>
				<cfelse>
					<a id="farcryTray-caching" href="#application.fc.lib.esapi.encodeForHTMLAttribute(application.fapi.fixURL(url='#form.refererURL#', addvalues='showdraft=1'))#" title="<admin:resource key='tray.button.showdrafts@hint'>Hiding Drafts (click to turn on)</admin:resource>"><span class="ui-icon ui-icon-document"></span><admin:resource key='tray.button.showdrafts@label'>Drafts</admin:resource></a>
				</cfif>
				<cfif request.mode.showdraft OR request.mode.design OR findNoCase("bDebug=1", "#form.refererURL#") OR findNoCase("bDebug/1", "#form.refererURL#") OR (findNoCase("tracewebskins=1", "#form.refererURL#") OR findNoCase("tracewebskins/1", "#form.refererURL#"))>
					<a id="farcryTray-caching" class="farcryTrayButtonDisabled" title="<admin:resource key='tray.button.cacheadmin@hint'>Caching is disabled when showing drafts, rules, debugging or webskin tracer</admin:resource>"><span class="ui-icon ui-icon-script"></span><admin:resource key='tray.button.cacheadmin@label'>Caching</admin:resource></a>
				<cfelse>
					<cfif request.mode.flushcache>				
						<a id="farcryTray-caching" href="#application.fc.lib.esapi.encodeForHTMLAttribute(application.fapi.fixURL(url='#form.refererURL#', addvalues='flushcache=0'))#" title="<admin:resource key='tray.button.cacehenable@label'>Showing latest pages (click to show cached)</admin:resource>"><span class="ui-icon ui-icon-script"></span><admin:resource key='tray.button.cacehenable@label'>Caching</admin:resource></a>
					<cfelse>
						<a id="farcryTray-caching" class="farcryTrayButtonSelected" href="#application.fc.lib.esapi.encodeForHTMLAttribute(application.fapi.fixURL(url='#form.refererURL#', addvalues='flushcache=1'))#" title="<admin:resource key='tray.button.cacehdisable@label'>Showing cached pages (click to show latest)</admin:resource>"><span class="ui-icon ui-icon-script"></span><admin:resource key='tray.button.cacehdisable@label'>Caching</admin:resource></a>
					</cfif>
				</cfif>
			</div>

		</div>
		<div class="farcryTrayBody">
			<div class="farcryTrayBodyMenu">
				<ul>
					<li><a href="#application.fc.lib.esapi.encodeForHTMLAttribute(application.fapi.fixURL(url='#application.url.webtop#'))#"><span class="ui-icon ui-icon-calculator"></span><admin:resource key='tray.button.webtop@label'>Webtop</admin:resource></a></li>
					<cfif application.fapi.getContentTypeMetadata(stObj.typename, "bUseInTree", false)>
						<li><a id="farcryTray-sitetree" href="#application.url.webtop#/index.cfm?id=site&rootobjectid=#request.navid#" target="_blank"><span class="ui-icon ui-icon-zoomin"></span><admin:resource key='tray.button.sitetree@label'>Site Tree</admin:resource></a></li>
					</cfif>
					<li><a href="#application.fc.lib.esapi.encodeForHTMLAttribute(application.fapi.fixURL(url='#form.refererURL#', addvalues='logout=1'))#"><span class="ui-icon ui-icon-power"></span><admin:resource key='tray.button.logout@label'>Logout</admin:resource></a></li>
					<li class="farcryTrayPageSpeed"><a title="<admin:resource key='tray.information.renderingspeed@hint'>Page rendering speed</admin:resource>"><span class="ui-icon ui-icon-clock" style="background-position:-81px -112px;"></span> <admin:resource key='tray.information.renderingspeed@label' var1="#application.fc.lib.esapi.encodeForHTML(url.totalTickCount)#">{1} ms</admin:resource></a></li>
				</ul>
			</div>

			<div class="farcryTrayBodyContent">

				</cfoutput>
				<skin:view typename="#stobj.typename#" objectid="#stobj.objectid#" webskin="#session.fc.trayWebskin#" bIgnoreSecurity="true" stParam="#form#" />
				<cfoutput>

				<div class="farcryTrayClear"></div>
			</div>
		</div>
	</div>
	</cfoutput>
	
</cfif>

<cfsetting enablecfoutputonly="false" />