<cfsetting enablecfoutputonly="Yes">

<cfparam name="FORM.sourceDSN" default="rocheIntranet">
<cfparam name="FORM.targetDSN" default="farcry_Roche">

<cfparam name="bShowForm" default="true">

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>farcry Migration</title>
<link rel="STYLESHEET" type="text/css" href="migration.css">
</head>
<body>
<div align="center">
<p><img src="#application.url.farcry#/images/farcry_logo.gif" alt="farcry" width="265" height="70" border="0" align="bottom"></p>
</cfoutput>

<!--- handle form processing --->
<cfif isDefined("form.submit")>
    <!--- ensure we have all required information to commence with the migration --->
    <cfif FORM.sourceDSN neq "" AND FORM.targetDSN neq "">
        <!--- form validated so kickstart migration scripts --->

        <cfoutput><p>Migrating categories... </cfoutput>
        <cfflush>
        <cf_migrateCategories sourceDSN="#FORM.sourceDSN#" migrateDSN="#FORM.targetDSN#" r_bSuccess="bSuccess">
        <cfif bSuccess>
            <cfoutput><strong><font color="green">SUCCESS</font></strong></p></cfoutput>
            <cfset bShowForm = "false">
            <cfflush>
        <cfelse>
            <cfoutput><strong><font color="maroon">FAILED</font></strong></p></cfoutput>
            <cfflush>
        </cfif>

        <cfoutput><p>Migrating tree... </cfoutput>
        <cfflush>
        <cf_migrateTree sourceDSN="#FORM.sourceDSN#" migrateDSN="#FORM.targetDSN#" r_bSuccess="bSuccess">
        <cfif bSuccess>
            <cfoutput><strong><font color="green">SUCCESS</font></strong></p></cfoutput>
            <cfflush>
            <cfset bShowForm = "false">
        <cfelse>
            <cfoutput><strong><font color="maroon">FAILED</font></strong></p></cfoutput>
            <cfflush>
        </cfif>

        <cfoutput><p>Migrating news... </cfoutput>
        <cfflush>
        <cf_migrateNews sourceDSN="#FORM.sourceDSN#" migrateDSN="#FORM.targetDSN#" r_bSuccess="bSuccess">
        <cfif bSuccess>
            <cfoutput><strong><font color="green">SUCCESS</font></strong></p></cfoutput>
            <cfflush>
            <cfset bShowForm = "false">
        <cfelse>
            <cfoutput><strong><font color="maroon">FAILED</font></strong></p></cfoutput>
            <cfflush>
        </cfif>

        <cfoutput><p>Fixing old content... </cfoutput>
        <cfflush>
        <cf_fixContent datasource="#FORM.targetDSN#" r_bSuccess="bSuccess">
        <cfif bSuccess>
            <cfoutput><strong><font color="green">SUCCESS</font></strong></p></cfoutput>
            <cfflush>
            <cfset bShowForm = "false">
        <cfelse>
            <cfoutput><strong><font color="maroon">FAILED</font></strong></p></cfoutput>
            <cfflush>
        </cfif>
    </cfif>
</cfif>

<!--- display form --->
<cfif bShowForm>
    <cfscript>
    lDSNs = listSort(structKeyList(application.o_serviceFactory.datasourceService.getDatasources()), "textnocase", "asc");
    </cfscript>

    <cfoutput>
<p>Please complete the form below with your migration options...</p>

<form action="#CGI.SCRIPT_NAME#" method="POST" name="migrateForm">
<table border="1" cellspacing="0" cellpadding="3" bgcolor="##EEEEEE" bordercolor="##000000">
<tr>
    <td align="center" bgcolor="##808080"><span class="tableHeading">MIGRATION SETTINGS</span></td>
</tr>
<tr><td align="center">

<table border="0" cellpadding="3" cellspacing="0" width="400">
<tr>
    <td rowspan="10">&nbsp;</td>
    <td colspan="2" style="height: 10px;"></td>
    <td rowspan="10">&nbsp;</td>
</tr>
<tr>
    <td class="formLabel">NAVAJO Datasource</td>
    <td>
        <select name="sourceDSN" class="formField">
        <cfloop list="#lDSNs#" index="i">
        <option value="#i#"<cfif i eq FORM.sourceDSN> selected</cfif>>#i#</option>
        </cfloop>
        </select>
    </td>
</tr>
<tr>
    <td class="formLabel">FARCRY Datasource</td>
    <td>
        <select name="targetDSN" class="formField">
        <cfloop list="#lDSNs#" index="i">
        <option value="#i#"<cfif i eq FORM.targetDSN> selected</cfif>>#i#</option>
        </cfloop>
        </select>
    </td>
</tr>
<tr>
    <td colspan="2" style="height: 10px;"></td>
</tr>
<tr>
    <td>&nbsp;</td>
    <td>
        <input type="submit" name="submit" value="MIGRATE DB" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle'" onMouseOut="this.className='normalbttnstyle'">
        <input type="button" name="clear" value="CLEAR" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle'" onMouseOut="this.className='normalbttnstyle'" onClick="clearForm()">
    </td>
</tr>
<tr>
    <td colspan="2" style="height: 10px;"></td>
</tr>
</table>

</td></tr>
</table>
</form>
    </cfoutput>
<cfelse>
    <cfoutput>
    <h3>Operation completed successfully!</h3>
    </cfoutput>
</cfif>

<cfoutput>
<font size="1">&copy; 2003 Daemon Internet Consultants</font>

</div>
</body>
</html>
</cfoutput>

<cfsetting enablecfoutputonly="No">