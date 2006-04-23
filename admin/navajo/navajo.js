
var cookieName = "nodeState=";

// toggleDivVisibility
function tdv() 
{
	eventEl = window.event.srcElement;
	id = eventEl.objectId;
	elBody = document.getElementById(id);
	thisImage = eventEl.src;
	eventEl.src = eventEl.swpsrc;
	eventEl.swpsrc = thisImage;
			
	if( elBody != null && elBody != "" )
	{
		if ( elBody.style.display=="none" )
		{
			elBody.style.display="block";
			storeState(id,1);
		}
		else
		{
			elBody.style.display="none";
			storeState(id,0);
		}
	}
}

function storeState( id, state )
{
	var aCookies = document.cookie.split(";");

	var newCookie=cookieName;
	
	for( i=0; i<aCookies.length; i++ )
	{
		if ( aCookies[i].indexOf( cookieName ) != -1 )
		{
			// loop through the cookies and generate the new node state
			for( pos=cookieName.length; pos < aCookies[i].length; pos+=35 )
			{
				var thisId = aCookies[i].substr( pos, 35 );
				if( thisId != id ) newCookie += thisId;
			}
		}
	}
	
	if(state) newCookie += id;
	
	var aDate = new Date();
	aDate.setFullYear( aDate.getFullYear()+1 );
	
	document.cookie = newCookie + "; expires="+aDate.toGMTString();
}

function validate(id,cond)
{
	var el = document.getElementById(id);
	var el_disabled = document.getElementById(id+"_disabled");
	
	if ( cond )
	{
		el.style.display="block";
		el_disabled.style.display="none";
	}
	else
	{
		el.style.display="none";
		el_disabled.style.display="inline";
	}
	
	return cond;
}

function hideNavigationMenu( divId )
{
	var theDiv = document.getElementById( divId );
	theDiv.style.visibility="hidden"
}

function checkNavigationMenu()
{
	// if none of the sub navs are showing
	if( !(checkMouseInDiv("CreateObject_menu")+checkMouseInDiv("Approve_menu")+checkMouseInDiv("MoveNav_menu")) )
		checkMouseInDiv("daemon_navigation_popupMenu");

	if( !checkMouseInDiv("MoveObject_menu") ) checkMouseInDiv("daemon_object_popupMenu");
}

function popupMenu( id )
{
	var menuObject = document.getElementById(id+"_menu");
	var boundingRect = document.getElementById(id+"_item").getBoundingClientRect();
	
	menuObject.style.left=(boundingRect.right-22+document.body.scrollLeft);
	menuObject.style.top=boundingRect.top+document.body.scrollTop;
	
	menuObject.style.visibility="visible"
}

function checkMouseInDiv( divId )
{
	var theDiv = document.getElementById(divId);
	
	if( theDiv.style.visibility!="hidden" )
	{
		var boundingRect = theDiv.getBoundingClientRect();
		
		if ( event.x<boundingRect.left || event.x>boundingRect.right || 
				event.y<boundingRect.top || event.y>boundingRect.bottom )
		{
			hideNavigationMenu( divId );
			return 0;
		}
		return 1;
	}
	
	return 0;
}

function permissionCheck( id, pid )
{
	var permission = 0;
	var thisPerm = 0;
	
	while(permission==0)
	{
		if( typeof(p[id][pid])=='undefined' ) thisPerm=0; else thisPerm=p[id][pid];
		if( permission==0 && thisPerm != 0) permission=thisPerm;
		
		if( typeof( p[id].n ) != 'undefined' ) id = p[id].n; else break;
	}
	
	return permission;
}