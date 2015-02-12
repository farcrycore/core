<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Display container management toolbar --->

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!--- Environment Variables --->
<cfparam name="stParam.desc" default="" />
<cfparam name="stParam.originalID" default="#stobj.objectid#" />
<cfparam name="stParam.lRules" default="" />
<cfparam name="stParam.lExcludedRules" default="" />


<!--- Allows the container description to be different to the actual label. Defaults to the label --->
<cfif not structKeyExists(stParam, "desc") OR not len(stparam.desc)>
	<cfset stParam.desc = "#rereplace(stObj.label,'\w{8,8}-\w{4,4}-\w{4,4}-\w{16,16}_','')#" />
</cfif>

<skin:loadJS id="fc-jquery" />
<skin:loadJS id="fc-jquery-ui" />
<skin:loadJS id="farcry-form" />

<skin:loadCSS id="jquery-ui" />
<skin:loadCSS id="fc-bootstrap-tray" />


<skin:htmlHead id="containers"><cfoutput>
	<!-- Container styles / javascript -->
	<style>
		div.containeradmin { background-color: ##c1c1c1; font-weight:bold; padding:2px 2px 0; color:##000000; padding-bottom:2px; margin:3px 0px;font-size:11px;line-height:16px;}
		div.containeradmin a { text-decoration:none; border: 0 none; display: block; padding-right:5px; float:left; color:##000000; }
		div.containeradmin a img { border:0 none !important; margin: 0 !important; padding: 0 !important; background: transparent none repeat scroll 0 0 !important; }
		div.containeradmin div.type { width: 6.5em; float:left; }
		div.containeradmin div.title { padding:1px 5px; }
		div.containeradmin div.title a { padding-left:5px; display:inline; float:none; }
		div.containeradmin div.title a:hover { text-decoration:underline; }
		
		##ajaxindicator { text-align: center; padding: 10px; }
		##ajaxindicator img { border: 0 none; }
		
		div.ruleadmin { background-color: ##e3e3e3; font-weight:bold; padding:2px 2px 0; color:##000000; clear:both; padding-bottom:2px; margin:3px 0px;font-size:11px;line-height:16px;}
		div.ruleadmin * { vertical-align: middle; }
		div.ruleadmin a { text-decoration:none; border: 0 none; display: block; padding-right:5px; float:left; color:##000000; }
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
			color:##000000;
			padding:2px;	
			line-height:16px;
			display:block;
			text-decoration:none;
			border:1px solid transparent;
		} 
		
		div.containeradmin a:hover {
			background-color:##ffffff;
			border:1px solid ##000000;
		} 
		
		div.ruleadmin a,
		div.ruleadmin a:link,
		div.ruleadmin a:visited,
		div.ruleadmin a:hover,
		div.ruleadmin a:active {	
			color:##000000;
			padding:2px;	
			line-height:16px;
			display:block;
			text-decoration:none;
			border:1px solid transparent;
		} 
		
		div.ruleadmin a:hover {
			background-color:##ffffff;
			border:1px solid ##000000;
		} 
	</style>
</cfoutput></skin:htmlHead>

<skin:onReady id="container-js">
<cfoutput>
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
$j('body').on(
	"click",
	'a.con-refresh',
	function( event ){
		$fc.reloadContainer(
			$j(this).attr('con:id'), 
			$j(this).attr('href')
		);
		return false;
	}
);	
$j('body').on(
	"click",
	'a.con-delete',
	function( event ){
		if (confirm('Are you sure you want to DELETE this rule?')) {
			$fc.reloadContainer(
				$j(this).attr('con:id'), 
				$j(this).attr('href')
			);
		}
		return false;
	}
);
$j('body').on(
	"click",
	'a.con-admin',
	function( event ){
		$fc.objectAdminTrayAction($j(this).attr('rule:title'), $j(this).attr('href'), null, null, {
			onHidden: function() {
				$fc.reloadContainer($j(this).attr('con:id'),$j(this).attr('con:url'));
			}
		});

		return false;
	}
);			
</cfoutput>
</skin:onReady>

<cfset containerURL = application.fapi.getLink(type="container",objectid="#stobj.objectid#", view="displayContainer", urlParameters="ajaxmode=1&designmode=1") />
<cfset containerID = replace(stParam.originalID,'-','','ALL') />

<cfoutput>
	<div class="containeradmin clearfix" <cfif stobj.bShared>style="background-color:##8e44ad;"</cfif>>
		
		
		<!--- Container Label --->
		<div style="float:left;padding:2px;">
			<cfif stobj.bShared>
				<span style="font-size:10px;">REFLECTED CONTAINER:</span>
			<cfelse>
				<span style="font-size:10px;">CONTAINER:</span>
			</cfif>
			#stparam.desc#
		</div>
		
		<div style="float:right;">
			<!--- ADD A RULE --->
			<a title="Add new rule to container"
				class="con-admin con-add-rule" 
				href="#application.url.farcry#/conjuror/invocation.cfm?objectid=#stObj.objectid#&typename=#stObj.typename#&lRules=#stParam.lRules#&lExcludedRules=#stParam.lExcludedRules#&method=editAddRule&iframe" 
				con:id="#containerID#"
				con:url="#containerURL#"
				rule:title="#stParam.desc#: Add Rule To Container">
				
				<span class="ui-icon ui-icon-plusthick" style="float:left;">&nbsp;</span>
			</a>	
			<skin:toolTip selector=".con-add-rule">Add a new rule into this container.</skin:toolTip>
			
			<!--- MANAGE REFLECTION --->
			<a title="Manage Reflection"
				class="con-admin con-manage-reflection" 
				href="#application.url.farcry#/conjuror/invocation.cfm?objectid=#stParam.originalID#&typename=container&method=editManageReflection&iframe" 
				con:id="#containerID#"
				con:url="#containerURL#"
				rule:title="#stParam.desc#: Manage Reflection">
				
				<span class="ui-icon ui-icon-copy" style="float:left;">&nbsp;</span>
			</a>
			<skin:toolTip selector=".con-manage-reflection">Set this container to use a reflection.<br>Reflections are containers that are centrally managed from the webtop.</skin:toolTip>
			
			<!--- REFRESH CONTAINER --->
	
			<a class="con-refresh con-refresh-container" href="#containerURL#" con:id="#containerID#" title="Refresh container">
				<span class="ui-icon ui-icon-refresh" style="float:left;">&nbsp;</span>
			</a>
			<skin:toolTip selector=".con-refresh-container">Refresh the contents of this container.</skin:toolTip>
		</div>
		<br style="clear:both;" />
	</div>
</cfoutput>

<cfsetting enablecfoutputonly="false" />