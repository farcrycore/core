<cfsetting enablecfoutputonly="true" />
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2005, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/tags/admin/menu.cfm,v 1.6 2005/10/07 04:06:17 daniela Exp $
$Author: daniela $
$Date: 2005/10/07 04:06:17 $
$Name:  $
$Revision: 1.6 $

|| DESCRIPTION || 
$Description: Sidebar menu custom tag. 
Generates sidebar subsection menu and permissions 
based on webtop xml for subsection.$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au)$
$Developer: Guy Phanvongsa (guy@daemon.com.au)$
--->

<cfswitch expression="#thistag.executionmode#">
  <cfcase value="start">

    <!--- optional attributes --->
    <cfparam name="attributes.sectionid" default="" type="string" />
    <cfparam name="attributes.subsectionid" default="" type="string" />
    <cfparam name="attributes.webTop" default="" type="any" />

		<!--- local variables --->
		<cfset sectionID = attributes.sectionid />
		<cfset subsectionid = attributes.subsectionid />
		<cfset oWebTop = attributes.webTop />
    <cfset errorMessage = "" />

    <!--- get sidebar contents based on passed in subsectionid --->
		<cfif isObject(oWebTop) AND len(subsectionid)>
			<cfset aSubSections = owebtop.getSubSectionsAsArray(subsection=subsectionid)>
			<cfloop index="i" from="1" to="#ArrayLen(aSubSections)#">
				<cfset owebtop.fTranslateXMLElement(aSubSections[i]) />
			</cfloop>
			<!--- get section & subsection to display --->
			<cfset aSubectionToDisplay = xmlSearch(oWebTop.xmlWebTop,"//section/subsection[@id='#attributes.subsectionid#']") />
			<cfset aMenu = aSubectionToDisplay[1].xmlChildren />
		<cfelse>
			<cfset errorMessage = errorMessage & "Invalid SectionID And/Or WebTop Object.<br />" />
		</cfif>
		<cfset showListbox = 0 />
		<cfif arraylen(asubsections)>
			<cfloop from="1" to="#arraylen(asubsections)#" index="i">
				<cfif request.dmsec.oAuthorisation.fCheckXMLPermission(asubsections[i].xmlAttributes)>
					<cfset showListbox = 1 />
				</cfif>
			</cfloop>
		</cfif>

		<cfoutput>
		<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
		<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
			<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
			<title>FarCry Sidebar</title>
			<style type="text/css" title="default" media="screen">@import url(../css/main.css);</style>
		</head>
		<body class="iframed">
		</cfoutput>

		<!--- errormessage check --->
		<cfif len(errorMessage)> 
			<cfoutput>#errormessage#</cfoutput>
		<cfelse>
		<!--- output subsection jump menu --->
		<cfif arraylen(asubsections) and showListbox>
		<cfoutput>
			<form id="subjump" action="" method="get" class="iframe-nav-form">
				<select name="sub" onchange="location=this.value;return false;"></cfoutput>
				<cfloop from="1" to="#arraylen(asubsections)#" index="i">
					<cfif request.dmsec.oAuthorisation.fCheckXMLPermission(asubsections[i].xmlAttributes)><cfoutput>
					<option value="#cgi.script_path#?sub=#asubsections[i].xmlAttributes.id#"<cfif subsectionid eq asubsections[i].xmlAttributes.id> selected="selected"</cfif>>#asubsections[i].xmlAttributes.label#</option></cfoutput>
					</cfif>
				</cfloop><cfoutput>
				</select>
			</form>
			</cfoutput>
		<cfelse>
			<cfoutput><br /></cfoutput>
		</cfif>
	
		<!--- TODO: clean up and apply permission checks --->
		<cfloop from="1" to="#arrayLen(aMenu)#" index="i">
			<cfif request.dmsec.oAuthorisation.fCheckXMLPermission(aMenu[i].xmlAttributes)><cfoutput>
				<h3>#aMenu[i].xmlattributes.label#</h3></cfoutput>
				<cfset amenuitems=aMenu[i].xmlchildren />
				<cfoutput>
				<ul></cfoutput>
				<cfloop from="1" to="#arrayLen(amenuitems)#" index="j">
					<cfif request.dmsec.oAuthorisation.fCheckXMLPermission(amenuitems[j].xmlAttributes)>
						<cfparam name="amenuitems[j].xmlattributes.linkType" default="farcry" />
						<cfswitch expression="#amenuitems[j].xmlattributes.linkType#">
							<cfcase value="External">
								<cfoutput>
								<li><a href="#amenuitems[j].xmlattributes.link#" target="content">#amenuitems[j].xmlattributes.label#</a></li></cfoutput>
							</cfcase>
							<cfdefaultcase>
								<cfoutput>
								<li><a href="#application.url.farcry##ReplaceNoCase(amenuitems[j].xmlattributes.link,'#application.url.farcry#','')#" target="content">#amenuitems[j].xmlattributes.label#</a></li></cfoutput>
							</cfdefaultcase>
						</cfswitch>
					</cfif>
				</cfloop>
				<cfoutput>
				</ul></cfoutput>
			</cfif>
		</cfloop>
		</cfif> 
		<!--- // errormessage check --->
		<cfoutput>
		</body>
		</html></cfoutput>
	</cfcase>
</cfswitch>

<cfsetting enablecfoutputonly="false" />