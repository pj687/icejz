-- ICEJZ Boot MySQL dump (sanitized)
-- Database: icejz_boot
-- Notes:
--   1. AI / SMS / Mail / Third-login / IoT / Generator secrets are cleared.
--   2. sys_user_token data is omitted.
--   3. Fill API keys again in 「系统管理 · AI助手」 after import if needed.
--   4. Default demo passwords remain SM3 hashes (e.g. 123456).

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

--

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
--

DROP TABLE IF EXISTS `gen_base_class`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_base_class` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `package_name` varchar(200) DEFAULT NULL COMMENT '基类包名',
  `code` varchar(200) DEFAULT NULL COMMENT '基类编码',
  `fields` varchar(500) DEFAULT NULL COMMENT '基类字段，多个用英文逗号分隔',
  `remark` varchar(200) DEFAULT NULL COMMENT '备注',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='基类管理';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `gen_base_class` WRITE;
/*!40000 ALTER TABLE `gen_base_class` DISABLE KEYS */;
INSERT INTO `gen_base_class` (`id`, `package_name`, `code`, `fields`, `remark`, `create_time`) VALUES (1,'net.icejz.framework.mybatis.entity','BaseEntity','id,creator,create_time,updater,update_time,version,deleted','使用该基类，则需要表里有这些字段','2026-10-28 05:12:37');
/*!40000 ALTER TABLE `gen_base_class` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `gen_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_config` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `config_key` varchar(200) DEFAULT NULL,
  `config_value` varchar(2000) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='配置信息';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `gen_config` WRITE;
/*!40000 ALTER TABLE `gen_config` DISABLE KEYS */;
INSERT INTO `gen_config` (`id`, `config_key`, `config_value`) VALUES (1,'gen_config','{\"author\":\"ice_jz\",\"backendPath\":\"D:/framework/icejz/icejz-boot/icejz-boot-new\",\"email\":\"960681673@qq.com\",\"frontendPath\":\"D:/framework/icejz/icejz-admin\",\"moduleName\":\"test\",\"packageName\":\"net.icejz\",\"tablePrefix\":\"\",\"version\":\"5.0.0\"}');
/*!40000 ALTER TABLE `gen_config` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `gen_datasource`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_datasource` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `db_type` varchar(200) DEFAULT NULL COMMENT '数据库类型',
  `conn_name` varchar(200) NOT NULL COMMENT '连接名',
  `conn_url` varchar(500) DEFAULT NULL COMMENT 'URL',
  `username` varchar(200) DEFAULT NULL COMMENT '用户名',
  `password` varchar(200) DEFAULT NULL COMMENT '密码',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='数据源管理';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `gen_datasource` WRITE;
