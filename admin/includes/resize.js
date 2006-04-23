

moving = new Boolean(false);

function resizerdown()
{ moving=true;
 resizer.setCapture();
 x = event.clientX;
}
function resizermove()
{ if (moving==true)
 { deltax = event.clientX - x;
  column1.style.pixelWidth += deltax;
  resizer.style.pixelLeft += deltax;
  column2.style.pixelWidth -=deltax;
  x = event.clientX;
 }
}
function resizerup()
{ resizer.releaseCapture();
 moving = false;
}

function windowResize()
{/*x = event.clientX;
	deltax = event.clientX - x;
	alert(deltax);

  column1.style.pixelWidth += deltax;
  resizer.style.pixelLeft += deltax;
  column2.style.pixelWidth -=deltax;
  x = event.clientX;*/
}