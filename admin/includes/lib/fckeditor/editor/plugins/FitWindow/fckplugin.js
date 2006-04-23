/*
 * FCKeditor - The text editor for internet
 * Copyright (C) 2003-2004 Frederico Caldeira Knabben
 * 
 * Licensed under the terms of the GNU Lesser General Public License:
 * 		http://www.opensource.org/licenses/lgpl-license.php
 * 
 * For further information visit:
 * 		http://www.fckeditor.net/
 * 
 * File Name: en.js
 * 	English language file for the sample plugin.
 * 
 * Version:  2.0 RC2
 * Modified: 2004-11-22 11:20:42
 * 
 * File Authors:
 * 		Paul Moers (mail@saulmade.nl)
 * 		Thanks to Christian Fecteau (webmaster@christianfecteau.com)
 */


// Register the related command.
var FCKFitWindow = function(name)
{
	// variable declaration
	this.Name = name;
	this.editorFrame = parent.document.getElementById(FCK.Name + '___Frame');
	this.documentElementOverflow;
	this.bodyCssText;
	this.bodyClassName;
	this.originalCssText;
	this.originalWidth;
	this.originalHeight;
}


FCKFitWindow.prototype.Resize = function()
{
	var FCKFitWindowInstance	= new FCKFitWindow();
	FCKFitWindowInstance.Execute(true);
}


FCKFitWindow.prototype.Execute = function(hasBeenResized)
{
	var viewPaneWidth, viewPaneHeight;

	hasBeenResized = (hasBeenResized == null) ? false : hasBeenResized;

	// no original style properties known? Then we hop to fullscreen.
	// or forced because of windowResize when in fullscreen mode!
	if (this.originalCssText == null || hasBeenResized == true)
	{
		// Registering an event handler for when the window gets resized (only if the config var FitWindow_autoFitToResize has been set)
		if (hasBeenResized == false && FCKConfig.FitWindow_autoFitToResize == true)
		{
			if (top.attachEvent)
			{
				top.attachEvent("onresize", this.Resize);
			}
			else if(top.addEventListener)
			{
				top.addEventListener("resize", this.Resize, true);
			}
		}

		// preparing the body for the editor in fullsize and hiding the scrollbars in Firefox
		with (top.document.getElementsByTagName("body")[0].style)
		{
			this.bodyCssText	 						= cssText;
			cssText	 									= "";
			overflow									= "hidden";
			margin										= "0px";
			padding										= "0px";
			height										= "0px";
			width											= "0px";
			position										= "static";
			top											= "0px";
			left											= "0px";
		}
		// also storing a possible className
		this.bodyClassName = top.document.getElementsByTagName("body")[0].className;
		// hide IE scrollbars (in strict mode)
		if (FCKBrowserInfo.IsIE)
		{
			this.documentElementOverflow = top.document.documentElement.style.overflow;
			top.document.documentElement.style.overflow = "hidden";
		}

		// now when the scrollbar is hidden, find the viewPane's dimensions
		viewPaneWidth = findViewPaneWidth();
		viewPaneHeight = findViewPaneHeight();

		// resize
		with (this.editorFrame.style)
		{
			this.originalCssText					= cssText;
			this.originalWidth						= this.editorFrame.width;
			this.originalHeight						= this.editorFrame.height;
			position										= "absolute";
			zIndex										= "9999999";
			left											= "0px";
			top											= "0px";
			width											= viewPaneWidth + "px";
			height										= viewPaneHeight + "px";
			// giving the frame some (huge) borders on his right and bottom side to hide the background that would otherwise show when the editor is in fullsize mode and the window is increased in size
			// not for IE, because IE immediately adapts the editor on resize, without showing any of the background
			// oddly in firefox, the editor seems not to fill the whole frame, so just setting the background of it to white to cover the page laying behind it anyway
			if (!FCKBrowserInfo.IsIE)
			{
				borderRight							= "9999px solid white";
				borderBottom							= "9999px solid white";
				backgroundColor						= "white";
			}
		}

		// scroll to top left
		top.window.scrollTo(0, 0);
	}
	// original style properties available? Resize to original size.
	else
	{
		// Removing the event handler of windowresizing
		if (FCKConfig.FitWindow_autoFitToResize == true)
		{
			if (top.detachEvent)
			{
				top.detachEvent("onresize", this.Resize);
			}
			else if(top.removeEventListener)
			{
				top.removeEventListener("resize", this.Resize, true);
			}
		}

		// restoring the body and restoring the scrollbars in Firefox
		with (top.document.getElementsByTagName("body")[0].style)
		{
			cssText										= this.bodyCssText;
		}
		// maybe it had a className...
		top.document.getElementsByTagName("body")[0].className = this.bodyClassName;
		// show IE scrollbars
		if (FCKBrowserInfo.IsIE)
		{
			top.document.documentElement.style.overflow = this.documentElementOverflow;
		}

		// restore original size
		with (this.editorFrame.style)
		{
			cssText										= this.originalCssText;
			width											= this.originalWidth;
			height										= this.originalHeight;
			position										= "static";
		}

		// scrolling so that the editor appears centered in the viewPane
		var adjustX, adjustY = 0;
		if (FCKConfig.FitWindow_center)
		{
			viewPaneWidth = findViewPaneWidth();
			viewPaneHeight = findViewPaneHeight();

			adjustX = (viewPaneWidth - this.editorFrame.width) / 2;
			adjustY = (viewPaneHeight - this.editorFrame.height) / 2;
			if (adjustX < 1)
			{
				adjustX = 0;
			}
			if (adjustY < 1)
			{
				adjustY = 0;
			}
		}

		// Scroll to the editor
		top.window.scrollTo(findPosX(this.editorFrame) - adjustX, findPosY(this.editorFrame) - adjustY);

		// empty CSS buffer
		this.originalCssText = null;
	}
}


