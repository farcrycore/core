function showHide(theTable,theImg) 
{ 
	if (document.getElementById(theTable).style.display == 'none') 
	{ 
		document.getElementById(theTable).style.display = 'block'; 
		document.getElementById(theImg).src='#application.url.webtop#/facade/icon.cfm?icon=collapse&size=16'; 
	} 
	else 
	{ 
		document.getElementById(theTable).style.display = 'none'; 
		document.getElementById(theImg).src='#application.url.webtop#/facade/icon.cfm?icon=expand&size=16'; 
	} 
}

function toggleDocumentItem(document_id)
{
	objItem = document.getElementById(document_id);
	if(objItem)
	{
		if(objItem.style.display == 'none')
			objItem.style.display = 'block';
		else
			objItem.style.display = 'none';
	}	
	return false;
}