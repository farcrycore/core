<!--- Author: Gavin Stewart
        Date: Jul 27, 2005
     Purpose: custom tag to display images
--->
<cfsetting enablecfoutputonly="true">

<!--- make sure the tag only runs once --->
<cfif thistag.ExecutionMode eq "end"><cfexit></cfif>

<cfparam name="attributes.ImageSize" default="thumb"> <!--- thumb, optimised or large --->
<cfparam name="attributes.onclick" default="no"> <!--- yes or no --->
<cfparam name="attributes.onclickevent" default="new"> <!--- popup or new page --->
<cfparam name="attributes.onclickDisplay" default="original"> <!--- thumb, optimised or original --->
<cfparam name="attributes.objectid" default=""> <!--- image Objectid --->
<cfparam name="attributes.popup" default="true">
<cfparam name="attributes.height" default="">
<cfparam name="attributes.width" default="">
<cfparam name="attributes.autosize" default="yes">
<cfparam name="attributes.class" default="">
<cfparam name="attributes.alt" default="">
<cfparam name="attributes.bCustomOnClick" default="false">
<cfparam name="attributes.bFailToTitle" default="true">

<!--- returned caller variables --->
<cfparam name="attributes.r_caption" default="r_caption">
<cfparam name="attributes.r_bsuccess" default="r_bsuccess">

<cfif attributes.onclick>
    <!--- javascript function to open window --->
    <cfoutput>
    <script language="javascript">
        function openNewWindow(sURL,sName,sFeatures,bReplace){
            window.open(sURL,sName,sFeatures,bReplace);
        }
    </script>
    </cfoutput>
</cfif>
<!--- create image object --->
<cfset oImage = createObject("component", "#application.types.dmImage.typePath#")>
<cfset stImage = oImage.getData(attributes.objectid)>

<!--- quit if image doesn't exist --->
<cfif structisempty(stimage)>
    <cfexit />
</cfif>

<!--- return caption to calling page --->
<cfif len(stImage.alt)>
    <cfset setVariable("caller.#attributes.r_caption#", stImage.alt)>
	<cfif attributes.alt eq "">
		<cfset attributes.alt = stImage.alt>
	</cfif>
<cfelse>
	<cfif attributes.bFailToTitle>
    		<cfset setVariable("caller.#attributes.r_caption#", stImage.title)>
    	<cfelse>
    		<cfset setVariable("caller.#attributes.r_caption#", "")>
    </cfif>
</cfif>

<cfset imageUtilsObj = CreateObject("component","#application.packagepath#.farcry.imageUtilities")>
<!--- if autosize now get the size of the image --->
<cfif attributes.autosize>
    <cfset imageSizeStruct = getImageSize()>
    <cfif isStruct(imageSizeStruct) AND (NOT isNumeric(imageSizeStruct.width) OR NOT isNumeric(imageSizeStruct.height))>
        <cfset imageSizeStruct.width = 270>
        <cfset imageSizeStruct.height = 270>
    </cfif>
</cfif>
<!--- get the path of the image --->
<cfset imagePath = oImage.getURLImagePath(attributes.objectid, attributes.ImageSize)>
<cfif NOT len(imagePath)>
    <cfset setvariable("caller.#attributes.r_bsuccess#", false)>
    <cfexit />
</cfif>
<cfif attributes.bCustomOnClick>
    <cfset onClickImagePath = "#application.url.webroot#/index.cfm?objectID=#attributes.objectID#&resize=0">
<cfelse>
    <cfset onClickImagePath = oImage.getURLImagePath(attributes.objectid, attributes.onclickDisplay)>
</cfif>

<!--- output image --->
<cfswitch expression="#attributes.onclick#">
    <cfcase value="yes">
        <!--- if onclick event, see if a popup window --->
        <cfif attributes.popup>
            <cfif attributes.autosize>
                <cfoutput><a href="##" onclick="openNewWindow('#onClickImagePath#','popup','height=#imageSizeStruct.height#,width=#imageSizeStruct.width#,channelmode=no,directories=no,fullscreen=no,location=no,menubar=no,resizable=yes,status=no,titlebar=no,toolbar=no')"><img src="#imagePath#" class="#attributes.class#" alt="#attributes.alt#" /></a></cfoutput>
            <cfelse>
                <cfoutput><a href="##" onclick="openNewWindow('#onClickImagePath#',null,'height=#attributes.height#,width=#attributes.width#,status=yes,toolbar=no,menubar=no,resizable=yes,location=no')"><img src="#imagePath#" class="#attributes.class#" alt="#attributes.alt#" /></a></cfoutput>
            </cfif>
        <cfelse>
            <cfoutput><a href="#onClickImagePath#"><img src="#imagePath#" height="#stImage.height#" width="#stImage.width#" class="#attributes.class#" alt="#attributes.alt#" /></a></cfoutput>
        </cfif>
    </cfcase>
    <cfcase value="no">
        <!--- if no onclick event, just display image --->
        <cfoutput><img src="#imagePath#" class="#attributes.class#" alt="#attributes.alt#" /></cfoutput>
    </cfcase>
    <cfdefaultcase>
        <cfoutput><img src="#imagePath#" class="#attributes.class#" alt="#attributes.alt#" /></cfoutput>
        <cftrace text="onClick attribute is not valid which will cause incorrect behaviour when clicking on image">
    </cfdefaultcase>
</cfswitch>

<!--- return success if we make it this far --->
<cfset setvariable("caller.#attributes.r_bsuccess#", true)>

<!--- internal utility function --->
<cffunction name="getImageSize" returntype="struct" hint="returns a sructure with image size">
    <cfswitch expression="#attributes.onclickDisplay#">
            <cfcase value="thumb">
                 <cfset filePath = "#stImage.thumbnailimagepath#/#stImage.thumbnail#">
            </cfcase>
            <cfcase value="optimised">
                <cfset filePath = "#stImage.optimisedimagepath#/#stImage.optimisedimage#">
            </cfcase>
            <cfcase value="original">
                <cfset filePath = "#stImage.originalimagepath#/#stImage.imagefile#">
            </cfcase>
        </cfswitch>
        <cfset sStruct = imageUtilsObj.fGetProperties(filePath)>
    <cfreturn sStruct>
</cffunction>
<cfsetting enablecfoutputonly="false">
