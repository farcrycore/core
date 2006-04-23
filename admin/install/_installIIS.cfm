<cfif form.osType eq "server">
    <cfif form.hostName neq "">
        <cfexecute name="cscript" arguments="//B #form.iisAdminPath#\mkw3site.vbs -r ""#application.path.project#\www"" -t ""#form.siteName#"" -h ""#form.hostName#""" timeout="5"></cfexecute>
    <cfelse>
        <cfexecute name="cscript" arguments="//B #form.iisAdminPath#\mkw3site.vbs -r ""#application.path.project#\www"" -t ""#form.siteName#""" timeout="5"></cfexecute>
    </cfif>
</cfif>

<!--- determing site number created --->
<cfsavecontent variable="siteInfo">
<cfoutput><cfexecute name="cscript" arguments="//NoLogo #form.iisAdminPath#\findweb.vbs ""#form.siteName#""" timeout="3"></cfexecute></cfoutput>
</cfsavecontent>

<cfscript>
if (trim(siteInfo) contains "No matching web found") siteNum = 1;
else siteNum = listGetAt(replace(trim(siteInfo), "#chr(13)##chr(10)#", "", "ALL"), 5, " ");
</cfscript>

<cfif form.osType eq "workstation" AND form.hostname neq "">
    <cfexecute name="cscript" arguments="//B #form.iisAdminPath#\adsutil.vbs SET w3svc/#siteNum#/ServerBindings "":80:#form.hostName#""" timeout="3"></cfexecute>
</cfif>

<cfexecute name="cscript" arguments="//B #form.iisAdminPath#\adsutil.vbs SET w3svc/#siteNum#/ServerComment ""#form.siteName#""" timeout="3"></cfexecute>
<cfexecute name="cscript" arguments="//B #form.iisAdminPath#\adsutil.vbs SET w3svc/#siteNum#/Root/DefaultDoc ""index.cfm,index.cfml,index.html,index.htm""" timeout="3"></cfexecute>
<cfexecute name="cscript" arguments="//B #form.iisAdminPath#\adsutil.vbs SET w3svc/#siteNum#/Root/Path ""#application.path.project#\www""" timeout="3"></cfexecute>
<cfexecute name="cscript" arguments="//B #form.iisAdminPath#\adsutil.vbs SET w3svc/#siteNum#/Root/AppIsolated 2" timeout="3"></cfexecute>

<cfexecute name="cscript" arguments="//B #form.iisAdminPath#\mkwebdir.vbs -w #siteNum# -v ""farcry"",""#application.path.core#\admin""" timeout="3"></cfexecute>
<cfexecute name="cscript" arguments="//B #form.iisAdminPath#\chaccess.vbs -a ""w3svc/#siteNum#/Root/farcry"" +read -write -browse +script -execute" timeout="3"></cfexecute>
