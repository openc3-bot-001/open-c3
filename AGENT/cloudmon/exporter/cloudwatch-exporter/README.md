# 监控采集器/云监控/AWS

https://github.com/prometheus/cloudwatch_exporter

# 配置例子
```
---
ak: 'ak'
sk: 'sk'

region: us-west-2
metrics:
 - aws_namespace: AWS/RDS
   aws_metric_name: DatabaseConnections
   aws_dimensions: [ DBInstanceIdentifier]
   aws_statistics: [Maximum]

 - aws_namespace: AWS/RDS
   aws_metric_name: FreeableMemory
   aws_dimensions: [ DBInstanceIdentifier]
   aws_statistics: [Maximum]

 - aws_namespace: AWS/RDS
   aws_metric_name: CPUUtilization
   aws_dimensions: [ DBInstanceIdentifier]
   aws_statistics: [Maximum]

 - aws_namespace: AWS/RDS
   aws_metric_name: FreeStorageSpace
   aws_dimensions: [ DBInstanceIdentifier]
   aws_statistics: [Maximum]

 - aws_namespace: AWS/ELB
   aws_metric_name: RequestCount
   aws_dimensions: [AvailabilityZone, LoadBalancerName]
   aws_statistics: [Sum]

 - aws_namespace: AWS/ElastiCache
   aws_metric_name: EngineCPUUtilization
   aws_dimensions: [ CacheClusterId]
   aws_statistics: [Maximum]

 - aws_namespace: AWS/ElastiCache
   aws_metric_name: DatabaseMemoryUsagePercentage
   aws_dimensions: [ CacheClusterId]
   aws_statistics: [Maximum]

```
# 获取metrics列表
AWS_ACCESS_KEY_ID='ak' AWS_SECRET_ACCESS_KEY='sk' aws cloudwatch list-metrics
AWS_ACCESS_KEY_ID='ak' AWS_SECRET_ACCESS_KEY='sk' aws cloudwatch list-metrics --namespace AWS/RDS
AWS_ACCESS_KEY_ID='ak' AWS_SECRET_ACCESS_KEY='sk' aws cloudwatch list-metrics --namespace AWS/ElastiCache

# 生成配置文件

上述配置文件的编写步骤繁琐，可以通过如下方式生产配置文件。

```
# 查看可用的namespace
./cloudmon/exporter/cloudwatch-exporter/config-make  --ak yourak --sk yoursk --region ap-southeast-1

# 生成某类资源的配置
./cloudmon/exporter/cloudwatch-exporter/config-make  --ak yourak --sk yoursk --region ap-southeast-1 --namespace AWS/Kafka
```
