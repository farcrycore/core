/* SpryXML.js - Revision: Spry Preview Release 1.2 */

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

var Spry; if (!Spry) Spry = {}; if (!Spry.XML) Spry.XML = {}; if (!Spry.XML.Schema) Spry.XML.Schema = {};

Spry.XML.Schema.Node = function(nodeName)
{
	this.nodeName = nodeName;
	this.isAttribute = false;
	this.appearsMoreThanOnce = false;
	this.children = new Array;
};

Spry.XML.Schema.Node.prototype.toString = function (indentStr)
{
	if (!indentStr)
		indentStr = "";

	var str = indentStr + this.nodeName;

	if (this.appearsMoreThanOnce)
		str += " (+)";

	str += "\n";

	var newIndentStr = indentStr + "    ";

	for (var $childName in this.children)
	{
		var child = this.children[$childName];
		if (child.isAttribute)
			str += newIndentStr + child.nodeName + "\n";
		else
			str += child.toString(newIndentStr);
	}

	return str;
};

Spry.XML.Schema.mapElementIntoSchemaNode = function(ele, schemaNode)
{
	if (!ele || !schemaNode)
		return;

	// Add all attributes as children to schemaNode!

	var i = 0;
	for (i = 0; i < ele.attributes.length; i++)
	{
		var attr = ele.attributes.item(i);
		if (attr && attr.nodeType == 2 /* Node.ATTRIBUTE_NODE */)
		{
			var attrName = "@" + attr.name;

			// We don't track the number of times an attribute appears
			// in a given element so we only handle the case where the
			// attribute doesn't already exist in the schemaNode.children array.

			if (!schemaNode.children[attrName])
			{
				var attrObj = new Spry.XML.Schema.Node(attrName);
				attrObj.isAttribute = true;
				schemaNode.children[attrName] = attrObj;
			}
		}
	}

	// Now add all of element's element children as children of schemaNode!

	var child = ele.firstChild;
	var namesSeenSoFar = new Array;
  
	while (child)
	{
		if (child.nodeType == 1 /* Node.ELEMENT_NODE */)
		{
			var childSchemaNode = schemaNode.children[child.nodeName];

			if (!childSchemaNode)
			{
				childSchemaNode = new Spry.XML.Schema.Node(child.nodeName);
				if (childSchemaNode)
					schemaNode.children[child.nodeName] = childSchemaNode;
			}

			if (childSchemaNode)
			{
				if (namesSeenSoFar[childSchemaNode.nodeName])
					childSchemaNode.appearsMoreThanOnce = true;
				else
					namesSeenSoFar[childSchemaNode.nodeName] = true;
			}

			Spry.XML.Schema.mapElementIntoSchemaNode(child, childSchemaNode);
		}

		child = child.nextSibling;
	} 
};

Spry.XML.getSchemaForElement = function(ele)
{
	if (!ele)
		return null;

	schemaNode = new Spry.XML.Schema.Node(ele.nodeName);
	Spry.XML.Schema.mapElementIntoSchemaNode(ele, schemaNode);

	return schemaNode;
};

Spry.XML.getSchema = function(xmlDoc)
{
	if (!xmlDoc)
		return null;

	// Find the first element in the document that doesn't start with "xml".
	// According to the XML spec tags with names that start with "xml" are reserved
	// for future use.

	var node = xmlDoc.firstChild;

	while (node)
	{
		if (node.nodeType == 1 /* Node.ELEMENT_NODE */)
			break;

		node = node.nextSibling;
	}

	return Spry.XML.getSchemaForElement(node);
};
