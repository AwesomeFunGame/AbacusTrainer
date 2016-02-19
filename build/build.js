#!/usr/bin/env node

require('shelljs/global');
var directories = require('./directories.js');
var path = require('path');

rm('-Rf', directories.target ); // path.join( directories.target, 'elm.js') );



cd(directories.build);

exec('elm-make ' + directories.source + '/Main.elm' + ' --output ' + path.join( directories.target, 'elm.js')  );

cp('-f', path.join( directories.site, 'index.html' ), directories.target );