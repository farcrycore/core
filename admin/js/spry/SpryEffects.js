/* SpryEffects.js - Revision: Spry Preview Release 1.1 */

// Copyright (c) 2006. Adobe Systems Incorporated.
// All rights reserved.
//
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

var Spry;
if (!Spry) Spry = {};
if (!Spry.Effects) Spry.Effects = {};

Spry.Effects.getElement = function(ele)
{
	if (ele && typeof ele == "string")
		return document.getElementById(ele);
	return ele;
}

Spry.Effects.getStyleProp = function(element, prop)
{
	try
	{
		if (element.style[prop])
			return element.style[prop];
		else if (element.currentStyle)
			return element.currentStyle[prop];
		else if (document.defaultView && document.defaultView.getComputedStyle)
		{
			var style = document.defaultView.getComputedStyle(element, null);
			return style.getpropValue(prop);
		}
	}
	catch (e) {}

	return null;
};

Spry.Effects.Animator = function(options)
{
	this.timer = null;
	this.interval = 0;
	this.stepCount = 0;

	this.options = {
		fps: 0,
		steps: 10,
		duration: 500,
		onComplete: null
	};

	this.setOptions(options);

	// If caller specified speed in terms of frames per second,
	// convert them into steps.

	if (this.options.fps > 0)
	{
		this.interval = Math.floor(1000 / this.options.fps);
		this.options.steps = parseInt((this.options.duration + (this.interval - 1)) / this.interval);
	}
	else if (this.options.steps > 0)
		this.interval = this.options.duration / this.options.steps;

	this.timeElapsed = 0;
};

Spry.Effects.Animator.prototype.setOptions = function(options)
{
	if (!options)
		return;
	for (var prop in options)
		this.options[prop] = options[prop];
};

Spry.Effects.Animator.prototype.start = function()
{
	var self = this;
	this.timer = setTimeout(function() { self.stepAnimation(); }, this.interval);
};

Spry.Effects.Animator.prototype.stop = function()
{
	if (this.timer)
		clearTimeout(this.timer);
	this.timer = null;
};

Spry.Effects.Animator.prototype.stepAnimation = function()
{
	++this.stepCount;

	this.animate();

	if (this.stepCount < this.options.steps)
		this.start();
	else if (this.options.onComplete)
		this.options.onComplete();
};

Spry.Effects.Animator.prototype.animate = function() {};

/////////////////////////////////////////////////////

Spry.Effects.Move = function(element, x, y, options)
{
	Spry.Effects.Animator.call(this, options);

	this.element = Spry.Effects.getElement(element);
	this.stopX = x;
	this.stopY = y;

	this.x = Spry.Effects.getStyleProp(element, "left");
	this.y = Spry.Effects.getStyleProp(element, "top");

	if (!this.x || this.x == "auto")
		this.x = element.offsetLeft;
	else
		this.x = parseInt(this.x);
	
	if (!this.y || this.y == "auto")
		this.y = element.offsetTop;
	else
		this.y = parseInt(this.y);

	this.incrX = (this.stopX - this.x) / this.options.steps;
	this.incrY = (this.stopY - this.y) / this.options.steps;
	
	this.start();
};

Spry.Effects.Move.prototype = new Spry.Effects.Animator();
Spry.Effects.Move.prototype.constructor = Spry.Effects.Move;

Spry.Effects.Move.prototype.animate = function()
{
	if (this.stepCount >= this.options.steps)
	{
		this.x = this.stopX;
		this.y = this.stopY;
	}
	else
	{
		this.x += this.incrX;
		this.y += this.incrY;
	}

	this.element.style.left = this.x + "px";
	this.element.style.top = this.y + "px";
};

/////////////////////////////////////////////////////

