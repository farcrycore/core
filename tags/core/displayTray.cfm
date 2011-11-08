
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/farcry/" prefix="farcry" />


<cfif thistag.executionMode eq "Start">

	<!--- environment variables --->
	<cfparam name="request.fc.startTickCount" default="#GetTickCount()#" />
	<cfparam name="url.bHideContextMenu" default="false" type="boolean" />
	<cfparam name="request.bHideContextMenu" default="false" type="boolean" /><!--- Hide the tray.  For backwards compatibility --->
	<cfparam name="request.fc.trayData" default="#structnew()#" />
	
	<cfset request.fc.trayData.objectid = url.objectid />
	<cfset request.fc.trayData.type = url.type />
	<cfset request.fc.trayData.view = url.view />
	<cfset request.fc.trayData.bodyView = url.bodyView />
	
</cfif>

<cfif thistag.executionMode eq "End">
	
	<cfset application.fapi.addProfilePoint("End","End") />
	
	<cfif (request.bHideContextMenu eq true or request.fc.bShowTray eq false or url.bHideContextMenu)
		AND len(url.type) 
		AND NOT structKeyExists(application.rules, url.type) 
		AND request.mode.bAdmin 
		AND NOT structKeyExists(request.fc, "bAdminTrayRendered") 
		AND NOT request.mode.ajax>
		
		<cfset request.fc.bAdminTrayRendered = true />
		
		<cfparam name="session.fc" default="#structNew()#" />
		<cfparam name="session.fc.trayWebskin" default="trayStandard" />
		<cfset session.fc.trayWebskin = "trayStandard" />
		
		<cfset request.fc.totalTickCount = (GetTickCount() - request.fc.startTickCount) />
		
		<!--- import libraries --->
		<skin:loadJS id="jquery" />
		<skin:loadJS id="jquery-ui" />
		<skin:loadJS id="jquery-tooltip" />
		<skin:loadJS id="farcry-form" />
		<skin:loadCSS id="jquery-ui" />
		<skin:loadCSS id="farcry-form" />
		<skin:loadCSS id="farcry-tray" />	
		<skin:loadCSS id="jquery-tooltip" />

		<cfoutput>	
		<skin:onReady>

		$fc.loadTray = function(){
		    $j('##farcryTray').html('');
					    
			$j.ajax({
				type: "POST",
				cache: false,
				url: '#application.fapi.getLink(type=url.type, view="trayContainer", objectid=url.objectid, urlParameters="ajaxmode=1&totalTickCount=#request.fc.totalTickCount#")#', 
				complete: function(data){
					$j('##farcryTray').html(data.responseText);					
				},
				data:{
					refererURL:'#cgi.script_name#?#cgi.query_string#'
					<cfloop collection="#request.fc.trayData#" item="thistag.traydatakey">
						<cfif issimplevalue(request.fc.trayData[thistag.traydatakey])>
							, '#thistag.traydatakey#':'#jsstringformat(request.fc.trayData[thistag.traydatakey])#'
						<cfelse>
							<cfwddx action="cfml2wddx" input="#request.fc.trayData[thistag.traydatakey]#" output="thistag.traydatawddx" />
							, '#thistag.traydatakey#':'#jsstringformat(thistag.traydatawddx)#'
						</cfif>
					</cfloop>
				},
				dataType: "html"
			});
		}
		
		
		$fc.trayAction = function(urlParams){
		    document.location = '#cgi.script_name#?#cgi.query_string#&' + urlParams;
		}
			
		$fc.editTrayObject = function(typename,objectid) {
			$fc.objectAdminAction('Inline Edit', '#application.url.webtop#/edittabOverview.cfm?typename=' + typename + '&objectid=' + objectid + '&method=edit&ref=iframe');		
		};	
		
		
		// only show the tray if we are not in a frame
		if (top === self) { 		
			$j("body").append("<div id='farcryTray'></div>");	
			$fc.loadTray();
		}	
		
		</skin:onReady>
	
		
		</cfoutput>
		
		<farcry:webskinTracer />
	<cfelseif isdefined("request.fc.trayData.profile") 
		AND request.mode.profile
		AND NOT structKeyExists(request.fc, "bAdminTrayRendered") 
		AND NOT request.mode.ajax>
		
		<cfset request.fc.bAdminTrayRendered = true />
		
		<skin:loadJS id="jquery-modal" />
		<skin:loadCSS id="jquery-modal" />
		
		<cfsavecontent variable="profilehtml"><cfoutput>
			<div id="info-picker">
				<a href="##" onclick="$j('div.request-html').hide();$j(this.rel).show();return false;" rel="##request-profile-html">Profiling</a> |
				<a href="##" onclick="$j('div.request-html').hide();$j(this.rel).show();return false;" rel="##request-log-html">Log</a>
			</div>
			<div id="request-profile-html" class="request-html">#application.fapi.getProfileHTML(request.fc.trayData.profile,true)#</div>
			<div id="request-log-html" class="request-html" style="display:none;">#application.fapi.getRequestLogHTML(request.fc.trayData.log,true)#</div>
		</cfoutput></cfsavecontent>
		<skin:onReady><cfoutput>
			$fc.openModal('#jsstringformat(trim(profilehtml))#','auto','auto',1,1);
		</cfoutput></skin:onReady>
		
		<farcry:webskinTracer />
	<cfelseif request.mode.tracewebskins
		AND NOT structKeyExists(request.fc, "bAdminTrayRendered") 
		AND NOT request.mode.ajax>
		
		<cfset request.fc.bAdminTrayRendered = true />
		
		<farcry:webskinTracer />
	</cfif>
	
</cfif>