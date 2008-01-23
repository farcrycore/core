<cfsetting enablecfoutputonly="true" />
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2006, http://www.daemon.com.au $
$Community: FarCry CMS http://www.farcrycms.org $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

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

<admin:header />
<ft:form>
<cfoutput>
	<h1>Object Broker Settings</h1>
	<p>Object broker has been activated for the following content types.</p>

<table class="table-1">
<tr>
	<th>Typename</th>
	<th>Cached Objects</th>
	<th>Capacity %</th>
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
		<td>
			<cfif structKeyExists(form, "selectedObjectID") AND form.selectedObjectID EQ key>
				<cfset maxSkins = 0 />
				<cfset minSkins = 0 />
				<cfset totalObjects = arrayLen(application.objectbroker[key].aobjects) />
				<cfset totalSkins = 0 />
				<cfset maxSkinsObjectID = "">
				<cfloop collection="#application.objectbroker[key]#" item="obj">
					<cfif obj NEQ "MAXOBJECTS" AND obj NEQ "AOBJECTS">
						<cfif structKeyExists(application.objectBroker[key][obj], "stWebskins")>
							<cfloop collection="#application.objectBroker[key][obj].stWebskins#" item="webskinName">
								<cfset currentSkins  = StructCount(application.objectBroker[key][obj].stWebskins[webskinName]) />
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
				<ft:farcryButton value="show webskin detail" selectedObjectID="#key#" bInPanel="true" />
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
