# Tachikoma

[![Gem Version](http://img.shields.io/gem/v/tachikoma.svg?style=flat)](http://badge.fury.io/rb/tachikoma)
[![Build Status](http://img.shields.io/travis/sanemat/tachikoma/master.svg?style=flat)](https://travis-ci.org/sanemat/tachikoma)
[![Code Climate](http://img.shields.io/codeclimate/github/sanemat/tachikoma.svg?style=flat)](https://codeclimate.com/github/sanemat/tachikoma)
[![Coverage Status](http://img.shields.io/coveralls/sanemat/tachikoma/master.svg?style=flat)](https://coveralls.io/r/sanemat/tachikoma)

**Tachikoma** is a Interval Pull Requester with
bundler/carton/david/cocoapods/composer/none update.
This is [Actual pull request](https://github.com/sanemat/tachikoma/pull/152).

![tachikoma](https://cloud.githubusercontent.com/assets/75448/4431995/1f7817e4-4681-11e4-8235-64df5c562496.gif 'tachikoma')
![tachikoma](https://cloud.githubusercontent.com/assets/75448/4431997/26649596-4681-11e4-8d9e-a456f570acd1.gif 'tachikoma')

Most aspects of its behavior can be tweaked via various
[configuration options](data/default.yaml).

## Strategies

You can use these strategies:

- Bundler (Ruby)
- Carton (Perl)
- David (Node.js)
- Cocoapods (Objective-C)
- Composer (PHP)
- None (without strategy)

If you use carton, then you use `tachikoma:run_carton` instead of `tachikoma:run_bundler`.
You can also use `tachikoma:run_none`, `tachikoma:run_cocoapods`, `tachikoma:run_composer` and `tachikoma:run_david`.

## Setting

See [configuration options](data/default.yaml).

### Use as rubygem

see: https://github.com/sanemat/bot-motoko-tachikoma

```
$ mkdir -p my-tachikoma
$ cd my-tachikoma
$ bundle init
$ echo "gem 'tachikoma'" >> Gemfile
$ bundle
$ bundle exec tachikoma init
```

### Write repository information

1. Get GitHub OAuth2 token: See [Creating an OAuth token for command-line use](https://help.github.com/articles/creating-an-oauth-token-for-command-line-use)
2. Add YAML of repository you want to build by Tachikoma: Copy `data/bot-motoko-tachikoma.yaml` then edit `url` and `type`. to clone URL of your repository. Change `type` to `shared`, if you use shared repository model.
3. Run below command in your shell:

```
$ export BUILD_FOR=<your-repository-name-that-is-same-to-yaml-filename>
$ export TOKEN_YOUR_REPOSITORY_NAME_THAT_IS_SAME_TO_YAML_FILENAME=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
$ bundle exec rake tachikoma:run_bundler
```

### Example

[gist-mail setting (data/gist-mail.yaml)](https://github.com/sanemat/bot-motoko-tachikoma/blob/a47ceb8b88f8b6da8028e5c0b641b8a84c9c3505/data/gist-mail.yaml)

```yaml
url:
  'https://github.com/sanemat/gist-mail.git'
type:
  'fork'
pull_request_body:
  ':ideograph_advantage::ideograph_advantage::ideograph_advantage:'
```

This is the [result](https://github.com/sanemat/gist-mail/pull/54).

### Build script example

- [cloudbees.com dev@cloud: Above v4.0.0.beta](https://gist.github.com/sanemat/5859031/aa1966a46a7c00ed975b487f423c36b8ae5b976d)

## Versioning

Tachikoma will be maintained under the Semantic Versioning guidelines as much as possible. Releases will be numbered with the following format:

`<major>.<minor>.<patch>`

And constructed with the following guidelines:

* Breaking backward compatibility bumps the major (and resets the minor and patch)
* New additions without breaking backward compatibility bumps the minor (and resets the patch)
* Bug fixes and misc changes bumps the patch

For more information on SemVer, please visit http://semver.org.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Resources

### Concept
- [Continuous gem dependency updating with Jenkins and Pull Request](http://rubykaigi.org/2013/talk/S72)
at Rubykaigi2013 Talk
by @kyanny
[movie](http://vimeo.com/68300423) _Japanese_
[slide](https://speakerdeck.com/kyanny/continuous-gem-dependency-updating-with-jenkins-and-pull-request) _English/Japanese_

### Screencast
- Tachikoma 10min (Below v3.1 - Old API) _Silent_
[![screen shot 2013-07-22 at 8 09 29 am](https://f.cloud.github.com/assets/75448/832475/b0ce829a-f25a-11e2-8984-521dbe7d838e.png)](https://vimeo.com/70733613)

### Talk
- [Updating Library Dependencies Off and On with Tachikoma](http://yapcasia.org/2013/talk/show/f7fe8ed4-1bcd-11e3-93a2-f74c6aeab6a4)
at YAPC::Asia Tokyo 2013 Lightning Talk
by @sanemat
[slide](https://gist.github.com/sanemat/6605029) _Japanese_
[video](http://www.youtube.com/watch?v=IAoJzxBzOok) _Japanese_
- Updating Library Dependencies Off and On with Tachikoma
at RubyConf 2013 Lightning Talk
by @sanemat
[slide](https://gist.github.com/sanemat/7374944) _English_
[video](http://www.youtube.com/watch?v=gJOkpP__dY4#t=5393) _English_

### Article
- [tachikoma を使って毎日自動で bundle update - willnet.in](http://willnet.in/111)
by @willnet (Below v3.1 - Old API) _Japanese_
- [Jenkins scheduled build Triggers with environment variable | 實松アウトプット](https://sanematsu.wordpress.com/2013/08/17/jenkins-scheduled-build-triggers-with-environment-variable/)
by @sanemat _Japanese_
