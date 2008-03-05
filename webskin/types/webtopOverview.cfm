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

<cfset iDeveloperPermission = application.security.checkPermission(permission="developer") />
	
	
<cfoutput>
<dl class="dl-style1">
	<dt>#application.rb.getResource("objTitleLabel")#</dt>
	<dd><cfif stobj.label NEQ "">
		#stobj.label#<cfelse>
		<i>#application.rb.getResource("undefined")#</i></cfif>
	</dd>
	<dt>#application.rb.getResource("objTypeLabel")#</dt>
	<dd><cfif structKeyExists(application.types[stobj.typename],"displayname")>
		#application.types[stobj.typename].displayname#<cfelse>
		#stobj.typename#</cfif>
	</dd><cfif StructKeyExists(stobj,"lnavidalias")>
	<dt>Navigation Alias(es):</dt>
	<dd>#stobj.lnavidalias#</dd></cfif>
	<dt>#application.rb.getResource("createdByLabel")#</dt>
	<dd>#stobj.createdby#</dd>
	<dt>#application.rb.getResource("dateCreatedLabel")#</dt>
	<dd>#application.thisCalendar.i18nDateFormat(stobj.datetimecreated,session.dmProfile.locale,application.shortF)#</dd>
	<dt>#application.rb.getResource("lockingLabel")#</dt>
	<dd><cfif stobj.locked and stobj.lockedby eq session.security.userid>
			<!--- locked by current user --->
			<cfset tDT=application.thisCalendar.i18nDateTimeFormat(stobj.dateTimeLastUpdated,session.dmProfile.locale,application.mediumF)>
		<span style="color:red">#application.rb.formatRBString("locked",tDT)#</span> <a href="navajo/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#">[#application.rb.getResource("unLock")#]</a>
		<cfelseif stobj.locked>
			<!--- locked by another user --->
			<cfset subS=listToArray('#application.thisCalendar.i18nDateFormat(stobj.dateTimeLastUpdated,session.dmProfile.locale,application.mediumF)#,#stobj.lockedby#')>
		#application.rb.formatRBString("lockedBy",subS)#
			<!--- check if current user is a sysadmin so they can unlock --->
			<cfif iDeveloperPermission eq 1><!--- show link to unlock --->
			<a href="navajo/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#">[#application.rb.getResource("unlockUC")#]</a>
			</cfif><cfelse><!--- no locking --->
			#application.rb.getResource("unlocked")#</cfif>
	</dd>
	<cfif StructKeyExists(stobj, "datetimelastupdated")>
		<dt>#application.rb.getResource("lastUpdatedLabel")#</dt>
		<dd>#application.thisCalendar.i18nDateFormat(stobj.datetimelastupdated,session.dmProfile.locale,application.mediumF)#</dd>
	</cfif>
	<cfif StructKeyExists(stobj, "lastupdatedby")>
		<dt>#application.rb.getResource("lastUpdatedByLabel")#</dt>
		<dd>#stobj.lastupdatedby#</dd>
	</cfif>
	<cfif StructKeyExists(stobj, "status")>	
		<dt>#application.rb.getResource("currentStatusLabel")#</dt>
		<dd>#stobj.status#</dd>
	</cfif>
	<cfif StructKeyExists(stobj, "displaymethod")>		
		<dt>#application.rb.getResource("templateLabel")#</dt>
		<dd>#stobj.displaymethod#</dd>
	</cfif>
	<cfif StructKeyExists(stobj, "teaser")>
		<dt>#application.rb.getResource("teaserLabel")#</dt>
		<dd>#stobj.teaser#</dd>
	</cfif>
	<cfif StructKeyExists(stobj, "thumbnailimagepath") AND stobj.thumbnailimagepath NEQ "">
		<dt>#application.rb.getResource("thumbnailLabel")#</dt>
		<dd><img src="#application.url.webroot#/images/#stobj.thumbnail#"></dd>
	</cfif>
	<cfif iDeveloperPermission eq 1>
		<dt>ObjectID</dt>
		<dd>#stobj.objectid#</dd>
	</cfif>
	</dl>
</cfoutput>

<cfsetting enablecfoutputonly="false">