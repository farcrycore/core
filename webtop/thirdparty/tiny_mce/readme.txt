TinyMCE CF GZIP gzips all javascript files in TinyMCE to
a single streamed file. This makes the overall download
size 75% smaller and the number of requests will also be
reduced. The overall initialization time for TinyMCE will
be reduced dramatically if you use this script. 

Copyright (c) 2009 Gravinese Enterprises Inc.
Jules Gravinese :: http://www.webveteran.com/

TinyMCE CF GZIP is licensed under LGPL license.
More details can be found here: http://tinymce.moxiecode.com/license.php

The gzip functions were adapted and incorporated by permission
from Artur Kordowski's Zip CFC 1.2 : http://zipcfc.riaforge.org/

REQUIREMENTS:
* CF/Java write permission to the directory tinyMCE is in.
* CF Permission to CFObject tag.