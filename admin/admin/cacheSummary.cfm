<!--- 
|| BEGIN DAEMONDOC||

|| Copyright ||
Daemon Pty Limited 1995-2003
http://www.daemon.com.au

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/admin/admin/cacheSummary.cfm,v 1.9 2005/08/16 05:53:23 pottery Exp $
$Author: pottery $
$Date: 2005/08/16 05:53:23 $
$Name: milestone_3-0-1 $
$Revision: 1.9 $

|| DESCRIPTION || 
Displays a summary of cache blocks

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)

|| ATTRIBUTES ||
in:
out:

|| END DAEMONDOC||
--->

<cfsetting enablecfoutputonly="yes">

<cfprocessingDirective pageencoding="utf-8">

<!--- check permissions --->
<cfscript>
	iGeneralTab = request.dmSec.oAuthorisation.checkPermission(reference="policyGroup",permissionName="AdminGeneralTab");
</cfscript>

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">

<cfif iGeneralTab eq 1>
	<!--- clean selected blocks --->
	<cfif isdefined("form.cleanBlock")>
		<cfinvoke component="#application.packagepath#.farcry.cache" method="cacheClean">
			<cfinvokeargument name="cacheBlockName" value="#form.cleanBlock#"/>
			<cfinvokeargument name="bShowResults" value="true"/>
		</cfinvoke>
	</cfif>
	<!--- flush selected blocks --->
	<cfif isdefined("form.flushBlock")>
		<cfinvoke component="#application.packagepath#.farcry.cache" method="cacheFlush">
			<cfinvokeargument name="cacheBlockName" value="#form.flushBlock#"/>
			<cfinvokeargument name="bShowResults" value="true"/>
		</cfinvoke>
	</cfif>
	
	<!--- display form --->
	<cfoutput><h3>#application.adminBundle[session.dmProfile.locale].contentCacheSummary#</h3></cfoutput>
	
	<!--- block caches --->
	<!--- check a block cache exists --->
	<cfif structkeyexists(server,"dm_cacheblock")>
		<!--- setup form and header --->
		<cfoutput>
		<form action="" method="post" name="BlockForm">
		<table class="table-4" cellspacing="0">
		<tr>
			<th>#application.adminBundle[session.dmProfile.locale].Block#</th>
			<th>#application.adminBundle[session.dmProfile.locale].numberCaches#</th>
			<th>#application.adminBundle[session.dmProfile.locale].expiredCaches#</th>
			<th>#application.adminBundle[session.dmProfile.locale].clean#</th>
			<th>#application.adminBundle[session.dmProfile.locale].flush#</th>
		</tr>
		</cfoutput>
		
		<cflock timeout="10" throwontimeout="Yes" name="CacheBlockRead_#application.applicationname#" type="EXCLUSIVE">
			<cfset blockcache = structget("server.dm_CacheBlock.#application.applicationname#")>
			<!--- sort structure --->
			<cfset listofKeys = structKeyList(blockCache)>
			<cfset listofKeys = listsort(listofkeys,"textnocase")>
			<!--- loop over each block cache --->
			<cfloop list="#listofKeys#" index="blockName">
				<cfset cacheflushnum = 0>
				<!--- check block has a cache --->
				<cfif structkeyexists(blockcache, blockName)>
					<cflock timeout="10" throwontimeout="Yes" name="GeneratedContentCache_#application.applicationname#" type="EXCLUSIVE"><!--- possibility to get contention against cachewrite, but this is admin, so it'll throw and no probs... --->
						<cfoutput>
						<tr>
							<!--- display block cache name --->
							<td><a href="cacheDetail.cfm?block=#blockName#">#blockname#</a></td>
							<!--- display number of caches within block --->
							<td>#listlen(blockCache[blockName])#</td>
						</cfoutput>
						<cfset contentcache = structget("server.dm_generatedcontentcache.#application.applicationname#")>
						<cfset cacheflushnum = 0>
						<!--- loop over each cache in block to see how many have timed out --->
						<cfloop index="element" list="#blockcache[blockName]#">
							<!--- concatinate blockName & cacheName (this is how caches are first named) --->
							<cfset element = blockName & element>
							<!--- check cache exists --->
							<cfif structkeyexists(contentcache, element)>
								<!--- check for timeout --->
								<cfif contentcache[element].cachetimeout neq 0 and contentcache[element].cachetimestamp lt now() - contentcache[element].cachetimeout>
									<cfset cacheflushnum = cacheflushnum + 1>
								</cfif>
							</cfif>
						</cfloop>
						
						<cfoutput>
								<!--- display number of caches that have timed out --->
								<td>#cacheflushnum#</td>
								<td><input type="checkbox" value="#blockName#" name="cleanBlock"></td>
								<td><input type="checkbox" value="#blockName#" name="flushBlock"></td>
							</tr>
						</cfoutput>
					</cflock>
				</cfif>
			</cfloop>
		</cflock>
		<cfoutput>
		<tr>
			<!--- show form buttons, javascript to submit the form onClick of button --->
			<td colspan="3"><input type="button" value="Refresh" name="refresh" class="normalbttnstyle" onClick="forms.BlockForm.submitButton.name='refresh';forms.BlockForm.submitButton.click()"></td>
			<td><input type="button" name"cleanBlock" value="Clean" class="normalbttnstyle" onClick="forms.BlockForm.submitButton.name='cleanBlock';forms.BlockForm.submitButton.click()"></td>
			<td><input type="button" value="Flush" name="flushBlock" class="normalbttnstyle" onClick="forms.BlockForm.submitButton.name='flushBlock';forms.BlockForm.submitButton.click()"></td>
		</tr>
		</table>
		
		<input type="submit" name="submitButton" style="visibility:hidden;width:28px;">	
		<input type="hidden" value="" name="dummyField">
		</form>
		</cfoutput>
	<cfelse>
		<cfoutput><p>#application.adminBundle[session.dmProfile.locale].noBlockCachesNow#</p></cfoutput>
	</cfif>

<cfelse>
	<admin:permissionError>
</cfif>

<admin:footer>
<cfsetting enablecfoutputonly="no">