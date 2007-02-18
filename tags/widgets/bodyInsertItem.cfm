<cfsetting enablecfoutputonly="true">
<cfimport taglib="/farcry/core/packages/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/core/tags/navajo" prefix="nj">
<cfparam name="caller.output" default="#StructNew()#">
<cfparam name="caller.delaObjectID" default="">
<cfparam name="attributes.typename" default="dmImage">
<cfset output = caller.output>
<cfset relatedItems = ArrayToList(output.aobjectids)>
<cfset primaryObjectID = output.objectid>
<cfset typeName = attributes.typename>
<cfif typeName EQ "dmImage">
	<cfset strDisplayTypeName = "Image">
<cfelse>
	<cfset strDisplayTypeName = "File">
</cfif>

<nj:listTemplates typename="#attributes.typename#" prefix="inserthtml" r_qMethods="qListTemplate">

<cfdirectory directory="#application.path.project#\webskin\#typeName#" name="qListTemplates" filter="inserthtml*">
<cfset aInsertHtmlTemplates = ArrayNew(1)>
<cfloop query="qListTemplates">
	<cfset stTemp = StructNew()>
	<cfset stTemp.display_name = ListFirst(ListLast(qListTemplates.name,"_"),".")>
	<cfset stTemp.template_name = qListTemplates.name>
	<cfset ArrayAppend(aInsertHtmlTemplates, stTemp)>
</cfloop>

<!--- do all processing before entering html to avoid whitespace and have cleaner code --->
<cfset aLibraryItem = ArrayNew(1)>
<cfset aRelatedItemsIDs = ListToArray(relatedItems)>
<cfset iCounter = 0>
<cfset objImage = CreateObject("component","#application.types.dmImage.typepath#")>
<cfloop index="i" from="1" to="#ArrayLen(aRelatedItemsIDs)#">
	<!--- get object details --->
	<q4:contentobjectget objectid="#aRelatedItemsIDs[i]#" r_stobject="stItem">
	<cfif NOT structisEmpty(stItem) AND stItem.typeName eq typeName> <!--- check item exist and is the type we want --->
		<cfswitch expression="#typeName#">
			<cfcase value="dmImage">
				<cfif stItem.sourceImage neq "">
					<cfset iCounter = iCounter + 1>
					<cfset aLibraryItem[iCounter] = StructNew()>
					<cfset aLibraryItem[iCounter].text = stItem.title>

					<cfset imageurl_default = objImage.getURLImagePath(stItem.objectID,"original")>
					<cfset imageurl_thumbnail = objImage.getURLImagePath(stItem.objectID,"thumb")>
					<cfset imageurl_highres = objImage.getURLImagePath(stItem.objectID,"optimised")>

					<!--- default thumbnail to original if it doesnt exist --->
					<cfif trim(imageurl_thumbnail) EQ "">
						<cfset imageurl_thumbnail = imageurl_default>
					</cfif>

					<!--- default highres to original if it doesnt exist --->						
					<cfif trim(imageurl_highres) EQ "">
						<cfset imageurl_highres = imageurl_default>
					</cfif>
							
					<!--- get the image insert html config item (returns to insertHTML javascript funvction) --->
					<cfset aLibraryItem[iCounter].value = Application.config.image.insertHTML>
							
					<!--- replace thumbnail with thumbnail image url --->
					<cfset aLibraryItem[iCounter].value = replaceNoCase(aLibraryItem[iCounter].value,"*thumbnail*",imageurl_thumbnail,"all")>

					<!--- replace original with original image url --->
					<cfset aLibraryItem[iCounter].value = replaceNoCase(aLibraryItem[iCounter].value,"*imagefile*",imageurl_default,"all")>
																	
					<!--- replace high resolution with high resolution image url --->
					<cfset aLibraryItem[iCounter].value = replaceNoCase(aLibraryItem[iCounter].value,"*optimisedImage*",imageurl_highres,"all")>

					<!--- replace high resolution with high resolution image url --->
					<cfset aLibraryItem[iCounter].value = replaceNoCase(aLibraryItem[iCounter].value,"*alt*",stItem.alt,"all")>
					
					<!--- this is returned to the generateLibraryXML file and sent to a javasecript function .: have to escape javascript --->
					<cfset aLibraryItem[iCounter].value = "#stItem.objectID#|#aLibraryItem[iCounter].value#">
							
					<!--- check if hi res image exists --->
					<!--- <cfif stItem.optimisedimage neq "">
						<!--- display normal image with link to high res image in new window --->
						<cfset aLibraryItem[iCounter].value = "#stItem.objectID#|&lt;a href='#application.url.webroot#/images/#stItem.optimisedimage#' target='_blank'&gt;&lt;img src='#application.url.webroot#/images/#stItem.imagefile#' border=0 alt='#stItem.alt#'&gt;&lt;/a&gt;">
					<cfelse>
						<!--- display normal image --->
						<cfset aLibraryItem[iCounter].value = "#stItem.objectID#|&lt;img src='#application.url.webroot#/images/#stItem.imagefile#' border=0 alt='#stItem.alt#'&gt;">
					</cfif> --->
				</cfif>
			</cfcase>
			
			<cfcase value="dmFile">
				<cfif stItem.filename neq "">
					<cfset iCounter = iCounter + 1>				
					<cfset aLibraryItem[iCounter] = StructNew()>
					<cfset aLibraryItem[iCounter].text = stItem.title>
					<!--- check whether to link directly to file or use download.cfm --->
					<cfif application.config.general.fileDownloadDirectLink eq "false">
						<cfset aLibraryItem[iCounter].value = "#stItem.objectID#|<a href='#application.url.webroot#/download.cfm?DownloadFile=#stItem.objectID#'>#stItem.title#</a>">
					<cfelse>
						<cfset aLibraryItem[iCounter].value = "#stItem.objectID#|<a href='#application.url.webroot#/files/#stItem.filename#'>#stItem.title#</a>">
					</cfif>
				</cfif>			
			</cfcase>		
		</cfswitch>
	</cfif> <!--- // check item exist and is the type we want --->
