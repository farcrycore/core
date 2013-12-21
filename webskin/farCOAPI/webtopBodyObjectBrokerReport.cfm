<cfsetting enablecfoutputonly="true" />
<!--- @@Copyright: Daemon Pty Limited 2002-2008, http://www.daemon.com.au --->
<!--- @@License:
    This file is part of FarCry.

    FarCry is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    FarCry is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with FarCry.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: $
$Author: $
$Date: $
$Name: $
$Revision: $

|| DESCRIPTION || 
$Description: Provides information about the object broker and what it contains. $

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
--->
<!--- import tag libraries --->
<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />

<!--- Reap any dead entries to update stats --->
<cfset application.fc.lib.objectbroker.reapDeadEntriesFromBroker() />

<admin:header />
<ft:form>
<cfoutput>
	<h1>Object Broker Settings</h1>
	<p>Object broker has been activated for the following content types.</p>

<style type="text/css">
	.table-1 td, .table-1 th {padding:5px}
</style>

<table class="table-1">
<tr>
	<th>Typename</th>
	<th>Cached Objects</th>
	<th>Capacity %</th>
	<th>Hits/Misses</th>
	<th>Hit %</th>
	<th>Flushes</th>
	<th>Evicts</th>
	<th>Null Hits (Reaps)</th>
	<th>Skin Cache Detail</th>
</tr>
<cfloop collection="#application.types#" item="key">
<cfif structkeyexists(application.types[key], "bObjectBroker") AND application.types[key].bObjectBroker>
<tr>
	<cfif structkeyexists(application.types[key], "displayname")>
		<td>#application.types[key].displayname#</td>
	<cfelse>
		<td>#key#</td>
	</cfif>
	<cfif structkeyexists(application.objectbroker, key)>
		<td>#arrayLen(application.objectbroker[key].aobjects)#/#application.types[key].objectbrokermaxobjects#</td>
		<td>
			<cfif application.types[key].objectbrokermaxobjects GT 0>
				#numberFormat((arrayLen(application.objectbroker[key].aobjects)/application.types[key].objectbrokermaxobjects)*100)#%
			<cfelse>
				N/A
			</cfif>
		</td>
		<cfif isDefined("application.fcstats.objectbroker.typeCounters") and structKeyExists(application.fcstats.objectbroker.typeCounters,key)>
			<cfset stCounters = application.fcstats.objectbroker.typeCounters[key] />
			<cfset hitRatio = stCounters.hit.get() / (stCounters.hit.get()+stCounters.miss.get()) />
			<td>#ToString(stCounters.hit)#/#ToString(stCounters.miss)#</td>
			<td>#Round(hitRatio*100)#%</td>
			<td>#ToString(stCounters.flush)#</td>
			<td>#ToString(stCounters.evict)#</td>
			<td>#ToString(stCounters.nullhit)# (#ToString(stCounters.reap)#)</td>
		<cfelse>
			<td>-</td>
			<td>-</td>
			<td>-</td>
			<td>-</td>
			<td>-</td>
		</cfif>
		<td>
			<cfif structKeyExists(form, "selectedObjectID") AND form.selectedObjectID EQ key>
				<cfset maxSkins = 0 />
				<cfset minSkins = 0 />
				<cfset totalObjects = arrayLen(application.objectbroker[key].aobjects) />
				<cfset totalSkins = 0 />
				<cfset maxSkinsObjectID = "">
				<cfloop collection="#application.objectbroker[key]#" item="obj">
					<cfif obj NEQ "MAXOBJECTS" AND obj NEQ "AOBJECTS">
						<cfset stCacheEntry = application.fc.lib.objectbroker.GetObjectCacheEntry(objectid=obj,typename=key) />
						<cfif structKeyExists(stCacheEntry, "stWebskins")>
							<cfloop collection="#stCacheEntry.stWebskins#" item="webskinName">
								<cfset currentSkins  = StructCount(stCacheEntry.stWebskins[webskinName]) />
								<cfset totalSkins = totalSkins + currentSkins />
								<cfif currentSkins LT minSkins OR minSkins EQ 0>
									<cfset minSkins = currentSkins />
								</cfif>
								<cfif currentSkins GT maxSkins>
									<cfset maxSkins = currentSkins />
									<cfset maxSkinsObjectID = obj />
								</cfif>
							</cfloop>
						</cfif>
					</cfif>
				</cfloop>
				
				<strong>Minimum Skins:</strong> #minSkins#<br />
				<strong>Max Skins:</strong> #maxSkins# <cfif len(maxSkinsObjectID)>(<a href="#application.url.webroot#/index.cfm?objectid=#maxSkinsObjectID#">#maxSkinsObjectID#</a>)</cfif><br />
				<strong>Total Skins:</strong> #totalSkins#<br />
				<strong>Avg Skins per object:</strong> <cfif totalObjects GT 0>#totalSkins/totalObjects#<cfelse>N/A</cfif><br />
				<cfif len(maxSkinsObjectID)>
					<p>For more details, paste the following into the "<strong>Scope Dump Utility</strong>":<br /> application.objectBroker.ieProcess.#maxSkinsObjectID#.STWEBSKINS</p>
				</cfif>
			<cfelse>
				<ft:button value="show webskin detail" selectedObjectID="#key#" bInPanel="true" />
			</cfif>
				
			
			
			
		</td>
	<cfelse>
		<td colspan="2">Unknown</td>
	</cfif>
</tr>
</cfif>
</cfloop>
</table>

</cfoutput>

</ft:form>

<admin:footer />

<cfsetting enablecfoutputonly="true" />
