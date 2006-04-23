<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/admin/install/_installForm.cfm,v 1.28 2003/10/20 06:14:36 brendan Exp $
$Author: brendan $
$Date: 2003/10/20 06:14:36 $
$Name: b201 $
$Revision: 1.28 $

|| DESCRIPTION ||
$Description: Installation form for FarCry$
$TODO: $

|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$
$Developer: Peter Alexandrou (suspiria@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfscript>
lDSNs = listSort(structKeyList(application.o_serviceFactory.datasourceService.getDatasources()), "textnocase", "asc");
</cfscript>

<cfoutput>
<script language="JavaScript" type="text/javascript">
<!--
function verifyForm() {
    var formObj = document.installForm;
    var siteName = formObj.siteName.value;
    var dsn = formObj.appDSN[formObj.appDSN.selectedIndex].value;

    if (!siteName) {
        alert('Please enter a site name');
        formObj.siteName.focus();
        return false;
    } else if (!dsn) {
        alert('Please select an installation DSN');
        formObj.appDSN.focus();
        return false;
    } else
        return true;
}

function hideIIS(showAlert) {
    if (document.installForm.bInstallIIS.checked) {
        document.getElementById("iisOSType").style.visibility="visible";
        document.getElementById("iisHName").style.visibility="visible";
        document.getElementById("iisAScripts").style.visibility="visible";
    } else {
        document.getElementById("iisOSType").style.visibility="hidden";
        document.getElementById("iisHName").style.visibility="hidden";
        document.getElementById("iisAScripts").style.visibility="hidden";
				if (showAlert) {
			alert('You will need to setup your webserver mappings manually before continuing. Please refer to the install guide for details.');
			}
    }
}


//-->
</script>
</cfoutput>

<cfif isDefined("errorMsg")>
    <cfoutput><p><b><font color="maroon">ERROR:</font><font color="black"><br>#errorMsg#</font></b></p></cfoutput>
</cfif>


<cfif form.dbonly>
	<cfparam name="FORM.bInstallIIS" default="false">
<cfelse>
	<cfparam name="FORM.bInstallIIS" default="true">
</cfif>

<cfoutput>
<form name="installForm" action="#CGI.SCRIPT_NAME#" method="POST" onSubmit="return verifyForm();">
<table border="1" cellspacing="0" cellpadding="3" bgcolor="##EEEEEE" bordercolor="##000000">
<tr>
    <td align="center" bgcolor="##808080"><span class="tableHeading">farcry INSTALLATION SETTINGS</span></td>
</tr>
<tr><td align="center">

<table border="0" cellpadding="3" cellspacing="0" width="450">
<tr>
    <td rowspan="16">&nbsp;</td>
    <td colspan="2" style="height: 10px;">&nbsp;</td>
    <td rowspan="16">&nbsp;</td>
</tr>
<tr>
    <td align="right" nowrap><strong>Site Name</strong></td>
    <td><input type="text" name="siteName" value="#form.siteName#" class="formField" size="30"> <a href="##" onclick="window.open('help.cfm?topic=siteName','help','height=250,width=350')">?</a></td>
</tr>
<tr>
    <td align="right" nowrap><strong>Installation DSN</strong></td>
    <td>
        <select name="appDSN" class="formField">
        <!--- <option value="createnew">&lt;&lt; CREATE NEW &gt;&gt;</option> --->
		<option value=""> </option>
        <cfloop list="#lDSNs#" index="i">
        <option value="#i#"<cfif i eq FORM.appDSN> selected</cfif>>#i#</option>
        </cfloop>
        </select>
		 <a href="##" onclick="window.open('help.cfm?topic=dsn','help','height=250,width=350')">?</a>
    </td>
</tr>
<tr>
    <td align="right" nowrap><strong>DB Type</strong></td>
    <td>
        <select name="dbType" class="formField">
        <option value="odbc"<cfif FORM.dbType eq "sql"> selected</cfif>>SQL Server</option>
        <option value="ora"<cfif FORM.dbType eq "oracle"> selected</cfif>>Oracle</option>
        <option value="mysql"<cfif FORM.dbType eq "mysql"> selected</cfif>>MySQL</option>
        </select>
		 <a href="##" onclick="window.open('help.cfm?topic=dbType','help','height=250,width=350')">?</a>
    </td>
</tr>
<tr>
    <td align="right" nowrap><strong>DB Owner</strong></td>
    <td><input type="text" name="dbOwner" value="#form.dbOwner#" class="formField" size="15"> <a href="##" onclick="window.open('help.cfm?topic=dbOwner','help','height=250,width=350')">?</a></td>
</tr>
<tr>
    <td align="right" nowrap><strong>Application Mapping</strong></td>
    <td><input type="text" name="appMapping" value="#form.appMapping#" class="formField" size="30"> <a href="##" onclick="window.open('help.cfm?topic=appMapping','help','height=250,width=350')">?</a></td>
</tr>
<tr>
    <td align="right" nowrap><strong>FarCry Admin Mapping</strong></td>
    <td><input type="text" name="farcryMapping" value="#form.farcryMapping#" class="formField" size="30"> <a href="##" onclick="window.open('help.cfm?topic=farcryMapping','help','height=250,width=350')">?</a></td>
</tr>
<!--- added/modified by Gary Menzel --->
<!--- makes the hidden DOMAIN form variable accessible --->
<tr>
    <td align="right" nowrap><strong>FarCry Domain</strong></td>
    <td>
    <input type="text" name="domain" value="#cgi.server_name#" class="formField" size="30">
    <a href="##" onclick="window.open('help.cfm?topic=domain','help','height=250,width=350')">?</a></td>
</tr>

<tr>
    <td align="right" nowrap>&nbsp;</td>
    <td><input type="checkbox" value="true" name="dbonly" <cfif FORM.dbonly> checked</cfif>><strong>Install Database only.</strong> <a href="##" onclick="window.open('help.cfm?topic=dbOnly','help','height=250,width=350')">?</a></td>
</tr>
<tr>
    <td align="right" nowrap>&nbsp;</td>
    <td><input type="checkbox" value="true" name="bDeleteApp" <cfif FORM.bDeleteApp> checked</cfif>><strong>Delete farcry_aura on completion</strong> <a href="##" onclick="window.open('help.cfm?topic=deleteApp','help','height=250,width=350')">?</a></td>
</tr>
<tr>
    <td colspan="2" style="height: 10px;">&nbsp;</td>
</tr>
<tr>
    <td>&nbsp;</td>
    <td>
        <input type="submit" name="proceed" value="INSTALL" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle'" onMouseOut="this.className='normalbttnstyle'">
        <input type="reset" name="reset" value="RESET" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle'" onMouseOut="this.className='normalbttnstyle'">
    </td>
</tr>
<tr>
    <td colspan="2" style="height: 10px;">&nbsp;</td>
</tr>
</table>

</td></tr>
</table>
</form>

<cfif not FORM.bInstallIIS>
<script language="JavaScript" type="text/javascript">
	hideIIS(false);
</script>
</cfif>
</cfoutput>