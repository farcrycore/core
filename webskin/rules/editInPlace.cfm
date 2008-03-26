<cfsetting enablecfoutputonly="true" />
<!--- @@displayname: Edit rule and update page on close --->

<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />

<cfif not structkeyexists(application.stCOAPI[stObj.typename],"displayname")>
	<admin:header title="EDIT: #application.stCOAPI[stObj.typename].displayname#" />
<cfelse>
	<admin:header title="EDIT: #stObj.typename#" />
</cfif>

<ft:processform action="Save">
	<cfoutput>
		<script type="text/javascript">
			<cfif structkeyexists(url,"iframe")>
				parent.location.reload();
			<cfelse>
				window.opener.location.reload();
			</cfif>
		</script>
	</cfoutput>
</ft:processform>

<ft:processform action="Cancel">
	<cfoutput>
		<script type="text/javascript">
			<cfif structkeyexists(url,"iframe")>
				parent.closeDialog();
			<cfelse>
				window.close();
			</cfif>
		</script>
	</cfoutput>
</ft:processform>

<cfoutput>
	<div id="scrollcontrol">
		<h1>EDIT: <cfif not structkeyexists(application.stCOAPI[stObj.typename],"displayname")>#application.stCOAPI[stObj.typename].displayname#<cfelse>#stObj.typename#</cfif></h1>
		#this.update(objectid=stObj.objectid)#
</cfoutput>

<cfoutput>
	</div>
</cfoutput>

<admin:footer />

<cfsetting enablecfoutputonly="false" />