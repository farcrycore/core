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
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
--->
<!---
|| VERSION CONTROL ||
$Header: /cvs/farcry/core/webtop/reporting/statsOwnedBy.cfm,v 1.2 2005/08/09 03:54:40 geoff Exp $
$Author: geoff $
$Date: 2005/08/09 03:54:40 $
$Name: milestone_3-0-1 $
$Revision: 1.2 $

|| DESCRIPTION || 
$Description: Displays a listing for who's currently on the website$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfprocessingDirective pageencoding="utf-8">
<cfparam name="errormessage" default="" />

<!--- set up page header --->
<cfimport taglib="/farcry/core/tags/admin/" prefix="admin">
<cfset returnStruct = application.factory.oStats.getOwnedBy() />
<cfif returnStruct.returnCode EQ 1>
	<cfset stReport = returnStruct.owners />
<cfelse>
	<cfset errormessage = returnStruct.returnmessage />
</cfif>

<cfoutput>
<admin:header writingDir="#session.writingDir#" userLanguage="#session.userLanguage#">
<script type="text/javascript">
function doToggle(tglItem)
{
	objTgl = document.getElementById('tgl_' + tglItem);
	if(objTgl.style.display == "none")
		objTgl.style.display = "inline";
	else
		objTgl.style.display = "none";
		
	return false;
}
</script>
</cfoutput>

<sec:CheckPermission error="true" permission="ReportingStatsTab">
  <cfoutput><h3>Owned By Report</h3></cfoutput>

	<cfif errorMessage NEQ "">
    	<cfoutput>
      		<p id="fading1" class="fade"><span class="error">#errormessage#</span></p>
    	</cfoutput>
  	<cfelse>
		<cfoutput>
			<table class="table-3" cellspacing="0">
	    		<tr>
	        		<th colspan="2">Owned By</th>
		        	<th>Total</th>
		      	</tr>
		</cfoutput>
		<cfif isDefined("stReport")>
			<cfset iCounter = 0 />
			<cfloop collection="#stReport#" item="key">
				<cfset iCounter = iCounter + 1 />
			    <cfoutput>
			    	<tr<cfif iCounter MOD 2> class="alt"</cfif>>
			        	<td colspan="2"><!--- <a href="##" onclick="return doToggle('#key#');"> --->#key#<!--- </a> ---></td>
			          	<td>#stReport[key].items.total#</td>
			        </tr>
			        <!--- <tbody id="tgl_#key#" style="display:none;"> --->
				</cfoutput>
			    <cfloop collection="#stReport[key].items#" item="subItemKey">
			    	<cfif subItemKey NEQ "total">
			        	<cfset iCounter = iCounter + 1 />
			            <cfoutput>
			            <tr<cfif iCounter MOD 2> class="alt"</cfif>>
			              <td>&nbsp;</td>
			              <td>#subItemKey#</td>
			              <td>#stReport[key].items[subItemKey]#</td>
			            </tr>
		              	</cfoutput>
			        </cfif>
				</cfloop>
			    <!--- </tbody> --->
			</cfloop>
		</cfif>
		<cfoutput>
		</table>
	</cfoutput>
	</cfif>
</sec:CheckPermission>

<admin:footer>