<cfsetting enablecfoutputonly="true" />
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

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