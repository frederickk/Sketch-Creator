Sketch-Creator
==============

##A Tool for the creation of p5.js sketches ##

![Screenshot](sketch-creator-screenshot.png)

A simple app for the creation of [p5.js](https://github.com/lmccart/p5.js) sketches. Similar to [OpenFrameworks-Project Creator](https://github.com/ofZach/project-creator) and [Cinder-TinderBox](https://github.com/cinder/TinderBox-Mac). This app will create the scaffolding for a self-contained—html, css, js, etc.—[p5.js](https://github.com/lmccart/p5.js) project.

**Download**

[Sketch Creator.zip](https://github.com/frederickk/Sketch-Creator/raw/master/distribution/Sketch%20Creator.zip)



Usage
-------------

**Compatible for OSX 10.7 and above**

A short video showing basic functionality is forthcoming...


**Sketch Name**
Obvious. The name of your sketch.

**Sketchbook Location**
The save location of your sketch. Default is `~/Documents/Processing/` Use the "..." to choose a path to desired folder.

**Events**
Checkboxes for adding hooks for events. Mouse, Touch, and Keyboard are baked into [p5.js](https://github.com/lmccart/p5.js). Drag and Drop is my own implementation and not part of the [p5.js](https://github.com/lmccart/p5.js) core.


**Additional JavaScript Libraries/Addons**
Add source files of any additional JavaScript libraries. Load ordering can be adjusted by dragging rows. This means the tool could easily be used for easily scaffolding for other frameworks [two.js](http://jonobr1.github.io/two.js/), [paper.js](http://paperjs.org/), etc.
-  Checkbox toggles inclusion of selected library during sketch creation.
- "..." change/update path of selected library
- "+" add JavaScript library
- "-" remove selected library

**Include bundled CSS styles**
The included CSS only makes things prettier, it is not required for p5.js.

**Open in browser on creation**
Opens created sketch within the browser. Watch the overview video to see how to use the browser as an [IDE](http://en.wikipedia.org/wiki/Integrated_development_environment).

**Suppress overwrite warnings**
Avoid pop-up warnings for overwriting sketch files with same name.



Examples
-------------




License
-------------
The MIT License (MIT)

Copyright (c) 2014 Ken Frederick

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.