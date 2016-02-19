#!/usr/bin/env node

require('shelljs/global');
var directories = require('./directories.js');
var path = require('path');

rm('-Rf', directories.target ); // path.join( directories.target, 'elm.js') );

cp('-R', directories.site, directories.target);

cd(directories.build);

exec('elm-make ' + directories.source + '/Main.elm' + ' --output ' + directories.target + '/elm.js' );
