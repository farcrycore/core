<cfsetting enablecfoutputonly="true" />
<!--- @@Copyright: Daemon Pty Limited 1995-2007, http://www.daemon.com.au --->
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
<!--- @@displayname: Build a pagination link --->
<!--- @@description: Used within a pagination webskin, this tag allows the developer to build a link to a specific page in their paginated recordset.  --->
<!--- @@author: Matthew Bryant (mbryant@daemon.com.au) --->

<!------------------ 
FARCRY IMPORT FILES
 ------------------>
<cfimport taglib="/farcry/core/tags/formtools" prefix="ft" />
<cfimport taglib="/farcry/core/tags/webskin" prefix="skin" />

<!------------------ 
START WEBSKIN
 ------------------>
<cfif thistag.executionMode eq "Start">
	<cfparam name="attributes.stLink" type="struct" /><!--- The link to render --->
	<cfparam name="attributes.linkText" default="" /><!--- The text to use as the link. defaults to defaultLinktext but can be overridden by generatedContent --->
	<cfparam name="attributes.title" default="" /><!--- The title of the anchor tag --->
	<cfparam name="attributes.bHideSpan" default="false" /><!--- Hides span tag around non-link --->
</cfif>

<cfif thistag.executionMode eq "end">
	<!--- USE THE LINKTEXT AS GENERATED CONTENT IF AVAILABLE --->
	<cfif not structIsEmpty(attributes.stLink) and NOT attributes.stLink.bHidden>
		<cfif len(attributes.linktext)>
			<cfset thistag.GeneratedContent = attributes.linktext />
		</cfif>
		<cfif NOT len(trim(thistag.GeneratedContent))>
			<cfset thistag.GeneratedContent = attributes.stLink.defaultLinktext />
		</cfif>	
		
		<!--- Determine link or text --->
		<cfif attributes.stLink.bDisabled>
       <cfif attributes.bHideSpan>
				<cfoutput>#thistag.GeneratedContent#</cfoutput>
       <cfelse>
				<cfoutput><span class="#attributes.stLink.class#" title="#attributes.title#">#thistag.GeneratedContent#</span></cfoutput>
       </cfif>
		<cfelse>
			<skin:buildLink href="#attributes.stLink.href#" onclick="#attributes.stLink.onclick#;" linktext="#thistag.GeneratedContent#" class="#attributes.stLink.class#" title="#attributes.title#" />
		</cfif>	

	</cfif>
	
	<cfset thistag.GeneratedContent = "" />
</cfif>

<cfsetting enablecfoutputonly="false" />