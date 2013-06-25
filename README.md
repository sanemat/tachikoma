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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
