ENV?=dev

.PHONY: dev.start dev.stop verify release

.DEFAULT_GOAL := dev

# 默认目标，启动开发环境，并启动iex
dev: dev.pre dev.iex

# 启动开发环境
dev.pre:
	@mix dev.start

# 启动iex
dev.iex:
	@iex -S mix

# 停止开发环境
dev.stop:
	@mix dev.stop

# 验证API
verify:
	./priv/sh/verify.sh $(ENV)

# 编译发布版本
build:
	@ENV=prod mix release --force --quiet --overwrite
 