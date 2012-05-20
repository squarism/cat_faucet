Arduino Cat Faucet
==================

Rails3 webapp that monitors sensors around the home.  Right now, just a sink for my cat.  :)

[Screenshots and blog post here](http://squarism.com/2011/03/09/arduino-cat-faucet-with-mongodb-and-rails/)

Layout
------
Arduino folder for arduino code to be uploaded onto an arduino

cat_faucet_bridge.rb that collects arduino data and loads it to a rails JSON route, bridging serial and the rails app.  IE: run on the console, in tmux or in screen.

Normal rails layout after that.