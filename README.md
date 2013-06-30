# Tachikoma

Daily Pull Requester with bundle update

## How to run at your local machine

1. Get GitHub OAuth2 token: See [Creating an OAuth token for command-line use](https://help.github.com/articles/creating-an-oauth-token-for-command-line-use)
2. Add YAML of repository you want to build by Tachikoma: Copy `data/fenix-knight.yaml` then edit `url` and `type`. Change `url` to clone URL of your repository. Change `type` to `shared`.
3. Run below command in your shell:

```
$ mkdir -p repos
$ export BUILD_FOR=<your-repository-name-that-is-same-to-yaml-filename>
$ export TOKEN_YOUR_REPOSITORY_NAME_THAT_IS_SAME_TO_YAML_FILENAME=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
$ bundle exec rake tachikoma:load tachikoma:fetch tachikoma:bundle tachikoma:pull_request
```

## Collaborate with private YAML data

Tachikoma uses `./data` as a default data directory that stores YAML setting files.

To locate other data directory, set `LOCAL_DATA_PATH` and `LOCAL_DATA_REMOTE_URL` environment variables.

* `LOCAL_DATA_PATH`: data directory/location of YAML files. relative/absolute path also ok.
* `LOCAL_DATA_REMOTE_URL`: git clone URL of your data repository. typically HTTPS for public repo, SSH for private repo.

```
$ export LOCAL_DATA_PATH=<local-data-path>
$ export LOCAL_DATA_REMOTE_URL=<git-clone-url-of-your-public-or-private-data-repository>
$ bundle exec rake tachikoma:fetch_data
```

To work with other tasks, just put other tasks after `tachikoma:fetch_data`.

NOTE: other environment variables such as `BUILD_FOR` are also required

```
$ bundle exec rake tachikoma:fetch_data tachikoma:load tachikoma:fetch tachikoma:bundle tachikoma:pull_request
```

## Usage as gem (experimental)

Above description is _inside_ tachikoma, below is usage not _inside_ but _outside_ tachikoma, as gem.

https://github.com/sanemat/bot-motoko-tachikoma

```
$ mkdir -p my-tachikoma
$ cd my-tachikoma
$ bundle init
$ echo "gem 'tachikoma'" >> Gemfile
$ bundle
$ bundle exec tachikoma init
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
