<!--- 
|| BEGIN FUSEDOC ||

|| Copyright ||

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/display/OpenLayer.cfm,v 1.3 2003/09/09 09:22:43 paul Exp $
$Author: paul $
$Date: 2003/09/09 09:22:43 $
$Name: milestone_3-0-1 $
$Revision: 1.3 $

|| DESCRIPTION || 
Wraps its content with an collapse-expand-layer... 

|| DEVELOPER ||
 mail@Christian-Schneider.de 
 www.Christian-Schneider.de 
 
|| ATTRIBUTES ||
         <CF_openLayer 
                  [ Border="yes|no" ] 
                  [ BorderSize="size" ] 
                  [ BorderColor="color" ] 
                  [ Image="image" ] 
                  [ ImageOpen="image" ] 
                  [ Title="string" ] 
                  [ TitleClosed="string" ] 
                  [ TitleTooltip="string" ] 
                  [ TitleFont="font" ] 
                  [ TitleColor="color" ] 
                  [ TitleColorOpen="color" ] 
                  [ TitleSize="size in pt" ] 
                  [ IsColsed="yes|no" ] 
                  [ Width="width in px or %" ]&gt; 
            ... 
         </CF_openLayer> 
  
|| HISTORY ||
$Log: OpenLayer.cfm,v $
Revision 1.3  2003/09/09 09:22:43  paul
Removed all IE specific javascript - this should work a treat now in standards compliant browsers.

Revision 1.2  2002/09/27 07:28:38  petera
no message

Revision 1.2  2002/08/22 07:32:06  geoff
no message

Revision 1.1  2002/08/22 00:03:50  geoff
no message

Revision 1.2  2001/08/02 16:40:43  nick
added fusedoc comments


|| END FUSEDOC ||
--->


<!--- openLayer.cfm ---> 

<!--- 
   ********************************************************** 

 <CF_openLayer> 
 Version 1.0 
 Wraps its content with an collapse-expand-layer... 
  
 (This layer only works in IE4++ 
  To be browser-safe: when accessed with another 
   browser, only a title is shown without the layer.) 
  
 Usage: 

         <CF_openLayer 
                  [ Border="yes|no" ] 
                  [ BorderSize="size" ] 
                  [ BorderColor="color" ] 
                  [ Image="image" ] 
                  [ ImageOpen="image" ] 
                  [ Title="string" ] 
                  [ TitleClosed="string" ] 
                  [ TitleTooltip="string" ] 
                  [ TitleFont="font" ] 
                  [ TitleColor="color" ] 
                  [ TitleColorOpen="color" ] 
                  [ TitleSize="size in pt" ] 
                  [ IsColsed="yes|no" ] 
                  [ Width="width in px or %" ]&gt; 
            ... 
         </CF_openLayer> 
  
 Contact: 
 mail@Christian-Schneider.de 
 www.Christian-Schneider.de 
  
   ************************************************************* 
---> 
<cfsetting enablecfoutputonly="Yes"> 
  

<!--- When no Ending-Tag is used throw an Exception ---> 
<cfif ThisTag.HasEndTag EQ false> 
 <CFTHROW message="CF_openLayer needs an ending tag! Please ensure that this tag has an closing tag."> 
 <CFEXIT> 
</cfif> 
  

<!--- Set all default values for optional parameters ---> 

<CFPARAM NAME="ATTRIBUTES.border"     DEFAULT="Yes"> 
<CFPARAM NAME="ATTRIBUTES.bordersize"   DEFAULT="3"> 
<CFPARAM NAME="ATTRIBUTES.bordercolor"    DEFAULT="##F0F0F0"> 
<CFPARAM NAME="ATTRIBUTES.image"     DEFAULT=""> 
<CFPARAM NAME="ATTRIBUTES.imageopen"    DEFAULT=#ATTRIBUTES.image#> 
<CFPARAM NAME="ATTRIBUTES.title"      DEFAULT=""> 
<CFPARAM NAME="ATTRIBUTES.titleclosed"    DEFAULT=#ATTRIBUTES.title#> 
<CFPARAM NAME="ATTRIBUTES.titletooltip"   DEFAULT=""> 
<CFPARAM NAME="ATTRIBUTES.isclosed"     DEFAULT="No"> 
<CFPARAM NAME="ATTRIBUTES.width"       DEFAULT="100%"> 
<CFPARAM NAME="ATTRIBUTES.titlefont"    DEFAULT="Arial"> 
<CFPARAM NAME="ATTRIBUTES.titlecolor"    DEFAULT=""> 
<CFPARAM NAME="ATTRIBUTES.titlecoloropen" 
DEFAULT=#ATTRIBUTES.titlecolor#> 
<CFPARAM NAME="ATTRIBUTES.titlesize"    DEFAULT="10"> 

