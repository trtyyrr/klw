# 快速指令
.PHONY: init help

help:
	@echo "可用命令:"
	@echo "  make init    - 初始化项目环境 (复制配置)"

init:
	cp .env.example .env
	@echo "基础环境初始化完成，请修改 .env 文件"