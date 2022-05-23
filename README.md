# cls log service ios sdk

## 功能特点

* 异步
    * 异步写入，客户端线程无阻塞
* 聚合&压缩 上传
    * 支持按超时时间、日志数、日志size聚合数据发送
    * 支持lz4压缩
* 缓存
    * 支持缓存上限可设置
    * 超过上限后日志写入失败



- 核心上报架构

![image-20220520153540004](/Users/herrylv/Library/Application Support/typora-user-images/image-20220520153540004.png)

## Podfile
```
待补充
```

## 配置说明

| 参数                     | 说明                                                         | 取值                                                         |
| ------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| connect_timeout_sec      | 网络连接超时时间                                             | 整数，单位秒，默认为10                                       |
| send_timeout_sec         | 日志发送超时时间                                             | 整数，单位秒，默认为15                                       |
| destroy_flusher_wait_sec | flusher线程销毁最大等待时间                                  | 整数，单位秒，默认为1                                        |
| destroy_sender_wait_sec  | sender线程池销毁最大等待时间                                 | 整数，单位秒，默认为1                                        |
| compress_type            | 数据上传时的压缩类型，默认为LZ4压缩                          | 0 不压缩，1 LZ4压缩， 默认为1                                |
| ntp_time_offset          | 设备时间与标准时间之差，值为标准时间-设备时间，一般此种情况用户客户端设备时间不同步的场景 | 整数，单位秒，默认为0；比如当前设备时间为1607064208, 标准时间为1607064308，则值设置为 1607064308 - 1607064208 = 100 |
| max_log_delay_time       | 日志时间与本机时间之差，超过该大小后会根据 `drop_delay_log` 选项进行处理。一般此种情况只会在设置persistent的情况下出现，即设备下线后，超过几天/数月启动，发送退出前未发出的日志 | 整数，单位秒，默认为7*24*3600，即7天                         |
| drop_delay_log           | 对于超过 `max_log_delay_time` 日志的处理策略                 | 0 不丢弃，把日志时间修改为当前时间; 1 丢弃，默认为 1 （丢弃） |
| drop_unauthorized_log    | 是否丢弃鉴权失败的日志，0 不丢弃，1丢弃                      | 整数，默认为 0，即不丢弃                                     |

```

```

### 创建config

https://help.aliyun.com/document_detail/29064.html

```
// endpoint前需要加 https://
NSString* endpoint = @"project's_endpoint";
NSString* project = @"project_name";
NSString* logstore = @"logstore_name";
NSString* accesskeyid = @"your_accesskey_id";
NSString* accesskeysecret = @"your_accesskey_secret";

LogProducerConfig* config = [[LogProducerConfig alloc] initWithEndpoint:endpoint project:project logstore:logstore accessKeyID:accesskeyid accessKeySecret:accesskeysecret];
// 指定sts token 创建config，过期之前调用ResetSecurityToken重置token
// LogProducerConfig* config = [[LogProducerConfig alloc] initWithEndpoint:endpoint project:project logstore:logstore accessKeyID:accesskeyid accessKeySecret:accesskeysecret securityToken:securityToken];
```

### 配置config & 创建client
