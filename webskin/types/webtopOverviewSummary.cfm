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
		
	<cfoutput><img src="#application.stCOAPI[stObj.typename].icon#" alt="alt text" class="icon" style="float: right; padding: 10px;" /></cfoutput>
	
	<cfoutput>
	<dl class="dl-style1" style="padding: 10px;">
		<dt>#apapplication.rb.getResource("objTitleLabel")#</dt>
		<dd><cfif stobj.label NEQ "">
			#stobj.label#<cfelse>
			<i>#apapplication.rb.getResource("undefined")#</i></cfif>
		</dd>
		<dt>#apapplication.rb.getResource("objTypeLabel")#</dt>
		<dd><cfif structKeyExists(application.types[stobj.typename],"displayname")>
			#application.types[stobj.typename].displayname#<cfelse>
			#stobj.typename#</cfif>
		</dd><cfif StructKeyExists(stobj,"lnavidalias")>
		<dt>Navigation Alias(es):</dt>
		<dd>#stobj.lnavidalias#</dd></cfif>
		<dt>#apapplication.rb.getResource("createdByLabel")#</dt>
		<dd>#stobj.createdby#</dd>
		<dt>#apapplication.rb.getResource("dateCreatedLabel")#</dt>
		<dd>#application.thisCalendar.i18nDateFormat(stobj.datetimecreated,session.dmProfile.locale,application.shortF)#</dd>
		<dt>#apapplication.rb.getResource("lockingLabel")#</dt>
		<dd><cfif stobj.locked and stobj.lockedby eq session.security.userid>
				<!--- locked by current user --->
				<cfset tDT=application.thisCalendar.i18nDateTimeFormat(stobj.dateTimeLastUpdated,session.dmProfile.locale,application.mediumF)>
			<span style="color:red">#application.rb.formatRBString("locked",tDT)#</span> <a href="navajo/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#">[#apapplication.rb.getResource("unLock")#]</a>
			<cfelseif stobj.locked>
				<!--- locked by another user --->
				<cfset subS=listToArray('#application.thisCalendar.i18nDateFormat(stobj.dateTimeLastUpdated,session.dmProfile.locale,application.mediumF)#,#stobj.lockedby#')>
			#application.rb.formatRBString("lockedBy",subS)#
				<!--- check if current user is a sysadmin so they can unlock --->
				<cfif iDeveloperPermission eq 1><!--- show link to unlock --->
				<a href="navajo/unlock.cfm?objectid=#stobj.objectid#&typename=#stobj.typename#">[#apapplication.rb.getResource("unlockUC")#]</a>
				</cfif><cfelse><!--- no locking --->
				#apapplication.rb.getResource("unlocked")#</cfif>
		</dd>
		<cfif StructKeyExists(stobj, "datetimelastupdated")>
			<dt>#apapplication.rb.getResource("lastUpdatedLabel")#</dt>
			<dd>#application.thisCalendar.i18nDateFormat(stobj.datetimelastupdated,session.dmProfile.locale,application.mediumF)#</dd>
		</cfif>
		<cfif StructKeyExists(stobj, "lastupdatedby")>
			<dt>#apapplication.rb.getResource("lastUpdatedByLabel")#</dt>
			<dd>#stobj.lastupdatedby#</dd>
		</cfif>
		<cfif StructKeyExists(stobj, "status")>	
			<dt>#apapplication.rb.getResource("currentStatusLabel")#</dt>
			<dd>#stobj.status#</dd>
		</cfif>
		<cfif StructKeyExists(stobj, "displaymethod")>		
			<dt>#apapplication.rb.getResource("templateLabel")#</dt>
			<dd>#stobj.displaymethod#</dd>
		</cfif>
		<cfif StructKeyExists(stobj, "teaser")>
			<dt>#apapplication.rb.getResource("teaserLabel")#</dt>
			<dd>#stobj.teaser#</dd>
		</cfif>
		<cfif StructKeyExists(stobj, "thumbnailimagepath") AND stobj.thumbnailimagepath NEQ "">
			<dt>#apapplication.rb.getResource("thumbnailLabel")#</dt>
			<dd><img src="#application.url.webroot#/images/#stobj.thumbnail#"></dd>
		</cfif>
		<cfif iDeveloperPermission eq 1>
			<dt>ObjectID</dt>
			<dd>#stobj.objectid#</dd>
		</cfif>
		</dl>
	</cfoutput>


<cfsetting enablecfoutputonly="false">