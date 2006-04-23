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
	}
</style>
</cfoutput>
<cfoutput>
<cfset Attributes.label = reReplaceNoCase(attributes.label,"$*.*_","")>
<div class="widget">
	<a href="javascript:void(0)" onClick="popUpWindow('#application.url.farcry#/navajo/editContainer.cfm?containerID=#attributes.objectID#',100,200,600,600);"><img border="0" src="#application.url.farcry#/images/treeImages/containeredit.gif" alt="Edit Container Content"></a><strong>&nbsp;Container Label : #attributes.label#</strong><br>
</div>	
</cfoutput>	






