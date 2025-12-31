# 交叉编译配置 (需指定 NDK 路径)
CXX = aarch64-linux-android30-clang++
STRIP = aarch64-linux-android-strip

all: thread_manager

thread_manager: src/main.cpp
	$(CXX) -O3 src/main.cpp -o thread_manager
	$(STRIP) thread_manager

clean:
	rm -f thread_manager