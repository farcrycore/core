// Copyright (c) 2006. Adobe Systems Incorporated.
// All rights reserved.
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
//   * Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//   * Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//   * Neither the name of Adobe Systems Incorporated nor the names of its
//     contributors may be used to endorse or promote products derived from this
//     software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

// Global variables:

var gThumbWidth = 24;
var gThumbHeight = 24;
var gBehaviorsArray = [];
var gSlideShowTimer = null;
var gImageLoader = null;

// Register a callback on the thumbnails region so we can show the first
// image in the data set whenever the data changes.

Spry.Data.Region.addObserver("thumbnails", function(nType, notifier, data) {
	if (nType == "onPreLoad")
		StopSlideShow();
	else if (nType == "onPostUpdate")
	{
		StartSlideShow();
		ShowCurrentImage();
	}
});

// Trigger the transition animation from the current image
// being displayed to the image at imgPath.

function SetMainImage(imgPath, width, height, tnID)
{
  var img = document.getElementById("mainImage");
  if (!img)
    return;

  CancelBehavior("mainImage");

  Spry.Utils.SelectionManager.clearSelection("thumbnailSelection");

  if (tnID)
    Spry.Utils.SelectionManager.select("thumbnailSelection", document.getElementById(tnID), "selectedThumbnail");

  if (gImageLoader)
  {
    gImageLoader.onload = function() {};
    gImageLoader = null;
  }

  gBehaviorsArray["mainImage"] = new Spry.Effects.Opacity(img, 0, { duration: 400, steps: 10,
    onComplete: function(b)
	{
      gBehaviorsArray["mainImage"] = new Spry.Effects.Size(img.parentNode, width, height, {duration: 400, steps: 10,
	    onComplete: function(b)
	    {
		  // Use an image loader to make sure we only fade in the new image after
		  // it is completely loaded.
	      gImageLoader = new Image();
		  gImageLoader.onload = function()
		  {
	        img.src = gImageLoader.src;
			gImageLoader = null;
	        gBehaviorsArray["mainImage"] = new Spry.Effects.Opacity(img, 1, { duration: 400, steps: 10, onComplete: function(b) { gBehaviorsArray["mainImage"] = null; }});
		  };
		  gImageLoader.src = imgPath;
	    }
	  });
    }
  });
}

// Cancel the animation behavior of the object with the given id.

function CancelBehavior(id)
{
  if (gBehaviorsArray[id])
  {
    gBehaviorsArray[id].stop();
    gBehaviorsArray[id] = null;
  }
}

// Trigger the animation of the thumbnail growing.

function GrowThumbnail(img, width, height)
{
  Spry.Utils.addClassName(img, "inFocus");
  img.style.zIndex = 150;

  var id = img.getAttribute("id");

  var twidth = Math.floor(width * .75);
  var theight = Math.floor(height * .75);
  var tx = (gThumbWidth - twidth) / 2;
  var ty = (gThumbHeight - theight) / 2;

  CancelBehavior(id);

  gBehaviorsArray[id] = new Spry.Effects.SizeAndPosition(img, tx, ty, twidth, theight,{duration:400,steps:10,onComplete:function(b){gBehaviorsArray[id] = null;}});
}

// Trigger the animation of the thumbnail shrinking.

function ShrinkThumbnail(img)
{
  Spry.Utils.addClassName(img, "inFocus");
  img.style.zIndex = 1;

  var id = img.getAttribute("id");

  CancelBehavior(id);

  gBehaviorsArray[id] = new Spry.Effects.SizeAndPosition(img, 0, 0, gThumbWidth, gThumbHeight, {duration:400,steps:10,onComplete:function(b){gBehaviorsArray[id] = null; Spry.Utils.removeClassName(img, "inFocus");}});
}

// Show the image of the current selected row inside the dsPhotos data set.

function ShowCurrentImage()
{
  var curRow = dsPhotos.getCurrentRow();
  SetMainImage("galleries/" + dsGalleries.getCurrentRow()["@base"] + "images/" + curRow["@path"], curRow["@width"], curRow["@height"], "tn" + curRow["ds_RowID"]);
}

// Utility function to advance (forwards or backwards) the current selected row
// in dsPhotos. This has the side effect of "selecting" the thumbnail and image
// of the new current row.

function AdvanceToNextImage(moveBackwards)
{
  var rows = dsPhotos.getData();
  var curRow = dsPhotos.getCurrentRow();
  
  if (rows.length < 1)
    return;

  for (var i = 0; i < rows.length; i++)
  {
    if (rows[i] == curRow)
    {
      if (moveBackwards)
        --i;
      else
        ++i;
      break;
    }
  }

  if (!moveBackwards && i >= rows.length)
    i = 0;
  else if (moveBackwards && i < 0)
    i = rows.length - 1;

  curRow = rows[i];
  dsPhotos.setCurrentRow(curRow["ds_RowID"]);
  ShowCurrentImage();
}

// Start the slide show that runs forwards through all
// the rows in dsPhotos.

function StartSlideShow()
{
  if (gSlideShowTimer)
    clearInterval(gSlideShowTimer);
  gSlideShowTimer = setInterval(function(){ AdvanceToNextImage(false); }, 6000);
  var playLabel = document.getElementById("playLabel");
  if (playLabel)
  	playLabel.firstChild.data = "Pause";
}

// Kill any slide show that is currently running.

function StopSlideShow()
{
  if (gSlideShowTimer)
    clearInterval(gSlideShowTimer);
  gSlideShowTimer = null;
  var playLabel = document.getElementById("playLabel");
  if (playLabel)
  	playLabel.firstChild.data = "Play";
}

function HandleThumbnailClick(id)
{
  StopSlideShow();
  dsPhotos.setCurrentRow(id);
  ShowCurrentImage();
}