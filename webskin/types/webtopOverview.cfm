<cfsetting enablecfoutputonly="true">
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
<!--- @@License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php --->
<!--- @@displayname: Webtop Overview --->
<!--- @@description: The default webskin to use to render the object's summary in the webtop overview screen  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->


<!------------------ 
FARCRY INCLUDE FILES
 ------------------>

<!------------------ 
START WEBSKIN
 ------------------>

<cfset iDeveloperPermission = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="developer") />
	
	
<cfoutput>
<dl class="dl-style1">
	<dt>#application.adminBundle[session.dmProfile.locale].objTitleLabel#</dt>
	<dd><cfif stobj.label NEQ "">
		#stobj.label#<cfelse>
		<i>#application.adminBundle[session.dmProfile.locale].undefined#</i></cfif>
	</dd>
	<dt>#application.adminBundle[session.dmProfile.locale].objTypeLabel#</dt>
	<dd><cfif structKeyExists(application.types[stobj.typename],"displayname")>
		#application.types[stobj.typename].displayname#<cfelse>
		#stobj.typename#</cfif>
	</dd><cfif StructKeyExists(stobj,"lnavidalias")>
	<dt>Navigation Alias(es):</dt>
	<dd>#stobj.lnavidalias#</dd></cfif>
	<dt>#application.adminBundle[session.dmProfile.locale].createdByLabel#</dt>
	<dd>#stobj.createdby#</dd>
	<dt>#application.adminBundle[session.dmProfile.locale].dateCreatedLabel#</dt>
	<dd>#application.thisCalendar.i18nDateFormat(stobj.datetimecreated,session.dmProfile.locale,application.shortF)#</dd>
	<dt>#application.adminBundle[session.dmProfile.locale].lockingLabel#</dt>
	<dd><cfif stobj.locked and stobj.lockedby eq "#session.dmSec.authentication.userlogin#_#session.dmSec.authentication.userDirectory#">
			<!--- locked by current user --->
			<cfset tDT=application.thisCalendar.i18nDateTimeFormat(stobj.dateTimeLastUpdated,session.dmProfile.locale,application.mediumF)>
		<span style="color:red">#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].locked,tDT)#</span> <a href="navajo/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#">[#application.adminBundle[session.dmProfile.locale].unLock#]</a>
		<cfelseif stobj.locked>
			<!--- locked by another user --->
			<cfset subS=listToArray('#application.thisCalendar.i18nDateFormat(stobj.dateTimeLastUpdated,session.dmProfile.locale,application.mediumF)#,#stobj.lockedby#')>
		#application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].lockedBy,subS)#
			<!--- check if current user is a sysadmin so they can unlock --->
			<cfif iDeveloperPermission eq 1><!--- show link to unlock --->
			<a href="navajo/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#">[#application.adminBundle[session.dmProfile.locale].unlockUC#]</a>
			</cfif><cfelse><!--- no locking --->
			#application.adminBundle[session.dmProfile.locale].unlocked#</cfif>
	</dd>
	<cfif StructKeyExists(stobj, "datetimelastupdated")>
		<dt>#application.adminBundle[session.dmProfile.locale].lastUpdatedLabel#</dt>
		<dd>#application.thisCalendar.i18nDateFormat(stobj.datetimelastupdated,session.dmProfile.locale,application.mediumF)#</dd>
	</cfif>
	<cfif StructKeyExists(stobj, "lastupdatedby")>
		<dt>#application.adminBundle[session.dmProfile.locale].lastUpdatedByLabel#</dt>
		<dd>#stobj.lastupdatedby#</dd>
	</cfif>
	<cfif StructKeyExists(stobj, "status")>	
		<dt>#application.adminBundle[session.dmProfile.locale].currentStatusLabel#</dt>
		<dd>#stobj.status#</dd>
	</cfif>
	<cfif StructKeyExists(stobj, "displaymethod")>		
		<dt>#application.adminBundle[session.dmProfile.locale].templateLabel#</dt>
		<dd>#stobj.displaymethod#</dd>
	</cfif>
	<cfif StructKeyExists(stobj, "teaser")>
		<dt>#application.adminBundle[session.dmProfile.locale].teaserLabel#</dt>
		<dd>#stobj.teaser#</dd>
	</cfif>
	<cfif StructKeyExists(stobj, "thumbnailimagepath") AND stobj.thumbnailimagepath NEQ "">
		<dt>#application.adminBundle[session.dmProfile.locale].thumbnailLabel#</dt>
		<dd><img src="#application.url.webroot#/images/#stobj.thumbnail#"></dd>
	</cfif>
	<cfif iDeveloperPermission eq 1>
		<dt>ObjectID</dt>
		<dd>#stobj.objectid#</dd>
	</cfif>
	</dl>
</cfoutput>

<cfsetting enablecfoutputonly="false">