# XP to Fiat Discord bot script

[![Build Status](https://travis-ci.org/xpjp/xpfiat-bot.svg?branch=master)](https://travis-ci.org/xpjp/xpfiat-bot)

ようこそ！初めての方は以下をご覧ください。

[開発ガイドライン](https://github.com/xpjp/xpfiat-bot/wiki/%E9%96%8B%E7%99%BA%E3%82%AC%E3%82%A4%E3%83%89%E3%83%A9%E3%82%A4%E3%83%B3)

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
