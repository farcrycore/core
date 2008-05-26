<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$

|| VERSION CONTROL ||
$Header: /cvs/farcry/core/packages/types/dmFlash.cfc,v 1.13 2005/09/16 00:56:13 guy Exp $
$Author: guy $
$Date: 2005/09/16 00:56:13 $
$Name: milestone_3-0-1 $
$Revision: 1.13 $

|| DESCRIPTION || 
$Description: dmFlash type $


|| DEVELOPER ||
$Developer: Brendan Sisson (brendan@daemon.com.au) $

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfcomponent extends="types" displayname="Flash" hint="Forms the basis of the content framework of the site.  Displays a flash movie in the page." bSchedule="1" bUseInTree="1">
<!------------------------------------------------------------------------
type properties
------------------------------------------------------------------------->	
<cfproperty ftSeq="1" ftFieldSet="General Details" name="title" type="string" hint="Title of content item." required="no" default="" ftlabel="Title" ftvalidation="required" />
<cfproperty ftSeq="2" ftFieldSet="General Details" name="teaser" type="longchar" hint="Teaser text." required="no" default="" ftlabel="Teaser" />
<cfproperty ftSeq="3" ftFieldSet="General Details" name="displayMethod" type="string" hint="Display template to render this Flash content." required="yes" default="" ftType="webskin" ftPrefix="displayPage" ftlabel="Display" />
<cfproperty ftSeq="4" ftFieldSet="General Details" name="metaKeywords" type="nstring" hint="Keywords or tags to describe this content." required="no" default="" ftlabel="Keywords/Tags">
<cfproperty ftSeq="5" ftFieldSet="General Details" name="bLibrary" type="boolean" hint="Flag to make the Flash movie shared." required="no" default="1" ftlabel="Add to Shared Library">

<cfproperty ftSeq="10" ftFieldSet="Flash File" name="flashURL" type="string" hint="The url to a remote flash movie file." required="No" default="" ftLabel="Remote File" ftType="url" 
			fthelptitle="Location of the Flash File"
			fthelpsection="You can choose to either upload a SWF to the server or point to a remote Flash file using a URL.  If a URL is nominated the Flash file field will be ignored." /> 
<cfproperty ftSeq="11" ftFieldSet="Flash File" name="flashMovie" type="string" hint="The name of the physical flash movie file." required="No" default="" ftLabel="Flash File" ftType="file" ftDestination="/dmFlash/flashMovie" /> 
<cfproperty ftSeq="12" ftFieldSet="Flash File" name="flashWidth" type="numeric" hint="width of flash movie in pixels" required="No" default="0" ftLabel="Width" ftIncludeDecimal="false" ftvalidation="validate-digits,required" /> 
<cfproperty ftSeq="13" ftFieldSet="Flash File" name="flashHeight" type="numeric" hint="height of flash movie in pixels" required="No" default="0" ftLabel="Height" ftIncludeDecimal="false" ftvalidation="validate-digits,required" />
<cfproperty ftSeq="14" ftFieldSet="Flash File" name="flashParams" type="string" hint="paremeters to be passed to flash movie" required="No" default="" ftLabel="Parameters" />

<!--- flash categorisation --->
<cfproperty ftSeq="20" ftFieldset="Categorisation" name="catFlash" type="string" hint="Flash categorisation." required="no" default="" ftlabel="Category" fttype="category" ftalias="dmflash" ftselectmultiple="true" />

<cfproperty ftSeq="31" ftFieldSet="Flash Player Settings" name="flashVersion" type="string" hint="version of flash player required" required="No" default="8,0,0,0" ftLabel="Required Version" 
			fthelptitle="Detailed Settings"
			fthelpsection="If in doubt accept the default Flash Player settings.  They should be fine for most settings." />
<cfproperty ftSeq="35" ftFieldSet="Flash Player Settings"  name="flashQuality" type="string" hint="The quality of the flash movie" required="no" default="high" ftLabel="Quality" ftType="list" ftList="high:High,medium:Medium,low:Low"> 
<cfproperty ftSeq="36" ftFieldSet="Flash Player Settings"  name="flashAlign" type="string" hint="The alignment of the flash movie" required="no" default="center" ftLabel="Alignment"> 
<cfproperty ftSeq="37" ftFieldSet="Flash Player Settings"  name="flashBgcolor" type="string" hint="The background colour of the flash movie" required="no" default="##FFFFFF" ftLabel="Background Color" ftDefault="##FFFFFF"> 
<cfproperty ftSeq="38" ftFieldSet="Flash Player Settings"  name="flashLoop" type="boolean" hint="Whether or not to loop over flash movie" required="yes" default="0" ftLabel="Loop" ftType="list" ftList="1:true,0:false"> 
<cfproperty ftSeq="39" ftFieldSet="Flash Player Settings"  name="flashPlay" type="boolean" hint="Play flash movie straight away?" required="yes" default="1" ftLabel="Play" ftType="list" ftList="1:true,0:false"> 
<cfproperty ftSeq="40" ftFieldSet="Flash Player Settings"  name="flashMenu" type="boolean" hint="Display options menu in flash movie" required="yes" default="0" ftLabel="Menu" ftType="list" ftList="1:true,0:false"> 

<!--- system properties --->
<cfproperty name="status" type="string" hint="Status of movie - draft,pending or approved" required="No" default="">

<!------------------------------------------------------------------------
object methods 
------------------------------------------------------------------------->	


<!---
><cffunction name="delete" access="public" hint="Specific delete method for dmFlash. Removes physical files from ther server." returntype="struct">
	<cfargument name="objectid" required="yes" type="UUID" hint="Object ID of the object being deleted">
	
	<cfreturn stReturn>
</cffunction> --->

</cfcomponent>