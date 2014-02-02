<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 2002-2013, http://www.daemon.com.au --->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!--- 
 // process form 
--------------------------------------------------------------------------------->
<ft:processform action="Change password">
	<cfset stProfile = createobject("component",application.stCOAPI.dmProfile.packagepath).getData(form.selectedobjectid) />
	
	<cfif stProfile.userdirectory eq "CLIENTUD">
		<cfset userID = application.factory.oUtils.listSlice(stProfile.username,1,-2,"_") />
		<cfset stUser = createobject("component",application.stCOAPI.farUser.packagepath).getByUserID(userID) />
		
		<cfif structIsEmpty(stUser)>
			<skin:bubble title="Error" message="This profile does not have a valid user attached. Please edit this profile to create a username/password." tags="security,error" />
		<cfelse>

			<skin:onReady>
			<cfoutput>
				$fc.openDialog('Edit Password', '?id=#url.id#&type=farUser&objectid=#stUser.objectid#&view=webtopPageModal&bodyView=editPassword');
			</cfoutput>
			</skin:onReady>
		</cfif>
		
	<cfelse>
		<skin:bubble title="Error" message="'Change password' only applies to CLIENTUD users." tags="security,error" />
	</cfif>
</ft:processform>


<ft:processform action="Preview Webtop Security">	

	<cfset stProfile = application.fapi.getContentObject(typename="dmProfile", objectid="#form.selectedobjectid#") />

	<skin:onReady>
	<cfoutput>
		$fc.openDialog('Preview Webtop Security', '?id=#url.id#&type=dmProfile&objectid=#stProfile.objectid#&view=webtopPageModal&bodyView=webtopBodyWebtopSecurity');
	</cfoutput>
	</skin:onReady>
</ft:processform>


<!--- 
 // view: objectadmin grid 
--------------------------------------------------------------------------------->
<!--- ONLY ALLOW DELETE BUTTON FOR PERMISSION NAME dmProfileDelete --->
<cfif application.fapi.checkTypePermission(typename="dmProfile", permission="dmProfileDelete")>
	<cfset lButtons = "Add,Delete,Properties,Unlock" />
<cfelse>
	<cfset lButtons = "Add,Properties,Unlock" />
</cfif>

<ft:objectadmin
	typename="dmProfile"
	title="User Administration"
	columnList="avatar,username,userstatus,userdirectory,firstname,lastname,emailAddress" 
	sortableColumns="username,userstatus"
	lFilterFields="username,firstname,lastname,emailAddress"
	lCustomActions="Change password,Preview Webtop Security"
	lButtons="#lButtons#"
	bPreviewCol="false"
	sqlorderby="username asc" 
 />

<cfsetting enablecfoutputonly="false">