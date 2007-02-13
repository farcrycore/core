<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmFlash/edit.cfm,v 1.27.2.4 2006/03/21 05:03:26 jason Exp $
$Author: jason $
$Date: 2006/03/21 05:03:26 $
$Name: milestone_3-0-1 $
$Revision: 1.27.2.4 $

|| DESCRIPTION || 
$Description: edit handler$


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->
<cfsetting enablecfoutputonly="yes">

<cfprocessingDirective pageencoding="utf-8">
<cfimport taglib="/farcry/farcry_core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/farcry_core/tags/navajo/" prefix="nj">
<cfimport taglib="/farcry/farcry_core/tags/widgets" prefix="widgets">

<cfparam name="bFormSubmitted" default="no">
<cfparam name="errormessage" default="">
<!--- default form elements --->
<cfparam name="title" default="">
<cfparam name="height" default="">
<cfparam name="width" default="">
<cfparam name="flashVersion" default="">
<cfparam name="flashParams" default="">
<cfparam name="flashAlign" default="center">
<cfparam name="flashQuality" default="high">
<cfparam name="flashBgcolor" default="##FFFFFF">
<cfparam name="flashPlay" default="0">
<cfparam name="flashLoop" default="0">
<cfparam name="flashMenu" default="0">
<cfparam name="teaser" default="">
<cfparam name="bLibrary" default="0">
<cfparam name="ownedBy" default="">

<cfif isdefined("url.ref") AND url.ref eq "typeadmin"> <!--- typeadmin edit --->
    <cfset cancelCompleteURL = "#application.url.farcry#/content/dmflash.cfm">
<cfelse> <!--- editing from site tree --->
    <cfset cancelCompleteURL = "#application.url.farcry#/edittabOverview.cfm?objectid=#stObj.ObjectID#">
</cfif>

<cfif bFormSubmitted EQ "yes"> <!--- perform the update --->
    <cfset stProperties = structNew()>
    <cfset stProperties.objectid = stObj.objectid>

    <cfset stProperties.title = Trim(title)>
    <cfset stProperties.label = Trim(title)>
    <cfset stProperties.teaser = Trim(teaser)>
    <cfset stProperties.flashHeight = Trim(height)>
    <cfset stProperties.flashWidth = Trim(width)>
    <cfset stProperties.flashQuality = Trim(flashQuality)>
    <cfset stProperties.flashAlign = Trim(flashAlign)>
    <cfset stProperties.flashBgcolor = Trim(flashBgcolor)>
    <cfset stProperties.flashPlay = Trim(flashPlay)>
    <cfset stProperties.flashLoop = Trim(flashLoop)>
    <cfset stProperties.flashMenu = Trim(flashMenu)>
    <cfset stProperties.flashVersion = Trim(flashVersion)>
    <cfset stProperties.flashParams = Trim(flashParams)>
    <cfset stProperties.displayMethod = Trim(displayMethod)>
    <cfset stProperties.bLibrary = Trim(bLibrary)>
    <cfset stProperties.flashmovie = stObj.flashmovie>
    <!--- TODO MUST sort out this date stuff. Can't just keep overwriting datetime created --->
    <cfset stProperties.datetimelastupdated = Now()>
    <cfset stProperties.lastupdatedby = session.dmSec.authentication.userlogin>
    <!--- unlock object --->
    <cfset stProperties.locked = 0>
    <cfset stProperties.lockedBy = "">
    
    <!--- upload the flash movie --->
    <cftry> <!--- check for file to upload --->
        <cfif Trim(form.flash_file_upload) NEQ "">      
            <cffile action="upload" filefield="flash_file_upload" destination="#application.config.file.folderpath_flash#" accept="application/x-shockwave-flash" nameConflict="Overwrite"> 
            <cfset oForm = createObject("component","#application.packagepath#.farcry.form")>
            <cfset stProperties.flashmovie = oForm.sanitiseFileName(file.ServerFile,file.ClientFileName,file.ServerDirectory)>
            <cfif Trim(stobj.flashmovie) NEQ "">
                <cffile action="delete" file="#application.config.file.folderpath_flash##stObj.flashMovie#"> 
            </cfif>         
        </cfif>

        <cfcatch>
            <!--- if error flow back through the page and display the error message --->
            <cfset errormessage = errormessage & application.rb.formatRBString(application.adminBundle[session.dmProfile.locale].cfcatchErrorMsg,cfcatch.message) & "<br>" & application.adminBundle[session.dmProfile.locale].fileMustBeFlash>
        </cfcatch>
    </cftry>
    
    <!--- update the OBJECT if no error occured and reloacte--->
    <cfif Trim(errormessage) EQ "">
        <cfset oType = createobject("component", application.types.dmFlash.typePath)>
        <cfset oType.setData(stProperties=stProperties)>
        <cfif NOT (isdefined("url.ref") AND url.ref eq "typeadmin")> <!--- if not typeadmin edit (from site tree edit) --->
                <!--- get parent to update site js tree --->
                <nj:treeGetRelations typename="#stObj.typename#" objectId="#stObj.ObjectID#" get="parents" r_lObjectIds="ParentID" bInclusive="1">
                <!--- update site js tree --->
                <nj:updateTree objectId="#parentID#">
        </cfif>

