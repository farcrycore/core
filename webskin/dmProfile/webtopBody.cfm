<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 2002-2013, http://www.daemon.com.au --->

<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />
<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />

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


<ft:processform action="Manage multi-factor">
	<cfset stProfile = application.fapi.getContentObject(typename="dmProfile", objectid="#form.selectedobjectid#") />
	<cfset oUD = structKeyExists(application.security.userdirectories, stProfile.userdirectory) ? application.security.userdirectories[stProfile.userdirectory] : "" />

	<cfif not isObject(oUD) or not oUD.providesMFA()>
		<!--- directory-agnostic gate: the owning UD must implement the optional MFA contract --->
		<skin:bubble title="Error" message="This user's directory does not support multi-factor authentication." tags="security,error" />
	<cfelseif application.fapi.hasWebskin("dmProfile", "editMFAReset#stProfile.userdirectory#")>
		<!--- the directory ships its own admin reset surface; hand it the profile (same per-UD dispatch as Impersonate below) --->
		<skin:onReady><cfoutput>
			$fc.openDialog('Manage multi-factor','?id=#encodeForJavaScript(url.id)#&type=dmProfile&objectid=#stProfile.objectid#&view=webtopPageModal&bodyView=editMFAReset#stProfile.userdirectory#');
		</cfoutput></skin:onReady>
	<cfelseif stProfile.userdirectory eq "CLIENTUD">
		<!--- CLIENTUD default: the built-in farUser-based reset modal --->
		<cfset userID = application.factory.oUtils.listSlice(stProfile.username,1,-2,"_") />
		<cfset stUser = createobject("component",application.stCOAPI.farUser.packagepath).getByUserID(userID) />

		<cfif structIsEmpty(stUser)>
			<skin:bubble title="Error" message="This profile does not have a valid user attached." tags="security,error" />
		<cfelse>
			<skin:onReady><cfoutput>
				$fc.openDialog('Manage multi-factor','?id=#encodeForJavaScript(url.id)#&type=farUser&objectid=#stUser.objectid#&view=webtopPageModal&bodyView=editMFAReset');
			</cfoutput></skin:onReady>
		</cfif>
	<cfelse>
		<!--- a UD that reports providesMFA() but has not shipped an admin reset surface here - it manages MFA on its own admin pages --->
		<skin:bubble title="Error" message="This directory manages multi-factor authentication on its own admin surface." tags="security,info" />
	</cfif>
</ft:processform>


<ft:processform action="Preview Webtop Security">	
	<cfset stProfile = application.fapi.getContentObject(typename="dmProfile", objectid="#form.selectedobjectid#") />

	<cfif stProfile.userdirectory eq "CLIENTUD">
		<skin:onReady><cfoutput>
			$fc.openDialog('Preview Webtop Security', '?id=#url.id#&type=dmProfile&objectid=#stProfile.objectid#&view=webtopPageModal&bodyView=webtopBodyWebtopSecurity');
		</cfoutput></skin:onReady>
	<cfelse>
		<skin:bubble title="Error" message="'Preview Webtop Security' only applies to CLIENTUD users." tags="security,error" />
	</cfif>
</ft:processform>


<ft:processform action="Impersonate User">	
	<cfset stProfile = application.fapi.getContentObject(typename="dmProfile", objectid="#form.selectedobjectid#") />
	<cfset impersonator = structKeyExists(session,"impersonator") ? session.impersonator : session.dmProfile.username />

	<cfif not application.security.checkPermission(permission="impersonation")>
		<cfif application.fapi.getContentType("farPermission").permissionExists("impersonation")>
			<skin:bubble title="Error" message="You do not have permission to impersonate other users" tags="security,error" />
		<cfelse>
			<skin:bubble title="Error" message="The 'impersonation' permission has not been set up" tags="security,error" />
		</cfif>
	<cfelseif not len(stProfile.username)>
		<skin:bubble title="Error" message="Invalid user" tags="security,error" />
	<cfelseif application.fapi.hasWebskin("dmProfile", "webtopBodyImpersonate#stProfile.userdirectory#")>
		<!--- If the directory specifies a webskin, presumably for configurating the impersonation, use that --->
		<skin:onReady><cfoutput>
			$fc.openDialog('Preview Webtop Security', '?id=#url.id#&type=dmProfile&objectid=#stProfile.objectid#&view=webtopPageModal&bodyView=webtopBodyImpersonate#stProfile.userdirectory#');
		</cfoutput></skin:onReady>
	<cfelse>
		<!--- Otherwise, assume that the vanilla user directory functions will be sufficient --->

		<!--- Create a new session --->
		<cfset application.fc.lib.session.switchSession() />

		<!--- Log in user --->
		<cfset session.impersonator = impersonator />
		<cfset application.security.login(listDeleteAt(stProfile.username, listLen(stProfile.username, "_"), "_"), stProfile.userdirectory) />

		<!--- Redirect browser based on webtop access --->
		<cfif application.security.checkPermission(permission="admin")>
			<cflocation url="#application.url.webtop#" addtoken="false" />
		<cfelse>
			<cflocation url="#application.url.webroot#/" addtoken="false" />
		</cfif>
	</cfif>
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

<cfif application.security.checkPermission(permission="impersonation")>
	<cfset lCustomActions = "Change password,Preview Webtop Security,Impersonate User" />
<cfelse>
	<cfset lCustomActions = "Change password,Preview Webtop Security" />
</cfif>

<!--- offer the MFA reset action only when multi-factor is switched on for the site --->
<cfif application.fapi.getConfig("security","mfaMode","off") neq "off">
	<cfset lCustomActions = listInsertAt(lCustomActions, 2, "Manage multi-factor") /><!--- slot directly after "Change password" --->
</cfif>

<ft:objectadmin
	typename="dmProfile"
	title="User Administration"
	columnList="avatar,username,userstatus,userdirectory,firstname,lastname,emailAddress" 
	sortableColumns="username,userstatus"
	lFilterFields="username,firstname,lastname,emailAddress"
	lCustomActions="#lCustomActions#"
	lButtons="#lButtons#"
	bPreviewCol="false"
	sqlorderby="username asc" 
 />

<cfsetting enablecfoutputonly="false">