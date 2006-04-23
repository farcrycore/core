
<cfinclude template="/farcry/farcry_core/admin/includes/cfFunctionWrappers.cfm">

<cfparam name="url.objectId">
<cfparam name="url.direction">

<cflock name="moveBranchNTM" type="EXCLUSIVE" timeout="3" throwontimeout="Yes">
	<cfscript>
			oAuthentication = request.dmSec.oAuthentication;	
			stuser = oAuthentication.getUserAuthenticationData();
			qparentObject = request.factory.oTree.getParentID(objectid=url.objectid,dsn=application.dsn);
			parentObjectID = qParentObject.parentid;
			qGetChildren = request.factory.oTree.getChildren(dsn=application.dsn,objectid=parentObjectID);
			bottom = qGetChildren.recordCount;
			for(i=1;i LTE qGetChildren.recordCount;i = i + 1)
			{
				if (qGetChildren.objectid[i] IS url.objectID)
				{
					thisPosition = i;
					break;
				}
			}
				
			//get the new position
			if( url.direction is "up" AND thisPosition NEQ 1)
				newPosition = thisPosition - 1;
			else if( url.direction is "down" AND thisPosition LT bottom)
				newPosition = thisPosition + 1;
			else if ( url.direction is "top" )
				newPosition = 1;
			else if( url.direction eq "bottom" )	
				newPosition = bottom;
				//make the move	
			request.factory.oTree.moveBranch(dsn=application.dsn,objectid=url.objectid,parentid=parentobjectid,pos=newposition);	
			application.factory.oaudit.logActivity(objectid="#URL.objectid#",auditType="categorisation.movenode", username=StUser.userlogin, location=cgi.remote_host, note="object moved to child position #newposition#");
	</cfscript>	
</cflock>
<cfoutput>
<script type="text/javascript">
	parent.location.reload();
</script>
</cfoutput>