/*!40000 ALTER TABLE `gen_datasource` DISABLE KEYS */;
/*!40000 ALTER TABLE `gen_datasource` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `gen_field_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_field_type` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `column_type` varchar(200) DEFAULT NULL COMMENT '字段类型',
  `attr_type` varchar(200) DEFAULT NULL COMMENT '属性类型',
  `package_name` varchar(200) DEFAULT NULL COMMENT '属性包名',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_gen_columntype` (`column_type`)
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='字段类型管理';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `gen_field_type` WRITE;
/*!40000 ALTER TABLE `gen_field_type` DISABLE KEYS */;
INSERT INTO `gen_field_type` (`id`, `column_type`, `attr_type`, `package_name`, `create_time`) VALUES (1,'datetime','LocalDateTime','java.time.LocalDateTime','2026-10-28 05:12:37'),(2,'date','LocalDateTime','java.time.LocalDateTime','2026-10-28 05:12:37'),(3,'tinyint','Integer',NULL,'2026-10-28 05:12:37'),(4,'smallint','Integer',NULL,'2026-10-28 05:12:37'),(5,'mediumint','Integer',NULL,'2026-10-28 05:12:37'),(6,'int','Integer',NULL,'2026-10-28 05:12:37'),(7,'integer','Integer',NULL,'2026-10-28 05:12:37'),(8,'bigint','Long',NULL,'2026-10-28 05:12:37'),(9,'float','Float',NULL,'2026-10-28 05:12:37'),(10,'double','Double',NULL,'2026-10-28 05:12:37'),(11,'decimal','BigDecimal','java.math.BigDecimal','2026-10-28 05:12:37'),(12,'bit','Boolean',NULL,'2026-10-28 05:12:37'),(13,'char','String',NULL,'2026-10-28 05:12:37'),(14,'varchar','String',NULL,'2026-10-28 05:12:37'),(15,'tinytext','String',NULL,'2026-10-28 05:12:37'),(16,'text','String',NULL,'2026-10-28 05:12:37'),(17,'mediumtext','String',NULL,'2026-10-28 05:12:37'),(18,'longtext','String',NULL,'2026-10-28 05:12:37'),(19,'timestamp','LocalDateTime','java.time.LocalDateTime','2026-10-28 05:12:37'),(20,'NUMBER','Integer',NULL,'2026-10-28 05:12:37'),(21,'BINARY_INTEGER','Integer',NULL,'2026-10-28 05:12:37'),(22,'BINARY_FLOAT','Float',NULL,'2026-10-28 05:12:37'),(23,'BINARY_DOUBLE','Double',NULL,'2026-10-28 05:12:37'),(24,'VARCHAR2','String',NULL,'2026-10-28 05:12:37'),(25,'NVARCHAR','String',NULL,'2026-10-28 05:12:37'),(26,'NVARCHAR2','String',NULL,'2026-10-28 05:12:37'),(27,'CLOB','String',NULL,'2026-10-28 05:12:37'),(28,'int8','Long',NULL,'2026-10-28 05:12:37'),(29,'int4','Integer',NULL,'2026-10-28 05:12:37'),(30,'int2','Integer',NULL,'2026-10-28 05:12:37'),(31,'numeric','BigDecimal','java.math.BigDecimal','2026-10-28 05:12:37');
/*!40000 ALTER TABLE `gen_field_type` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `gen_project_modify`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_project_modify` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `project_name` varchar(100) DEFAULT NULL COMMENT '项目名',
  `project_code` varchar(100) DEFAULT NULL COMMENT '项目标识',
  `project_package` varchar(100) DEFAULT NULL COMMENT '项目包名',
  `project_path` varchar(200) DEFAULT NULL COMMENT '项目路径',
  `modify_project_name` varchar(100) DEFAULT NULL COMMENT '变更项目名',
  `modify_project_code` varchar(100) DEFAULT NULL COMMENT '变更标识',
  `modify_project_package` varchar(100) DEFAULT NULL COMMENT '变更包名',
  `exclusions` varchar(200) DEFAULT NULL COMMENT '排除文件',
  `modify_suffix` varchar(200) DEFAULT NULL COMMENT '变更文件',
  `modify_tmp_path` varchar(100) DEFAULT NULL COMMENT '变更临时路径',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='项目名变更';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `gen_project_modify` WRITE;
/*!40000 ALTER TABLE `gen_project_modify` DISABLE KEYS */;
INSERT INTO `gen_project_modify` (`id`, `project_name`, `project_code`, `project_package`, `project_path`, `modify_project_name`, `modify_project_code`, `modify_project_package`, `exclusions`, `modify_suffix`, `modify_tmp_path`, `create_time`) VALUES (1,'icejz-boot','icejz','net.icejz','D:/framework/icejz/icejz-boot','demo-boot','demo','com.demo','.git,.idea,target,logs','java,xml,yml,txt',NULL,'2026-10-28 05:12:37'),(2,'icejz-cloud','icejz','net.icejz','D:/framework/icejz/icejz-cloud','demo-cloud','demo','com.demo','.git,.idea,target,logs','java,xml,yml,txt',NULL,'2026-10-28 05:12:37');
/*!40000 ALTER TABLE `gen_project_modify` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `gen_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_table` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `table_name` varchar(200) DEFAULT NULL COMMENT '表名',
  `class_name` varchar(200) DEFAULT NULL COMMENT '类名',
  `table_comment` varchar(200) DEFAULT NULL COMMENT '说明',
  `author` varchar(200) DEFAULT NULL COMMENT '作者',
  `email` varchar(200) DEFAULT NULL COMMENT '邮箱',
  `package_name` varchar(200) DEFAULT NULL COMMENT '项目包名',
  `version` varchar(200) DEFAULT NULL COMMENT '项目版本号',
  `generator_type` tinyint DEFAULT NULL COMMENT '生成方式  0：zip压缩包   1：自定义目录',
  `backend_path` varchar(500) DEFAULT NULL COMMENT '后端生成路径',
  `frontend_path` varchar(500) DEFAULT NULL COMMENT '前端生成路径',
  `module_name` varchar(200) DEFAULT NULL COMMENT '模块名',
  `function_name` varchar(200) DEFAULT NULL COMMENT '功能名',
  `form_layout` tinyint DEFAULT NULL COMMENT '表单布局  1：一列   2：两列',
  `table_type` tinyint DEFAULT NULL COMMENT '表类型',
  `sub_table` varchar(4000) DEFAULT NULL COMMENT '子表数据',
  `table_operation` varchar(200) DEFAULT NULL COMMENT '生成功能',
  `auth_level` tinyint DEFAULT NULL COMMENT '权限级别  0:页面层级  1:按钮层级',
  `open_type` tinyint DEFAULT NULL COMMENT '新增编辑  0:弹窗  1:右侧栏',
  `request_url` varchar(200) DEFAULT NULL COMMENT '请求URL',
  `authority` varchar(200) DEFAULT NULL COMMENT '权限标识',
  `tree_id` varchar(200) DEFAULT NULL COMMENT '树形ID',
  `tree_pid` varchar(200) DEFAULT NULL COMMENT '树形父ID',
  `tree_label` varchar(200) DEFAULT NULL COMMENT '树展示列',
  `left_title` varchar(200) DEFAULT NULL COMMENT '左侧标题',
  `left_from` tinyint DEFAULT NULL COMMENT '数据来源',
  `left_table_name` varchar(200) DEFAULT NULL COMMENT '左侧树表名',
  `left_url` varchar(200) DEFAULT NULL COMMENT '接口地址',
  `left_relation_field` varchar(200) DEFAULT NULL COMMENT '关联字段',
  `datasource_id` bigint DEFAULT NULL COMMENT '数据源ID',
  `baseclass_id` bigint DEFAULT NULL COMMENT '基类ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_gen_tablename` (`table_name`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='代码生成表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `gen_table` WRITE;
/*!40000 ALTER TABLE `gen_table` DISABLE KEYS */;
INSERT INTO `gen_table` (`id`, `table_name`, `class_name`, `table_comment`, `author`, `email`, `package_name`, `version`, `generator_type`, `backend_path`, `frontend_path`, `module_name`, `function_name`, `form_layout`, `table_type`, `sub_table`, `table_operation`, `auth_level`, `open_type`, `request_url`, `authority`, `tree_id`, `tree_pid`, `tree_label`, `left_title`, `left_from`, `left_table_name`, `left_url`, `left_relation_field`, `datasource_id`, `baseclass_id`, `create_time`) VALUES (20,'gen_test_member','GenTestMember','单表测试','ice_jz','960681673@qq.com','net.icejz','',1,'D:/framework/icejz/icejz-boot/icejz-boot-new','D:/framework/icejz/icejz-admin','test','member',1,0,NULL,'[\"query\",\"insert\",\"update\",\"delete\",\"export\",\"import\"]',0,0,'/test/member','test:member',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,'2026-10-28 05:12:37'),(21,'gen_test_tree','GenTestTree','树表测试','ice_jz','960681673@qq.com','net.icejz','',1,'D:/framework/icejz/icejz-boot/icejz-boot-new','D:/framework/icejz/icejz-admin','test','tree',1,1,NULL,'[\"query\",\"insert\",\"update\",\"delete\",\"export\"]',0,0,'/test/tree','test:tree','id','parent_id','tree_name',NULL,NULL,NULL,NULL,NULL,0,NULL,'2026-10-28 05:12:37'),(22,'gen_test_goods','GenTestGoods','商品管理','ice_jz','960681673@qq.com','net.icejz','',1,'D:/framework/icejz/icejz-boot/icejz-boot-new','D:/framework/icejz/icejz-admin','test','goods',1,2,'[]','[\"query\",\"insert\",\"update\",\"delete\"]',0,0,'/test/goods','test:goods',NULL,NULL,NULL,'分类列表',0,'gen_test_goods_category','/test/category/list','category_id',0,NULL,'2026-10-28 05:12:37'),(23,'gen_test_goods_category','GenTestGoodsCategory','商品分类','ice_jz','960681673@qq.com','net.icejz','',1,'D:/framework/icejz/icejz-boot/icejz-boot-new','D:/framework/icejz/icejz-admin','test','category',1,1,'[]','[\"query\",\"insert\",\"update\",\"delete\"]',0,0,'/test/category','test:category','id','pid','name',NULL,NULL,NULL,NULL,NULL,0,NULL,'2026-10-28 05:12:37'),(24,'gen_test_product_info','GenTestProductInfo','产品信息','ice_jz','960681673@qq.com','net.icejz','',0,'D:/framework/icejz/icejz-boot/icejz-boot-new','D:/framework/icejz/icejz-admin','test','info',1,0,NULL,'[\"query\",\"insert\",\"update\",\"delete\",\"export\"]',0,0,'/test/info','test:info',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,'2026-10-28 05:12:37'),(25,'gen_test_product_param','GenTestProductParam','产品参数','ice_jz','960681673@qq.com','net.icejz','',0,'D:/framework/icejz/icejz-boot/icejz-boot-new','D:/framework/icejz/icejz-admin','test','param',1,0,NULL,'[\"query\",\"insert\",\"update\",\"delete\",\"export\"]',0,0,'/test/param','test:param',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,'2026-10-28 05:12:37'),(26,'gen_test_product','GenTestProduct','产品测试','ice_jz','960681673@qq.com','net.icejz','',1,'D:/framework/icejz/icejz-boot/icejz-boot-new','D:/framework/icejz/icejz-admin','test','product',1,0,'[{\"tableName\":\"gen_test_product_info\",\"foreignKey\":\"product_id\",\"tableTitle\":\"产品信息\",\"mainRelation\":1,\"sort\":0},{\"tableName\":\"gen_test_product_param\",\"foreignKey\":\"product_id\",\"tableTitle\":\"产品参数\",\"mainRelation\":2,\"sort\":1}]','[\"query\",\"insert\",\"update\",\"delete\"]',0,1,'/test/product','test:product',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,'2026-10-28 05:12:37');
/*!40000 ALTER TABLE `gen_table` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `gen_table_field`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_table_field` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `table_id` bigint DEFAULT NULL COMMENT '表ID',
  `field_name` varchar(200) DEFAULT NULL COMMENT '字段名称',
  `field_type` varchar(200) DEFAULT NULL COMMENT '字段类型',
  `field_comment` varchar(200) DEFAULT NULL COMMENT '字段说明',
  `attr_name` varchar(200) DEFAULT NULL COMMENT '属性名',
  `attr_type` varchar(200) DEFAULT NULL COMMENT '属性类型',
  `package_name` varchar(200) DEFAULT NULL COMMENT '属性包名',
  `sort` int DEFAULT NULL COMMENT '排序',
  `auto_fill` varchar(20) DEFAULT NULL COMMENT '自动填充  DEFAULT、INSERT、UPDATE、INSERT_UPDATE',
  `primary_pk` tinyint DEFAULT NULL COMMENT '主键 0：否  1：是',
  `base_field` tinyint DEFAULT NULL COMMENT '基类字段 0：否  1：是',
  `form_item` tinyint DEFAULT NULL COMMENT '表单项 0：否  1：是',
  `form_required` tinyint DEFAULT NULL COMMENT '表单必填 0：否  1：是',
  `form_type` varchar(200) DEFAULT NULL COMMENT '表单类型',
  `form_dict` varchar(200) DEFAULT NULL COMMENT '表单字典类型',
  `form_validator` varchar(200) DEFAULT NULL COMMENT '表单效验',
  `grid_item` tinyint DEFAULT NULL COMMENT '列表项 0：否  1：是',
  `grid_sort` tinyint DEFAULT NULL COMMENT '列表排序 0：否  1：是',
  `query_item` tinyint DEFAULT NULL COMMENT '查询项 0：否  1：是',
  `query_type` varchar(200) DEFAULT NULL COMMENT '查询方式',
  `query_form_type` varchar(200) DEFAULT NULL COMMENT '查询表单类型',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=283 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='代码生成表字段';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `gen_table_field` WRITE;
/*!40000 ALTER TABLE `gen_table_field` DISABLE KEYS */;
INSERT INTO `gen_table_field` (`id`, `table_id`, `field_name`, `field_type`, `field_comment`, `attr_name`, `attr_type`, `package_name`, `sort`, `auto_fill`, `primary_pk`, `base_field`, `form_item`, `form_required`, `form_type`, `form_dict`, `form_validator`, `grid_item`, `grid_sort`, `query_item`, `query_type`, `query_form_type`, `create_time`) VALUES (220,20,'id','bigint','ID','id','Long',NULL,0,'DEFAULT',1,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(221,20,'name','varchar','姓名','name','String',NULL,1,'DEFAULT',0,0,1,1,'input',NULL,NULL,1,0,0,'=','input','2026-10-28 05:12:37'),(222,20,'gender','tinyint','性别','gender','Integer',NULL,2,'DEFAULT',0,0,1,1,'radio','user_gender',NULL,1,0,1,'=','select','2026-10-28 05:12:37'),(223,20,'age','int','年龄','age','Integer',NULL,3,'DEFAULT',0,0,1,1,'number',NULL,NULL,1,0,0,'=','input','2026-10-28 05:12:37'),(224,20,'tenant_id','bigint','租户ID','tenantId','Long',NULL,4,'DEFAULT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(225,20,'version','int','版本号','version','Integer',NULL,5,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(226,20,'deleted','tinyint','删除标识','deleted','Integer',NULL,6,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(227,20,'create_time','datetime','创建时间','createTime','LocalDateTime','java.time.LocalDateTime',7,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(228,21,'id','bigint','ID','id','Long',NULL,0,'DEFAULT',1,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(229,21,'tree_name','varchar','名称','treeName','String',NULL,1,'DEFAULT',0,0,1,1,'input',NULL,NULL,1,0,1,'=','input','2026-10-28 05:12:37'),(230,21,'parent_id','bigint','上级ID','parentId','Long',NULL,2,'DEFAULT',0,0,1,0,'treeselect',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(231,21,'tenant_id','bigint','租户ID','tenantId','Long',NULL,3,'DEFAULT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(232,21,'create_time','datetime','创建时间','createTime','LocalDateTime','java.time.LocalDateTime',4,'INSERT',0,0,0,0,'input',NULL,NULL,1,0,1,'=','date','2026-10-28 05:12:37'),(233,22,'id','bigint','ID','id','Long',NULL,0,'DEFAULT',1,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(234,22,'name','varchar','名称','name','String',NULL,1,'DEFAULT',0,0,1,1,'input',NULL,NULL,1,0,1,'like','input','2026-10-28 05:12:37'),(235,22,'intro','varchar','介绍','intro','String',NULL,2,'DEFAULT',0,0,1,1,'input',NULL,NULL,1,0,0,'=','input','2026-10-28 05:12:37'),(236,22,'category_id','bigint','分类ID','categoryId','Long',NULL,3,'DEFAULT',0,0,1,1,'input',NULL,NULL,1,0,0,'=','input','2026-10-28 05:12:37'),(237,22,'tenant_id','bigint','租户ID','tenantId','Long',NULL,4,'DEFAULT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(238,22,'deleted','tinyint','删除标识','deleted','Integer',NULL,5,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(239,22,'creator','bigint','创建者','creator','Long',NULL,6,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(240,22,'create_time','datetime','创建时间','createTime','LocalDateTime','java.time.LocalDateTime',7,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(241,22,'updater','bigint','更新者','updater','Long',NULL,8,'INSERT_UPDATE',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(242,22,'update_time','datetime','更新时间','updateTime','LocalDateTime','java.time.LocalDateTime',9,'INSERT_UPDATE',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(243,23,'id','bigint','ID','id','Long',NULL,0,'DEFAULT',1,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(244,23,'name','varchar','名称','name','String',NULL,2,'DEFAULT',0,0,1,1,'input',NULL,NULL,1,0,1,'like','input','2026-10-28 05:12:37'),(245,23,'pid','bigint','上级ID','pid','Long',NULL,1,'DEFAULT',0,0,1,0,'treeselect',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(246,23,'tenant_id','bigint','租户ID','tenantId','Long',NULL,3,'DEFAULT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(247,23,'deleted','tinyint','删除标识','deleted','Integer',NULL,4,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(248,23,'creator','bigint','创建者','creator','Long',NULL,5,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(249,23,'create_time','datetime','创建时间','createTime','LocalDateTime','java.time.LocalDateTime',6,'INSERT',0,0,0,0,'input',NULL,NULL,1,0,1,'=','datetime','2026-10-28 05:12:37'),(250,23,'updater','bigint','更新者','updater','Long',NULL,7,'INSERT_UPDATE',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(251,23,'update_time','datetime','更新时间','updateTime','LocalDateTime','java.time.LocalDateTime',8,'INSERT_UPDATE',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(252,24,'id','bigint','ID','id','Long',NULL,0,'DEFAULT',1,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(253,24,'images','varchar','图片','images','String',NULL,1,'DEFAULT',0,0,1,1,'image',NULL,NULL,1,0,0,'=','input','2026-10-28 05:12:37'),(254,24,'intro','varchar','介绍','intro','String',NULL,2,'DEFAULT',0,0,1,1,'editor',NULL,NULL,1,0,0,'=','input','2026-10-28 05:12:37'),(255,24,'product_id','bigint','产品ID','productId','Long',NULL,3,'DEFAULT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(256,24,'tenant_id','bigint','租户ID','tenantId','Long',NULL,4,'DEFAULT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(257,24,'version','int','版本号','version','Integer',NULL,5,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(258,24,'deleted','tinyint','删除标识','deleted','Integer',NULL,6,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(259,24,'creator','bigint','创建者','creator','Long',NULL,7,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(260,24,'create_time','datetime','创建时间','createTime','LocalDateTime','java.time.LocalDateTime',8,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(261,24,'updater','bigint','更新者','updater','Long',NULL,9,'INSERT_UPDATE',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(262,24,'update_time','datetime','更新时间','updateTime','LocalDateTime','java.time.LocalDateTime',10,'INSERT_UPDATE',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(263,25,'id','bigint','ID','id','Long',NULL,0,'DEFAULT',1,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(264,25,'param_name','varchar','参数名称','paramName','String',NULL,1,'DEFAULT',0,0,1,1,'input',NULL,NULL,1,0,0,'=','input','2026-10-28 05:12:37'),(265,25,'param_value','varchar','参数值','paramValue','String',NULL,2,'DEFAULT',0,0,1,1,'input',NULL,NULL,1,0,0,'=','input','2026-10-28 05:12:37'),(266,25,'product_id','bigint','产品ID','productId','Long',NULL,3,'DEFAULT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(267,25,'tenant_id','bigint','租户ID','tenantId','Long',NULL,4,'DEFAULT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(268,25,'version','int','版本号','version','Integer',NULL,5,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(269,25,'deleted','tinyint','删除标识','deleted','Integer',NULL,6,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(270,25,'creator','bigint','创建者','creator','Long',NULL,7,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(271,25,'create_time','datetime','创建时间','createTime','LocalDateTime','java.time.LocalDateTime',8,'INSERT',0,0,0,0,'input',NULL,NULL,1,0,0,'=','input','2026-10-28 05:12:37'),(272,25,'updater','bigint','更新者','updater','Long',NULL,9,'INSERT_UPDATE',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(273,25,'update_time','datetime','更新时间','updateTime','LocalDateTime','java.time.LocalDateTime',10,'INSERT_UPDATE',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(274,26,'id','bigint','ID','id','Long',NULL,0,'DEFAULT',1,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(275,26,'name','varchar','名称','name','String',NULL,1,'DEFAULT',0,0,1,1,'input',NULL,NULL,1,0,1,'like','input','2026-10-28 05:12:37'),(276,26,'tenant_id','bigint','租户ID','tenantId','Long',NULL,2,'DEFAULT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(277,26,'version','int','版本号','version','Integer',NULL,3,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(278,26,'deleted','tinyint','删除标识','deleted','Integer',NULL,4,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(279,26,'creator','bigint','创建者','creator','Long',NULL,5,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(280,26,'create_time','datetime','创建时间','createTime','LocalDateTime','java.time.LocalDateTime',6,'INSERT',0,0,0,0,'input',NULL,NULL,1,0,1,'=','datetime','2026-10-28 05:12:37'),(281,26,'updater','bigint','更新者','updater','Long',NULL,7,'INSERT_UPDATE',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(282,26,'update_time','datetime','更新时间','updateTime','LocalDateTime','java.time.LocalDateTime',8,'INSERT_UPDATE',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37');
/*!40000 ALTER TABLE `gen_table_field` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `gen_test_goods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_test_goods` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `name` varchar(100) DEFAULT NULL COMMENT '名称',
  `intro` varchar(4000) DEFAULT NULL COMMENT '介绍',
  `category_id` bigint DEFAULT NULL COMMENT '分类ID',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品管理';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `gen_test_goods` WRITE;
/*!40000 ALTER TABLE `gen_test_goods` DISABLE KEYS */;
/*!40000 ALTER TABLE `gen_test_goods` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `gen_test_goods_category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_test_goods_category` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `name` varchar(100) DEFAULT NULL COMMENT '名称',
  `pid` bigint DEFAULT NULL COMMENT '上级ID',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='商品分类';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `gen_test_goods_category` WRITE;
/*!40000 ALTER TABLE `gen_test_goods_category` DISABLE KEYS */;
/*!40000 ALTER TABLE `gen_test_goods_category` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `gen_test_member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_test_member` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `name` varchar(50) DEFAULT NULL COMMENT '姓名',
  `gender` tinyint DEFAULT NULL COMMENT '性别',
  `age` int DEFAULT NULL COMMENT '年龄',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='单表测试';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `gen_test_member` WRITE;
/*!40000 ALTER TABLE `gen_test_member` DISABLE KEYS */;
/*!40000 ALTER TABLE `gen_test_member` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `gen_test_product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_test_product` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `name` varchar(100) DEFAULT NULL COMMENT '名称',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='产品测试';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `gen_test_product` WRITE;
/*!40000 ALTER TABLE `gen_test_product` DISABLE KEYS */;
/*!40000 ALTER TABLE `gen_test_product` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `gen_test_product_info`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_test_product_info` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `images` varchar(2000) DEFAULT NULL COMMENT '图片',
  `intro` varchar(4000) DEFAULT NULL COMMENT '介绍',
  `product_id` bigint DEFAULT NULL COMMENT '产品ID',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='产品信息';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `gen_test_product_info` WRITE;
/*!40000 ALTER TABLE `gen_test_product_info` DISABLE KEYS */;
/*!40000 ALTER TABLE `gen_test_product_info` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `gen_test_product_param`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_test_product_param` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `param_name` varchar(200) DEFAULT NULL COMMENT '参数名称',
  `param_value` varchar(200) DEFAULT NULL COMMENT '参数值',
  `product_id` bigint DEFAULT NULL COMMENT '产品ID',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='产品参数';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `gen_test_product_param` WRITE;
/*!40000 ALTER TABLE `gen_test_product_param` DISABLE KEYS */;
/*!40000 ALTER TABLE `gen_test_product_param` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `gen_test_tree`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gen_test_tree` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `parent_id` bigint DEFAULT NULL COMMENT '上级ID',
  `tree_name` varchar(100) DEFAULT NULL COMMENT '名称',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='树表测试';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `gen_test_tree` WRITE;
/*!40000 ALTER TABLE `gen_test_tree` DISABLE KEYS */;
/*!40000 ALTER TABLE `gen_test_tree` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `iot_device`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iot_device` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'ID',
  `code` varchar(255) NOT NULL COMMENT '编码',
  `name` varchar(255) NOT NULL COMMENT '名称',
  `type` int NOT NULL COMMENT '设备类型，1.手持设备，2.柜体，3传感设备',
  `uid` varchar(255) NOT NULL COMMENT '唯一标识码',
  `secret` varchar(255) DEFAULT NULL COMMENT '设备密钥',
  `app_version` varchar(255) DEFAULT NULL COMMENT 'App版本号',
  `battery_percent` varchar(10) DEFAULT NULL COMMENT '电池电量百分比',
  `temperature` varchar(10) DEFAULT NULL COMMENT '温度',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态，0禁用，1启用',
  `running_status` int NOT NULL DEFAULT '0' COMMENT '运行状态，0.离线状态 1.在线状态 2.正常待机 3.用户使用中 4.OTA升级中',
  `protocol_type` varchar(20) NOT NULL DEFAULT 'MQTT' COMMENT '协议类型',
  `up_time` datetime DEFAULT NULL COMMENT '上线时间',
  `down_time` datetime DEFAULT NULL COMMENT '下线时间',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识  0：正常   1：已删除',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='设备表';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `iot_device` WRITE;
/*!40000 ALTER TABLE `iot_device` DISABLE KEYS */;
INSERT INTO `iot_device` (`id`, `code`, `name`, `type`, `uid`, `secret`, `app_version`, `battery_percent`, `temperature`, `status`, `running_status`, `protocol_type`, `up_time`, `down_time`, `tenant_id`, `creator`, `create_time`, `updater`, `update_time`, `version`, `deleted`) VALUES
(1, 'test-tcp', 'testTCP', 1, 'test12345678', '', NULL, NULL, NULL, 1, 1, 'TCP', '2026-10-28 05:13:35', NULL, NULL, 10000, '2026-10-28 05:13:35', 10000, '2026-10-28 05:13:35', 0, 0);

/*!40000 ALTER TABLE `iot_device` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `iot_device_event_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iot_device_event_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `device_id` bigint NOT NULL COMMENT '设备id',
  `event_type` tinyint NOT NULL COMMENT '事件类型',
  `event_uid` varchar(50) DEFAULT NULL COMMENT '事件标识id',
  `event_payload` varchar(1000) DEFAULT NULL COMMENT '事件数据',
  `event_time` datetime DEFAULT NULL COMMENT '事件时间',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识  0：正常   1：已删除',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='设备事件日志';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `iot_device_event_log` WRITE;
/*!40000 ALTER TABLE `iot_device_event_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `iot_device_event_log` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `iot_device_service_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `iot_device_service_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `device_id` bigint NOT NULL COMMENT '设备id',
  `service_type` tinyint NOT NULL COMMENT '服务类型',
  `service_uid` varchar(50) DEFAULT NULL COMMENT '服务标识id',
  `service_payload` varchar(1000) DEFAULT NULL COMMENT '服务数据',
  `service_time` datetime DEFAULT NULL COMMENT '服务时间',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识  0：正常   1：已删除',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='设备服务日志';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `iot_device_service_log` WRITE;
/*!40000 ALTER TABLE `iot_device_service_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `iot_device_service_log` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `member_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `member_user` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `nick_name` varchar(100) NOT NULL COMMENT '昵称',
  `mobile` varchar(20) NOT NULL COMMENT '手机号',
  `avatar` varchar(200) DEFAULT NULL COMMENT '头像',
  `birthday` date DEFAULT NULL COMMENT '出生日期',
  `gender` tinyint DEFAULT NULL COMMENT '性别   0：男   1：女   2：未知',
  `openid` varchar(200) DEFAULT NULL COMMENT '第三方平台，唯一标识',
  `last_login_ip` varchar(100) DEFAULT NULL COMMENT '最后登录IP',
  `last_login_time` datetime DEFAULT NULL COMMENT '最后登录时间',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `remark` varchar(500) DEFAULT NULL COMMENT '备注',
  `status` tinyint DEFAULT NULL COMMENT '状态  0：禁用   1：启用',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识  0：正常   1：已删除',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='会员管理';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `member_user` WRITE;
/*!40000 ALTER TABLE `member_user` DISABLE KEYS */;
/*!40000 ALTER TABLE `member_user` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `schedule_job`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `schedule_job` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `job_name` varchar(200) DEFAULT NULL COMMENT '名称',
  `job_group` varchar(100) DEFAULT NULL COMMENT '分组',
  `bean_name` varchar(200) DEFAULT NULL COMMENT 'spring bean名称',
  `method` varchar(100) DEFAULT NULL COMMENT '执行方法',
  `params` varchar(2000) DEFAULT NULL COMMENT '参数',
  `cron_expression` varchar(100) DEFAULT NULL COMMENT 'cron表达式',
  `status` tinyint unsigned DEFAULT NULL COMMENT '状态  0：暂停  1：正常',
  `concurrent` tinyint unsigned DEFAULT NULL COMMENT '是否并发  0：禁止  1：允许',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识  0：正常   1：已删除',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='定时任务';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `schedule_job` WRITE;
/*!40000 ALTER TABLE `schedule_job` DISABLE KEYS */;
INSERT INTO `schedule_job` (`id`, `job_name`, `job_group`, `bean_name`, `method`, `params`, `cron_expression`, `status`, `concurrent`, `remark`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,'测试任务','system','testTask','run','123','0 * * * * ? *',0,0,'',14,0,10000,'2026-10-28 05:14:01',10000,'2026-10-28 05:14:01');
/*!40000 ALTER TABLE `schedule_job` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `schedule_job_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `schedule_job_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `job_id` bigint NOT NULL COMMENT '任务id',
  `job_name` varchar(200) DEFAULT NULL COMMENT '任务名称',
  `job_group` varchar(100) DEFAULT NULL COMMENT '任务组名',
  `bean_name` varchar(200) DEFAULT NULL COMMENT 'spring bean名称',
  `method` varchar(100) DEFAULT NULL COMMENT '执行方法',
  `params` varchar(2000) DEFAULT NULL COMMENT '参数',
  `status` tinyint unsigned NOT NULL COMMENT '任务状态    0：失败    1：成功',
  `error` varchar(2000) DEFAULT NULL COMMENT '异常信息',
  `times` bigint NOT NULL COMMENT '耗时(单位：毫秒)',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_job_id` (`job_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='定时任务日志';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `schedule_job_log` WRITE;
/*!40000 ALTER TABLE `schedule_job_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `schedule_job_log` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `sys_ai_chat_message`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_ai_chat_message` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `session_id` bigint DEFAULT NULL COMMENT '会话ID',
  `user_id` bigint DEFAULT NULL COMMENT '用户ID',
  `role` varchar(20) DEFAULT NULL COMMENT '角色 user/assistant',
  `content` text COMMENT '内容',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_session_id` (`session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='AI对话消息';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `sys_ai_chat_message` WRITE;
/*!40000 ALTER TABLE `sys_ai_chat_message` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_ai_chat_message` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `sys_ai_chat_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_ai_chat_session` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `user_id` bigint DEFAULT NULL COMMENT '用户ID',
  `title` varchar(200) DEFAULT NULL COMMENT '会话标题',
  `last_msg_time` datetime DEFAULT NULL COMMENT '最后消息时间',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_last` (`user_id`,`last_msg_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='AI对话会话';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `sys_ai_chat_session` WRITE;
/*!40000 ALTER TABLE `sys_ai_chat_session` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_ai_chat_session` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `sys_ai_model`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_ai_model` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `name` varchar(100) DEFAULT NULL COMMENT '显示名称',
  `provider` varchar(50) DEFAULT NULL COMMENT '厂商 openai/deepseek/ollama/qwen/custom',
  `api_type` tinyint DEFAULT NULL COMMENT '接入类型 0本地 1线上',
  `base_url` varchar(255) DEFAULT NULL COMMENT '接口地址',
  `api_key` varchar(255) DEFAULT NULL COMMENT 'API Key',
  `model_name` varchar(100) DEFAULT NULL COMMENT '模型名',
  `temperature` decimal(4,2) DEFAULT NULL COMMENT '温度',
  `max_tokens` int DEFAULT NULL COMMENT '最大token',
  `system_prompt` text COMMENT '系统提示词',
  `is_default` tinyint DEFAULT NULL COMMENT '是否默认 0否 1是',
  `sort` int DEFAULT NULL COMMENT '排序',
  `status` tinyint DEFAULT NULL COMMENT '状态 0禁用 1启用',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='AI模型配置';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `sys_ai_model` WRITE;
/*!40000 ALTER TABLE `sys_ai_model` DISABLE KEYS */;
INSERT INTO `sys_ai_model` (`id`, `name`, `provider`, `api_type`, `base_url`, `api_key`, `model_name`, `temperature`, `max_tokens`, `system_prompt`, `is_default`, `sort`, `status`, `remark`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES
(1, '本地 Ollama', 'ollama', 0, 'http://127.0.0.1:11434/v1', '', 'qwen2.5', 0.70, 2048, '你是 ICEJZ 平台助手小冰，语气友好、简洁，擅长帮助用户理解平台功能、系统配置与研发协作问题。', 0, 0, 0, '默认禁用，启动 Ollama 后改为启用', 0, 0, 10000, '2026-10-29 16:59:38', 10000, '2026-10-30 05:18:56'),
(2, '小冰 · DeepSeek', 'deepseek', 1, 'https://api.deepseek.com/v1', '', 'deepseek-chat', 0.70, 4096, '你是 ICEJZ 平台助手小冰，语气友好、简洁，擅长帮助用户理解平台功能、系统配置与研发协作问题。', 1, 0, 1, 'DeepSeek 官方 OpenAI 兼容接口，请填写 API Key 后使用', 1, 0, 10000, '2026-10-30 05:19:03', 10000, '2026-10-30 05:24:31');

/*!40000 ALTER TABLE `sys_ai_model` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `sys_attachment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_attachment` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `name` varchar(255) NOT NULL COMMENT '附件名称',
  `url` varchar(255) NOT NULL COMMENT '附件地址',
  `size_` bigint DEFAULT NULL COMMENT '附件大小',
  `platform` varchar(50) DEFAULT NULL COMMENT '存储平台',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识  0：正常   1：已删除',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='附件管理';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `sys_attachment` WRITE;
/*!40000 ALTER TABLE `sys_attachment` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_attachment` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `sys_dict_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dict_data` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `dict_type_id` bigint NOT NULL COMMENT '字典类型ID',
  `dict_label` varchar(255) NOT NULL COMMENT '字典标签',
  `dict_value` varchar(255) DEFAULT NULL COMMENT '字典值',
  `label_class` varchar(100) DEFAULT NULL COMMENT '标签样式',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `sort` int DEFAULT NULL COMMENT '排序',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识  0：正常   1：已删除',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=73 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='字典数据';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `sys_dict_data` WRITE;
/*!40000 ALTER TABLE `sys_dict_data` DISABLE KEYS */;
INSERT INTO `sys_dict_data` (`id`, `dict_type_id`, `dict_label`, `dict_value`, `label_class`, `remark`, `sort`, `tenant_id`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,1,'停用','0','danger','',1,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(2,1,'正常','1','primary','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(3,2,'男','0','primary','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(4,2,'女','1','success','',1,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(5,2,'未知','2','warning','',2,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(6,3,'正常','1','primary','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(7,3,'封禁','0','danger','',1,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(8,4,'全部数据','0','','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(9,4,'本机构及子机构数据','1','','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(10,4,'本机构数据','2','','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(11,4,'本人数据','3','','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(12,4,'自定义数据','4','','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(13,5,'禁用','0','danger','',1,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(14,5,'启用','1','primary','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(15,6,'失败','0','danger','',1,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(16,6,'成功','1','primary','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(17,7,'登录成功','0','primary','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(18,7,'退出成功','1','warning','',1,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(19,7,'验证码错误','2','danger','',2,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(20,7,'账号密码错误','3','danger','',3,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(21,8,'否','0','primary','',1,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(22,8,'是','1','danger','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(23,9,'是','1','danger','',1,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(24,9,'否','0','primary','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(25,10,'其它','0','info','',10,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(26,10,'查询','1','primary','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(27,10,'新增','2','success','',1,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(28,10,'修改','3','warning','',2,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(29,10,'删除','4','danger','',3,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(30,10,'导出','5','info','',4,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(31,10,'导入','6','info','',5,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(32,11,'阿里云','0','','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(33,11,'腾讯云','1','','',1,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(34,11,'七牛云','2','','',2,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(35,11,'华为云','3','','',3,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(36,12,'本地','-1','','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(37,12,'阿里云','0','','',1,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(38,13,'手持设备','1','primary','',0,10000,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(39,13,'柜体','2','primary','',1,10000,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(40,13,'传感设备','3','primary','',2,10000,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(41,14,'离线状态','0','danger',NULL,0,10000,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(42,14,'在线状态','1','success',NULL,1,10000,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(43,15,'远程锁定','LOCK',NULL,NULL,0,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(44,15,'远程解锁','UNLOCK',NULL,NULL,1,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(45,15,'登录','SIGN_ON',NULL,NULL,2,NULL,0,1,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(46,15,'登出','SIGN_OFF',NULL,NULL,3,NULL,0,1,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(47,15,'OTA升级','OTA_UPGRADE',NULL,NULL,4,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(48,16,'MQTT','MQTT',NULL,NULL,0,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(49,16,'TCP','TCP',NULL,NULL,1,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(50,16,'UDP','UDP',NULL,NULL,2,NULL,0,1,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(51,16,'BLE','BLE',NULL,NULL,3,NULL,0,1,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(52,16,'CoAP','CoAP',NULL,NULL,4,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(53,16,'LwM2M','LwM2M',NULL,NULL,4,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(54,16,'Modbus','Modbus',NULL,NULL,4,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(55,17,'运行状态','RUNNING_STATUS',NULL,NULL,0,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(56,17,'APP版本','APP_VERSION',NULL,NULL,1,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(57,17,'电池电量百分比','BATTERY_PERCENT',NULL,NULL,2,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(58,17,'温度','TEMPERATURE',NULL,NULL,3,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(59,18,'下线','OFFLINE','danger',NULL,1,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(60,18,'上线','ONLINE','primary',NULL,2,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(61,18,'登录','SIGN_ON','primary',NULL,3,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(62,18,'退出登录','SIGN_OFF','danger',NULL,4,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(63,18,'OTA升级','OTA_UPGRADE','primary',NULL,5,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(64,18,'设备远程锁定','LOCK','primary',NULL,6,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(65,18,'设备远程解锁','UNLOCK','primary',NULL,7,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(66,18,'APP版本信息','APP_VERSION_REPORT','primary',NULL,8,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(67,18,'电池电量','BATTERY_PERCENT_REPORT','primary',NULL,9,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(68,18,'温度','TEMPERATURE_REPORT','primary',NULL,0,NULL,10,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(69,19,'默认','default','','',0,10000,0,0,10000,'2026-10-28 05:14:01',10000,'2026-10-28 05:14:01'),(70,19,'系统','system','','',1,10000,0,0,10000,'2026-10-28 05:14:01',10000,'2026-10-28 05:14:01'),(71,20,'暂停','0','danger','',0,10000,0,0,10000,'2026-10-28 05:14:01',10000,'2026-10-28 05:14:01'),(72,20,'正常','1','primary','',1,10000,0,0,10000,'2026-10-28 05:14:01',10000,'2026-10-28 05:14:01');
/*!40000 ALTER TABLE `sys_dict_data` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `sys_dict_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_dict_type` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `dict_type` varchar(100) NOT NULL COMMENT '字典类型',
  `dict_name` varchar(255) NOT NULL COMMENT '字典名称',
  `dict_source` tinyint DEFAULT '0' COMMENT '来源  0：字典数据  1：动态SQL',
  `dict_sql` varchar(500) DEFAULT NULL COMMENT '动态SQL',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `sort` int DEFAULT NULL COMMENT '排序',
  `pid` bigint DEFAULT NULL COMMENT '上级节点',
  `has_child` tinyint DEFAULT '0' COMMENT '是否有子节点',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识  0：正常   1：已删除',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='字典类型';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `sys_dict_type` WRITE;
/*!40000 ALTER TABLE `sys_dict_type` DISABLE KEYS */;
INSERT INTO `sys_dict_type` (`id`, `dict_type`, `dict_name`, `dict_source`, `dict_sql`, `remark`, `sort`, `pid`, `has_child`, `tenant_id`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,'post_status','状态',0,NULL,'岗位管理',0,NULL,0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(2,'user_gender','性别',0,NULL,'用户管理',0,NULL,0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(3,'user_status','状态',0,NULL,'用户管理',0,NULL,0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(4,'role_data_scope','数据范围',0,NULL,'角色管理',0,NULL,0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(5,'enable_disable','状态',0,NULL,'功能状态：启用 | 禁用 ',0,NULL,0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(6,'success_fail','状态',0,NULL,'操作状态：成功 | 失败',0,NULL,0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(7,'login_operation','操作信息',0,NULL,'登录管理',0,NULL,0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(8,'params_type','系统参数',0,NULL,'参数管理',0,NULL,0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(9,'user_super_admin','用户是否是超管',0,NULL,'用户是否是超管',0,NULL,0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(10,'log_operate_type','操作类型',0,NULL,'操作日志',0,NULL,0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(11,'sms_platform','短信平台类型',0,NULL,'短信管理',0,NULL,0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(12,'mail_platform','邮件平台类型',0,NULL,'邮件管理',0,NULL,0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(13,'device_type','设备类型',0,NULL,'设备类型',0,NULL,0,10000,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(14,'device_running_status','设备运行状态',0,NULL,'设备运行状态：离线|在线|待机|使用中|OTA升级中',0,NULL,0,10000,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(15,'device_command','设备指令',0,NULL,'设备服务具备的功能',0,NULL,0,10000,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(16,'device_protocol_type','设备协议类型',0,NULL,'设备协议类型',0,NULL,0,10000,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(17,'device_property','设备属性',0,NULL,'设备通用属性：运行状态|APP版本|电池电量百分比|温度',0,NULL,0,10000,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(18,'device_event_type','事件类型',0,NULL,'事件日志类型',0,NULL,0,10000,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(19,'schedule_group','任务组名',0,NULL,'定时任务',0,NULL,0,10000,0,0,10000,'2026-10-28 05:14:01',10000,'2026-10-28 05:14:01'),(20,'schedule_status','状态',0,NULL,'定时任务',0,NULL,0,10000,0,0,10000,'2026-10-28 05:14:01',10000,'2026-10-28 05:14:01');
/*!40000 ALTER TABLE `sys_dict_type` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `sys_log_login`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_log_login` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `username` varchar(50) DEFAULT NULL COMMENT '用户名',
  `ip` varchar(32) DEFAULT NULL COMMENT '登录IP',
  `address` varchar(32) DEFAULT NULL COMMENT '登录地点',
  `user_agent` varchar(500) DEFAULT NULL COMMENT 'User Agent',
  `status` tinyint DEFAULT NULL COMMENT '登录状态  0：失败   1：成功',
  `operation` tinyint unsigned DEFAULT NULL COMMENT '操作信息   0：登录成功   1：退出成功  2：验证码错误  3：账号密码错误',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='登录日志';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `sys_log_login` WRITE;
/*!40000 ALTER TABLE `sys_log_login` DISABLE KEYS */;
INSERT INTO `sys_log_login` (`id`, `username`, `ip`, `address`, `user_agent`, `status`, `operation`, `tenant_id`, `create_time`) VALUES (1,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,2,NULL,'2026-10-29 04:23:57'),(2,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-10-29 04:24:12'),(3,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,1,NULL,'2026-10-29 04:35:41'),(4,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-10-29 04:36:16'),(5,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,1,NULL,'2026-10-29 04:37:14'),(6,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-10-29 05:14:56'),(7,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,1,NULL,'2026-10-29 05:32:18'),(8,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-10-29 05:37:54'),(9,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,1,NULL,'2026-10-29 15:15:03'),(10,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-10-29 15:15:12'),(11,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.22621.6133',0,2,NULL,'2026-10-29 15:17:27'),(12,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-10-29 18:18:12'),(13,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,1,NULL,'2026-10-29 23:13:04'),(14,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-10-29 23:56:20'),(15,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,1,NULL,'2026-10-30 04:45:42'),(16,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-10-30 04:49:56'),(17,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,1,NULL,'2026-10-30 04:50:20'),(18,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-10-30 04:52:23'),(19,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,1,NULL,'2026-10-30 06:06:23'),(20,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,3,NULL,'2026-10-30 06:08:16'),(21,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-10-30 06:08:37'),(22,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,1,NULL,'2026-10-30 06:12:55');
/*!40000 ALTER TABLE `sys_log_login` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `sys_log_operate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_log_operate` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `module` varchar(100) DEFAULT NULL COMMENT '模块名',
  `name` varchar(100) DEFAULT NULL COMMENT '操作名',
  `req_uri` varchar(200) DEFAULT NULL COMMENT '请求URI',
  `req_method` varchar(20) DEFAULT NULL COMMENT '请求方法',
  `req_params` text COMMENT '请求参数',
  `ip` varchar(32) DEFAULT NULL COMMENT '操作IP',
  `address` varchar(32) DEFAULT NULL COMMENT '登录地点',
  `user_agent` varchar(500) DEFAULT NULL COMMENT 'User Agent',
  `operate_type` tinyint DEFAULT NULL COMMENT '操作类型',
  `duration` int NOT NULL COMMENT '执行时长',
  `status` tinyint DEFAULT NULL COMMENT '操作状态  0：失败   1：成功',
  `user_id` bigint DEFAULT NULL COMMENT '用户ID',
  `real_name` varchar(50) DEFAULT NULL COMMENT '操作人',
  `result_msg` varchar(500) DEFAULT NULL COMMENT '返回消息',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='操作日志';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `sys_log_operate` WRITE;
/*!40000 ALTER TABLE `sys_log_operate` DISABLE KEYS */;
INSERT INTO `sys_log_operate` (`id`, `module`, `name`, `req_uri`, `req_method`, `req_params`, `ip`, `address`, `user_agent`, `operate_type`, `duration`, `status`, `user_id`, `real_name`, `result_msg`, `tenant_id`, `create_time`) VALUES (1,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":null,\"email\":\"960681673@qq.com\",\"gender\":0,\"mobile\":\"18816881688\",\"realName\":\"admin\"}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,88,1,10000,'admin',NULL,10000,'2026-10-29 04:37:06'),(2,'文件上传','上传','/sys/file/upload','POST','{\"file\":\"[ignore]\"}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',2,710,1,10000,'admin',NULL,10000,'2026-10-29 05:52:01'),(3,'用户管理','修改登录用户签名','/sys/user/signature','PUT','{\"signature\":{\"signature\":\"http://localhost:8080/upload/20261029/admin_21112.png\"}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,100,1,10000,'admin',NULL,10000,'2026-10-29 05:52:01'),(4,'文件上传','上传','/sys/file/upload','POST','{\"file\":\"[ignore]\"}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',2,186,1,10000,'admin',NULL,10000,'2026-10-29 16:47:57'),(5,'用户管理','修改登录用户签名','/sys/user/signature','PUT','{\"signature\":{\"signature\":\"http://localhost:8080/upload/20261029/admin_60474.png\"}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,38,1,10000,'admin',NULL,10000,'2026-10-29 16:47:57'),(6,'AI助手','对话','/sys/ai/chat','POST','{\"vo\":{\"history\":[],\"message\":\"你好\",\"modelId\":null}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,44,0,10000,'admin',NULL,10000,'2026-10-30 00:11:52'),(7,'AI助手','对话','/sys/ai/chat','POST','{\"vo\":{\"history\":[],\"message\":\"你好\",\"modelId\":null}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,26,0,10000,'admin',NULL,10000,'2026-10-30 00:14:52'),(8,'工作台记事','保存记事','/sys/workbench/note','POST','{\"vo\":{\"content\":\"别忘了换配置信息\",\"createTime\":null,\"id\":null,\"noteDate\":\"2026-10-31\",\"noteType\":\"nudge\"}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',2,103,1,10000,'admin',NULL,10000,'2026-10-30 05:17:53'),(9,'AI助手','测试模型','/sys/ai/model/test/2','POST','{\"id\":2}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,461,0,10000,'admin',NULL,10000,'2026-10-30 05:21:03'),(10,'AI助手','测试模型','/sys/ai/model/test/2','POST','{\"id\":2}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,858,0,10000,'admin',NULL,10000,'2026-10-30 05:21:43'),(11,'AI助手','测试模型','/sys/ai/model/test/2','POST','{\"id\":2}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,576,0,10000,'admin',NULL,10000,'2026-10-30 05:24:53'),(12,'AI助手','测试模型','/sys/ai/model/test/2','POST','{\"id\":2}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,569,1,10000,'admin',NULL,10000,'2026-10-30 05:26:53'),(13,'AI助手','对话','/sys/ai/chat','POST','{\"vo\":{\"history\":[],\"message\":\"你好\",\"modelId\":null}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,867,1,10000,'admin',NULL,10000,'2026-10-30 05:27:13'),(14,'AI助手','对话','/sys/ai/chat','POST','{\"vo\":{\"history\":[{\"content\":\"你好\",\"role\":\"user\"},{\"content\":\"你好呀！我是 ICEJZ 平台助手小冰，很高兴见到你 😊\\n\\n有什么可以帮你的吗？比如平台功能、系统配置、研发协作相关的问题，都可以问我～\",\"role\":\"assistant\"}],\"message\":\"平台功能是什么\",\"modelId\":null}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,1622,1,10000,'admin',NULL,10000,'2026-10-30 05:28:43'),(15,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":null,\"email\":\"960681673@qq.com\",\"gender\":1,\"mobile\":\"13800138000\",\"realName\":\"admin\"}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,38,1,10000,'admin',NULL,10000,'2026-10-30 05:56:33');
/*!40000 ALTER TABLE `sys_log_operate` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `sys_mail_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_mail_config` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `platform` tinyint DEFAULT NULL COMMENT '平台类型  -1：本地   0：阿里云',
  `group_name` varchar(100) DEFAULT NULL COMMENT '分组名称，发送邮件时，可指定分组',
  `mail_host` varchar(100) DEFAULT NULL COMMENT 'SMTP服务器',
  `mail_port` int DEFAULT NULL COMMENT 'SMTP端口',
  `mail_from` varchar(100) DEFAULT NULL COMMENT '发件人邮箱',
  `mail_pass` varchar(100) DEFAULT NULL COMMENT '发件人密码',
  `region_id` varchar(100) DEFAULT NULL COMMENT 'regionId',
  `endpoint` varchar(100) DEFAULT NULL COMMENT '阿里云 endpoint',
  `access_key` varchar(100) DEFAULT NULL COMMENT 'AccessKey',
  `secret_key` varchar(100) DEFAULT NULL COMMENT 'SecretKey',
  `status` tinyint DEFAULT NULL COMMENT '状态  0：禁用   1：启用',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识  0：正常   1：已删除',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='邮件平台';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `sys_mail_config` WRITE;
/*!40000 ALTER TABLE `sys_mail_config` DISABLE KEYS */;
INSERT INTO `sys_mail_config` (`id`, `platform`, `group_name`, `mail_host`, `mail_port`, `mail_from`, `mail_pass`, `region_id`, `endpoint`, `access_key`, `secret_key`, `status`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES
(1, -1, 'test', NULL, NULL, 'baba_tv@163.com', 'TZNVURLYVBNJUNBB', '', '', '', '', 1, 1, 0, 10000, '2026-10-28 05:12:20', 10000, '2026-10-28 05:12:20');

/*!40000 ALTER TABLE `sys_mail_config` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `sys_mail_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_mail_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `platform_id` bigint DEFAULT NULL COMMENT '平台ID',
  `platform` tinyint DEFAULT NULL COMMENT '平台类型',
  `mail_from` varchar(100) DEFAULT NULL COMMENT '发件人邮箱',
  `mail_tos` varchar(1000) DEFAULT NULL COMMENT '接受人邮箱',
  `subject` varchar(200) DEFAULT NULL COMMENT '邮件主题',
  `content` text COMMENT '邮件内容',
  `status` tinyint DEFAULT NULL COMMENT '状态  0：失败   1：成功',
  `error` varchar(2000) DEFAULT NULL COMMENT '异常信息',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='邮件日志';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `sys_mail_log` WRITE;
/*!40000 ALTER TABLE `sys_mail_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_mail_log` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `sys_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_menu` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `pid` bigint DEFAULT NULL COMMENT '上级ID',
  `name` varchar(200) DEFAULT NULL COMMENT '菜单名称',
  `url` varchar(200) DEFAULT NULL COMMENT '菜单URL',
  `authority` varchar(500) DEFAULT NULL COMMENT '授权标识(多个用逗号分隔，如：sys:menu:list,sys:menu:save)',
  `type` tinyint DEFAULT NULL COMMENT '类型   0：菜单   1：按钮   2：接口',
  `open_style` tinyint DEFAULT NULL COMMENT '打开方式   0：内部   1：外部',
  `icon` varchar(50) DEFAULT NULL COMMENT '菜单图标',
  `sort` int DEFAULT NULL COMMENT '排序',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识  0：正常   1：已删除',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_menu_pid` (`pid`)
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='菜单管理';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `sys_menu` WRITE;
/*!40000 ALTER TABLE `sys_menu` DISABLE KEYS */;
INSERT INTO `sys_menu` (`id`, `pid`, `name`, `url`, `authority`, `type`, `open_style`, `icon`, `sort`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,NULL,'系统管理',NULL,NULL,0,0,'icon-setting',2,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(2,1,'菜单管理','sys/menu/index',NULL,0,0,'icon-menu',1,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(3,2,'查看','','sys:menu:list',1,0,'',0,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(4,2,'新增','','sys:menu:save',1,0,'',1,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(5,2,'修改','','sys:menu:update,sys:menu:info',1,0,'',2,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(6,2,'删除','','sys:menu:delete',1,0,'',3,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(7,1,'数据字典','sys/dict/type','',0,0,'icon-book',2,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(8,7,'查询','','sys:dict:page',1,0,'',0,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(9,7,'新增','','sys:dict:save',1,0,'',2,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(10,7,'修改','','sys:dict:update,sys:dict:info',1,0,'',1,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(11,7,'删除','','sys:dict:delete',1,0,'',3,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(12,NULL,'组织权限','','',0,0,'icon-apartment',1,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(13,12,'岗位管理','sys/post/index','',0,0,'icon-post',4,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(14,13,'查询','','sys:post:page',1,0,'',0,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(15,13,'新增','','sys:post:save',1,0,'',1,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(16,13,'修改','','sys:post:update,sys:post:info',1,0,'',2,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(17,13,'删除','','sys:post:delete',1,0,'',3,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(18,12,'机构管理','sys/org/index','',0,0,'icon-org',3,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(19,18,'查询','','sys:org:list',1,0,'',0,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(20,18,'新增','','sys:org:save',1,0,'',1,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(21,18,'修改','','sys:org:update,sys:org:info',1,0,'',2,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(22,18,'删除','','sys:org:delete',1,0,'',3,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(23,12,'角色管理','sys/role/index','',0,0,'icon-team',2,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(24,23,'查询','','sys:role:page',1,0,'',0,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(25,23,'新增','','sys:role:save,sys:role:menu,sys:org:list',1,0,'',1,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(26,23,'修改','','sys:role:update,sys:role:info,sys:role:menu,sys:org:list,sys:user:page',1,0,'',2,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(27,23,'删除','','sys:role:delete',1,0,'',3,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(28,12,'用户管理','sys/user/index','',0,0,'icon-user',1,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(29,28,'查询','','sys:user:page',1,0,'',0,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(30,28,'新增','','sys:user:save,sys:role:list',1,0,'',1,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(31,28,'修改','','sys:user:update,sys:user:info,sys:role:list',1,0,'',2,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(32,28,'删除','','sys:user:delete',1,0,'',3,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(33,NULL,'开发工具','','',0,0,'icon-codelibrary',4,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(34,NULL,'运维中心','','',0,0,'icon-monitor',3,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(35,34,'登录日志','sys/log/login','sys:log:login',0,0,'icon-login',1,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(36,28,'导入','','sys:user:import',1,0,'',5,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(37,28,'导出','','sys:user:export',1,0,'',6,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(38,1,'参数管理','sys/params/index','sys:params:all',0,0,'icon-control',3,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(39,33,'接口文档','{{apiUrl}}/doc.html',NULL,0,1,'icon-api',2,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(40,34,'操作日志','sys/log/operate','sys:operate:all',0,0,'icon-file-text',2,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(41,1,'系统配置','sys/config/index',NULL,0,0,'icon-sliders',4,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(42,41,'短信配置','','sys:sms:config',1,0,'',0,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(43,41,'邮件配置','','sys:mail:config',1,0,'',1,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(44,41,'第三方登录','','sys:third:config',1,0,'',2,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(45,NULL,'基础工具','','',0,0,'icon-wrench-fill',5,0,1,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(46,33,'短信发送','sys/tool/sms/index','sys:sms:log',0,0,'icon-message',3,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(47,33,'邮件发送','sys/tool/mail/index','sys:mail:log',0,0,'icon-mail',4,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(48,33,'附件管理','sys/attachment/index',NULL,0,0,'icon-folder-fill',5,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(49,48,'查看','','sys:attachment:page',1,0,'',0,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(50,48,'上传','','sys:attachment:save',1,0,'',1,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(51,48,'删除','','sys:attachment:delete',1,0,'',1,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(53,33,'代码生成器','{{apiUrl}}/maku-generator/index.html','',0,0,'icon-rocket',1,0,0,10000,'2026-10-28 05:12:36',10000,'2026-10-30 05:39:43'),(54,NULL,'物联网平台',NULL,NULL,0,0,'icon-deploymentunit',5,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-30 05:39:43'),(55,54,'设备列表','iot/device/index',NULL,0,0,'icon-laptop',1,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-30 05:39:43'),(56,55,'查看','','iot:device:page',1,0,'',0,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(57,55,'新增','','iot:device:save',1,0,'',1,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(58,55,'修改','','iot:device:update,iot:device:info',1,0,'',2,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(59,55,'删除','','iot:device:delete',1,0,'',3,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(60,55,'下发指令','','iot:device:send',1,0,'',4,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(61,55,'上报数据','','iot:device:report',1,0,'',5,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(62,55,'设备事件日志','','iot:device_event_log:page',1,0,'',5,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(63,55,'设备服务日志','','iot:device_service_log:page',1,0,'',5,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(64,34,'系统监控','','',0,0,'icon-dashboard',4,0,0,10000,'2026-10-28 05:13:54',10000,'2026-10-30 05:39:43'),(65,64,'服务监控','monitor/server/index','monitor:server:all',0,0,'icon-sever',1,0,0,10000,'2026-10-28 05:13:54',10000,'2026-10-30 05:39:43'),(66,64,'缓存监控','monitor/cache/index','monitor:cache:all',0,0,'icon-cloud-server',2,0,0,10000,'2026-10-28 05:13:54',10000,'2026-10-30 05:39:43'),(67,64,'在线用户','monitor/user/index','monitor:user:all',0,0,'icon-team',3,0,0,10000,'2026-10-28 05:13:54',10000,'2026-10-30 05:39:43'),(68,34,'定时任务','quartz/schedule/index',NULL,0,0,'icon-reloadtime',3,0,0,10000,'2026-10-28 05:14:01',10000,'2026-10-30 05:39:43'),(69,68,'查看','','schedule:page',1,0,'',0,0,0,10000,'2026-10-28 05:14:01',10000,'2026-10-28 05:14:01'),(70,68,'新增','','schedule:save',1,0,'',1,0,0,10000,'2026-10-28 05:14:01',10000,'2026-10-28 05:14:01'),(71,68,'修改','','schedule:update,schedule:info',1,0,'',2,0,0,10000,'2026-10-28 05:14:01',10000,'2026-10-28 05:14:01'),(72,68,'删除','','schedule:delete',1,0,'',3,0,0,10000,'2026-10-28 05:14:01',10000,'2026-10-28 05:14:01'),(73,68,'立即运行','','schedule:run',1,0,'',2,0,0,10000,'2026-10-28 05:14:01',10000,'2026-10-28 05:14:01'),(74,68,'日志','','schedule:log',1,0,'',4,0,0,10000,'2026-10-28 05:14:01',10000,'2026-10-28 05:14:01'),(75,1,'AI助手','sys/config/ai/index','sys:ai:config',0,0,'icon-robot',5,0,0,10000,'2026-10-29 16:59:32',10000,'2026-10-30 05:39:43');
/*!40000 ALTER TABLE `sys_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `sys_org`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_org` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `pid` bigint DEFAULT NULL COMMENT '上级ID',
  `name` varchar(50) DEFAULT NULL COMMENT '机构名称',
  `sort` int DEFAULT NULL COMMENT '排序',
  `leader_id` bigint DEFAULT NULL COMMENT '负责人ID',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识  0：正常   1：已删除',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_sys_org_pid` (`pid`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='机构管理';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `sys_org` WRITE;
/*!40000 ALTER TABLE `sys_org` DISABLE KEYS */;
INSERT INTO `sys_org` (`id`, `pid`, `name`, `sort`, `leader_id`, `tenant_id`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,NULL,'ICEJZ 总部',1,10000,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(2,1,'研发中心',1,10001,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(3,1,'运维中心',2,10005,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(4,1,'产品中心',3,10006,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(5,2,'平台研发组',1,10001,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(6,2,'物联网研发组',2,10001,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27');
/*!40000 ALTER TABLE `sys_org` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `sys_params`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_params` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `param_name` varchar(100) DEFAULT NULL COMMENT '参数名称',
  `param_type` tinyint NOT NULL COMMENT '系统参数   0：否   1：是',
  `param_key` varchar(100) DEFAULT NULL COMMENT '参数键',
  `param_value` varchar(2000) DEFAULT NULL COMMENT '参数值',
  `remark` varchar(200) DEFAULT NULL COMMENT '备注',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识  0：正常   1：已删除',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='参数管理';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `sys_params` WRITE;
/*!40000 ALTER TABLE `sys_params` DISABLE KEYS */;
INSERT INTO `sys_params` (`id`, `param_name`, `param_type`, `param_key`, `param_value`, `remark`, `tenant_id`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,'用户登录-验证码开关',1,'LOGIN_CAPTCHA','false','是否开启验证码（true：开启，false：关闭）',10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(2,'AI机器人名称',1,'AI_ROBOT_NAME','小冰','ICEJZ IP 助手名称',10000,0,0,10000,'2026-10-29 16:59:37',10000,'2026-10-29 16:59:37'),(3,'AI机器人欢迎语',1,'AI_ROBOT_WELCOME','你好，我是 ICEJZ 小冰，有什么可以帮你的？','助手欢迎语',10000,0,0,10000,'2026-10-29 16:59:37',10000,'2026-10-29 16:59:37'),(4,'AI机器人开关',1,'AI_ROBOT_ENABLED','true','是否启用助手入口',10000,0,0,10000,'2026-10-29 16:59:37',10000,'2026-10-29 16:59:37');
/*!40000 ALTER TABLE `sys_params` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `sys_post`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_post` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `post_code` varchar(100) DEFAULT NULL COMMENT '岗位编码',
  `post_name` varchar(100) DEFAULT NULL COMMENT '岗位名称',
  `sort` int DEFAULT NULL COMMENT '排序',
  `status` tinyint DEFAULT NULL COMMENT '状态  0：停用   1：正常',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识  0：正常   1：已删除',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='岗位管理';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `sys_post` WRITE;
/*!40000 ALTER TABLE `sys_post` DISABLE KEYS */;
INSERT INTO `sys_post` (`id`, `post_code`, `post_name`, `sort`, `status`, `tenant_id`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,'CTO','技术负责人',1,1,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(2,'BE','后端工程师',2,1,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(3,'FE','前端工程师',3,1,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(4,'OPS','运维工程师',4,1,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(5,'PM','产品经理',5,1,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(6,'IOT','物联网工程师',6,1,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27');
/*!40000 ALTER TABLE `sys_post` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `sys_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `name` varchar(50) DEFAULT NULL COMMENT '角色名称',
  `role_code` varchar(50) DEFAULT NULL COMMENT '角色编码',
  `remark` varchar(100) DEFAULT NULL COMMENT '备注',
  `data_scope` tinyint DEFAULT NULL COMMENT '数据范围  0：全部数据  1：本机构及子机构数据  2：本机构数据  3：本人数据  4：自定义数据',
  `org_id` bigint DEFAULT NULL COMMENT '机构ID',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识  0：正常   1：已删除',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_sys_role_orgid` (`org_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色管理';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `sys_role` WRITE;
/*!40000 ALTER TABLE `sys_role` DISABLE KEYS */;
INSERT INTO `sys_role` (`id`, `name`, `role_code`, `remark`, `data_scope`, `org_id`, `tenant_id`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,'系统管理员','ROLE_ADMIN','平台系统管理，可维护配置与权限',0,1,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(2,'研发工程师','ROLE_DEV','研发中心成员，可使用开发工具与物联网',1,2,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(3,'运维工程师','ROLE_OPS','运维中心成员，关注日志、监控与任务',1,3,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(4,'产品成员','ROLE_PM','产品中心成员，日常协作与查看',2,4,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27');
/*!40000 ALTER TABLE `sys_role` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `sys_role_data_scope`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role_data_scope` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `role_id` bigint DEFAULT NULL COMMENT '角色ID',
  `org_id` bigint DEFAULT NULL COMMENT '机构ID',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识  0：正常   1：已删除',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_data_scope_roleid` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色数据权限';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `sys_role_data_scope` WRITE;
/*!40000 ALTER TABLE `sys_role_data_scope` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_role_data_scope` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `sys_role_menu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_role_menu` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `role_id` bigint DEFAULT NULL COMMENT '角色ID',
  `menu_id` bigint DEFAULT NULL COMMENT '菜单ID',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识  0：正常   1：已删除',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_roleid` (`role_id`),
  KEY `idx_role_menuid` (`menu_id`)
) ENGINE=InnoDB AUTO_INCREMENT=181 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色菜单关系';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `sys_role_menu` WRITE;
/*!40000 ALTER TABLE `sys_role_menu` DISABLE KEYS */;
INSERT INTO `sys_role_menu` (`id`, `role_id`, `menu_id`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,1,1,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(2,1,2,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(3,1,3,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(4,1,4,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(5,1,5,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(6,1,6,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(7,1,7,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(8,1,8,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(9,1,9,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(10,1,10,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(11,1,11,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(12,1,12,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(13,1,13,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(14,1,14,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(15,1,15,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(16,1,16,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(17,1,17,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(18,1,18,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(19,1,19,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(20,1,20,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(21,1,21,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(22,1,22,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(23,1,23,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(24,1,24,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(25,1,25,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(26,1,26,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(27,1,27,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(28,1,28,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(29,1,29,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(30,1,30,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(31,1,31,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(32,1,32,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(33,1,33,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(34,1,34,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(35,1,35,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(36,1,36,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(37,1,37,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(38,1,38,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(39,1,39,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(40,1,40,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(41,1,41,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(42,1,42,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(43,1,43,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(44,1,44,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(45,1,46,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(46,1,47,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(47,1,48,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(48,1,49,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(49,1,50,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(50,1,51,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(51,1,53,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(52,1,54,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(53,1,55,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(54,1,56,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(55,1,57,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(56,1,58,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(57,1,59,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(58,1,60,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(59,1,61,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(60,1,62,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(61,1,63,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(62,1,64,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(63,1,65,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(64,1,66,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(65,1,67,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(66,1,68,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(67,1,69,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(68,1,70,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(69,1,71,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(70,1,72,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(71,1,73,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(72,1,74,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(73,1,75,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(128,2,1,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(129,2,7,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(130,2,8,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(131,2,33,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(132,2,39,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(133,2,46,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(134,2,47,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(135,2,48,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(136,2,49,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(137,2,50,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(138,2,51,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(139,2,53,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(140,2,54,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(141,2,55,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(142,2,56,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(143,2,57,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(144,2,58,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(145,2,59,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(146,2,60,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(147,2,61,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(148,2,62,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(149,2,63,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(150,2,75,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(159,3,34,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(160,3,35,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(161,3,40,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(162,3,64,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(163,3,65,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(164,3,66,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(165,3,67,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(166,3,68,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(167,3,69,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(168,3,70,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(169,3,71,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(170,3,72,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(171,3,73,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(172,3,74,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(174,4,33,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(175,4,39,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(176,4,48,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(177,4,49,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(178,4,75,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27');
/*!40000 ALTER TABLE `sys_role_menu` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `sys_sms_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_sms_config` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `platform` tinyint DEFAULT NULL COMMENT '平台类型  0：阿里云   1：腾讯云   2：七牛云   3：华为云',
  `group_name` varchar(100) DEFAULT NULL COMMENT '分组名称，发送短信时，可指定分组',
  `sign_name` varchar(100) DEFAULT NULL COMMENT '短信签名',
  `template_id` varchar(100) DEFAULT NULL COMMENT '短信模板',
  `app_id` varchar(100) DEFAULT NULL COMMENT '短信应用ID，如：腾讯云等',
  `sender_id` varchar(100) DEFAULT NULL COMMENT '腾讯云国际短信、华为云等需要',
  `url` varchar(200) DEFAULT NULL COMMENT '接入地址，如：华为云',
  `access_key` varchar(100) DEFAULT NULL COMMENT 'AccessKey',
  `secret_key` varchar(100) DEFAULT NULL COMMENT 'SecretKey',
  `status` tinyint DEFAULT NULL COMMENT '状态  0：禁用   1：启用',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识  0：正常   1：已删除',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='短信配置';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `sys_sms_config` WRITE;
/*!40000 ALTER TABLE `sys_sms_config` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_sms_config` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `sys_sms_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_sms_log` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `platform_id` bigint DEFAULT NULL COMMENT '平台ID',
  `platform` tinyint DEFAULT NULL COMMENT '平台类型',
  `mobile` varchar(20) NOT NULL COMMENT '手机号',
  `params` varchar(200) DEFAULT NULL COMMENT '参数',
  `status` tinyint DEFAULT NULL COMMENT '状态  0：失败   1：成功',
  `error` varchar(2000) DEFAULT NULL COMMENT '异常信息',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='短信日志';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `sys_sms_log` WRITE;
/*!40000 ALTER TABLE `sys_sms_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_sms_log` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `sys_third_login`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_third_login` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `open_type` varchar(50) DEFAULT NULL COMMENT '开放平台类型',
  `open_id` varchar(100) DEFAULT NULL COMMENT '开放平台，唯一标识',
  `username` varchar(100) DEFAULT NULL COMMENT '昵称',
  `user_id` bigint DEFAULT NULL COMMENT '用户ID',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识  0：正常   1：已删除',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='第三方登录';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `sys_third_login` WRITE;
/*!40000 ALTER TABLE `sys_third_login` DISABLE KEYS */;
/*!40000 ALTER TABLE `sys_third_login` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `sys_third_login_config`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_third_login_config` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `open_type` varchar(50) DEFAULT NULL COMMENT '开放平台类型',
  `client_id` varchar(200) DEFAULT NULL COMMENT 'ClientID',
  `client_secret` varchar(200) DEFAULT NULL COMMENT 'ClientSecret',
  `redirect_uri` varchar(200) DEFAULT NULL COMMENT 'RedirectUri',
  `agent_id` varchar(200) DEFAULT NULL COMMENT 'AgentID',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识  0：正常   1：已删除',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='第三方登录配置';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `sys_third_login_config` WRITE;
/*!40000 ALTER TABLE `sys_third_login_config` DISABLE KEYS */;
INSERT INTO `sys_third_login_config` (`id`, `open_type`, `client_id`, `client_secret`, `redirect_uri`, `agent_id`, `tenant_id`, `version`, `deleted`, `create_time`) VALUES
(1, 'feishu', 'cli_a541d3aa03f8500b', '', 'http://localhost:8080/sys/third/callback/feishu', '', 10000, 0, 0, '2026-10-28 05:12:20');

/*!40000 ALTER TABLE `sys_third_login_config` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `sys_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `password` varchar(100) DEFAULT NULL COMMENT '密码',
  `real_name` varchar(50) DEFAULT NULL COMMENT '姓名',
  `avatar` varchar(200) DEFAULT NULL COMMENT '头像',
  `signature` varchar(200) DEFAULT NULL COMMENT '签名',
  `gender` tinyint DEFAULT NULL COMMENT '性别   0：男   1：女   2：未知',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `mobile` varchar(20) DEFAULT NULL COMMENT '手机号',
  `org_id` bigint DEFAULT NULL COMMENT '机构ID',
  `leader_id` bigint DEFAULT NULL COMMENT '直属主管ID',
  `super_admin` tinyint DEFAULT NULL COMMENT '超级管理员   0：否   1：是',
  `status` tinyint DEFAULT NULL COMMENT '状态  0：封禁   1：正常',
  `ban_reason` varchar(500) DEFAULT NULL COMMENT '封禁原因',
  `ban_time` datetime DEFAULT NULL COMMENT '封禁时间',
  `ban_expire_time` datetime DEFAULT NULL COMMENT '封禁到期时间，空表示永久',
  `multi_device_login` tinyint DEFAULT NULL COMMENT '多设备登录：空跟随系统 0单设备 1多设备',
  `multi_device_max` int DEFAULT NULL COMMENT '个人多设备上限，空跟随系统',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识  0：正常   1：已删除',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10007 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户管理';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `sys_user` WRITE;
/*!40000 ALTER TABLE `sys_user` DISABLE KEYS */;
INSERT INTO `sys_user` (`id`, `username`, `password`, `real_name`, `avatar`, `signature`, `gender`, `email`, `mobile`, `org_id`, `leader_id`, `super_admin`, `status`, `tenant_id`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (10000,'admin','207cf410532f92a47dee245ce9b11ff71f578ebd763eb3bbea44ebd043d018fb','超级管理员','https://oss.mlh.jucheng.icu/logo.png','http://localhost:8080/upload/20261029/admin_60474.png',1,'960681673@qq.com','13800138000',1,NULL,1,1,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 06:00:27'),(10001,'chenkai','207cf410532f92a47dee245ce9b11ff71f578ebd763eb3bbea44ebd043d018fb','陈凯',NULL,NULL,0,'chenkai@icejz.net','13800010001',2,10000,0,1,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(10002,'linyue','207cf410532f92a47dee245ce9b11ff71f578ebd763eb3bbea44ebd043d018fb','林悦',NULL,NULL,1,'linyue@icejz.net','13800010002',5,10001,0,1,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(10003,'zhouqi','207cf410532f92a47dee245ce9b11ff71f578ebd763eb3bbea44ebd043d018fb','周琪',NULL,NULL,0,'zhouqi@icejz.net','13800010003',5,10001,0,1,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(10004,'sunhao','207cf410532f92a47dee245ce9b11ff71f578ebd763eb3bbea44ebd043d018fb','孙浩',NULL,NULL,0,'sunhao@icejz.net','13800010004',6,10001,0,1,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(10005,'wanning','207cf410532f92a47dee245ce9b11ff71f578ebd763eb3bbea44ebd043d018fb','万宁',NULL,NULL,1,'wanning@icejz.net','13800010005',3,10000,0,1,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(10006,'hejia','207cf410532f92a47dee245ce9b11ff71f578ebd763eb3bbea44ebd043d018fb','何佳',NULL,NULL,1,'hejia@icejz.net','13800010006',4,10000,0,1,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27');
/*!40000 ALTER TABLE `sys_user` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `sys_user_post`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user_post` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `user_id` bigint DEFAULT NULL COMMENT '用户ID',
  `post_id` bigint DEFAULT NULL COMMENT '岗位ID',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识  0：正常   1：已删除',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_post_id` (`user_id`),
  KEY `idx_user_post_postid` (`post_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户岗位关系';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `sys_user_post` WRITE;
/*!40000 ALTER TABLE `sys_user_post` DISABLE KEYS */;
INSERT INTO `sys_user_post` (`id`, `user_id`, `post_id`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,10000,1,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(2,10001,1,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(3,10002,2,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(4,10003,3,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(5,10004,6,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(6,10005,4,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(7,10006,5,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27');
/*!40000 ALTER TABLE `sys_user_post` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `sys_user_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user_role` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `role_id` bigint DEFAULT NULL COMMENT '角色ID',
  `user_id` bigint DEFAULT NULL COMMENT '用户ID',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识  0：正常   1：已删除',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_sys_user_roleid` (`role_id`),
  KEY `idx_sys_user_userid` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户角色关系';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `sys_user_role` WRITE;
/*!40000 ALTER TABLE `sys_user_role` DISABLE KEYS */;
INSERT INTO `sys_user_role` (`id`, `role_id`, `user_id`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,1,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(2,1,10001,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(3,2,10002,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(4,2,10003,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(5,2,10004,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(6,3,10005,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(7,4,10006,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27');
/*!40000 ALTER TABLE `sys_user_role` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `sys_user_token`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_user_token` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `user_id` bigint DEFAULT NULL COMMENT '用户ID',
  `access_token` varchar(32) DEFAULT NULL COMMENT 'accessToken',
  `access_token_expire` datetime DEFAULT NULL COMMENT 'accessToken 过期时间',
  `refresh_token` varchar(32) DEFAULT NULL COMMENT 'refreshToken',
  `refresh_token_expire` datetime DEFAULT NULL COMMENT 'refreshToken 过期时间',
  `tenant_id` bigint DEFAULT NULL COMMENT '租户ID',
  `login_ip` varchar(64) DEFAULT NULL COMMENT '登录IP',
  `user_agent` varchar(512) DEFAULT NULL COMMENT 'User-Agent',
  `client_type` varchar(32) DEFAULT NULL COMMENT '客户端类型',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户Token';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `sys_user_token` WRITE;
/*!40000 ALTER TABLE `sys_user_token` DISABLE KEYS */;

/*!40000 ALTER TABLE `sys_user_token` ENABLE KEYS */;
UNLOCK TABLES;

--
--

DROP TABLE IF EXISTS `sys_workbench_note`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sys_workbench_note` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',
  `user_id` bigint DEFAULT NULL COMMENT '用户ID',
  `note_date` varchar(10) DEFAULT NULL COMMENT '日期 yyyy-MM-dd',
  `note_type` varchar(20) DEFAULT NULL COMMENT '类型 memo/nudge/remind',
  `content` varchar(1000) DEFAULT NULL COMMENT '内容',
  `version` int DEFAULT NULL COMMENT '版本号',
  `deleted` tinyint DEFAULT NULL COMMENT '删除标识',
  `creator` bigint DEFAULT NULL COMMENT '创建者',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `updater` bigint DEFAULT NULL COMMENT '更新者',
  `update_time` datetime DEFAULT NULL COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_date` (`user_id`,`note_date`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='工作台日历记事';
/*!40101 SET character_set_client = @saved_cs_client */;

--
--

LOCK TABLES `sys_workbench_note` WRITE;
/*!40000 ALTER TABLE `sys_workbench_note` DISABLE KEYS */;
INSERT INTO `sys_workbench_note` (`id`, `user_id`, `note_date`, `note_type`, `content`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,10000,'2026-10-31','nudge','别忘了换配置信息',0,0,10000,'2026-10-30 05:17:45',10000,'2026-10-30 05:17:45');
/*!40000 ALTER TABLE `sys_workbench_note` ENABLE KEYS */;
UNLOCK TABLES;

--
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;


SET FOREIGN_KEY_CHECKS = 1;
