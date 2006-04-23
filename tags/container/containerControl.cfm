<!--- 
|| LEGAL ||
$Copyright: Daemon Pty Limited 1995-2003, http://www.daemon.com.au $
$License: Released Under the "Common Public License 1.0", http://www.opensource.org/licenses/cpl.php$ 

|| VERSION CONTROL ||
$Header: /cvs/farcry/farcry_core/tags/container/containerControl.cfm,v 1.4 2003/09/25 23:28:09 brendan Exp $
$Author: brendan $
$Date: 2003/09/25 23:28:09 $
$Name: b201 $
$Revision: 1.4 $

|| DESCRIPTION || 
$Description: Edit widget for containers $
$TODO: $

|| DEVELOPER ||
$Developer: Paul Harrison (harrisonp@cbs.curtin.edu.au)$

|| ATTRIBUTES ||
$in: $
$out:$
--->

<cfparam name="attributes.objectID" default="">

<cfoutput>
<script>
var popUpWin=0;
function popUpWindow(URLStr, left, top, width, height)
{
  if(popUpWin)
  {
    if(!popUpWin.closed) popUpWin.close();
  }
  popUpWin = open(URLStr, 'popUpWin', 'toolbar=no,location=no,directories=no,status=no,scrollbars=yes,resizable=yes,copyhistory=yes,width='+width+',height='+height+',left='+left+', top='+top+',screenX='+left+',screenY='+top+'');
  popUpWin.focus();
}
	
</script>

<style>
	.widget
	{
		color: ##333;
		background: ##ccc;
		text-decoration : none;
		font-family : Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-weight : bold;
		font-size : 12px;
		border: 1px solid black;
		clear:both;
	}
</style>
</cfoutput>
<cfoutput>
<cfset Attributes.label = reReplaceNoCase(attributes.label,"$*.*_","")>
<div class="widget">
	<a href="javascript:void(0)" onClick="popUpWindow('#application.url.farcry#/navajo/editContainer.cfm?containerID=#attributes.objectID#',100,200,600,600);"><img border="0" src="#application.url.farcry#/images/treeImages/containeredit.gif" alt="Edit Container Content"></a><strong>&nbsp;Container Label : #attributes.label#</strong><br>
</div>	
</cfoutput>	






