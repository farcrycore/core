function verifyForm() 
{
    var formObj = document.installForm;
    var siteName = formObj.siteName.value;
    var dsn = formObj.appDSN.value;
	var dbType = formObj.dbType[formObj.dbType.selectedIndex].value;
	var re = /[^a-zA-Z0-9\_]/;

    if (!siteName) {
        alert('Please enter an Application Name');
        formObj.siteName.focus();
        return false;
    } else if (siteName == 'farcry') {
        alert('You cannot name your site "farcry"');
        formObj.siteName.focus();
        return false;
	} else if (siteName == 'farcry_pliant') {
        alert('You cannot name your site "farcry_pliant"');
        formObj.siteName.focus();
        return false;
	} else if (siteName == 'farcry_mollio') {
        alert('You cannot name your site "farcry_mollio"');
        formObj.siteName.focus();
        return false;		
	} else if (siteName == 'farcry_core') {
        alert('You cannot name your site "farcry_core"');
        formObj.siteName.focus();
        return false;
	} else if (siteName == 'fourq') {
        alert('You cannot name your site "fourq"');
        formObj.siteName.focus();
        return false;
	} else if (!dsn) {
        alert('Please enter your project DSN');
        formObj.appDSN.focus();
        return false;
    } else if ('0123456789'.indexOf(dsn.charAt(0),0)!=-1) {
        alert("Your dsn can't begin with a number");
        formObj.appDSN.focus();
        return false;		
	} else if (re.test(dsn)) {
        alert('Please select an installation DSN with [a-zA-Z0-9_].');
        formObj.appDSN.focus();
        return false;
	} else if (dsn.indexOf('-')!=-1) {
        alert('You cannot have a - in your dsn');
        formObj.appDSN.focus();
        return false;	
	} else if (siteName.indexOf('-')!=-1) {
        alert('You cannot have a hypen (\'-\') in your site name');
        formObj.siteName.focus();
        return false;	
    } else if ('0123456789'.indexOf(siteName.charAt(0),0)!=-1) {
        alert("Your site name can't begin with a number");
        formObj.siteName.focus();
        return false;
	} else if (!dbType) {
        alert('Please select a database type');
        formObj.dbType.focus();
        return false;	
	} else
        return true;
}

function hideIIS(showAlert) 
{
    if (document.installForm.bInstallIIS.checked) 
    {
        document.getElementById("iisOSType").style.visibility="visible";
        document.getElementById("iisHName").style.visibility="visible";
        document.getElementById("iisAScripts").style.visibility="visible";
    } 
    else 
    {
        document.getElementById("iisOSType").style.visibility="hidden";
        document.getElementById("iisHName").style.visibility="hidden";
        document.getElementById("iisAScripts").style.visibility="hidden";
		if (showAlert) 
		{
			alert('You will need to setup your webserver mappings manually before continuing. Please refer to the install guide for details.');
		}
    }
}

function checkDBType(dbType)
{
	//alert(dbType);
	if(dbType == "postgresql" || dbType == "mysql" || dbType == "")
	{
		document.installForm.dbOwner.value='';
		//hide DB Owner field for relevant db types
		blocking('divDBOwner', 0);		
	}
	else
	{
		document.installForm.dbOwner.value='dbo.';
		blocking('divDBOwner', 1);
	}
}


function blocking(nr, status)
{
	var current;		
	current = (status) ? 'block' : 'none';
	
	if (document.layers)
	{
		document.layers[nr].display = current;
	}
	else if (document.all)
	{
		document.all[nr].style.display = current;
	}
	else if (document.getElementById)
	{
		document.getElementById(nr).style.display = current;
	}
}

function setWebtopMapping()
{
	var frm = document.installForm;
	
	if(frm.appMapping.value != '/')
	{
		//there is a virtual directory present, prepend to admin mapping
		//frm.farcryMapping.value = frm.appMapping.value + frm.farcryMapping.value;
		frm.farcryMapping.value = frm.appMapping.value + '/farcry';
	}	
}

function checkFarcryMapping()
{
	var frm = document.installForm;
	var currentFarcryMapping = frm.farcryMapping.value;
	
	//make sure there is a '/' at the start of the Farcry Web Mapping
	if(currentFarcryMapping.charAt(0) != '/')
	{
		frm.farcryMapping.value = '/' + frm.farcryMapping.value;
	}
}



function xstooltip_findPosX(obj) 
{
  var curleft = 0;
  if (obj.offsetParent) 
  {
    while (obj.offsetParent) 
        {
            curleft += obj.offsetLeft
            obj = obj.offsetParent;
        }
    }
    else if (obj.x)
        curleft += obj.x;
    return curleft;
}

function xstooltip_findPosY(obj) 
{
    var curtop = 0;
    if (obj.offsetParent) 
    {
        while (obj.offsetParent) 
        {
            curtop += obj.offsetTop
            obj = obj.offsetParent;
        }
    }
    else if (obj.y)
        curtop += obj.y;
    return curtop;
}

function xstooltip_show(tooltipId, parentId, posX, posY)
{
    it = document.getElementById(tooltipId);
    
    if ((it.style.top == '' || it.style.top == 0) 
        && (it.style.left == '' || it.style.left == 0))
    {
        // need to fixate default size (MSIE problem)
        it.style.width = it.offsetWidth + 'px';
        it.style.height = it.offsetHeight + 'px';
        
        img = document.getElementById(parentId); 
    
        // if tooltip is too wide, shift left to be within parent 
        if (posX + it.offsetWidth > img.offsetWidth) posX = img.offsetWidth - it.offsetWidth;
        if (posX < 0 ) posX = 0; 
        
        x = xstooltip_findPosX(img) + posX;
        y = xstooltip_findPosY(img) + posY;
        
        it.style.top = y + 'px';
        it.style.left = x + 'px';
    }
    
    it.style.visibility = 'visible'; 
}

function xstooltip_hide(id)
{
    it = document.getElementById(id); 
    it.style.visibility = 'hidden'; 
}