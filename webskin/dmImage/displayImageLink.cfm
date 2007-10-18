<!--- Author: Gavin Stewart
        Date: Jul 27, 2005
     Purpose: custom tag to display images
--->
<cfsetting enablecfoutputonly="true">

<cfparam name="arguments.stParam" default="#structNew()#">
<cfparam name="arguments.stParam.ImageSize" default="ThumbnailImage"> <!--- thumb, optimised or large --->
<cfparam name="arguments.stParam.onclick" default="no"> <!--- yes or no --->
<cfparam name="arguments.stParam.onclickevent" default="new"> <!--- popup or new page --->
<cfparam name="arguments.stParam.onclickDisplay" default="StandardImage"> <!--- thumb, optimised or original --->
<cfparam name="arguments.stParam.popup" default="true">
<cfparam name="arguments.stParam.height" default="">
<cfparam name="arguments.stParam.width" default="">
<cfparam name="arguments.stParam.autosize" default="yes">
<cfparam name="arguments.stParam.class" default="">
<cfparam name="arguments.stParam.alt" default="">
<cfparam name="arguments.stParam.caption" default="">
<cfparam name="arguments.stParam.bCustomOnClick" default="false">
<cfparam name="arguments.stParam.bFailToTitle" default="true">

<cfif arguments.stParam.onclick>
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
	<cfif arguments.stParam.alt eq "">
		<cfset arguments.stParam.alt = stObj.alt>
	</cfif>
</cfif>

<cfif not len(arguments.stParam.caption)>
	<cfif len(stObj.alt)>
		<cfset arguments.stParam.caption = stObj.alt>
	<cfelseif arguments.stParam.bFailToTitle>
		<cfset arguments.stParam.caption = stObj.title>
	<cfelse>
		<cfset arguments.stParam.caption = "">
    </cfif>
</cfif>

<cfset imageUtilsObj = CreateObject("component","#application.packagepath#.farcry.imageUtilities")>
<!--- if autosize now get the size of the image --->
<cfif arguments.stParam.autosize>
    <cfset imageSizeStruct = getImageSize(stObj=stObj, stParam=arguments.stParam)>
    <cfif isStruct(imageSizeStruct) AND (NOT isNumeric(imageSizeStruct.width) OR NOT isNumeric(imageSizeStruct.height))>
        <cfset imageSizeStruct.width = 270>
        <cfset imageSizeStruct.height = 270>
    </cfif>
</cfif>

<cfif arguments.stParam.bCustomOnClick>
	<cfset onClickImagePath = "#application.url.webroot#/index.cfm?objectID=#stObj.objectid#&resize=0">
<cfelse>
	<cfset onClickImagePath = "#application.url.imageroot##stObj[arguments.stParam.onclickDisplay]#">
</cfif>

<!--- output image --->
<cfswitch expression="#arguments.stParam.onclick#">
	<cfcase value="true">
		<!--- if onclick event, see if a popup window --->
		<cfif arguments.stParam.popup>
			<cfif arguments.stParam.autosize>
				<cfoutput><a href="##" onclick="openNewWindow('#onClickImagePath#','popup','height=#imageSizeStruct.height#,width=#imageSizeStruct.width#,channelmode=no,directories=no,fullscreen=no,location=no,menubar=no,resizable=yes,status=no,titlebar=no,toolbar=no')"><img src="#application.url.imageroot##stObj[arguments.stParam.ImageSize]#" class="#arguments.stParam.class#" alt="#arguments.stParam.alt#" /></a></cfoutput>
			<cfelse>
				<cfoutput><a href="##" onclick="openNewWindow('#onClickImagePath#',null,'height=#arguments.stParam.height#,width=#arguments.stParam.width#,status=yes,toolbar=no,menubar=no,resizable=yes,location=no')"><img src="#application.url.imageroot##stObj[arguments.stParam.ImageSize]#" class="#arguments.stParam.class#" alt="#arguments.stParam.alt#" /></a></cfoutput>
			</cfif>
		<cfelse>
			<cfoutput><a href="#onClickImagePath#"><img src="#application.url.imageroot##stObj[arguments.stParam.ImageSize]#" height="#stObj.height#" width="#stObj.width#" class="#arguments.stParam.class#" alt="#arguments.stParam.alt#" /></a></cfoutput>
		</cfif>
	</cfcase>
	<cfcase value="no">
		<!--- if no onclick event, just display image --->
		<cfoutput><img src="#application.url.imageroot##stObj[arguments.stParam.ImageSize]#" class="#arguments.stParam.class#" alt="#arguments.stParam.alt#" /></cfoutput>
	</cfcase>
	<cfdefaultcase>
		<cfoutput><img src="#application.url.imageroot##stObj[arguments.stParam.ImageSize]#" class="#arguments.stParam.class#" alt="#arguments.stParam.alt#" /></cfoutput>
		<cftrace text="onClick attribute is not valid which will cause incorrect behaviour when clicking on image">
	</cfdefaultcase>
</cfswitch>
<cfoutput><p class="caption">#arguments.stParam.caption#</p></cfoutput>


<!--- internal utility function --->
<cffunction name="getImageSize" returntype="struct" hint="returns a sructure with image size">
<cfargument name="stObj" required="true">
<cfargument name="stParam" required="true">

    <cfswitch expression="#arguments.stParam.onclickDisplay#">
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
