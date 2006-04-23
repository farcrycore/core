function synchTab(frameName, activeTabClass, normalTabClass, linkid) {

  var elList, i;

  // Exit if no frame name was given.

  if (frameName == null)
    return;

  // Set current active link to non active

  elList = parent.document.getElementsByTagName("A");
  for (i = 0; i < elList.length; i++)

    // Check if the link's target matches the frame being loaded.

    if (elList[i].target == frameName) {

      // If the link's URL matches the page being loaded, activate it.
      // Otherwise, make sure the tab is deactivated.
	  if (elList[i].className == activeTabClass) {
	  
        elList[i].className = normalTabClass;
        elList[i].blur();
      }
    } 
	
	 // Set active link
	if (parent.document.getElementById(linkid))
	   parent.document.getElementById(linkid).className = activeTabClass;
   //CalculateRemainingTime();
}

function synchTitle (newtitle)
{
	parent.document.getElementById('DisplayTitle').innerText = newtitle;
}

function synchTabLinks (tabType, objectid)
{
	var elList, i;
	var curList, newList;
   // Set current active link to non active
 
  elList = parent.document.getElementsByTagName("A");
  for (i = 0; i < elList.length; i++)

    // Check if the id contains the tabtype and make tab visible	
	if (elList[i].id)
	{
		
		if (elList[i].id.indexOf(tabType)!= -1) 
		{
		   	// break href into 2 bits, one the file and one the object parameter
			newList = new Array();
			curList = elList[i].href.split("=");
			elList[i].href = curList[0] + "=" + objectid; 
		}
	}
}