<!---
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmFacts/plpEdit/start.cfm,v 1.16.2.5 2006/03/21 05:03:26 jason Exp $
$Author: jason $
$Date: 2006/03/21 05:03:26 $
$Name: milestone_3-0-1 $
$Revision: 1.16.2.5 $

|| DESCRIPTION ||
First step of dmFact plp. Adds title, link, body and uploads image if needed.

|| DEVELOPER ||
Brendan Sisson (brendan@daemon.com.au)
--->
<cfsetting enablecfoutputonly="yes">
<cfprocessingDirective pageencoding="utf-8">
<cfparam name="errormessage" default="">

<cfimport taglib="/farcry/farcry_core/tags/widgets" prefix="widgets">

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<cfif isDefined("form.plpAction")>
    <cfif errormessage EQ "">
        <widgets:plpAction>
    </cfif>
</cfif>

<!--- show form --->
<cfif NOT thisstep.isComplete>
<widgets:plpWrapper><cfoutput>
<cfif errormessage NEQ "">
    <p id="fading1" class="fade"><span class="error">#errormessage#</span></p>
</cfif>
<form action="#cgi.script_name#?#cgi.query_string#" class="f-wrap-1 wider f-bg-short" name="editform" method="post" enctype="multipart/form-data">
    <fieldset>
    <div class="req"><b>*</b>Required</div>
    <label for="title"><b>#application.adminBundle[session.dmProfile.locale].titleLabel#<span class="req">*</span></b>
        <input type="text" name="title" id="title" value="#output.title#" maxlength="255" size="45" /><br />
    </label>

    <label for="link"><b>#application.adminBundle[session.dmProfile.locale].linkLabel#</b>
        <input type="text" name="link" id="link" value="#output.link#" maxlength="255" size="45" /><br />
    </label>
</cfoutput>
    <widgets:objectPicker fieldName="imageID" fieldlabel="Fact Image:" fieldvalue="#output.imageID#" typename="dmImage">
<cfoutput>
    <label for="body"><b>#application.adminBundle[session.dmProfile.locale].bodyLabel#</b>
        <textarea name="body" id="body">#output.body#</textarea><br />
    </label>
</cfoutput>
    <widgets:displayMethodSelector typeName="#output.typeName#">
<cfoutput>
    </fieldset>

    <input type="hidden" name="plpAction" value="" />
    <input style="display:none;" type="submit" name="buttonSubmit" value="submit" />
</form>
<cfinclude template="/farcry/farcry_core/admin/includes/QFormValidationJS.cfm">
</cfoutput>
</widgets:plpWrapper>
<cfelse>
    <!--- update plp data and move to next step --->
    <widgets:plpUpdateOutput>
</cfif>
<cfsetting enablecfoutputonly="no">