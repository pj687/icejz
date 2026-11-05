## 说明
icejz-boot 是采用组件模式，扩展不同的业务功能，可以很方便的实现各种业务需求，且不会导致系统臃肿，若想使用某个组件，按需引入即可，反之亦然。

## 引入
如果需要使用对应的组件，如：`icejz-boot-quartz`，则需要在`icejz-boot/icejz-server/pom.xml`里面引入，如下所示：

```xml
<dependency>
    <groupId>net.icejz</groupId>
    <artifactId>icejz-boot-quartz</artifactId>
    <version>${revision}</version>
</dependency>
```

## SQL 语句
组件相关表结构与初始数据已包含在全量脚本中，首次只需导入：

```
icejz-boot/db/mysql/icejz.sql
```