<cfoutput><script type="text/javascript">
if(parent['sidebar'].frames['sideTree'])
    parent['sidebar'].frames['sideTree'].location= parent['sidebar'].frames['sideTree'].location;
parent['content'].location.href = "#cancelCompleteURL#"
</script></cfoutput>
        <cfabort>
    </cfif>
<cfelse>
    <cfset title = stObj.title>
    <cfset height = stObj.flashHeight>
    <cfset width = stObj.flashWidth>
    <cfset flashVersion = stObj.flashVersion>
    <cfset flashParams = stObj.flashParams>
    <cfset flashAlign = stObj.flashAlign>
    <cfset flashQuality = stObj.flashQuality>
    <cfset flashBgcolor = stObj.flashBgcolor>
    <cfset flashPlay = stObj.flashPlay>
    <cfset flashLoop = stObj.flashLoop>
    <cfset flashMenu = stObj.flashMenu>
    <cfset teaser = stObj.teaser>
    <cfset bLibrary = stObj.bLibrary>
    <cfset ownedBy = stObj.ownedBy>
</cfif>

<cfoutput>
<form action="#cgi.script_name#?#cgi.query_string#" class="f-wrap-1 wider f-bg-medium" enctype="multipart/form-data" name="fileForm" method="post">
    <fieldset>
        <div class="req"><b>*</b>Required</div>
        <h3>#application.adminBundle[session.dmProfile.locale].generalInfo#: <span class="highlight">#stObj.title#</span></h3>
        <cfif errormessage NEQ "">
            <p id="fading1" class="fade"><span class="error">#errormessage#</span></p>
        </cfif>
        <label for="title"><b>#application.adminBundle[session.dmProfile.locale].titleLabel#<span class="req">*</span></b>
            <input type="text" name="title" id="title" value="#title#" maxlength="255" size="45" /><br />
        </label>
</cfoutput>
        <widgets:displayMethodSelector typeName="#stObj.typename#" prefix="displayPage"><br />

        <widgets:fileUpload fileFieldPrefix="flash" fieldLabel="#application.adminBundle[session.dmProfile.locale].fileLabel#" uploadType="flash" fieldValue="#stObj.flashMovie#" bShowPreview="1">
