Htmlshow
========

    $ htmlshow --help
    小さなHTMLを束ねてプレゼン向けHTTMLに変換するなんだかよくわからないツール htmlshow 0.0.6
    使い方: htmlshow [オプション] ディレクトリ or ファイル...
    options:
        -i, --files=FILES                対象ファイル(オプションで指定してもいい)
        -r, --range=RANGE                範囲(初期値:指定なし)
        -a, --assetsdir=DIR              assetsディレクトリ(初期値:assets)
            --outputdir=DIR              出力ディレクトリ(初期値:_show_files)
        -o, --open                       index.html を自動的に開く(初期値:false)
            --title=TITLE                タイトル(初期値:pwdのtitleizeでHtmlshow)
            --reset                      全部消して作り直す？(初期値:false)
            --[no-]static                assetsをコピーする？(初期値:false)
            --[no-]relpath               assetsをsymlinkするとき相対パスにしとく？(初期値:true)
            --[no-]keyboard              ページングをキーボードで操作する？(初期値:true)
            --[no-]prettify              コードに色付けする？(初期値:true)

実行例
------

    $ cd examples
    $ tree
    .
    ├── 0010_hello_world.html
    ├── 0020_jquery_hover.html
    ├── 0030_bootstrap.html
    └── assets
     ├── bootstrap.css
     ├── jquery.js
     └── rails.png

    $ htmlshow
    3 files done.

    $ tree _show_files
    _show_files/
    ├── 0010_hello_world.html
    ├── 0020_jquery_hover.html
    ├── 0030_bootstrap.html
    ├── application.css
    ├── assets
    │ ├── bootstrap.css
    │ ├── jquery.js
    │ └── rails.png
    ├── index.html
    └── jquery.js

    $ open _show_files/index.html
