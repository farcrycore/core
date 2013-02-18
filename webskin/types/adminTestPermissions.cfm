<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Test permissions --->

<cfimport taglib="/farcry/core/tags/admin/" prefix="admin" />
<cfimport taglib="/farcry/core/tags/security/" prefix="sec" />
<cfimport taglib="/farcry/core/tags/formtools/" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />


<cfset stLocal.lRoles = application.security.factory.role.getAllRoles() />
<cfset stLocal.lPermissions = application.security.factory.permission.getAllPermissions(stObj.typename) />

<cfif request.mode.ajax>
	<cfparam name="form.roles" default="" />
	<cfset stLocal.jsonresult = "" />
	<cfloop list="#stLocal.lPermissions#" index="stLocal.thispermission">
		<cfset stLocal.jsonresult = listappend(stLocal.jsonresult,'{ "objectid":"#stLocal.thispermission#", "label":"#application.security.factory.permission.getLabel(stLocal.thispermission)#", "result":#application.security.checkPermission(object=stObj.objectid,permission=stLocal.thispermission,role=form.roles)# }') />
	</cfloop>
	<cfset stLocal.jsonresult = '{ "objectid":"#stObj.objectid#", "roles":"#form.roles#", "results" : [ #stLocal.jsonresult# ] }' />
	<cfcontent type="text/json" variable="#ToBinary( ToBase64( trim(stLocal.jsonresult) ) )#" reset="Yes" />
</cfif>


<admin:header>

<skin:loadJS id="fc-jquery" />
<skin:htmlHead><cfoutput>
	<style>
		table.permissions {}
		table.permissions, tr.permissions, td.permissions { background: transparent none;border:0px solid ##e3e3e3; border-bottom: 1px dotted ##e3e3e3; vertical-align:middle;}
		td.permissions { padding: 3px;  }
	</style>
</cfoutput></skin:htmlHead>
<skin:onReady><script type="text/javascript"><cfoutput>
	$j("input[name=role]").bind("click",function(){
		$j.ajax({
			url			: "#application.fapi.getLink(type=stObj.typename,objectid=stObj.objectid,view='adminTestPermissions',urlParameters='ajaxmode=1')#",
			data		: {
							roles : $j('input[name=role]:checked').map(function() { return $j(this).val(); }).get().join()
						  },
			type		: "POST",
			success		: function(data){
							var $ul = $j("##permission-results").empty();
							for (var i=0;i<data.results.length;i++)
								$ul.append("<tr style='color:" + (data.results[i].result ? "green" : "red") + ";'><td>" + data.results[i].label + "&nbsp;&nbsp;</td><td>" + (data.results[i].result ? "granted" : "denied") + "</td></tr>");
						  },
			dataType	: "json"
		});
	});
</cfoutput></script></skin:onReady>

<sec:CheckPermission error="true" permission="ModifyPermissions">
	<ft:form bUniFormHighlight="false">
		<cfoutput>
			<h3>Test Permissions</h3>
			<div>
				<fieldset class="fieldset">
					<div class="ctrlHolder inlineLabels string ">
						<label class="label" for="fcE689D721B6C9605BDE1D813E4CDA3339title">Select Roles</label>
						<div class="multiField">
							<cfloop list="#stLocal.lRoles#" index="stLocal.thisrole">
								<label>
									<input type="checkbox" name="role" value="#stLocal.thisrole#" />
									#application.security.factory.role.getLabel(stLocal.thisrole)#<br>
								</label>
							</cfloop>
						</div>
						<br style="clear: both;">
					</div>
					
					<div class="ctrlHolder inlineLabels string ">
						<label class="label" for="fcE689D721B6C9605BDE1D813E4CDA3339title">Permissions</label>
						<div class="multiField">
							<table id="permission-results"></table>
						</div>
						<br style="clear: both;">
					</div>
				</fieldset>
			</div>
		</cfoutput>
		<ft:buttonPanel indentForLabel="false">
			<cfoutput><skin:buildLink objectid="#stObj.objectid#" view="adminPermissions">Manage Permissions</skin:buildLink>&nbsp;&nbsp;</cfoutput>
		</ft:buttonPanel>
	</ft:form>
</sec:CheckPermission>

<admin:footer>

<cfsetting enablecfoutputonly="false" />