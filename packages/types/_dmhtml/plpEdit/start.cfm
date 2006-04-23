<cfsetting enablecfoutputonly="Yes">
<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/packages/types/_dmhtml/plpEdit/start.cfm,v 1.18 2005/09/07 05:26:14 daniela Exp $
$Author: daniela $
$Date: 2005/09/07 05:26:14 $
$Name: milestone_3-0-0 $
$Revision: 1.18 $

|| DESCRIPTION || 
$Description: dmHTML PLP - Start Step $
$TODO: clean up formatting -- test in Mozilla 20030503 GB$

|| DEVELOPER ||
$Developer: Geoff Bowers (modius@daemon.com.au) $
--->
<cfprocessingDirective pageencoding="utf-8">
<cfparam name="errormessage" default="">
<cfparam name="bHasMetaData" default="0">

<cfimport taglib="/farcry/farcry_core/tags/widgets" prefix="widgets">

<cfset thisstep.isComplete = 0>
<cfset thisstep.name = stplp.currentstep>

<cfif isDefined("form.plpAction")>
	<cfif bHasMetaData EQ 0>
		<cfset form.extendedmetadata = "">
	</cfif>

	<cfif form.noReview EQ 1>
		<cfset reviewDate = '2050-#form.reviewMonth#-#form.reviewDay#'>
	<cfelse>
		<cfset reviewDate = '#form.reviewYear#-#form.reviewMonth#-#form.reviewDay#'>
	</cfif>

	<cfset output.reviewDate = createODBCDatetime(reviewDate)>
	
	<cfif errormessage EQ "">
		<widgets:plpAction>
	</cfif>
<cfelse>
	<cfif NOT IsDate(output.reviewDate)>
		<cfset output.reviewDate = DateAdd("d",application.config.general.contentReviewdayspan,now())>
	</cfif>
</cfif>

<cfif Trim(output.versionID) NEQ "">
	<cfinvoke  component="#application.packagepath#.farcry.versioning" method="getArchives" returnvariable="qListArchives">
		<cfinvokeargument name="objectID" value="#output.versionID#"/>
	</cfinvoke>
</cfif>

<cfif NOT thisstep.isComplete>
<widgets:plpWrapper><cfoutput>
<form action="#cgi.script_name#?#cgi.query_string#" class="f-wrap-1 wider f-bg-short" name="editform" method="post">	
	<fieldset>
		<div class="req"><b>*</b>Required</div>
<h3>#application.adminBundle[session.dmProfile.locale].generalInfo#: <span class="highlight">#output.label#</span></h3>
<cfif errormessage NEQ "">
<p id="fading1" class="fade"><span class="error">#errormessage#</span></p>
</cfif>
	<label for="title"><b>#application.adminBundle[session.dmProfile.locale].titleLabel#<span class="req">*</span></b>
		<input type="text" name="title" id="title" value="#output.title#" maxlength="255" /><br />
	</label>

	<label for="metakeywords"><b>#application.adminBundle[session.dmProfile.locale].keywordsLabel#</b>
		<input type="text" name="metakeywords" id="metakeywords" value="#output.metakeywords#" maxlength="255" /><br />
	</label>

	<label for="extendedmetadata"><b>#application.adminBundle[session.dmProfile.locale].extendedMetadata#</b>
		<a href="javascript:void(0);" onclick="doToggle('extendedmetadata','bHasMetaData');"><cfif trim(output.extendedmetadata) EQ ""><img src="#application.url.farcry#/images/no.gif" id="tglextendedmetadata_image" border="0" alt="#application.adminBundle[session.dmProfile.locale].extendedMetadata#"><cfelse>
			<img src="#application.url.farcry#/images/yes.gif" id="tglextendedmetadata_image" border="0" alt="#application.adminBundle[session.dmProfile.locale].noExtendedMetadata#"></cfif>
		</a>
		<span id="tglextendedmetadata" style="display:<cfif Trim(output.extendedmetadata) EQ ''>none<cfelse>inline</cfif>;">
		<textarea name="extendedmetadata" id="extendedmetadata" wrap="off">#output.extendedmetadata#</textarea><br />
		#application.adminBundle[session.dmProfile.locale].insertedInHeadBlurb#
		</span>
		<input type="hidden" id="bHasMetaData" name="bHasMetaData" value="#Len(trim(output.extendedmetadata))#">
	</label>

	<widgets:dateSelector fieldNameprefix="Review" bShowTime="0" bDateToggle="1">
	<widgets:ownedBySelector fieldLabel="Content Owner:" selectedValue="#output.ownedBy#">
	<widgets:displayMethodSelector typeName="#output.typeName#" prefix="displayPage">

