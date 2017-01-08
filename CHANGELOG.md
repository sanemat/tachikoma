## master

Features:

## 5.0.0 (2017-01-08)

- Drop support for ruby 1.9
- Remove json dependency

## 4.2.7 (2016-07-18)

Features:

  - Relax dependencies (#190, @sanemat)
  - Restrict dependencies (#247, @sanemat)

## 4.2.6 (2015-06-22)

Features:
  - Add option: bundler_restore_bundled_with (#185, #187, @sanemat)

## 4.2.5 (2015-05-07)

Features:
  - Support gems.rb/gems.locked pair for bundler v1.8.0 (#159, #161, @sanemat)
  - Support npm shrinkwrap (#176, @sanemat)

## 4.2.4 (2015-01-31)

Features:
  - Use shalow copy(optional) (#151, #141, #139, @laiso, @sanemat)

## 4.2.3 (2014-12-18)

Features:
  - Fix cocoapods command, s/pods/pod/g (#137, @laiso)

## 4.2.2 (2014-11-01)

Features:
  - Fix stripping a repos name too match if the url includes .git(#123, @sanemat)

## 4.2.1 (2014-09-28)

Features:
  - Get the ability for php application `composer update`(#112, #109, @sanemat)
  - Deprecate `run_bundle`, Use `run_bundler` instead (#113, @sanemat)
  - Get the ability for cocoapods application `pods update`(#115, #102, @sanemat)

## 4.2.0 (2014-08-18)

Features:
  - Get the ability for node.js application `david update`(#101, @sanemat)

## 4.1.0 (2014-07-31)

Features:
  - Remove deprecated code (#88, @sanemat)
  - Enable pull request with carton/none strategies :scream: (#95, #96, @sanemat)

## 4.0.4 (2014-04-14)

Features:
  - Add :none strategy (#85, @sanemat)

## 4.0.3 (2013-12-27)

Features:

  - Fix trailing slash in identify url (#71, @sanemat)
  - Add Tachikoma::Exception (#73, @sanemat)
  - All `git clone` and `git push` requests use github authentication token (#77, @sanemat)
  - Deprecate `type: private` (#77, @sanemat)

## 4.0.2 (2013-12-20)

Features:

  - Support for older git versions (1.7.x) and OAuth (#58, @kenchan)
  - Adjust rspec 3 syntax (#59, #60, @banyan)
  - Use Thor, and split template file from script (#61, #63, @sanemat)

## 4.0.1 (2013-12-07)

Features:

  -  Using `--path` option to enhance the independence of multiple projects (#55, @kenchan)

## 4.0.0 (2013-11-08)

Features:

  - Brand-new architecture (#42, @kyanny)
