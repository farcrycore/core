<!--- Author: Gavin Stewart
        Date: Jul 27, 2005
     Purpose: custom tag to display images
--->
<cfsetting enablecfoutputonly="true">

<cfparam name="stParam" default="#structNew()#">
<cfparam name="stParam.ImageSize" default="ThumbnailImage"> <!--- thumb, optimised or large --->
<cfparam name="stParam.onclick" default="no"> <!--- yes or no --->
<cfparam name="stParam.onclickevent" default="new"> <!--- popup or new page --->
<cfparam name="stParam.onclickDisplay" default="StandardImage"> <!--- thumb, optimised or original --->
<cfparam name="stParam.popup" default="true">
<cfparam name="stParam.height" default="">
<cfparam name="stParam.width" default="">
<cfparam name="stParam.autosize" default="yes">
<cfparam name="stParam.class" default="">
<cfparam name="stParam.alt" default="">
<cfparam name="stParam.caption" default="">
<cfparam name="stParam.bCustomOnClick" default="false">
<cfparam name="stParam.bFailToTitle" default="true">

<cfif stParam.onclick>
    <!--- javascript function to open window --->
    <cfoutput>
    <script type="text/javascript">
        function openNewWindow(sURL,sName,sFeatures,bReplace){
            window.open(sURL,sName,sFeatures,bReplace);
        }
    </script>
    </cfoutput>
</cfif>

<cfif len(stObj.alt)>
	<cfif stParam.alt eq "">
		<cfset stParam.alt = stObj.alt>
	</cfif>
</cfif>

<cfif not len(stParam.caption)>
	<cfif len(stObj.alt)>
		<cfset stParam.caption = stObj.alt>
	<cfelseif stParam.bFailToTitle>
		<cfset stParam.caption = stObj.title>
	<cfelse>
		<cfset stParam.caption = "">
    </cfif>
</cfif>

<cfset imageUtilsObj = CreateObject("component","#application.packagepath#.farcry.imageUtilities")>
<!--- if autosize now get the size of the image --->
<cfif stParam.autosize>
    <cfset imageSizeStruct = getImageSize(stObj=stObj, stParam=stParam)>
    <cfif isStruct(imageSizeStruct) AND (NOT isNumeric(imageSizeStruct.width) OR NOT isNumeric(imageSizeStruct.height))>
        <cfset imageSizeStruct.width = 270>
        <cfset imageSizeStruct.height = 270>
    </cfif>
</cfif>

<cfif stParam.bCustomOnClick>
	<cfset onClickImagePath = "#application.url.webroot#/index.cfm?objectID=#stObj.objectid#&resize=0">
<cfelse>
	<cfset onClickImagePath = "#application.fapi.getImageWebRoot()##stObj[stParam.onclickDisplay]#">
</cfif>

<!--- output image --->
<cfswitch expression="#stParam.onclick#">
	<cfcase value="true">
		<!--- if onclick event, see if a popup window --->
		<cfif stParam.popup>
			<cfif stParam.autosize>
				<cfoutput><a href="##" onclick="openNewWindow('#onClickImagePath#','popup','height=#imageSizeStruct.height#,width=#imageSizeStruct.width#,channelmode=no,directories=no,fullscreen=no,location=no,menubar=no,resizable=yes,status=no,titlebar=no,toolbar=no')"><img src="#application.fapi.getImageWebRoot()##stObj[stParam.ImageSize]#" class="#stParam.class#" alt="#application.fc.lib.esapi.encodeForHTMLAttribute(stParam.alt)#" /></a></cfoutput>
			<cfelse>
				<cfoutput><a href="##" onclick="openNewWindow('#onClickImagePath#',null,'height=#stParam.height#,width=#stParam.width#,status=yes,toolbar=no,menubar=no,resizable=yes,location=no')"><img src="#application.fapi.getImageWebRoot()##stObj[stParam.ImageSize]#" class="#stParam.class#" alt="#application.fc.lib.esapi.encodeForHTMLAttribute(stParam.alt)#" /></a></cfoutput>
			</cfif>
		<cfelse>
			<cfoutput><a href="#onClickImagePath#"><img src="#application.fapi.getImageWebRoot()##stObj[stParam.ImageSize]#" height="#stObj.height#" width="#stObj.width#" class="#stParam.class#" alt="#application.fc.lib.esapi.encodeForHTMLAttribute(stParam.alt)#" /></a></cfoutput>
		</cfif>
	</cfcase>
	<cfcase value="no">
		<!--- if no onclick event, just display image --->
		<cfoutput><img src="#application.fapi.getImageWebRoot()##stObj[stParam.ImageSize]#" class="#stParam.class#" alt="#application.fc.lib.esapi.encodeForHTMLAttribute(stParam.alt)#" /></cfoutput>
	</cfcase>
	<cfdefaultcase>
		<cfoutput><img src="#application.fapi.getImageWebRoot()##stObj[stParam.ImageSize]#" class="#stParam.class#" alt="#application.fc.lib.esapi.encodeForHTMLAttribute(stParam.alt)#" /></cfoutput>
		<cftrace text="onClick attribute is not valid which will cause incorrect behaviour when clicking on image">
	</cfdefaultcase>
</cfswitch>
<cfoutput><p class="caption">#stParam.caption#</p></cfoutput>


<!--- internal utility function --->
<cffunction name="getImageSize" returntype="struct" hint="returns a sructure with image size">
<cfargument name="stObj" required="true">
<cfargument name="stParam" required="true">

    <cfswitch expression="#stParam.onclickDisplay#">
            <cfcase value="ThumbnailImage">
                 <cfset filePath = "#application.path.imageroot##arguments.stObj.ThumbnailImage#">
            </cfcase>
            <cfcase value="StandardImage">
                <cfset filePath = "#application.path.imageroot##arguments.stObj.StandardImage#">
            </cfcase>
            <cfcase value="SourceImage">
                <cfset filePath = "#application.path.imageroot##arguments.stObj.SourceImage#">
            </cfcase>
        </cfswitch>

        <cfset sStruct = imageUtilsObj.fGetProperties(filePath)>
    <cfreturn sStruct>
</cffunction>
<cfsetting enablecfoutputonly="false">