<cfoutput>
        <label for="height"><b>#application.adminBundle[session.dmProfile.locale].heightLabel#<span class="req">*</span></b>
            <input type="text" name="height" id="height" value="#height#" maxlength="5" /><br />
        </label>

        <label for="width"><b>#application.adminBundle[session.dmProfile.locale].widthLabel#<span class="req">*</span></b>
            <input type="text" name="width" id="width" value="#width#" maxlength="5" /><br />
        </label>

        <label for="flashVersion"><b>#application.adminBundle[session.dmProfile.locale].flashversionLabel#<span class="req">*</span></b>
            <input type="text" name="flashVersion" id="flashVersion" value="#flashVersion#" maxlength="10" /><br />
        </label>

        <label for="flashParams"><b>#application.adminBundle[session.dmProfile.locale].flashParametersLabel#</b>
            <textarea name="flashParams" id="flashParams">#flashParams#</textarea><br />
        </label>

        <label for="flashAlign"><b>#application.adminBundle[session.dmProfile.locale].alignmentLabel#</b>
            <select name="flashAlign" id="flashAlign">
                <option value="left"<cfif flashalign EQ "left"> selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].left#</option>
                <option value="center"<cfif flashalign EQ "center"> selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].center#</option>
                <option value="right"<cfif flashalign EQ "right"> selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].right#</option>
                <option value="top"<cfif flashalign EQ "top"> selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].top#</option>
                <option value="bottom"<cfif flashalign EQ "bottom"> selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].bottom#</option>
            </select><br />
        </label>

        <label for="flashQuality"><b>#application.adminBundle[session.dmProfile.locale].qualityLabel#</b>
            <select name="flashQuality" id="flashQuality">
                <option value="low"<cfif flashQuality EQ "low"> selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].low#</option>
                <option value="medium"<cfif flashQuality EQ "medium"> selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].medium#</option>
                <option value="high"<cfif flashQuality EQ "high"> selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].high#</option>
                <option value="best"<cfif flashQuality EQ "best"> selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].best#</option>
                <option value="autoHigh"<cfif flashQuality EQ "autoHigh"> selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].autoHigh#</option>
            <option value="autoLow"<cfif flashQuality EQ "autoLow"> selected="selected"</cfif>>#application.adminBundle[session.dmProfile.locale].autoLow#</option>
            </select><br />
        </label>

        <label for="flashBgcolor"><b>#application.adminBundle[session.dmProfile.locale].widthLabel#</b>
            <input type="text" name="flashBgcolor" id="flashBgcolor" value="#flashBgcolor#" maxlength="7" /><br />
        </label>
        
        <fieldset class="f-radio-wrap">
            <b>#application.adminBundle[session.dmProfile.locale].automaticPlayLabel#</b>
            <fieldset>
                <label for="flashPlay">
                    <input type="radio" name="flashPlay" id="flashPlay" value="1"<cfif flashPlay EQ 1> checked="checked"</cfif> class="f-radio"> #application.adminBundle[session.dmProfile.locale].trueTxt#&nbsp;&nbsp;
                    <input type="radio" name="flashPlay" id="flashPlay" value="0"<cfif flashPlay EQ 0> checked="checked"</cfif> class="f-radio"> #application.adminBundle[session.dmProfile.locale].falseTxt#
                </label>
            </fieldset>
        </fieldset>
        
        <fieldset class="f-radio-wrap">
            <b>#application.adminBundle[session.dmProfile.locale].loopLabel#</b>
            <fieldset>
                <label for="flashLoop">
                    <input type="radio" name="flashLoop" id="flashLoop" value="1" <cfif flashLoop EQ 1>checked="checked"</cfif> class="f-radio"> #application.adminBundle[session.dmProfile.locale].trueTxt#&nbsp;&nbsp;
                    <input type="radio" name="flashLoop" id="flashLoop" value="0" <cfif flashLoop EQ 0>checked="checked"</cfif> class="f-radio"> #application.adminBundle[session.dmProfile.locale].falseTxt#
                </label>
            </fieldset>
        </fieldset>
        
        <fieldset class="f-radio-wrap">
            <b>#application.adminBundle[session.dmProfile.locale].showMenuLabel#</b>
            <fieldset>
                <label for="flashMenu">
                    <input type="radio" name="flashMenu" id="flashMenu" value="1" <cfif flashMenu EQ 1>checked="checked"</cfif> class="f-radio"> #application.adminBundle[session.dmProfile.locale].trueTxt#&nbsp;&nbsp;
                    <input type="radio" name="flashMenu" id="flashMenu" value="0" <cfif flashMenu EQ 0>checked="checked"</cfif> class="f-radio"> #application.adminBundle[session.dmProfile.locale].falseTxt#
                </label>
            </fieldset>
        </fieldset>
        
        <label for="teaser"><b>#application.adminBundle[session.dmProfile.locale].teaserLabel#</b>
            <textarea name="teaser" id="teaser">#teaser#</textarea><br />
        </label>

        <label for="bLibrary"><b>Flash Library:</b>
            <input type="checkbox" name="bLibrary" value="1" id="bLibrary"<cfif bLibrary EQ 1> checked="checked"</cfif>>
        </label>
    </fieldset>

</cfoutput>
    <widgets:ownedBySelector fieldLabel="Content Owner:" selectedValue="#ownedBy#">
<cfoutput>
    <div class="f-submit-wrap">
    <input type="submit" name="submit" value="OK" class="f-submit" />
    <input type="submit" name="cancel" value="Cancel" class="f-submit" />
    </div>
    <input type="hidden" name="bFormSubmitted" value="yes">
</form>
<script type="text/javascript">
//bring focus to title
document.fileForm.title.focus();
qFormAPI.errorColor="##cc6633";
objForm = new qForm("fileForm");
objForm.title.validateNotNull("#application.adminBundle[session.dmProfile.locale].pleaseEnterTitle#");
objForm.height.validateNotNull("#application.adminBundle[session.dmProfile.locale].pleaseEnterHeight#");
objForm.width.validateNotNull("#application.adminBundle[session.dmProfile.locale].pleaseEnterWidth#");
objForm.flashVersion.validateNotNull("#application.adminBundle[session.dmProfile.locale].pleaseEnterFlashVer#");
</script></cfoutput>
<cfsetting enablecfoutputonly="no">