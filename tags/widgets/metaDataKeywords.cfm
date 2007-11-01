<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
<farcry:deprecated message="widgets tag library is deprecated; please use formtools." />

<cfparam name="attributes.fieldNameKeywords" default="metakeywords">
<cfparam name="attributes.fieldNameExtendedMetadata" default="extendedmetadata">
<cfparam name="attributes.fieldLabelKeywords" default="#application.adminBundle[session.dmProfile.locale].keywordsLabel#">
<cfparam name="attributes.fieldLabelExtendedMetadata" default="#application.adminBundle[session.dmProfile.locale].extendedMetadata#">
<cfparam name="attributes.FieldValueKeywords" default="">
<cfparam name="attributes.FieldValueExtendedMetadata" default="">
<cfparam name="attributes.bExtendedMetadata" default="1">
<cfparam name="attributes.bKeyword" default="1">

<cfparam name="errormessage" default="">

<cfoutput>
<cfif attributes.bKeyword>
<label for="metakeywords"><b>#attributes.fieldLabelKeywords#</b>
	<input type="text" name="#attributes.fieldNameKeywords#" id="metakeywords" value="#attributes.FieldValueKeywords#" maxlength="255" size="45" /><br />
</label></cfif>
<cfif attributes.bExtendedMetadata>
<label for="extendedmetadata" style="width:360px"><b>#attributes.fieldLabelExtendedMetadata#</b>
	<a href="javascript:void(0);" onclick="doToggle('extendedmetadata','bHasMetaData');"><cfif trim(attributes.FieldValueExtendedMetadata) EQ ""><img src="#application.url.farcry#/images/no.gif" id="tglextendedmetadata_image" border="0" alt="#application.adminBundle[session.dmProfile.locale].extendedMetadata#"><cfelse>
		<img src="#application.url.farcry#/images/yes.gif" id="tglextendedmetadata_image" border="0" alt="#application.adminBundle[session.dmProfile.locale].noExtendedMetadata#"></cfif>
	</a>
	<span id="tglextendedmetadata" style="display:<cfif Trim(attributes.FieldValueExtendedMetadata) EQ ''>none<cfelse>inline</cfif>;">
	<textarea name="#attributes.fieldNameExtendedMetadata#" id="extendedmetadata" wrap="off" class="f-comments f-comments2">#attributes.FieldValueExtendedMetadata#</textarea><br />
	#application.adminBundle[session.dmProfile.locale].insertedInHeadBlurb#
	</span>
	<input type="hidden" id="bHasMetaData" name="bHasMetaData" value="#Len(trim(attributes.FieldValueExtendedMetadata))#">
</label></cfif>
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
</cfoutput>
<cfsetting enablecfoutputonly="false">