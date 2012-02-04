Htmlshow
========

HTMLファイルをまとめてプレゼン用のHTMLに変換するツール

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

    $ htmlshow
    3 files done.

    $ tree _show_files
    _show_files/
    ├── 10_hello_world.html
    ├── 20_jquery_hover.html
    ├── 30_bootstrap.html
    ├── application.css
    ├── assets
    │ ├── bootstrap.css
    │ ├── jquery.js
    │ └── rails.png
    ├── index.html
    └── jquery.js

    $ open _show_files/index.html
