<!--- 
|| BEGIN DAEMONDOC||

|| Copyright ||
Daemon Pty Limited 1995-2003
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/admin/cacheDetail.cfm,v 1.5 2003/09/03 01:50:31 brendan Exp $
$Author: brendan $
$Date: 2003/09/03 01:50:31 $
$Name: b201 $
$Revision: 1.5 $

|| DESCRIPTION || 
Displays cache details

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in:
out:

|| END DAEMONDOC||
--->

<cfsetting enablecfoutputonly="yes">

<!--- check permissions --->
<cfscript>
	iGeneralTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminGeneralTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/farcry_core/tags/admin/" prefix="admin">
<admin:header>

<cfif iGeneralTab eq 1>
	<!--- flush selected caches --->
	<cfif isdefined("form.flush")>
		<cfinvoke component="#application.packagepath#.farcry.cache" method="cacheFlush">
			<cfinvokeargument name="lcachenames" value="#form.flush#"/>
			<cfinvokeargument name="bShowResults" value="true"/>
		</cfinvoke>
	</cfif>
	
	<!--- display form --->
	<cfoutput><span class="Formtitle">Content Cache Detail</span><p></p></cfoutput>
	
	<!--- get individual caches from block--->
	<cfif structkeyexists(server,"dm_CacheBlock")>
		<cfoutput>
		<form action="" method="post" name="cacheForm">
		<table cellpadding="5" cellspacing="0" border="1" style="margin-left:30px;">
		<tr class="dataheader">
			<td>Cache</td>
			<td align="center">Timeout Period</td>
			<td align="center">Will Expire</td>
			<td align="center">Flush</td>
		</tr>
		</cfoutput>
		<!--- check there are caches to display --->
		<cfif listlen(server.dm_CacheBlock[application.applicationname][url.block])>
			<!--- loop over each cache in block --->
			<cfloop list="#server.dm_CacheBlock[application.applicationname][url.block]#" index="cacheDetail">
				<cflock timeout="20" throwontimeout="Yes" name="GeneratedContentCache_#cacheDetail#" type="READONLY">
					<!--- concatinate block name and cache name --->
					<cfset actualCacheName = url.block & cacheDetail>
					<!--- get cache detials --->		
					<cfset contentcache = structget("server.dm_generatedcontentcache.#application.applicationname#")>
												
					<!--- work out timeout period --->
					<cfset days = int(contentcache[actualCacheName].cachetimeout)>
					<cfset hours = int((contentcache[actualCacheName].cachetimeout - days) * 24)>
					<cfset minutes = int((((contentcache[actualCacheName].cachetimeout - days) * 24) - hours) * 60)>
					<cfset seconds = int((((((contentcache[actualCacheName].cachetimeout - days) * 24) - hours) * 60) - minutes) * 60)>
					
					<!--- work out expiry date/time --->
					<cfset expire = dateadd("d",days,contentcache[actualCacheName].cachetimestamp)>
					<cfset expire = dateadd("h",hours,expire)>
					<cfset expire = dateadd("n",minutes,expire)>
					<cfset expire = dateadd("s",seconds,expire)>
					
					<cfoutput>
					<tr>
						<td><a href="##" onClick="window.open('cacheView.cfm?cache=#actualCacheName#')">#actualCacheName#</a></td>
						<td align="center">#days#:#hours#:#minutes#:#seconds#</td>
						<td align="center">
							<cfif expire gt now()>
								#timeformat(expire, "HH:mm:ss")# #dateformat(expire, "dddd, mmm d, yyyy")#
							<cfelse>
								<span style="color:red;">expired!</span>
							</cfif>
						</td>
						<td align="center"><input type="checkbox" value="#actualCacheName#" name="flush"></td>
					</tr>
					</cfoutput>		
				</cflock>
				
			</cfloop>
			<cfoutput>
			<tr style="border: none;">
				<td style="border-right: none;" colspan="3"><input type="button" value="Refresh" name="refresh" class="normalbttnstyle" onClick="forms.cacheForm.submitButton.name='refresh';forms.cacheForm.submitButton.click()"></td>
				<td  style="border-left: none;" align="center"><input type="button" value="Flush" name="flush" class="normalbttnstyle" onClick="forms.cacheForm.submitButton.name='flush';forms.cacheForm.submitButton.click()"></td>
			</tr>
			</cfoutput>
		<cfelse>
			<cfoutput>
			<tr>
				<td colspan="5">No Caches to display.</td>
			</tr>
			</cfoutput>
		</cfif>
		<cfoutput>
		</table>
		<input type="submit" name="submitButton" style="visibility:hidden;width:28px;">	
		<input type="hidden" value="" name="dummyField">
		</form>
		</cfoutput>
	<cfelse>
		<cfoutput>No caches at this time.</cfoutput>
	</cfif>
	
	<!--- show link back to summary page --->
	<cfoutput><p><span class="frameMenuBullet">&raquo;</span> <a href="cacheSummary.cfm">Return to Cache Summary page</a></p></cfoutput>

<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>
<cfsetting enablecfoutputonly="no">