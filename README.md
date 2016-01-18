# AbacusTrainer
A simple game to improve Abacus skills

Please check the issues list and contribute to this game.  catch me on slack at elmlang or shoot me an email to info at AwesomeFunGame dot com

TODO: Add a screen shot here!


# Build instructions

cd build
elm-package install
npm install

```
cd ..

node build/build.js

```
Now test target/index.html

if every thing looks clean, commit your changes

use ```git status --porcelain``` to confirm that all your changes are committed
.

## Fixing issues

If you have an idea or a change you would like to see in the project,
 1.  Please create an issue on GitHub.
 2.  Make sure your commit message includes the # sign and issue number. example:  [ This fixes #8 ]
 3.  Please create a Pull Request ( PR ) for your commit through GitHub.
 4.  Please confirm that it says "This can be merged without changes" when you create the PR.


# Publish

after a successful build, use 

```node build/publish.js``` 

to publish the final output to the gh-pages branch of your repo.

In the future if the project changes testing the publish part will also help you catch bugs.