</cfloop>

<cfoutput>
<h2><small><a href="##" onclick="showWindow#typeName#();return false;">Add #strDisplayTypeName#s</a></small>#strDisplayTypeName#s</h2>
<select id="l#typeName#Library" name="l#typeName#Library" size="3"><cfif ArrayLen(aLibraryItem) EQ 0>
	<option value="" class="subdued">Currently no #strDisplayTypeName#s</option><cfelse><cfloop index="j" from="1" to="#ArrayLen(aLibraryItem)#">
	<option value="#aLibraryItem[j].value#">#aLibraryItem[j].text#</option></cfloop></cfif>
</select>

<a href="##" onclick="return fUpdate#typeName#Position('up');" class="moveup"><strong>Move Up</strong></a>
<a href="##" onclick="return fUpdate#typeName#Position('down');" class="movedown"><strong>Move Down</strong></a>
<cfif qListTemplate.recordcount>
<select name="l#typeName#_inserthtml" id="l#typeName#_inserthtml">
	<option value="default">default</option><cfloop query="qListTemplate">
	<option value="#qListTemplate.methodname#">#qListTemplate.displayname#</option></cfloop>
</select>
</cfif>
<div class="f-submit-wrap">
<input type="button" name="buttonFileDelete" value="Delete" class="f-submit f-delete" onclick="return fDelete#typeName#Item();" />
<cfif qListTemplate.recordcount>
<input type="button" name="buttonInsertInBody" value="Insert in body" class="f-submit" onclick="return get#typeName#TemplateValueInsert();" />
<cfelse> <!--- use default insert html (from config) --->
<input type="button" name="buttonInsertInBody" value="Insert in body" class="f-submit" onclick="return get#typeName#ValueInsert();" />
</cfif>
</div>

<script type="text/javascript">
var iCurrent#typeName#Pos = -1;
function get#typeName#ValueInsert()
{
	objSelect = document.getElementById("l#typeName#Library");
	tempStr = objSelect.options[objSelect.selectedIndex].value;
	arVal = tempStr.split("|");
	strVal = arVal[1];
	if(!strVal)
		alert("Please select a valid #strDisplayTypeName# to insert.");
	else
		insertHTML(strVal);
	return false;
}

function get#typeName#TemplateValueInsert()
{
	objSelect = document.getElementById("l#typeName#Library");
	if(objSelect.selectedIndex < 0){
		alert("Please select a valid #strDisplayTypeName# to insert.");
		return false;
	}

	tempStr = objSelect.options[objSelect.selectedIndex].value;
	arVal = tempStr.split("|");

	objSelectInsertHtml = document.getElementById("l#typeName#_inserthtml");
	// insert the default
	if(objSelectInsertHtml.selectedIndex <= 0){
		insertHTML(arVal[1]);
		return false;
	}
	else {
		// get the insert html from the template
		template_name = objSelectInsertHtml[objSelectInsertHtml.selectedIndex].value;
		var req#typeName# = new DataRequestor();
		strURL = "#application.url.farcry#/includes/generate_json.cfm";
		req#typeName#.addArg(_GET,"objectid",arVal[0]);
		req#typeName#.addArg(_GET,"typename","#typeName#");
		req#typeName#.addArg(_GET,"templatename",template_name);
		req#typeName#.onload = processReqChange#typeName#_inserthtml;
		req#typeName#.onfail = function (status){alert("Sorry and error occured while retrieving insert html data [" + status + "]")};
		req#typeName#.getURL(strURL,_RETURN_AS_TEXT);
		
//		strURL = "#application.url.farcry#/includes/generate_json.cfm?objectid=" + arVal[0] + "&typename=#typeName#&templatename=" + template_name;
//		window.open(strURL,"_blank");
	}
}

function processReqChange#typeName#_inserthtml(data, obj){
	if(data){
		str_inserthtml = JSON.parse(data);
		insertHTML(str_inserthtml);
	}
}

