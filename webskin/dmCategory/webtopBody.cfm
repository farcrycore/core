<cfsetting enablecfoutputonly="true" />

<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<cfset stArgs = structnew() />
<cfset stArgs.typename = "dmCategory" />
<cfset stArgs.stObject = structnew() />
<cfset stArgs.stObject.objectid = createuuid() />
<cfset stArsg.stObject.typename = "dmCategory" />
<cfset stArgs.stMetadata = structnew() />
<cfset stArgs.stMetadata.name = "categorytree" />
<cfset stArgs.stMetadata.type = "string" />
<cfset stArgs.stMetadata.ftType = "category" />
<cfset stArgs.stMetadata.value = "" />
<cfset stArgs.stMetadata.ftAlias = "root" />
<cfset stArgs.stMetadata.ftRenderType = "jquery" />
<cfset stArgs.stMetadata.ftHideRootNode = "false" />
<cfset stArgs.stMetadata.ftSelectMultiple = false />
<cfset stArgs.stMetadata.ftJQueryAllowEdit = true />
<cfset stArgs.stMetadata.ftJQueryAllowAdd = true />
<cfset stArgs.stMetadata.ftJQueryAllowRemove = true />
<cfset stArgs.stMetadata.ftJQueryAllowMove = true />
<cfset stArgs.stMetadata.ftJQueryAllowSelect = false />
<cfset stArgs.stMetadata.ftJQueryQuickEdit = true />
<cfset stArgs.stMetadata.ftJQueryOnEdit = "window.editingtree = this; $j(this).tree('selectNode',node); var catiframe = $j('<iframe width=\'100%\' height=\'700px\' src=\'#application.url.farcry#/conjuror/invocation.cfm?objectid='+node.id+'&typename=dmCategory&method=edit&ref=refresh&module=\' scrolling=\'auto\' frameborder=\'0\'></iframe>').appendTo($j('##cateditframe').html('')); var loaded = setInterval(function(){ if (catiframe[0].contentWindow.document.readyState !== 'complete') return false; clearInterval(loaded); $j(catiframe[0].contentDocument).delegate('form','submit',function(){ $j('.farcry-main').block(); }); },50);" />
<cfset stArgs.stMetadata.ftJQueryOnAdd = "window.editingtree = this; $j(this).tree('selectNode',node); var catiframe = $j('<iframe width=\'100%\' height=\'700px\' src=\'#application.url.farcry#/conjuror/invocation.cfm?objectid='+newid+'&typename=dmCategory&method=edit&ref=refresh&module=\' scrolling=\'auto\' frameborder=\'0\'></iframe>').appendTo($j('##cateditframe').html('')); var loaded = setInterval(function(){ if (catiframe[0].contentWindow.document.readyState !== 'complete') return false; clearInterval(loaded); $j(catiframe[0].contentDocument).delegate('form','submit',function(){ $j('.farcry-main').block(); }); },50);" />
<cfset stArgs.stMetadata.ftJQueryOnRemove = "" />
<cfset stArgs.stMetadata.ftJQueryOnMove = "" />
<cfset stArgs.stMetadata.ftJQueryOnSelect = "if (selected) $j(this).closest('li').addClass('selected'); else $j(this).closest('li').removeClass('selected');" />
<cfset stArgs.stMetadata.ftJQueryOnUpdateStart = "$j('.farcry-main').block();" />
<cfset stArgs.stMetadata.ftJQueryOnUpdateFinish = "$j('.farcry-main').unblock();" />
<cfset stArgs.stMetadata.ftJQueryOnUpdateError = "if (code === 'treechanged') $j('##bubbles').prepend('<div class=\'alert alert-error\'>'+error+' <a href=\'##\' class=\'refresh-tree\'>Refresh tree?</a></div>'); else $j('##bubbles').prepend('<div class=\'error\'>'+error+'</div>');" />
<cfset stArgs.stMetadata.ftJQueryVisibleInputs = false />
<cfset stArgs.stMetadata.ftEditableProperties = "" />
<cfset stArgs.stMetadata.ftJQueryURL = "#application.url.webtop#/index.cfm?id=#url.id#" />
<cfset stArgs.fieldname = "categorytree" />

<cfif structkeyexists(url,"node") or structkeyexists(url,"move") or structkeyexists(url,"remove") or structkeyexists(url,"add")>
	<cfcontent reset="true" type="text/json" variable="#ToBinary( ToBase64( application.formtools.category.oFactory.ajax(argumentCollection=stArgs) ) )#" />
<cfelse>
	<skin:loadJS id="fc-jquery" />
	<skin:htmlHead><cfoutput>
		<script type="text/javascript">
			function updateObject(objectid){
				if (window.editingtree){
					$fc.tree.updateObject($j(window.editingtree),objectid);
				}
			}
			
			$j(".farcry-main").delegate(".alert-error .refresh-tree","click",function(){
				var $tree = $j("##categorytree-tree").tree();
				$fc.tree.reloadBranch($tree,application.fapi.getCatID("root"),true);
				$(this).closest(".error").remove();
			});
		</script>
	</cfoutput></skin:htmlHead>
	
	<cfoutput>
		<h1><admin:resource key="">Manage Keywords</admin:resource></h1>
		<table width="100%">
			<tr>
				<td style="width:310px;padding-right:20px;border-right:2px solid ##eee;margin-right:10px" valign="top">
					#application.formtools.category.oFactory.edit(argumentCollection=stArgs)#
				</td>
				<td id="cateditframe"></td>
			</tr>
		</table>
	</cfoutput>
</cfif>

<cfsetting enablecfoutputonly="false" />