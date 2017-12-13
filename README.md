# XP to Fiat Discord bot script

## Usage

1. 依存Gemインストール

~~~sh
$ bundle install --path vendor/bundle
~~~

2. 動作させるにはTOKENとCLIENT_IDを下記で取得し設定する必要があります

https://discordapp.com/developers/applications/me

```
$ mv .env.sample .env
```

.envに`TOKEN`と`CLIENT_ID`をハードコートしてください。

3. とりあえず起動

Gemの管理がBundler経由になったので、以下のように`bundle exec`を忘れずに

~~~sh
$ bundle exec ruby xp_fiat.rb
~~~
