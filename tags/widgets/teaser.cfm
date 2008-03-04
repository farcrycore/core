<cfsetting enablecfoutputonly="true">

<cfimport taglib="/farcry/core/tags/farcry" prefix="farcry" />
<farcry:deprecated message="widgets tag library is deprecated; please use formtools." />

<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/farcry" prefix="tags">
<cfparam name="caller.output" default="#StructNew()#">
<cfset output = caller.output>
<cfset relatedItems = ArrayToList(output.aobjectids)>
<cfoutput>

<div class="teaser-image">
<h3>#apapplication.rb.getResource("teaserImage")#</h3>
<select id="teaserImage" name="teaserImage" onchange="ftglTeaserImage(this);return false">
	<option value="" class="subdued">#apapplication.rb.getResource("None")#</option>
	<cfloop list="#relatedItems#" index="id">
		<q4:contentobjectget objectid="#id#" r_stobject="stImages">
		<cfif isDefined("stImages.typeName") AND stImages.typeName eq "dmImage">
			<option value="#stImages.objectID#" <cfif output.teaserImage EQ id>selected="selected"</cfif>>#stImages.title#</option>
		</cfif>
	</cfloop>
</select>
<img id="teaserImage_preview" src="../images/no_thumbnail.gif" alt="currently no thumbnail" />
</div>

<div class="teaser-text">
<h3>Teaser text</h3>
<tags:countertext formname="editform" fieldname="teaser" fieldvalue="#output.teaser#" counter="#application.config.general.teaserLimit#">
</div>

<script type="text/javascript">

function ftglTeaserImage(objSelect)
{
	var objImage = document.getElementById("teaserImage_preview");
	if(objSelect.selectedIndex > 0){
		objectid = objSelect.options[objSelect.selectedIndex].value;
		var req = new DataRequestor();
		strURL = "#application.url.farcry#/includes/generateLibraryXML.cfm";

		req.addArg(_GET,"action","getItemByObjectID");
		req.addArg(_GET,"lObjectID",objectid);
		req.addArg(_GET,"libraryType","dmImage");
		req.onload = fUpdateImage;
		req.onfail = function (status){alert("Sorry and error occured while retrieving data [" + status + "]")};
		req.getURL(strURL,_RETURN_AS_TEXT);
	}
	else {
		objImage.src = "#application.url.farcry#/images/no_thumbnail.gif";
		objImage.alt = "currently no thumbnail";
	}
}

function fUpdateImage(data, obj)
{
	var arItem = JSON.parse(data);
	fDisplayTeaserImage(arItem);
}

function doUpdateTeaserImage(arItems)
{
	var objImage = document.getElementById("teaserImage_preview");
	var objSelect = document.getElementById("teaserImage");
	var imgSrc = "#application.url.farcry#/images/no_thumbnail.gif";
	var imgAlt = "currently no thumbnail";
	iObjectID = objSelect.options[objSelect.selectedIndex].value
	objSelect.length = 1;
	if(arItems.length){
		for(i=0;i<arItems.length;i++){
			objSelect.options[i+1] = new Option(arItems[i]["text"],arItems[i]["value"]);
			if(iObjectID == arItems[i]["value"])
				objSelect.options[i+1].selected = true;
		}
	}else
		objSelect.selectedIndex = 0;
	ftglTeaserImage(objSelect);
}

function fDisplayTeaserImage(arItem){
	var objImage = document.getElementById("teaserImage_preview");
	if(arItem.length){
		objImage.src = arItem[0]["value"];
		objImage.alt = arItem[0]["text"];
	}else{
		objImage.src = "#application.url.farcry#/images/no_thumbnail.gif";
		objImage.alt = "currently no thumbnail";
	}
}

ftglTeaserImage(document.getElementById("teaserImage"));
</script>
</cfoutput>
<cfsetting enablecfoutputonly="false">