</fieldset>
<!--- show coment log --->
<fieldset>
	<label><b>Comment Log:</b>
		<a href="javascript:void(0);" onclick="doToggle('CommentLog');">
			<img src="#application.url.farcry#/images/no.gif" id="tglCommentLog_image" border="0" alt="show hide comments">
		</a>
		<span id="tglCommentLog" style="display:none;"><textarea disabled="true" wrap="off"><cfif trim(output.commentLog) NEQ "">
		#trim(output.commentLog)#<cfelse>
		#application.adminBundle[session.dmProfile.locale].noComments#</cfif></textarea><br />
		</span>
	</label>
</fieldset>
	<!--- show archived --->
	<cfif Trim(output.versionID) NEQ "" AND qListArchives.recordCount GT 0>
<fieldset>
	<label><b>Archived Versions:</b>
		<a href="javascript:void(0);" onclick="doToggle('Archive');">
			<img src="#application.url.farcry#/images/no.gif" id="tglArchive_image" border="0" alt="show hide archive">
		</a>
		<span id="tglArchive" style="display:none;">
<table border="0" cellspacing="0" cellpadding="0">
<tr>
	<td>#application.adminBundle[session.dmProfile.locale].view#</td>
	<td>#application.adminBundle[session.dmProfile.locale].label#</td>
	<td>#application.adminBundle[session.dmProfile.locale].archiveDate#</td>
	<td>#application.adminBundle[session.dmProfile.locale].by#</td>
</tr><cfloop query="qListArchives"><cfset previewURL = "#application.url.farcry#/navajo/displayArchive.cfm?objectID=#qListArchives.objectID#">
<tr>
	<td><a href="#previewURL#" target="_blank"><img src="#application.url.farcry#/images/treeImages/preview.gif" border="0"></a> </td>
	<td><a href="#previewURL#">#qListArchives.label#</a></td>
	<td>#application.thisCalendar.i18nDateFormat(qListArchives.dateTimeCreated,session.dmProfile.locale,application.mediumF)#</td>
	<td>#qListArchives.lastUpdatedBy#</td>
</tr></cfloop>
</table><br />
		</span>
	</label>
</fieldset></cfif>

<input type="hidden" name="plpAction" value="" />
<input style="display:none;" type="submit" name="buttonSubmit" value="submit" />
</form>
<!--- form validation --->
<script type="text/javascript">
<!--//
function doToggle(prefix,bHiddenFieldName){
	objTgl = document.getElementById('tgl' + prefix);
	objTglImage = document.getElementById('tgl' + prefix + '_image');

	if(bHiddenFieldName)
		objTglHiddenValue = document.getElementById(bHiddenFieldName);

	if(objTgl.style.display == "none"){
		objTgl.style.display = "inline";
		objTglImage.src = "#application.url.farcry#/images/yes.gif";
//		objTglImage.alt = "#application.adminBundle[session.dmProfile.locale].noExtendedMetadata#";
		if(bHiddenFieldName)
			objTglHiddenValue.value = 1;
	}else {
		objTgl.style.display = "none";
		objTglImage.src = "#application.url.farcry#/images/no.gif";
//		objTglImage.alt = "#application.adminBundle[session.dmProfile.locale].extendedMetadata#";
		if(bHiddenFieldName)
			objTglHiddenValue.value = 0;
	}	
}
//-->
</script>
<cfinclude template="/farcry/farcry_core/admin/includes/QFormValidationJS.cfm">
</cfoutput>
</widgets:plpWrapper>
<cfelse>
	<widgets:plpUpdateOutput>
</cfif>

<cfsetting enablecfoutputonly="no">