// finding the viewPane's width
function findViewPaneWidth()
{
	var viewPaneWidth = 0;

	if (top.window.clientWidth) // all except Explorer
	{
		viewPaneWidth = top.window.clientWidth;
	}
	else if (top.document.documentElement && top.document.documentElement.clientWidth) // Explorer 6 Strict Mode
	{
		viewPaneWidth = top.document.documentElement.clientWidth;
	}
	else if (top.document.body) // other Explorers
	{
		viewPaneWidth = top.document.body.clientWidth;
	}

	return viewPaneWidth;
}


// finding the viewPane's height
function findViewPaneHeight()
{
	var viewPaneHeight = 0;

	if (top.window.clientHeight) // all except Explorer
	{
		viewPaneHeight = top.window.clientHeight;
	}
	else if (top.document.documentElement && top.document.documentElement.clientHeight) // Explorer 6 Strict Mode
	{
		viewPaneHeight = top.document.documentElement.clientHeight;
	}
	else if (top.document.body) // other Explorers
	{
		viewPaneHeight = top.document.body.clientHeight;
	}

	return viewPaneHeight;
}


function findPosX(obj)
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


function findPosY(obj)
{
	var curtop = 0;

	var printstring = '';
	if (obj.offsetParent)
	{
		while (obj.offsetParent)
		{
			printstring += ' element ' + obj.tagName + ' has ' + obj.offsetTop;
			curtop += obj.offsetTop
			obj = obj.offsetParent;
		}
	}
	else if (obj.y)
		curtop += obj.y;

	return curtop;
}


// manage the plugins' button behavior
FCKFitWindow.prototype.GetState = function()
{
  return FCK_TRISTATE_OFF;
  // default behavior, sometimes you wish to have some kind of if statement here
}

FCKCommands.RegisterCommand( 'FitWindow', new FCKFitWindow('FitWindow'));

// Create the "FitWindow" toolbar button.
var oFitWindowItem = new FCKToolbarButton( "FitWindow", FCKLang.FitWindow ) ;
oFitWindowItem.IconPath = FCKConfig.PluginsPath + 'FitWindow/FitWindow.gif' ;
FCKToolbarItems.RegisterItem( 'FitWindow', oFitWindowItem ) ;


