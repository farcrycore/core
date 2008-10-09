<cfcontent type="text/javascript; charset=UTF-8" />

<cfoutput>
function confirmRestore(navid,draftObjectID)
{
	confirmmsg = "#application.rb.getResource("workflow.buttons.restorelivecontent@confirmtext","This will restore the current live items data to this draft. The draft content will be replaced and any changes you have made lost.\nAre you sure you wish to do this?")#";
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