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

<cfif thistag.executionmode eq "start">
	
	<!--- optional attributes --->
	<cfparam name="attributes.sectionid" type="string" />
	<cfparam name="attributes.subsectionid" default="" type="string" />
	<cfparam name="attributes.webTop" default="" type="any" />
	
	<cfimport taglib="/farcry/core/tags/admin" prefix="admin" />
	
	<!--- Get section --->
	<cfset stSection = attributes.webtop.getItem(attributes.sectionid) />
	
	<!--- Default sub section is the first one --->
	<cfif len(attributes.subsectionid) and structkeyexists(stSection.children,attributes.subsectionid)>
		<cfset stSubSection = stSection.children[attributes.subsectionid] />
	<cfelseif len(stSection.childorder)>
		<cfset stSubSection = stSection.children[listfirst(stSection.childorder)] />
	<cfelse>
		<cfset stSubSection = structnew() />
	</cfif>
	
	<cfif structcount(stSection.children) gt 1>
		<!--- Show subsection jump menu --->
		<cfoutput>
			<form id="subjump" action="" method="get" class="iframe-nav-form">
				<select name="sub" onchange="urls=this.value.split('|');location=urls[0];window.open(urls[1],'content');return false;">
		</cfoutput>
		
		<admin:loopwebtop parent="#stSection#" item="subsection">
			<cfset url.sub = subsection.id />
			<cfoutput>
				<option value="#application.url.farcry#/#application.factory.oWebtop.getAttributeURL(subsection,'sidebar',url)#|#application.url.farcry#/#application.factory.oWebtop.getAttributeURL(subsection,'content',url)#"<cfif attributes.subsectionid eq subsection.id> selected="selected"</cfif>>#subsection.label#</option>
			</cfoutput>
		</admin:loopwebtop>
		
		<cfoutput>
				</select>
			</form>
		</cfoutput>
	</cfif>
	
	<cfif not structisempty(stSubSection)>
		<admin:loopwebtop parent="#stSubSection#" item="menu">
			<cfoutput>
				<h2>#menu.label#</h2>
				<ul>
			</cfoutput>
			
			<admin:loopwebtop parent="#menu#" item="menuitem">
				<cfswitch expression="#menuitem.linkType#">
					<cfcase value="External">
						<cfoutput>
							<li><a href="#menuitem.link#" target="content">#menuitem.label#</a></li>
						</cfoutput>
					</cfcase>
					<cfdefaultcase>
						<cfoutput>
							<li><a href="#application.url.farcry##ReplaceNoCase(menuitem.link,'#application.url.farcry#','')#" target="content">#menuitem.label#</a></li>
						</cfoutput>
					</cfdefaultcase>
				</cfswitch>
			</admin:loopwebtop>
			
			<cfoutput>
				</ul>
			</cfoutput>
		</admin:loopwebtop>
	</cfif>

</cfif>

<cfsetting enablecfoutputonly="false" />