<cfsetting enablecfoutputonly="true">
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
$Description: Installation form for FarCry$

|| DEVELOPER ||
$Developer: Michael Sharman (michael@daemon.com.au)$
--->

<!--- Logout and destroy session variables --->
<!--- todo: why are we doing this? GB 20061021 
<cfloop list="#structkeylist(application)#" index="a">
	<cfif a neq "applicationname">
		<cfset selfdestruct = StructDelete(application,a)>
	</cfif>
</cfloop>
<cfloop list="#structkeylist(session)#" index="a">
	<cfif a neq "sessionid" and a neq "cfid">
		<cfset selfdestruct = StructDelete(session,a)>
	</cfif>
</cfloop>
--->

<!--- form field defaults --->
<cfparam name="bShowForm" default="1" type="boolean" />
<cfparam name="form.appDsn" default="" type="string" />
<cfparam name="form.dbtype" default="" type="string" />
<cfparam name="form.dbowner" default="dbo." type="string" />
<cfparam name="form.dbonly" default="0" type="string" />
<cfparam name="form.osType" default="server" type="string" />
<cfparam name="form.hostName" default="" type="string" />
<cfparam name="form.farcryMapping" default="farcry" type="string" />
<cfparam name="form.domain" default="#cgi.server_name#" type="string" />
<cfparam name="form.bDeleteApp" default="1" type="boolean" />

<cfset oFlightCheck = createObject("component", "FlightCheck") />

<cfset form.siteName = oFlightCheck.getProjectName() />
<cfset form.appMapping = oFlightCheck.getProjectSubDirectory() />

<!--- include HTML for help bubbles --->
<cfinclude template="_helpToolTips.cfm" />