<!--- Make the title strings safe to use with JavaScript ---> 
<cfset ATTRIBUTES.title = Replace(ATTRIBUTES.title, "'", "&acute;", "ALL")> 
<cfset ATTRIBUTES.titleclosed = Replace(ATTRIBUTES.titleclosed, "'", "&acute;", "ALL")> 

<!--- Store in a REQUEST-scoped variable if the accessing browser is ok... ---> 
<cfif NOT IsDefined("REQUEST.openLayerBrowserSafeForIE4")> 
 <!--- *** Browser-Check for Internet Explorer 4 and higher *** ---> 
 <!--- Check for Internet Explorer ---> 
 <cfset tmpPositionMSIE = ListContainsNoCase(CGI.HTTP_USER_AGENT, "MSIE",";")> 
 <cfif tmpPositionMSIE GT 0> 
  <!--- Check for Version 4.0 and higher ---> 
  <cfset tmpVersionMSIE = ListLast(ListGetAt(CGI.HTTP_USER_AGENT,tmpPositionMSIE,";")," ")> 
  <cfif IsNumeric(ListFirst(tmpVersionMSIE,"."))> 
   <cfif ListFirst(tmpVersionMSIE,".") GTE 4> 
    <cfset REQUEST.openLayerBrowserSafeForIE4 = true> 
   <cfelse> 
    <cfset REQUEST.openLayerBrowserSafeForIE4 = false> 
   </cfif> 
  <cfelse> 
   <cfset REQUEST.openLayerBrowserSafeForIE4 = false> 
  </cfif> 
 <cfelse> 
  <cfset REQUEST.openLayerBrowserSafeForIE4 = false> 
 </cfif> <!--- REQUEST.openLayerBrowserSafeForIE4 is "true" when IEXP 4 and higher; otherwise "false" ---> 
</cfif> 
<!--- setting this to true - we dont care about crap browsers --->
<cfset  REQUEST.openLayerBrowserSafeForIE4 = true>

<!--- ***** Here comes the actual work of this custom tag: ***** ---> 

<!--- When the starting-tag is being processed: ---><CFIF ThisTag.ExecutionMode EQ "START"> 

 <!--- Generate a random unique ID for each instance of this tag so that each layer can be accessed separately ---> 
 <cfset GeneratedUniqueLayerID = RandRange(1,999999)> 
