<cfcontent type="text/javascript; charset=UTF-8" />

<cfoutput>
function confirmRestore(navid,draftObjectID)
{
	confirmmsg = "#apapplication.rb.getResource("confirmRestoreLiveObjToDraft")#";
	if(confirm(confirmmsg))
	{
		strURL = "#application.url.farcry#/navajo/restoreDraft.cfm";
		var req = new DataRequestor();
		req.addArg(_GET,"navid",navid);
		req.addArg(_GET,"objectid",draftObjectID);
		req.onload = processReqChange;
		req.onfail = function (status){alert("Sorry and error occured while restoring [" + status + "]")};
		req.getURL(strURL,_RETURN_AS_TEXT);
		return true;
	}
	else
		return false;	
}

function processReqChange(data, obj){
	var tmpmessage = JSON.parse(data);
	message = tmpmessage;
	alert(message);
	// refresh self
	self.window.location = self.window.location;
}
</cfoutput>