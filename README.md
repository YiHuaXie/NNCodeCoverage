# NNCodeCoverage

[![CI Status](https://img.shields.io/travis/NeroXie/NNCodeCoverage.svg?style=flat)](https://travis-ci.org/NeroXie/NNCodeCoverage)
[![Version](https://img.shields.io/cocoapods/v/NNCodeCoverage.svg?style=flat)](https://cocoapods.org/pods/NNCodeCoverage)
[![License](https://img.shields.io/cocoapods/l/NNCodeCoverage.svg?style=flat)](https://cocoapods.org/pods/NNCodeCoverage)
[![Platform](https://img.shields.io/cocoapods/p/NNCodeCoverage.svg?style=flat)](https://cocoapods.org/pods/NNCodeCoverage)

## 简介

NNCodeCoverage用来统计Swift & Objective-C 工程的代码全量或增量覆盖率，支持在本地开发环境中查看代码覆盖率。

全量代码覆盖率效果：
![全量代码覆盖率](https://neroblog.oss-cn-hangzhou.aliyuncs.com/nn_code_coverage_full.jpg)
增量代码覆盖率效果：
![增量代码覆盖率](https://neroblog.oss-cn-hangzhou.aliyuncs.com/nn_code_coverage_diff.jpg)

## 使用

### 1.安装 NNCodeCoverage

NNCodeCoverage 组件是用来监听代码执行情况，在Podfile 文件中添加以下代码：

```ruby
pod 'NNCodeCoverage'
```

### 2. Xcode中打开Code Coverage选项

![Xcode 配置 Code Coverage](https://neroblog.oss-cn-hangzhou.aliyuncs.com/nn_code_coverage_xcode_config.jpg)

### 3. 脚本安装

将[coverage_scripts]()连同文件夹拷贝至你的电脑任一位置。

![coverage scripts文件夹](https://neroblog.oss-cn-hangzhou.aliyuncs.com/nn_code_coverage_script_files.jpg)

### 4. Podfile文件配置

**Podfile引入coverage_config.rb**

![Podfile引入coverage_config](https://neroblog.oss-cn-hangzhou.aliyuncs.com/nn_code_coverage_config_path.jpg)

**post_intall与pre_install配置**

```ruby
# 重置覆盖率配置的标记
$coverage_recover = false
# 设置需要获取覆盖率的组件为static framework
$static_frameworks = ['MBProgressHUD', 'SwiftTestModule', 'OCTestModule']

# 初始化配置
coverage_setup($coverage_recover)

pre_install do |installer|
  # 设置组件为二进制格式
  coverage_static_frameworks_config($static_frameworks, installer)
end

post_install do |installer|
  # pod project配置
  coverage_pods_project_config(installer, $coverage_recover)
end
```

关于`coverage_static_frameworks_config`的这个函数是用来支持本地环境下获取代码覆盖率的，如果你的组件既不是二进制格式的，podspec中又没有指定`static_framework=true`，在代码覆盖率结果中是看不到相关代码的覆盖率的，可以通过该函数将组件改成 static framework（以`MBProgressHUD`为例）。

### 5. 安装lcov

如果想要获取增量代码覆盖率则需要依赖 lcov，通过 homebrew 安装 lcov。

```shell
brew install lcov
```

### 6. 执行pod install

```ruby
pod install
```

### 7. 编译项目并运行项目

编译并运行项目就开始代码覆盖率检测。通过上面步骤后，你可以看到你的项目中发生下面的变化：

![code coverage files](https://neroblog.oss-cn-hangzhou.aliyuncs.com/nn_code_coverage_files.jpg) 
### 8. 获取代码覆盖率

运行项目一段时间后，将app退至后面你可以在控制台中看到profraw文件的路径，此时就可以开始代码覆盖率解析了。使用`coverage_show.rb`脚本进行代码覆盖率解析，命令如下

```ruby
ruby xxx/xxx/coverage_scripts/coverage_show.rb --project-dir 项目地址 --profraw-path profraw文件地址 --git-diff-commit gitcommit1,gitcommit2
```

使用`ruby xxx/xxx/coverage_scripts/coverage_show.rb --help`可以查看具体参数

![coverage show help](https://neroblog.oss-cn-hangzhou.aliyuncs.com/nn_code_coverage_show_help.jpg)

### 9. 结果查看

![code coverage result](https://neroblog.oss-cn-hangzhou.aliyuncs.com/nn_code_coverage_html.jpg)

## 关于增量代码覆盖率

关于增量代码覆盖率，我采用的也是网上提到的基于git diff的方式进行获取增量覆盖率。通过git diff 命令我们可以获取到代码的修改，git diff直接使用网上现有的脚本[diffParser.rb](https://github.com/JerryChu/UnitTestParser/blob/master/utils/diffParser.rb)。

基于 llvm-cov 获取到 profdata 文件是一个二进制文件，直接解析该文件还是比较困难的，但是可以通过 profdata 文件生成 info文件。通过 diff 解析结果与原始的 info 文件做一次对比，裁剪出一份新的 info 文件，通过 lcov 对裁剪后的 info 文件进行解析就可以获取到增量代码的代码覆盖率情况。

## Example

这里提供了一个[Example App](./Example)来方便更好地理解。

1. 安装Example App
2. 按使用流程进行配置并运行pod install
3. 运行项目后退至后台，开始进行代码覆盖率解析

## 要求

`iOS 10+`

## 作者

NeroXie, xyh30902@163.com

## 许可证

NNBox 基于 MIT 许可证，查看 LICENSE 文件了解更多信息。