<cfset tmp = structNew()>
 <!--- Now set the starting properties depending on the passed attributes... ---> 
 <cfif CompareNoCase(ATTRIBUTES.border, "Yes") IS 0> 
  <cfset TMP.border = "solid"> 
 <cfelse> 
  <cfset TMP.border = "none"> 
 </cfif> 
  
 <cfif CompareNoCase(ATTRIBUTES.isclosed, "Yes") IS 0> 
  <cfset TMP.display = "none"> 
  <cfset TMP.visibility = "hidden"> 
  <cfset TMP.borderwidth = "0"> 
  <cfset TMP.title = ATTRIBUTES.titleclosed> 
  <cfif Len(ATTRIBUTES.image)> 
   <cfset TMP.image = ATTRIBUTES.image> 
  </cfif> 
  <cfif Len(ATTRIBUTES.titlecolor)> 
   <cfset TMP.titlecolor = ATTRIBUTES.titlecolor> 
  </cfif> 
 <cfelse> 
  <cfset TMP.display = "block"> 
  <cfset TMP.visibility = "visible"> 
  <cfset TMP.borderwidth = ATTRIBUTES.bordersize> 
  <cfset TMP.title = ATTRIBUTES.title> 
  <cfif Len(ATTRIBUTES.image)> 
   <cfset TMP.image = ATTRIBUTES.imageopen> 
  </cfif> 
  <cfif Len(ATTRIBUTES.titlecolor)> 
   <cfset TMP.titlecolor = ATTRIBUTES.titlecoloropen> 
  </cfif> 
 </cfif> 
  
 <CFOUTPUT> 
   <!--- Store in a REQUEST-scoped variable if this general JavaScript-Code was already written on the page... ---> 
   <cfif NOT IsDefined("REQUEST.openLayerScriptAlreadyWritten")> 

    <cfif REQUEST.openLayerBrowserSafeForIE4> 
     <!--- The general JavaScript to expand and collapse the layer... ---> 
     <SCRIPT LANGUAGE="JavaScript" TYPE="text/javascript"> 
     <!-- 
      function switchLayer(lyrID, title, titleclosed, borderwidth, imageA,imageB, colorA,colorB) { 
       if (document.getElementById) { 
        // Determine if the layer is currently expanded or collapsed: 
        var tmpStatus; 
       	tmpStatus = document.getElementById('lyrGroup_'+lyrID).style.display; 
        // OK, then now expand or collapse it... 
        if (tmpStatus == 'none') { 
         document.getElementById('lyrGroup_'+ lyrID).style.display='block'; 
         document.getElementById('border_'+ lyrID ).style.borderWidth=borderwidth;
         document.getElementById('title_'+ lyrID).innerHTML=title; 
         tmpImage = imageA; 
         tmpColor = colorA; 
        } 
        else { 
       	document.getElementById('lyrGroup_'+ lyrID).style.display='none'; 
        document.getElementById('border_'+ lyrID).style.borderWidth='0'; 
        document.getElementById('title_'+ lyrID).innerHTML=titleclosed; 
         tmpImage = imageB; 
         tmpColor = colorB; 
        } 
        // If an image is used as the click-control, switch it... 
        if ((tmpImage != null) && (imageA != imageB)) { 
         eval("document.all.image_"+ lyrID +".src='"+tmpImage+"'"); 
        } 
        // If different title-colors are used, switch them... 
        if (tmpColor != '') { 
         //eval("document.all.title_"+ lyrID +".style.color='"+tmpColor+"'"); 
        } 
       } 
      } 
     //--> 
     </SCRIPT> 
    </cfif> 

    <cfset REQUEST.openLayerScriptAlreadyWritten = true> 
   </cfif> 
  
   <cfif REQUEST.openLayerBrowserSafeForIE4> 
    <!--- Draw the titled border ---> 
    <fieldset id="border_#GeneratedUniqueLayerID#" class="OpenLayerFieldSet" style="border-width:#TMP.borderwidth#; border-color:#ATTRIBUTES.BorderColor#; border-style:#TMP.border#; width:#ATTRIBUTES.width#"> 
     <legend> 
      <span title="#ATTRIBUTES.TitleTooltip#"> 
       <!--- Draw either a button oder an image as click-control... ---> 
       <cfif Len(ATTRIBUTES.image)> 
        <img id="image_#GeneratedUniqueLayerID#" src="#TMP.image#" onClick="switchLayer(#GeneratedUniqueLayerID#,'#ATTRIBUTES.title#','#ATTRIBUTES.titleclosed#',#ATTRIBUTES.bordersize#,'#ATTRIBUTES.imageopen#','#ATTRIBUTES.image#','#ATTRIBUTES.titlecoloropen#','#ATTRIBUTES.titlecolor#')" border="0" alt="" style="cursor:hand"> 
       <cfelse> 
        <input type="button" value"" onClick="switchLayer(#GeneratedUniqueLayerID#,'#ATTRIBUTES.title#','#ATTRIBUTES.titleclosed#',#ATTRIBUTES.bordersize#,null,null,'#ATTRIBUTES.titlecoloropen#','#ATTRIBUTES.titlecolor#')" style="width:12; height:12; margin-bottom:3">
       </cfif> 
       <font face="#ATTRIBUTES.titlefont#"> 
        <b style="font-size:#ATTRIBUTES.titlesize#pt"> 
         <span id="title_#GeneratedUniqueLayerID#" <cfif Len(ATTRIBUTES.titlecolor)>style="color:#TMP.titlecolor#"</cfif>>#TMP.title#</span> 
        </b> 
       </font> 
      </span> 
     </legend> 
    <div id="lyrGroup_#GeneratedUniqueLayerID#" class="OpenLayerDIV" style="display:#TMP.display#; visibility:inherit; z-index:5; margin-left:5; margin-right:5; margin-top:5; margin-bottom:8;"> 
   <cfelse> 
    <!--- For all non-IEXP4-Browsers just draw the title ---> 
    <br> 
       <font face="#ATTRIBUTES.titlefont#" <cfif Len(ATTRIBUTES.titlecolor)>color="#ATTRIBUTES.titlecolor#"</cfif>><b style="font-size:#ATTRIBUTES.titlesize#pt"><span id="title_#GeneratedUniqueLayerID#">#TMP.title#</span></b></ 
font> 
    <br> 
   </cfif> 

 </CFOUTPUT> 
  
<!--- When the ending-tag is being processed: ---> 
<CFELSEIF ThisTag.ExecutionMode EQ "END"> 

 <CFOUTPUT> 
  <!--- Simply close all things that were opened, depending on the used browser ---> 
  <cfif REQUEST.openLayerBrowserSafeForIE4> 
  

 </div></fieldset> 
  </cfif> 
   
<p> 
 </CFOUTPUT> 
  
</CFIF> 

<cfsetting enablecfoutputonly="No"> 
