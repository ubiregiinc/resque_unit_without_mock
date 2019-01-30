# ResqueUnitWithoutMock
現物redisにを使いながらresque_unitとほぼ同じIFのメソッドを提供するgemです。
このgemを使うと、resque_unitを使っていたけど実物redisを使うテストに切り替える時に既存テストをほぼ維持したまま移行が可能です。
minitestのみサポートしています。(please pull request for support rspec)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'resque_unit_without_mock', group: :test
```

And then execute:

    $ bundle

## Usage
### resque_unitとの違い
resque_unitで提供していた `Resque#queues` は `Resque#queued` になっています。

### `Resque.reset!` は使用するプロジェクト内で再定義してください
```ruby
# example
module ResqueHelpersExt
  def reset!
    Resque.data_store.redis.select(ENV['TEST_ENV_NUMBER'].to_i + 1)
    Resque.data_store.redis.flushdb
    super
  end
end
ResqueUnitWithoutMock::ResqueHelpers.singleton_class.prepend(
  ResqueHelperExt
)
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
