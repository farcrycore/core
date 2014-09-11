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
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<skin:loadJS id="farcry-form" />

<style type="text/css">
	tbody {border-bottom:2px solid;}
</style>

<!--- Reap any dead entries to update stats --->
<cfset application.fc.lib.objectbroker.reapDeadEntriesFromBroker() />
application.objectbroker[listfirst(key,":")].maxobjects
<admin:header />
<ft:form>
<cfoutput>
	<h1>Object Broker Settings</h1>
	<p>Object broker has been activated for the following content types.</p>

<table class="table table-striped table-hover">
	<thead>
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
	</thead>
	<tbody>
		<cfloop list="fuLookup:Friendly URL Lookup,config:Configs,navid:Navigation Alias Hash,catid:Category Alias Hash" index="key">
			<tr>
				<td>#listlast(key,":")#</td>

				<cfif structkeyexists(application.objectbroker, listfirst(key,":"))>
					<td>#structcount(application.objectbroker[listfirst(key,":")])-2#/#application.objectbroker[listfirst(key,":")].maxobjects#</td>
					<td>
						<cfif application.objectbroker[listfirst(key,":")].maxobjects GT 0>
							#numberFormat(((structcount(application.objectbroker[listfirst(key,":")])-2)/application.objectbroker[listfirst(key,":")].maxobjects)*100)#%
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
				<cfelse>
					<td>-</td>
					<td>-</td>
					<td>-</td>
					<td>-</td>
					<td>-</td>
					<td>-</td>
					<td>-</td>
				</cfif>
				<td></td>
			</tr>
		</cfloop>
	
		<cfloop collection="#application.stCOAPI#" item="key">
			<cfif structkeyexists(application.stCOAPI[key], "bObjectBroker") AND application.stCOAPI[key].bObjectBroker>
				<tr>
					<cfif structkeyexists(application.stCOAPI[key], "displayname")>
						<td>#application.stCOAPI[key].displayname#</td>
					<cfelse>
						<td>#key#</td>
					</cfif>
					<cfif structkeyexists(application.objectbroker, key)>
						<td>#arrayLen(application.objectbroker[key].aobjects)#/#application.stCOAPI[key].objectbrokermaxobjects#</td>
						<td>
							<cfif application.stCOAPI[key].objectbrokermaxobjects GT 0>
								#numberFormat((arrayLen(application.objectbroker[key].aobjects)/application.stCOAPI[key].objectbrokermaxobjects)*100)#%
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
								<cfset stCount = {} />
								<cfset totalObjects = arrayLen(application.objectbroker[key].aobjects) />
								<cfset maxSkins = 0 />
								<cfset minSkins = 0 />
								<cfset totalSkins = 0 />
								<cfset maxSkinsObjectID = "">

								<cfloop collection="#application.objectbroker[key]#" item="obj">
									<cfif refind("^[^_]+_[^_]+_[^_]+",obj)>
										<cfif not structkeyexists(stCount,listGetAt(obj,1,"_"))>
											<cfset stCount[listGetAt(obj,1,"_")] = 0 />
										</cfif>

										<cfset stCount[listGetAt(obj,1,"_")] = stCount[listGetAt(obj,1,"_")] + 1 />
									</cfif>
								</cfloop>

								<cfloop collection="#stCount#" item="obj">
									<cfset currentSkins  = stCount[obj] />
									<cfset totalSkins = totalSkins + currentSkins />
									<cfif currentSkins LT minSkins OR minSkins EQ 0>
										<cfset minSkins = currentSkins />
									</cfif>
									<cfif currentSkins GT maxSkins>
										<cfset maxSkins = currentSkins />
										<cfset maxSkinsObjectID = obj />
									</cfif>
								</cfloop>

								<strong>Minimum Skins:</strong> #minSkins#<br />
								<strong>Max Skins:</strong> #maxSkins# <cfif len(maxSkinsObjectID)>(<a href="#application.url.webroot#/index.cfm?objectid=#maxSkinsObjectID#">#maxSkinsObjectID#</a>)</cfif><br />
								<strong>Total Skins:</strong> #totalSkins#<br />
								<strong>Avg Skins per object:</strong> <cfif totalObjects GT 0>#totalSkins/totalObjects#<cfelse>N/A</cfif><br />
								<cfif len(maxSkinsObjectID)>
									<p><a onclick="$fc.objectAdminAction('Object Broker Contents', this.href); return false;" href="#application.url.webtop#/index.cfm?id=#url.id#&typename=farCOAPI&view=webtopPageModal&bodyView=webtopBodyScopeDump&var=application.OBJECTBROKER.#key#">details</a></p>
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
	</tbody>
</table>

</cfoutput>

</ft:form>

<admin:footer />

<cfsetting enablecfoutputonly="true" />