<cfoutput>
	<div id="content">
		<h2>Farcry Installation Settings for<br />#UCASE(form.siteName)#</h2>

		<form name="installForm" id="installForm" action="#cgi.script_name#" method="post" class="content" onsubmit="return verifyForm();">
			<input type="hidden" name="farcryVersion" id="farcryVersion" value="#request.farcryVersion#" />
			
			<cfif len(form.sitename)>
				<input type="hidden" name="siteName" id="siteName" value="#form.siteName#" />
			<cfelse>
			<div class="item">
		      	<label for="siteName">Site Name <em>*</em></label>
		      	<input type="text" name="siteName" value="#form.siteName#" maxlength="100" class="inputText" />
				<img src="help.gif" alt="Help" id="the_image1" onmouseover="xstooltip_show('help.siteName', 'the_image1', 289, 39);" onmouseout="xstooltip_hide('help.siteName');" />
				<div class="xstooltip" id="help.siteName"><p class="content">#help.siteName#</p><p class="inner">&nbsp;</p></div>
		    </div>
			</cfif>
			
			<div class="item">
		      	<label for="domain">Installer Domain Name <em>*</em></label>
		      	<select name="domain" id="domain" class="selectOne">
			        <option value="#cgi.server_name#"<cfif form.domain EQ "#cgi.server_name#"> selected="selected"</cfif>>#cgi.server_name#</option>
			        <cfif cgi.server_name NEQ "127.0.0.1">
			        		<option value="127.0.0.1"<cfif form.domain EQ "127.0.0.1"> selected="selected"</cfif>>127.0.0.1</option>
			        </cfif>
			        <cfif cgi.server_name NEQ "localhost">
			        		<option value="localhost"<cfif form.domain EQ "localhost"> selected="selected"</cfif>>localhost</option>
			        </cfif>
				</select>
				<img src="help.gif" alt="Help" id="the_image6" onmouseover="xstooltip_show('help.domain', 'the_image6', 289, 39);" onmouseout="xstooltip_hide('help.domain');" />
				<div class="xstooltip" id="help.domain"><p class="content">#help.domain#</p><p class="inner">&nbsp;</p></div>
		    </div>
	
		    <div class="item">
		      	<label for="appMapping">Project Virtual Directory</label>
		      	<input type="text" name="appMappingDisplay" value="#form.appMapping#" maxlength="100" onblur="setWebtopMapping();" class="inputText" disabled="disabled" />
				<input type="hidden" name="appMapping" id="appMapping" value="#form.appMapping#" />
				<img src="help.gif" alt="Help" id="the_image4" onmouseover="xstooltip_show('help.appMapping', 'the_image4', 289, 39);" onmouseout="xstooltip_hide('help.appMapping');" />
				<div class="xstooltip" id="help.appMapping"><p class="content">#help.appMapping#</p><p class="inner">&nbsp;</p></div>
		    </div>
		    
		    <div class="item">
		      	<label for="farcryMapping">Farcry Virtual Directory</label>
		      	<input type="text" name="farcryMappingDisplay" value="#form.appMapping#/farcry" maxlength="100" onblur="checkFarcryMapping();" class="inputText" disabled="disabled" />
				<input type="hidden" name="farcryMapping" id="farcryMapping" value="#form.appMapping#/farcry" />
				<img src="help.gif" alt="Help" id="the_image5" onmouseover="xstooltip_show('help.farcryMapping', 'the_image5', 289, 39);" onmouseout="xstooltip_hide('help.farcryMapping');" />
				<div class="xstooltip" id="help.farcryMapping"><p class="content">#help.farcryMapping#</p><p class="inner">&nbsp;</p></div>
		    </div>
	
			<div class="item">
		      	<label for="appDSN">Project DSN <em>*</em></label>
		      	<input type="text" name="appDSN" id="appDSN" value="#form.appDSN#" maxlength="100" class="inputText" />
				<img src="help.gif" alt="Help" id="the_image2" onmouseover="xstooltip_show('help.appDSN', 'the_image2', 289, 39);" onmouseout="xstooltip_hide('help.appDSN');" />
				<div class="xstooltip" id="help.appDSN"><p class="content">#help.appDSN#</p><p class="inner">&nbsp;</p></div>
		    </div>
		    
		  	<div class="item">
		      	<label for="dbType">Database Type <em>*</em></label>
		      	<select name="dbType" id="dbType" onchange="checkDBType(this.options[this.selectedIndex].value);" class="selectOne">
			        <option value="">--Select</option>
			        <option value="mssql"<cfif form.dbType EQ "mssql"> selected="selected"</cfif>>Microsoft SQL Server</option>
			        <option value="ora"<cfif form.dbType EQ "ora"> selected="selected"</cfif>>Oracle</option>
			        <option value="mysql"<cfif form.dbType EQ "mysql"> selected="selected"</cfif>>MySQL</option>
			        <option value="postgresql"<cfif form.dbType EQ "postgresql"> selected="selected"</cfif>>PostgreSQL</option>
				</select>
		    </div>
		    
		    <div class="item" id="divDBOwner" style="display:none;">
		      	<label for="dbOwner">Database Owner</label>
		      	<input type="text" name="dbOwner" id="dbOwner" value="#form.dbOwner#" size="15" maxlength="100" class="inputText" />
				<img src="help.gif" alt="Help" id="the_image3" onmouseover="xstooltip_show('help.dbOwner', 'the_image3', 289, 39);" onmouseout="xstooltip_hide('help.dbOwner');" />
				<div class="xstooltip" id="help.dbOwner"><p class="content">#help.dbOwner#</p><p class="inner">&nbsp;</p></div>
		    </div>
		    
		    
		    
			
		    
		    <div class="item">
		      	<span class="itemGroup">
		      	<label for="dbonly">Install the database only</label>
		      	<input type="checkbox" value="true" name="dbonly" id="dbonly"<cfif form.dbonly> checked="checked"</cfif> class="inputCheckbox" />
				</span>
				<img src="help.gif" alt="Help" id="the_image7" onmouseover="xstooltip_show('help.dbonly', 'the_image7', 289, 39);" onmouseout="xstooltip_hide('help.dbonly');" />
				<div class="xstooltip" id="help.dbonly"><p class="content">#help.dbonly#</p><p class="inner">&nbsp;</p></div>
		    </div>
		    
		    <div class="item">
		      	<span class="itemGroup">
		      	<label for="postcode">Delete Installer on completion</label>
		      	<input type="checkbox" value="true" name="bDeleteApp" id="bDeleteApp"<cfif form.bDeleteApp> checked="checked"</cfif> class="inputCheckbox" />
				</span>
				<img src="help.gif" alt="Help" id="the_image8" onmouseover="xstooltip_show('help.bDeleteApp', 'the_image8', 289, 39);" onmouseout="xstooltip_hide('help.bDeleteApp');" />
				<div class="xstooltip" id="help.bDeleteApp"><p class="content">#help.bDeleteApp#</p><p class="inner">&nbsp;</p></div>
		    </div>
			
			<!--- see if there are any farcry plugins to install --->
		    <cfif qPlugins.recordCount>
		    	<div class="item">
		    	<h3>Farcry Plugins</h3>
		    	<p>
			    	Farcry plugins are addons used to extend core functionality. E.g 'facrycms' is a plugin which contains content types including News, Events, Facts and Links. This is useful for Content Management Systems.
				</p>
		    	<cfset lAmnesty = "core,fourq,plugins,#request.farcryVersion#" /><!--- ignore these directories --->
		    	<cfloop query="qPlugins">
					<cfif (qPlugins.type EQ "DIR") AND (NOT listContainsNoCase(lAmnesty, qPlugins.name))>
						<span class="itemGroup">
							<label for="#qPlugins.name#">#qPlugins.name#</label>
					      	<input type="checkbox" value="#qPlugins.name#" name="chkPlugins" id="#qPlugins.name#" class="inputCheckbox"<cfif qPlugins.name EQ "farcrycms"> checked="checked" readonly="readonly"</cfif> />
						</span><br /> 
					</cfif>
				</cfloop>
				</div>				
			</cfif>
		    
		    <div class="itemButtons">
				<input type="submit" name="proceed" value="INSTALL" />
		        <input type="reset" name="reset" value="RESET" />
			</div>  
					
		</form>
	</div>	
</cfoutput>

<cfsetting enablecfoutputonly="false">