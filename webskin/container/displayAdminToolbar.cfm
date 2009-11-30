<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Display container management toolbar --->

<cfimport taglib="/farcry/core/tags/extjs" prefix="extjs" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<cfset aProps = arraynew(1) />
<cfset arrayappend(aProps,"rules=#arraylen(stObj.aRules)#") />

<cfif structisempty(arguments.stParam.original)>
	<cfset originalcontainer = stObj.objectid />
<cfelse>
	<cfset originalcontainer = arguments.stParam.original.objectid />
	<cfset arrayappend(aProps,"reflected=true") />
</cfif>

<!--- Allows the container description to be different to the actual label. Defaults to the label --->
<cfif not structKeyExists(stParam, "desc") OR not len(stparam.desc)>
	<cfset stParam.desc = "#rereplace(stObj.label,'\w{8,8}-\w{4,4}-\w{4,4}-\w{16,16}_','')#" />
</cfif>

<!---<extjs:iframeDialog />--->

<skin:loadJS id="jquery" />
<skin:loadJS id="jquery-ui" />
<skin:loadJS id="farcry-form" />


<skin:loadCSS id="jquery-ui" />


<skin:htmlHead id="containers"><cfoutput>
	<!-- Container styles / javascript -->
	<style>
		div.containeradmin { background-color: ##ccc; font-weight:bold; padding:2px 2px 0; color:##000; padding-bottom:2px; }
		div.containeradmin a { text-decoration:none; border: 0 none; display: block; padding-right:5px; float:left; color:##000; }
		div.containeradmin a img { border:0 none !important; margin: 0 !important; padding: 0 !important; background: transparent none repeat scroll 0 0 !important; }
		div.containeradmin div.type { width: 6.5em; float:left; }
		div.containeradmin div.title { padding:1px 5px; }
		div.containeradmin div.title a { padding-left:5px; display:inline; float:none; }
		div.containeradmin div.title a:hover { text-decoration:underline; }
		
		##ajaxindicator { text-align: center; padding: 10px; }
		##ajaxindicator img { border: 0 none; }
		
		div.ruleadmin { background-color: ##ddd; font-weight:bold; padding:2px 2px 0; color:##000; clear:both; padding-bottom:2px; }
		div.ruleadmin * { vertical-align: middle; }
		div.ruleadmin a { text-decoration:none; border: 0 none; display: block; padding-right:5px; float:left; color:##000; }
		div.ruleadmin a img { clear:right; border:0 none !important; margin:0 !important; padding: 0 !important; background: transparent none repeat scroll 0 0 !important; }
		div.ruleadmin div.type { float:left; }
		div.ruleadmin div.title { padding:1px 5px; }
		div.ruleadmin div.title a { display:inline; float:none; }
		div.ruleadmin div.title a:hover { text-decoration:underline; }
	</style>
</cfoutput></skin:htmlHead>

<skin:onReady id="container-js">
<cfoutput>
$fc.containerAdmin = function(title,url,containerID,containerURL){
	var fcDialog = $j("<div id='" + containerID + "-dialog'><iframe style='width:99%;height:99%;border-width:0px;'></iframe></div>")
	//w = $j(window).width()-50;
	//h = $j(window).height()-50;
	w = $j(window).width() < 800 ? $j(window).width()-50 : 800;
	h = $j(window).height() < 600 ? $j(window).height()-50 : 600;
	
	$j("body").prepend(fcDialog);
	$j(fcDialog).dialog({
		bgiframe: true,
		modal: true,
		closeOnEscape: false,
		title:title,
		width: w,
		height: h,
		close: function(event, ui) {
			$j(fcDialog).remove();
			$fc.reloadContainer(containerID,containerURL);
		}
		
	});
	$j(fcDialog).dialog('open');
	$j('iframe',$j(fcDialog)).attr('src',url);
};		

$fc.reloadContainer = function(containerID,containerURL){

	$j('##' + containerID).html("<div id='ajaxindicator'><img src='#application.url.farcry#/images/loading.gif' /></div>");
	$j.ajax({
	   type: "POST",
	   url: containerURL,
	   cache: false,
	   timeout: 5000,
	   success: function(msg){
	   		$j('##' + containerID).html(msg);
									     	
	   }
	 });
};

</cfoutput>
</skin:onReady>

<cfset containerURL = application.fapi.getLink(objectid="#originalcontainer#", view="displayContainer", urlParameters="ajaxmode=1&designmode=1") />
<cfset containerID = replace(originalcontainer,'-','','ALL') />

<cfoutput>
	<div class="containeradmin" <cfif not structisempty(arguments.stParam.original)>style="background-color:##5B7FB9;"</cfif>>
		
		<!--- ADD A RULE --->
		<a id="con-add-rule-#stobj.objectid#" href="##" title="Add a ruler">
			<img src="#application.url.webtop#/facade/icon.cfm?icon=addrule&size=16" border="0" alt="Add a rule" />
		</a>
		<skin:onReady>
			<cfoutput>
            	$j('##con-add-rule-#stobj.objectid#').click(function() {
					$fc.containerAdmin('Add new rule to container: #jsStringFormat(stParam.desc)#', '#application.url.farcry#/conjuror/invocation.cfm?objectid=#stObj.objectid#&method=editAddRule&container=#originalcontainer#&iframe', '#containerID#', '#containerURL#');
					return false;
				});								
            </cfoutput>
		</skin:onReady>		
		
		
		<!--- MANAGE REFLECTION --->
		<a id="con-manage-reflection-#stobj.objectid#" href="##" title="Manage reflection">
			<img src="#application.url.webtop#/facade/icon.cfm?icon=managereflection&size=16" border="0" alt="Manage reflection" />
		</a>
		
		<skin:onReady>
			<cfoutput>
            	$j('##con-manage-reflection-#stobj.objectid#').click(function() {
					$fc.containerAdmin('Manage Reflection: #jsStringFormat(stParam.desc)#', '#application.url.farcry#/conjuror/invocation.cfm?objectid=#originalcontainer#&method=editManageReflection&iframe', '#containerID#', '#containerURL#');
					return false;
				});								
            </cfoutput>
		</skin:onReady>		
		
		
		<!--- REFRESH CONTAINER --->
		<a id="con-refresh-container-#stobj.objectid#" href="##" title="Refresh container">
			<img src="#application.url.webtop#/facade/icon.cfm?icon=refresh&size=16" border="0" alt="Refresh container" />
		</a>		
		<skin:onReady>
			<cfoutput>
            	$j('##con-refresh-container-#stobj.objectid#').click(function() {
					$fc.reloadContainer('#containerID#','#containerURL#');
					return false;
				});								
            </cfoutput>
		</skin:onReady>	
		
		<!--- ADD A RULE --->
		<div class="title">
			<div class="type">CONTAINER</div>
			<a id="con-add-container-rule-#stobj.objectid#" id="#replace(stObj.objectid,'-','','ALL')#_title" title="{<cfif arraylen(aProps)>#htmleditformat(arraytolist(aProps,", "))#</cfif>}" href="##">#stparam.desc#</a>
			<cfif not structisempty(arguments.stParam.original)>
				<span>(reflected container)</span>
			</cfif>
		</div>
		<skin:onReady>
			<cfoutput>
            	$j('##con-add-container-rule-#stobj.objectid#').click(function() {
					$fc.containerAdmin('Add new rule to container: #jsStringFormat(stParam.desc)#', '#application.url.farcry#/conjuror/invocation.cfm?objectid=#stObj.objectid#&method=editAddRule&container=#originalcontainer#&iframe', '#containerID#', '#containerURL#');
					return false;
				});								
            </cfoutput>
		</skin:onReady>	
	</div>
</cfoutput>

<cfsetting enablecfoutputonly="false" />