## Replicon iOS Client

## Building the app and running the tests

Run the following command line from the git root:

```bash
git submodule update --init
```

Open the project in XCode, select the `NextGenRepliconTimeSheet` target and run the app.

You can run the tests with the same target selected by pressing CMD+U.

For CI purposes, you can also run the tests by running this shell script from the project root:

```bash
./bin/run-specs
```

## Recommended tools

### Better Console

Better console is an Xcode plugin that makes Cedar test failures that include a file path and line number clickable.
You can install this plugin with these steps:

```bash
git clone https://github.com/cppforlife/betterconsole.git
cd betterconsole
rake install
```

### Cedar Shortcuts
Cedar shortcuts is another Xcode plugin that makes writing Cedar specs easier. For example, ctrl + opt + i will import the class name under the cursor. 
You can install the plugin by following these steps:

```bash
git clone https://github.com/cppforlife/cedarshortcuts.git
cd cedarshortcuts
rake install
```

### Installing xcode snippets

To install the code snippets (featuring luminaries such as `idnr` and `noinit`), please run the following command from the git root:

```bash
./bin/install-code-snippets.sh
```

And then restart XCode. The snippets should now be usable.

### Installing Checkman configuration

If you wish to use [Checkman](https://github.com/cppforlife/checkman) to display the CI status, install it and then do the following to install the configuration for this project:

```
$ mkdir ~/Checkman
$ ln -s /Users/pivotal/workspace/timesheet-ios/ci/Checkman/astro ~/Checkman/astro
```

Where `/Users/pivotal/workspace/timesheet-ios` is where you have cloned the timesheet-ios repository.

### Thrust

Thrust is a helpful set of Ruby rake tasks that allow you to automate running specs, making builds, etc. We have primarily been using it for two tasks

* `$ rake nof` - this will unfocus any focussed specs in our spec suite.
* `$ rake trim` - this will clean up any trailing whitespace in our sourcecode.

In order to get Thrust working, you will need to have a working Ruby installation. `rbenv` is a useful tool for managing Ruby versions:

https://github.com/sstephenson/rbenv

We recommend installing it with [homebrew](http://brew.sh/):

```
$ brew update
$ brew install rbenv ruby-build
$ echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
```

Restart your shell, and then you can install the latest Ruby version (2.2.2 at the time of writing):

```
$ rbenv install 2.2.2
$ rbenv global 2.2.2
```

Reopen your shell again, then go to your checked out project (~/workspace/timesheet-ios on the Pivotal machines). You can then install thrust:

```
$ gem install bundler
$ bundle
```

If you then run `rake -T`, you should see a list of rake tasks, including `nof` and `trim`.

## Install XcodeColors

**XcodeColors** is a simple plugin for Xcode.  
It allows you to use colors in the Xcode debugging console.

Full installation instructions can be found on the XcodeColors project page:  
https://github.com/robbiehanson/XcodeColors

But here's a summary:
- Download the plugin
- Slap it into the Xcode Plug-ins directory
- Restart Xcode
