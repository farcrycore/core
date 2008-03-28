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

<extjs:iframeDialog />

<skin:htmlHead id="managecontainer"><cfoutput>
	<!-- Container styles / javascript -->
	<style>
		div.containeradmin { background-color: ##ccc; font-weight:bold; padding:5px; color:##000; }
		div.containeradmin a { text-decoration:none; border: 0 none; display: block; padding-right:5px; float:left; color:##000; }
		div.containeradmin a img { border:0 none; }
		div.containeradmin div.type { width: 6.5em; float:left; }
		div.containeradmin div.title { padding-left:5px; padding-right:5px; }
		div.containeradmin div.title a { display:inline; float:none; }
		div.containeradmin div.title a:hover { text-decoration:underline; }
		
		##ajaxindicator { text-align: center; padding: 10px; }
		##ajaxindicator img { border: 0 none; }
		
		div.ruleadmin { background-color: ##ddd; font-weight:bold; padding:5px; color:##000; }
		div.ruleadmin a { text-decoration:none; border: 0 none; display: block; padding-right:5px; float:left; color:##000; }
		div.ruleadmin a img { border:0 none; }
		div.ruleadmin div.type { width: 6.5em; float:left; }
		div.ruleadmin div.title { padding-left:5px; padding-right:5px; }
		div.ruleadmin div.title a { display:inline; float:none; }
		div.ruleadmin div.title a:hover { text-decoration:underline; }
	</style>
	<script type="text/javascript">
		function reloadContainer(objectid,params) {
			var el = Ext.get(objectid.replace(/-/g,''));
			var url = window.location.href.replace(/[&?]updateapp=[^&]*/,'').replace(/\/$/,'/index.cfm');
			
			url += (url.match(/\?/)?'&':'?')+'ajaxcontainer='+objectid;
			
			params = params || {};
			
			for (param in params)
				url += "&"+param+"="+params[param];
			
			el.update("<div id='ajaxindicator'><img src='#application.url.farcry#/images/loading.gif' /></div>");
			Ext.Ajax.request({
				url: url,
				success: function(response){
					el.update(response.responseText);
				}
			});
		}
	</script>
</cfoutput></skin:htmlHead>

<cfoutput>
	<div class="containeradmin">
		<a href="#application.url.farcry#/conjuror/invocation.cfm?objectid=#stObj.objectid#&method=editAddRule" target="_blank" onclick="openScaffoldDialog(this.href+'&iframe','EDIT: #rereplace(stObj.label,"\w{8,8}-\w{4,4}-\w{4,4}-\w{16,16}_","")#',630,600,true,function(){ reloadContainer('#originalcontainer#'); });return false;" title="Add a rule">
			<img src="#application.url.farcry#/images/crystal/22x22/actions/window_new.png" border="0" alt="Add a rule" />
		</a>
		<a href="#application.url.farcry#/conjuror/invocation.cfm?objectid=#originalcontainer#&method=editManageReflection" target="_blank" onclick="openScaffoldDialog(this.href+'&iframe','EDIT: #rereplace(stObj.label,"\w{8,8}-\w{4,4}-\w{4,4}-\w{16,16}_","")#',630,300,true,function(){ reloadContainer('#originalcontainer#'); });return false;" title="Manage reflection">
			<img src="#application.url.farcry#/images/crystal/22x22/actions/editcopy.png" border="0" alt="Manage reflection" />
		</a>
		<a href="#cgi.SCRIPT_NAME#?#cgi.query_string#" onclick="reloadContainer('#originalcontainer#');return false;" title="Refresh container">
			<img src="#application.url.farcry#/images/crystal/22x22/actions/reload.png" border="0" alt="Refresh container" />
		</a>
		<div class="title">
			<div class="type">CONTAINER</div>
			<a id="#replace(stObj.objectid,'-','','ALL')#_title" title="{<cfif arraylen(aProps)>#htmleditformat(arraytolist(aProps,", "))#</cfif>}" href="#application.url.farcry#/conjuror/invocation.cfm?objectid=#stObj.objectid#&method=editAddRule" target="_blank" onclick="openScaffoldDialog(this.href+'&iframe','EDIT: #rereplace(stObj.label,"\w{8,8}-\w{4,4}-\w{4,4}-\w{16,16}_","")#',630,600,true,function(){ reloadContainer('#originalcontainer#'); });return false;">#rereplace(stObj.label,"\w{8,8}-\w{4,4}-\w{4,4}-\w{16,16}_","")#</a>
			<cfif not structisempty(arguments.stParam.original)>
				<span>(Shared container)</span>
			</cfif>
		</div>
	</div>
</cfoutput>

<cfsetting enablecfoutputonly="false" />