function doUpdate#typeName#(arItems)
{
	objSelect = document.getElementById("l#typeName#Library");
	objSelect.length = 0;	
	if (arItems.length == 0)
		objSelect.options[0] = new Option("Currently no #strDisplayTypeName#s","");
	
	for(i=0;i<arItems.length;i++){
		objSelect.options[i] = new Option(arItems[i]["text"],arItems[i]["value"]);
	}
	if(iCurrent#typeName#Pos > 0 && iCurrent#typeName#Pos < objSelect.length)
		objSelect.selectedIndex = iCurrent#typeName#Pos;

	<cfif typeName EQ "dmImage"> // also update the teaser image preview
	objSelect = document.getElementById("teaserImage");
	if(objSelect){
		arItemCleaned = new Array();
		for(i=0;i<arItems.length;i++){
			tempStr = arItems[i]["value"];
			arVal = tempStr.split("|");
			arItemCleaned[i] = new Array(1);
			arItemCleaned[i]["text"] = arItems[i]["text"];
			arItemCleaned[i]["value"] = arVal[0];
		}
		doUpdateTeaserImage(arItemCleaned);
	}
	</cfif>
}	

<cfif typeName EQ "dmImage">
var deleteAlertMessage#typeName# = "You should only delete #strDisplayTypeName#s that are not being used in the body or teaser.";<cfelse>
var deleteAlertMessage#typeName# = "You should only delete #strDisplayTypeName#s that are not being used in the body.";</cfif>

function fDelete#typeName#Item(){
	objSelect = document.getElementById("l#typeName#Library");
	if(objSelect.options[objSelect.selectedIndex].value == "")
		alert("Please select a #strDisplayTypeName# to delete.")
	else if(confirm(deleteAlertMessage#typeName#)){
		strVal = getSelected#typeName#ObjectID(objSelect.selectedIndex);
		strURL = "#application.url.farcry#/includes/generateLibraryXML.cfm";
		var req#typeName# = new DataRequestor();
		req#typeName#.addArg(_GET,"action","delete");
		req#typeName#.addArg(_GET,"primaryObjectID","#primaryObjectID#");
		req#typeName#.addArg(_GET,"libraryType","#typeName#");
		req#typeName#.addArg(_GET,"lObjectID",strVal);
		req#typeName#.onload = processReqChange#typeName#;
		req#typeName#.onfail = function (status){alert("Sorry and error occured while retrieving data [" + status + "]")};
		req#typeName#.getURL(strURL,_RETURN_AS_TEXT);
	}
	return false;
}

function fUpdate#typeName#Position(dir){
	objSelect = document.getElementById("l#typeName#Library");

	var iPos1 = objSelect.selectedIndex;
	if(dir == "up" && objSelect.selectedIndex >0)
		var iPos2 = objSelect.selectedIndex - 1;
	else if(dir == "down" && objSelect.selectedIndex < (objSelect.length - 1))
		var iPos2 = objSelect.selectedIndex + 1;
	else {
		alert("Please select a valid #strDisplayTypeName# to move.");
		return false;
	}
	iCurrent#typeName#Pos = iPos2;
	
	objectid1 = getSelected#typeName#ObjectID(iPos1);
	objectid2 = getSelected#typeName#ObjectID(iPos2);
	strURL = "#application.url.farcry#/includes/generateLibraryXML.cfm";


	var req#typeName# = new DataRequestor();
	req#typeName#.addArg(_GET,"action","reposition");
	req#typeName#.addArg(_GET,"primaryObjectID","#primaryObjectID#");
	req#typeName#.addArg(_GET,"libraryType","#typeName#");
	req#typeName#.addArg(_GET,"lObjectID",objectid1+","+objectid2);
	req#typeName#.onload = processReqChange#typeName#;
	req#typeName#.onfail = function (status){alert("Sorry and error occured while retrieving data [" + status + "]")};
	req#typeName#.getURL(strURL,_RETURN_AS_TEXT);
}

function getSelected#typeName#ObjectID(iPos){
	var strObjectid;
	objSelect = document.getElementById("l#typeName#Library");
	tempStr = objSelect.options[iPos].value;
	arVal = tempStr.split("|");
	strObjectid = arVal[0];
	return strObjectid;
}

function processReqChange#typeName#(data, obj) 
{
	var arItem = JSON.parse(data);
//	if(arItem.length)
	doUpdate#typeName#(arItem);
}

function showWindow#typeName#()
{
	var url = "#application.url.farcry#/includes/library.cfm?libraryType=#typeName#&primaryObjectID=#primaryObjectID#";
	var options = "width="+710+",height="+530+",status=no,toolbar=no,directories=no,menubar=no,location=no,resizable=yes,left=20,top=20,scrollbars=yes";
	var hwnd = open(url, "_winlibrary", options);

}
</script>

</cfoutput>
<cfsetting enablecfoutputonly="false">