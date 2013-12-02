<cfsetting enablecfoutputonly="true">

<cfset fieldPrefix = "fc#replace(stObj.objectid, "-", "", "all")#">

<cfset canonicalDomain = application.fc.lib.seo.getCanonicalDomain(bUseHostname=true)>
<cfif structKeyExists(stObj, "versionid") AND isValid("uuid", stObj.versionid)>
	<cfset canonicalFU = application.fc.lib.seo.getCanonicalFU(objectid=stObj.versionid, typename=stObj.typename)>
<cfelse>
	<cfset canonicalFU = application.fc.lib.seo.getCanonicalFU(stObject=stObj)>
</cfif>
<cfset seoTitleDefault = "">
<cfset seoDescriptionDefault = "">

<!--- title --->
<cfparam name="stObj.label" default="">
<cfparam name="stObj.title" default="">
<cfparam name="stObj.seoTitle" default="">
<cfif len(stObj.title)>
	<cfset seoTitleDefault = reReplace(stObj.title,"<[^>]*>","","all")>
<cfelse>
	<cfset seoTitleDefault = stObj.label>
</cfif>
<cfif NOT len(stObj.seoTitle)>
	<cfset stObj.seoTitle = seoTitleDefault>
</cfif>
<cfif len(stObj.seoTitle) gt 69>
	<cfset stObj.seoTitle = left(stObj.seoTitle, 69) & "...">
</cfif>

<!--- description --->
<cfparam name="stObj.body" default="">
<cfparam name="stObj.teaser" default="">
<cfparam name="stObj.extendedmetadata" default="">
<cfparam name="stObj.seoDescription" default="">
<cfif structKeyExists(stObj, "teaser") AND len(stObj.teaser)>
	<cfset seoDescriptionDefault = reReplace(stObj.teaser,"<[^>]*>","","all")>
<cfelse>
	<cfset seoDescriptionDefault = reReplace(stObj.body,"<[^>]*>","","all")>
</cfif>
<cfif NOT len(stObj.extendedmetadata)>
	<cfset stObj.extendedmetadata = seoDescriptionDefault>
</cfif>
<cfif len(stObj.extendedmetadata) gt 170>
	<cfset stObj.extendedmetadata = left(stObj.extendedmetadata, 170) & "...">
</cfif>
<cfif NOT len(stObj.seoDescription)>
	<cfset stObj.seoDescription = stObj.extendedmetadata>
</cfif>
<cfif len(stObj.seoDescription) gt 170>
	<cfset stObj.seoDescription = left(stObj.seoDescription, 170) & "...">
</cfif>


<cfoutput>
<style type="text/css">
.google-seo-container {
	padding: 0.5em;
	background: ##FFF7ED;
	margin: 0 auto;
	margin-bottom: 2em;
}
.google-preview {
	float: right;
	font-size: 11px;
	margin-bottom: 0.75em;
}
.google-seo-title {
	font-family: Arial, ​sans-serif;
	font-size: 16px;
	font-weight: 400;
	color: ##1122CC;
	text-decoration: underline;
	line-height: 19.2px;
	margin-bottom: 2px;
	max-width: 556px;
}
.google-seo-url {
	font-family: Arial, ​sans-serif;
	font-size: 14px;
	font-weight: 400;
	font-style: normal;
	color: ##009933;
	line-height: 16.8px;
	margin-bottom: 3px;
}
.google-seo-description {
	font-family: Arial,​ sans-serif;
	font-size: 13px;
	font-weight: 400;
	color: ##444444;
	line-height: 16.1167px;
	max-width: 556px;
}
</style>

<script type="text/javascript">
$j(function(){

	function truncate(str, length) {
		if (str.length > length) {
			str = str.substring(0, length) + "...";
		}
		return str;
	}

	$j("###fieldPrefix#seoTitle").on("keyup blur", function(){
		var str = truncate($j(this).val(), 69);
		if ($j.trim(str).length) {
			$j(".google-seo-title").text(str);
		}
		else {
			$j(".google-seo-title").text($j(".google-seo-title").data("value"));
		}
	})
	$j("###fieldPrefix#seoDescription").on("keyup blur", function(){
		var str = truncate($j(this).val(), 170);
		if ($j.trim(str).length) {
			$j(".google-seo-description").text(str);
		}
		else {
			$j(".google-seo-description").text($j(".google-seo-description").data("value"));
		}
	})
});
</script>

<div class="google-seo-container">
	<div class="google-preview">Google Search Result Preview</div>
	<div class="google-seo-title" data-value="#htmlEditFormat(seoTitleDefault)#">#stObj.seoTitle#</div>
	<div class="google-seo-url">#canonicalDomain##canonicalFU#</div>
	<div class="google-seo-description" data-value="#htmlEditFormat(seoDescriptionDefault)#">#stObj.seoDescription#</div>
</div>
</cfoutput>

<cfsetting enablecfoutputonly="false">