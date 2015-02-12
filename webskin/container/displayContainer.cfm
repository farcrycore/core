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


<!--- Import tag libraries --->
<cfimport taglib="/farcry/core/tags/container/" prefix="con">
<cfimport taglib="/farcry/core/tags/webskin/" prefix="skin" />

<!--- Environment Variables --->
<cfparam name="stParam.desc" default="" />
<cfparam name="stParam.originalID" default="#stobj.objectid#" />

<cfif structKeyExists(url, "originalID")>
	<cfset stParam.originalID = url.originalID />
</cfif>


<!--- Allows the container description to be different to the actual label. Defaults to the label --->
<cfif not len(stparam.desc)>
	<cfset stParam.desc = "#rereplace(stObj.label,'\w{8,8}-\w{4,4}-\w{4,4}-\w{16,16}_','')#" />
</cfif>


<!--- Need to make a duplicate so we can make changes. --->
<cfset stConObj = duplicate(stobj) />


<cfif structkeyexists(form,"rule_action")>
	<cfset url.rule_action = form.rule_action />
	<cfset url.rule_id = form.rule_id />
	<cfset url.rule_index = form.rule_index />
	<cfif isdefined("form.confirm")>
		<cfset url.confirm = form.confirm />
	</cfif>
</cfif>

<cfif request.mode.design and request.mode.showcontainers gt 0>
	<!--- Load CSS & JS --->
	<skin:loadJS id="fc-jquery" />
	<skin:loadJS id="gritter" />
	<skin:loadCSS id="gritter" />
	
	<cfif structkeyexists(url,"rule_action") and structkeyexists(url,"rule_id") and structkeyexists(url,"rule_index") and url.rule_index lte arraylen(stConObj.aRules)>
		
		<cfswitch expression="#url.rule_action#">
			<cfcase value="moveup">
				<cfif stConObj.aRules[url.rule_index] eq url.rule_id and url.rule_index gt 1>
					<cfset temp = stConObj.aRules[url.rule_index] />
					<cfset stConObj.aRules[url.rule_index] = stConObj.aRules[url.rule_index-1] />
					<cfset stConObj.aRules[url.rule_index-1] = temp />
					<cfset setData(stProperties=stConObj) />
					<skin:bubble title="Container management" tags="container,update,info"><cfoutput>The rule has been moved up</cfoutput></skin:bubble>
	
				</cfif>
			</cfcase>
			<cfcase value="movedown">
				<cfif stConObj.aRules[url.rule_index] eq url.rule_id and url.rule_index lt arraylen(stConObj.aRules)>
					<cfset temp = stConObj.aRules[url.rule_index] />
					<cfset stConObj.aRules[url.rule_index] = stConObj.aRules[url.rule_index+1] />
					<cfset stConObj.aRules[url.rule_index+1] = temp />
					<cfset setData(stProperties=stConObj) />
					<skin:bubble title="Container management" tags="container,update,info"><cfoutput>The rule has been moved down</cfoutput></skin:bubble>
	
				</cfif>
			</cfcase>
			<cfcase value="delete">
				<cfif stConObj.aRules[url.rule_index] eq url.rule_id>
					<cfset oFourq = createObject("component", "farcry.core.packages.fourq.fourq") />
					<cfset oRule = createObject("component", application.stcoapi[oFourq.findType(objectid=url.rule_id)].packagepath) />
					<cfset oRule.delete(objectid=url.rule_id) />
					<cfset arraydeleteat(stConObj.aRules,url.rule_index) />
					<cfset setData(stProperties=stConObj) />
					<skin:bubble title="Container management" tags="container,update,rule,deleted,info"><cfoutput>The rule has been deleted</cfoutput></skin:bubble>
	
				</cfif>
			</cfcase>
		</cfswitch>
		
	</cfif>
</cfif>

<cfif arrayLen(stConObj.aRules)>

	<!--- delay the populate so we can see the content --->
	<cfsavecontent variable="conOutput">
		<cfset populate(aRules=stConObj.aRules, originalID="#stParam.originalID#")>
	</cfsavecontent>

	<!--- output conOutput --->
	<cfparam name="stConObj.displayMethod" default="">
	
	<cfif len(stConObj.displayMethod) AND application.fapi.hasWebskin(typename="container", webskin="#stConObj.displayMethod#")>
	
		<cfset getDisplay(containerBody=conOutput,template=stConObj.displayMethod)>		
	<cfelse>		
		<cfoutput>#conOutput#</cfoutput>
	</cfif>
</cfif>


<cfsetting enablecfoutputonly="false" />