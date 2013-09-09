<cfsetting enablecfoutputonly="true">

<cfset fieldPrefix = "fc#replace(stObj.objectid, "-", "", "all")#">

<cfset canonicalDomain = cgi.http_host>
<cfset seoTitleDefault = "">
<cfset seoDescriptionDefault = "">

<!--- default title --->
<cfif structKeyExists(stObj, "title") AND len(stObj.title)>
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
<!--- default descriptiom --->
<cfif structKeyExists(stObj, "teaser") AND len(stObj.teaser)>
	<cfset seoDescriptionDefault = reReplace(stObj.teaser,"<[^>]*>","","all")>
<cfelse>
	<cfset seoDescriptionDefault = reReplace(stObj.body,"<[^>]*>","","all")>
</cfif>
<cfif len(seoDescriptionDefault) gt 170>
	<cfset seoDescriptionDefault = left(seoDescriptionDefault, 170) & "...">
</cfif>
<!--- default extendedmetadata --->
<cfif NOT len(stObj.extendedmetadata)>
	<cfset stObj.extendedmetadata = seoDescriptionDefault>
</cfif>
<cfif len(stObj.extendedmetadata) gt 170>
	<cfset stObj.extendedmetadata = left(stObj.extendedmetadata, 170) & "...">
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

<script>
$j(function(){

	function truncate(str, length) {
		if (str.length > length) {
			str = str.substring(0, length) + "...";
		}
		return str;
	}

	$j("###fieldPrefix#seoTitle").on("keyup blur", function(){
		var str = truncate($j(this).val(), 69);
		if (str.length) {
			$j(".google-seo-title").text(str);
		}
		else {
			$j(".google-seo-title").text($j(".google-seo-title").data("value"));
		}
	})
	$j("###fieldPrefix#extendedmetadata").on("keyup blur", function(){
		var str = truncate($j(this).val(), 170);
		if (str.length) {
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
	<div class="google-seo-url">#canonicalDomain##application.fapi.getLink(objectid=stObj.objectid)#</div>
	<div class="google-seo-description" data-value="#htmlEditFormat(seoDescriptionDefault)#">#stObj.extendedmetadata#</div>
</div>
</cfoutput>

<cfsetting enablecfoutputonly="false">