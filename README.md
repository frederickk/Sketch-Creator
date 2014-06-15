Sketch-Creator
==============

##A Tool for the creation of p5.js sketches ##

![Screenshot](sketch-creator-screenshot.png)

A simple app for the creation of [p5.js](https://github.com/lmccart/p5.js) sketches. Similar to [OpenFrameworks-Project Creator](https://github.com/ofZach/project-creator) and [Cinder-TinderBox](https://github.com/cinder/TinderBox-Mac), this app will create a director with all dependencies (html, css, js, etc.) required for a [p5.js](https://github.com/lmccart/p5.js) project.



Usage
-------------

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
Opens created sketch within the browser. Chrome is preferred. You can use the browser as an IDE. Chrome is prefferred because on save the browser is refreshed, but Safari works as well. I didn't test Firefox or Opera. (Video forthcoming)

**Suppress overwrite warnings**
Never see a pop-up warning of overwriting files again. You've been warned.



Examples
-------------
Check out the limited `examples` folder. Head to the home of [p5.js](https://github.com/lmccart/p5.js) for more examples.



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