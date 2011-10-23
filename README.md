HtmlShow
====================

Example
-------

    $ cd examples
    $ tree
    .
    ├── 10_hello_world.html
    ├── 20_jquery_hover.html
    ├── 30_bootstrap.html
    └── assets
         ├── bootstrap.css
         ├── jquery.js
         └── rails.png

    $ html_show
    3 files done.

    $ tree _present_html
    _present_html/
    ├── 10_hello_world.html
    ├── 20_jquery_hover.html
    ├── 30_bootstrap.html
    ├── application.css
    ├── assets
    │   ├── bootstrap.css
    │   ├── jquery.js
    │   └── rails.png
    ├── index.html
    └── jquery.js

    $ open _present_html/index.html
