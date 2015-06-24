
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
	
	<cfif NOT (request.bHideContextMenu eq true or request.fc.bShowTray eq false or url.bHideContextMenu eq true)
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
		<skin:loadJS id="fc-jquery" />
		<skin:loadJS id="fc-jquery-ui" />
		<skin:loadJS id="fc-bootstrap-tray" />
		<skin:loadJS id="farcry-form" />
		<skin:loadCSS id="jquery-ui" />
		<skin:loadCSS id="fc-bootstrap-tray" />
		<skin:loadCSS id="farcry-form" />
		<skin:loadCSS id="farcry-tray" />
		
		<cfset oCharset = createObject("java","java.nio.charset.Charset") />
		<cfset fromCharSet = oCharset.forName('iso-8859-1') />
		<cfset toCharSet = oCharset.forName('utf-8') />
		<cfset queryString = toCharSet.decode(fromCharSet.encode(cgi.query_string)).ToString() />

		<cfoutput>	
		<skin:onReady>

		$fc.loadTray = function(){
		    $j('##farcryTray').html('');

			$j.ajax({
				type: "POST",
				cache: false,
				url: '#application.url.webroot#/index.cfm?typename=#urlEncodedFormat(url.type)#&objectid=#urlEncodedFormat(url.objectid)#&view=trayContainer&ajaxmode=1&totalTickCount=#request.fc.totalTickCount#',
				complete: function(data){
					$j('##farcryTray').html(data.responseText);					
				},
				data:{
					refererURL:'#cgi.script_name#?#queryString#'
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
			$fc.objectAdminTrayAction('Inline Edit', '#application.url.webtop#/edittabOverview.cfm?typename=' + typename + '&objectid=' + objectid + '&method=edit&ref=iframe');		
		};	
		
		
		// show the tray
		$j("body").append("<div id='farcryTray'></div>");	
		$fc.loadTray();
		
		</skin:onReady>
	
		
		</cfoutput>
		
		<farcry:webskinTracer />
	<cfelseif isdefined("request.fc.trayData.profile") 
		AND request.mode.profile
		AND NOT structKeyExists(request.fc, "bAdminTrayRendered") 
		AND NOT request.mode.ajax>
		
		<cfset request.fc.bAdminTrayRendered = true />
		
		<skin:loadJS id="fc-jquery" />
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
	
	<cfif request.mode.livecombine>
		<skin:onReady id="css-updater"><cfoutput>
			(function(){
				if ($fc && $fc.livecombine) return;
				
				var aStylesheets = [];
				var stilltorefresh = 0;
				$fc = $fc || {};
				$fc.livecombine = 1;
				
				$j("link[type=text\\/css]").each(function(){
					var data = {};
					if (!this.id || !this.id.length){
						this.id = "stylesheet-"+this.href.replace(/[^\w\d]+/g,"-");
					}
					data.id = this.id;
					data.href = this.href;
					data.rel = this.rel || "";
					if (data.href.search(/^https?:\/\//i,this.href) > -1 && data.href.replace(/https?:\/\/([^\/]+)\/.*/i,"$1") == document.location.host)
						data.href = data.href.replace(/https?:\/\/[^\/]+(\/.*)/i,"$1");
					aStylesheets.push(data);
				});
				
				function loadStylesheet(data,failedFn){
					var el = $j("##"+data.id);
					var wrap = document.createElement('div');
					wrap.appendChild(el[0].cloneNode(true));
					var oldHTML = wrap.innerHTML;
					var newHTML = oldHTML.replace(/href=(["'])[^"']+(["'])/,"href='"+data.href+"'");
					stilltorefresh += 1;
					var newElement = $j(newHTML).insertAfter(el).each(function(){
						var self = this;
						var sheet = "", cssRules = "";
						
						if ( 'sheet' in self ) {
							sheet = 'sheet'; cssRules = 'cssRules';
						}
						else {
							sheet = 'styleSheet'; cssRules = 'rules';
						}
						
						var checkLoadedID = setInterval(function(){
							try{
								if ( self[sheet] && self[sheet][cssRules].length ){
									console.log("loaded "+data.href);
									el.remove();
									stilltorefresh -= 1;
									clearInterval(checkLoadedID);
									clearTimeout(checkTimeoutID);
									if (stilltorefresh == 0) setTimeout(refreshStylesheets,2000); 
								}
							}
							catch(e) {} finally {}
						},50);
						
						var checkTimeoutID = setTimeout(function(){
							newElement.remove();
							console.log("failed to load "+data.href);
							stilltorefresh -= 1;
							clearInterval(checkLoadedID);
							clearTimeout(checkTimeoutID);
							if (stilltorefresh == 0) setTimeout(refreshStylesheets,2000);
							
							if (failedFn) failedFn(data);
						},2000);
					});
				};
				
				function refreshStylesheets(){
					$j.post("#application.url.webtop#/facade/cssrefresh.cfm",{
						stylesheets:window.JSON.stringify(aStylesheets)
					},function(data){
						for (var i=0;i<data.length;i++){
							if (aStylesheets[i].href != data[i].href) {
								loadStylesheet(data[i],function(data){ alert(data.href); });
								aStylesheets[i].href = data[i].href;
							}
						}
						
						if (stilltorefresh == 0) setTimeout(refreshStylesheets,2000);
					},"json");
				};
				
				setTimeout(refreshStylesheets,2000);
			})();
		</cfoutput></skin:onReady>
	</cfif>
	
</cfif>