Spry.Effects.Size = function(element, w, h, options)
{
	Spry.Effects.Animator.call(this, options);

	this.element = Spry.Effects.getElement(element);
	this.stopW = w;
	this.stopH = h;

	this.w = Spry.Effects.getStyleProp(element, "width");
	this.h = Spry.Effects.getStyleProp(element, "height");
	
	if (!this.w || this.w == "auto")
		this.w = element.offsetWidth;
	else
		this.w = parseInt(this.w);
	
	if (!this.h || this.h == "auto")
		this.h = element.offsetHeight;
	else
		this.h = parseInt(this.h);

	this.incrW = (this.stopW - this.w) / this.options.steps;
	this.incrH = (this.stopH - this.h) / this.options.steps;
	
	this.start();
};

Spry.Effects.Size.prototype = new Spry.Effects.Animator();
Spry.Effects.Size.prototype.constructor = Spry.Effects.Size;

Spry.Effects.Size.prototype.animate = function()
{
	if (this.stepCount >= this.options.steps)
	{
		this.w = this.stopW;
		this.h = this.stopH;
	}
	else
	{
		this.w += this.incrW;
		this.h += this.incrH;
	}

	this.element.style.width = this.w + "px";
	this.element.style.height = this.h + "px";
};

/////////////////////////////////////////////////////

Spry.Effects.Opacity = function(element, opacity, options)
{
	Spry.Effects.Animator.call(this, options);

	this.element = Spry.Effects.getElement(element);
	this.stopOpacity = opacity;

	this.opacity = Spry.Effects.getStyleProp(element, "opacity");
	
	if (!this.opacity)
		this.opacity = 1.0; // Argh, just assume it is fully visible.
	else
		this.opacity = parseFloat(this.opacity);

	this.incrO = (this.stopOpacity - this.opacity) / this.options.steps;
	
	this.start();
};

Spry.Effects.Opacity.prototype = new Spry.Effects.Animator();
Spry.Effects.Opacity.prototype.constructor = Spry.Effects.Opacity;

Spry.Effects.Opacity.prototype.animate = function()
{
	if (this.stepCount >= this.options.steps)
		this.opacity = this.stopOpacity;
	else
		this.opacity += this.incrO;

	this.element.style.opacity = this.opacity;
	this.element.style.filter = "alpha(opacity=" + Math.floor(this.opacity * 100) + ")";
};

/////////////////////////////////////////////////////

// CSS Color Keywords:
Spry.Effects.cssColors = [];
Spry.Effects.cssColors["maroon"] = "#800000";
Spry.Effects.cssColors["red"] = "#ff0000";
Spry.Effects.cssColors["orange"] = "#ffA500";
Spry.Effects.cssColors["yellow"] = "#ffff00";
Spry.Effects.cssColors["olive"] = "#808000";
Spry.Effects.cssColors["purple"] = "#800080";
Spry.Effects.cssColors["fuchsia"] = "#ff00ff";
Spry.Effects.cssColors["white"] = "#ffffff";
Spry.Effects.cssColors["lime"] = "#00ff00";
Spry.Effects.cssColors["green"] = "#008000";
Spry.Effects.cssColors["navy"] = "#000080";
Spry.Effects.cssColors["blue"] = "#0000ff";
Spry.Effects.cssColors["aqua"] = "#00ffff";
Spry.Effects.cssColors["teal"] = "#008080";
Spry.Effects.cssColors["black"] = "#000000";
Spry.Effects.cssColors["silver"] = "#c0c0c0";
Spry.Effects.cssColors["gray"] = "#808080";

/////////////////////////////////////////////////////

// XXX: Replace thsi with the effects combinator
// when it's implemented.
Spry.Effects.SizeAndPosition = function(element, x, y, w, h, options)
{
	this.mover = new Spry.Effects.Move(element, x, y, options);
	this.sizer = new Spry.Effects.Size(element, w, h, options);
};

Spry.Effects.SizeAndPosition.prototype.stop = function()
{
	this.mover.stop();
	this.sizer.stop();
};
