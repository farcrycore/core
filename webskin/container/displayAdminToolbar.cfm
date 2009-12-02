<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Display container management toolbar --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!--- Environment Variables --->
<cfparam name="stParam.desc" default="" />
<cfparam name="stParam.originalID" default="#stobj.objectid#" />


<!--- Allows the container description to be different to the actual label. Defaults to the label --->
<cfif not structKeyExists(stParam, "desc") OR not len(stparam.desc)>
	<cfset stParam.desc = "#rereplace(stObj.label,'\w{8,8}-\w{4,4}-\w{4,4}-\w{16,16}_','')#" />
</cfif>

<skin:loadJS id="jquery" />
<skin:loadJS id="jquery-ui" />
<skin:loadJS id="farcry-form" />

<skin:loadCSS id="jquery-ui" />


<skin:htmlHead id="containers"><cfoutput>
	<!-- Container styles / javascript -->
	<style>
		div.containeradmin { background-color: ##ccc; font-weight:bold; padding:2px 2px 0; color:##000; padding-bottom:2px; margin:3px 0px;font-size:11px;line-height:16px;}
		div.containeradmin a { text-decoration:none; border: 0 none; display: block; padding-right:5px; float:left; color:##000; }
		div.containeradmin a img { border:0 none !important; margin: 0 !important; padding: 0 !important; background: transparent none repeat scroll 0 0 !important; }
		div.containeradmin div.type { width: 6.5em; float:left; }
		div.containeradmin div.title { padding:1px 5px; }
		div.containeradmin div.title a { padding-left:5px; display:inline; float:none; }
		div.containeradmin div.title a:hover { text-decoration:underline; }
		
		##ajaxindicator { text-align: center; padding: 10px; }
		##ajaxindicator img { border: 0 none; }
		
		div.ruleadmin { background-color: ##ddd; font-weight:bold; padding:2px 2px 0; color:##000; clear:both; padding-bottom:2px; margin:3px 0px;font-size:11px;line-height:16px;}
		div.ruleadmin * { vertical-align: middle; }
		div.ruleadmin a { text-decoration:none; border: 0 none; display: block; padding-right:5px; float:left; color:##000; }
		div.ruleadmin a img { clear:right; border:0 none !important; margin:0 !important; padding: 0 !important; background: transparent none repeat scroll 0 0 !important; }
		div.ruleadmin div.type { float:left; }
		div.ruleadmin div.title { padding:1px 5px; }
		div.ruleadmin div.title a { display:inline; float:none; }
		div.ruleadmin div.title a:hover { text-decoration:underline; }
		
		div.containeradmin a,
		div.containeradmin a:link,
		div.containeradmin a:visited,
		div.containeradmin a:hover,
		div.containeradmin a:active {	
			color:##000;
			padding:2px;	
			line-height:16px;
			display:block;
			text-decoration:none;
			border:1px solid transparent;
		} 
		
		div.containeradmin a:hover {
			background-color:##ffffff;
			border:1px solid ##B5B5B5;
		} 
		
		div.ruleadmin a,
		div.ruleadmin a:link,
		div.ruleadmin a:visited,
		div.ruleadmin a:hover,
		div.ruleadmin a:active {	
			color:##000;
			padding:2px;	
			line-height:16px;
			display:block;
			text-decoration:none;
			border:1px solid transparent;
		} 
		
		div.ruleadmin a:hover {
			background-color:##ffffff;
			border:1px solid ##B5B5B5;
		} 
	</style>
</cfoutput></skin:htmlHead>

<skin:onReady id="container-js">
<cfoutput>
$fc.containerAdmin = function(title,url,containerID,containerURL){
	var fcDialog = $j("<div id='" + containerID + "-dialog'><iframe style='width:99%;height:99%;border-width:0px;'></iframe></div>")
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

<cfset containerURL = application.fapi.getLink(objectid="#stobj.objectid#", view="displayContainer", urlParameters="ajaxmode=1&designmode=1") />
<cfset containerID = replace(stobj.objectid,'-','','ALL') />

<cfoutput>
	<div class="containeradmin" <cfif stParam.originalID NEQ stobj.objectid>style="background-color:##5B7FB9;"</cfif>>
		
		
		<!--- Container Label --->
		<div style="float:left;padding:2px;">
			<cfif stParam.originalID NEQ stobj.objectid>
				<span style="font-size:10px;">REFLECTED CONTAINER:</span>
			<cfelse>
				<span style="font-size:10px;">CONTAINER:</span>
			</cfif>
			#stparam.desc#
		</div>
		
		<div style="float:right;">
			<!--- ADD A RULE --->
			<a id="con-add-rule-#stobj.objectid#" href="#application.url.farcry#/conjuror/invocation.cfm?objectid=#stObj.objectid#&method=editAddRule&iframe" title="Add a rule">
				<span class="ui-icon ui-icon-plusthick" style="float:left;">&nbsp;</span>
			</a>
			<skin:onReady>
				<cfoutput>
	            	$j('##con-add-rule-#stobj.objectid#').click(function() {
						$fc.containerAdmin('Add new rule to container: #jsStringFormat(stParam.desc)#', this.href, '#containerID#', '#containerURL#');
						return false;
					});								
	            </cfoutput>
			</skin:onReady>		
			<skin:toolTip id="con-add-rule-#stobj.objectid#">Add a new rule into this container.</skin:toolTip>
			
			<!--- MANAGE REFLECTION --->
			<a id="con-manage-reflection-#stobj.objectid#" href="##" title="Manage reflection">
				<span class="ui-icon ui-icon-copy" style="float:left;">&nbsp;</span>
			</a>		
			<skin:onReady>
				<cfoutput>
	            	$j('##con-manage-reflection-#stobj.objectid#').click(function() {
						$fc.containerAdmin('Manage Reflection: #jsStringFormat(stParam.desc)#', '#application.url.farcry#/conjuror/invocation.cfm?objectid=#stParam.originalID#&method=editManageReflection&iframe', '#containerID#', '#containerURL#');
						return false;
					});								
	            </cfoutput>
			</skin:onReady>		
			<skin:toolTip id="con-manage-reflection-#stobj.objectid#">Set this container to use a reflection. Reflections are containers that are centrally managed from the webtop.</skin:toolTip>
			
			<!--- REFRESH CONTAINER --->
	
			<a id="con-refresh-container-#stobj.objectid#" href="##" title="Refresh container">
				<span class="ui-icon ui-icon-refresh" style="float:left;">&nbsp;</span>
			</a>
			<skin:onReady>
				<cfoutput>
	            	$j('##con-refresh-container-#stobj.objectid#').click(function() {
						$fc.reloadContainer('#containerID#','#containerURL#');
						return false;
					});								
	            </cfoutput>
			</skin:onReady>	
			<skin:toolTip id="con-refresh-container-#stobj.objectid#">Refresh the contents of this container.</skin:toolTip>
		</div>
		<br style="clear:both;" />
	</div>
</cfoutput>

<cfsetting enablecfoutputonly="false" />