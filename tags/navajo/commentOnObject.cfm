<cfoutput>
<cfimport taglib="/fourq/tags/" prefix="q4">
<cfimport taglib="/farcry/tags/navajo/" prefix="nj">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Add Comment</title>
<style type="text/css">
BODY {
	text-align : center;
	background-color : ##CCCCCC;
}

H1, H2, H3, H4, H5, H6 {
	color : ##002288;
}

BODY, TABLE, TEXTAREA, INPUT, SELECT {
	font-family : Verdana, sans-serif;
	font-size : 7.5pt;
}
		.normalbttnstyle {background-color: ##EeEeE5; border-bottom-width: 2px; border-color: ##666655; border-left-width: 2px; border-margin: 2px; border-right-width: 2px; border-style: solid; border-top-width: 2px; border-width: 1; color: black; font-family: sans-serif; font-size: 10px; font-weight: normal; height: 18px; margin: 2px; margin-bottom: 0; margin-left: 1px; margin-right: 1px; margin-top: 0; padding-bottom: 0; padding-left: 3px; padding-right: 3px; padding-top: 0; width: 45px; }
		.overbttnstyle {background-color: ##999995; border-bottom-width: 2px; border-color: ##666655; border-left-width: 2px; border-margin: 2px; border-right-width: 2px; border-style: solid; border-top-width: 2px; border-width: 1; color: fffff5; font-family: sans-serif; font-size: 10px; font-weight: normal; height: 18px; margin: 2px; margin-bottom: 0; margin-left: 1px; margin-right: 1px; margin-top: 0; padding-bottom: 0; padding-left: 3px; padding-right: 3px; padding-top: 0; width: 45px; }
		
</style>
</head>

<body>
<h3>Add Comment</h3>
</cfoutput>
<cfparam name="url.objectid" type="UUID">

<cfif isdefined("form.cancel")>
<cfoutput>
	<script>
		window.close();
	</script>
</cfoutput>
<cfabort>
</cfif>

<nj:getNavigation objectid="#url.objectID#" r_stObject="stNav" bInclusive="1">


<cfif not isstruct(stNav) or not structcount(stNav)>
	<cfoutput>
		<script>alert("cannot comment on this object from the website");
		window.close();
		</script>
	</cfoutput>
	<cfabort>
</cfif>
<cf_dmSec2_PermissionCheck permissionName="CanCommentOnContent" objectId="#stNav.objectid#" r_iState="iCanCommentOnContent" reference1="dmNavigation" >
<q4:contentobjectget objectid="#url.objectId#"  r_stobject="stObj">


<cfif iCanCommentOnContent eq true and isdefined("stObj.commentLog")>
	<cfif not isdefined("form.commentLog")>
		<cfoutput>
			<form action="" method="post">
			<div><textarea cols="58" rows="3" name="commentLog"></textarea></div>
			<div>			
			<input type="submit" name="submit" value="Submit" width="80" style="width:80;" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onclick="">
			<input type="submit" name="cancel" value="Cancel" width="80" style="width:80;" class="normalbttnstyle" onMouseOver="this.className='overbttnstyle';" onMouseOut="this.className='normalbttnstyle';" onclick="">
			</div>
			<cfif len(trim(stObj.commentLog))>
				</div><h4>Previous Comment Log</h4><textarea cols="58" rows="12">#stObj.commentLog#</textarea></div>
			</cfif>
			</form>
		</cfoutput>
	<cfelse>	
		<cfoutput>Adding Comments....<br></cfoutput><cfflush>
		<cfscript>
			stObj.datetimelastupdated = createODBCDate(now());
			stObj.datetimecreated = createODBCDate("#datepart('yyyy',stObj.datetimecreated)#-#datepart('m',stObj.datetimecreated)#-#datepart('d',stObj.datetimecreated)#");
			//only if the comment log exists - do we actually append the entry
			if (structkeyexists(stObj, "commentLog")){
				buildLog =  "#chr(13)##chr(10)##request.stLoggedInUser.canonicalName#" & "(#dateformat(now(),'dd/mm/yyyy')# #timeformat(now(), 'HH:mm:ss')#):#chr(13)##chr(10)# #FORM.commentLog#";
				stObj.commentLog = buildLog & "#chr(10)##chr(13)#" & stObj.commentLog;
				}
		</cfscript>
		<q4:contentobjectdata objectid="#stObj.objectID#"
				typename="#application.packagepath#.types.#stObj.typename#"
				 stProperties="#stObj#">
			
		<cfoutput><script>window.close();</script></cfoutput>
	</cfif>
<cfelse>
<cfoutput>
	<script>
		alert("You Cannot Comment On This Content");
		window.close();
	</script>
</cfoutput>
</cfif>
<cfoutput>
</body>
</html>
</cfoutput>
