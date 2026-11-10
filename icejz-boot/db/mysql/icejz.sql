-- ICEJZ Boot MySQL dump (sanitized)
-- Database: icejz_boot
-- Notes:
--   1. AI / SMS / Mail / Third-login / Captcha / IoT / Generator secrets are cleared.
--   2. sys_user_token data is omitted.
--   3. Fill API keys again in 「系统管理 · AI助手」 after import if needed.
--   4. Default demo passwords remain SM3 hashes; every seed user password is 123456.

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- MySQL dump 10.13  Distrib 8.0.37, for Win64 (x86_64)

--

-- Host: localhost    Database: icejz_boot

-- ------------------------------------------------------

-- Server version	8.0.37



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

-- Table structure for table `gen_base_class`

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

-- Dumping data for table `gen_base_class`

--



LOCK TABLES `gen_base_class` WRITE;

/*!40000 ALTER TABLE `gen_base_class` DISABLE KEYS */;

INSERT INTO `gen_base_class` (`id`, `package_name`, `code`, `fields`, `remark`, `create_time`) VALUES (1,'net.icejz.framework.mybatis.entity','BaseEntity','id,creator,create_time,updater,update_time,version,deleted','使用该基类，则需要表里有这些字段','2026-10-28 05:12:37');

/*!40000 ALTER TABLE `gen_base_class` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `gen_config`

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

-- Dumping data for table `gen_config`

--



LOCK TABLES `gen_config` WRITE;

/*!40000 ALTER TABLE `gen_config` DISABLE KEYS */;

INSERT INTO `gen_config` (`id`, `config_key`, `config_value`) VALUES (1,'gen_config','{\"author\":\"ice_jz\",\"backendPath\":\"D:/framework/icejz/icejz-boot/icejz-boot-new\",\"email\":\"960681673@qq.com\",\"frontendPath\":\"D:/framework/icejz/icejz-admin\",\"moduleName\":\"test\",\"packageName\":\"net.icejz\",\"tablePrefix\":\"\",\"version\":\"5.0.0\"}');

/*!40000 ALTER TABLE `gen_config` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `gen_datasource`

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

-- Dumping data for table `gen_datasource`

--



LOCK TABLES `gen_datasource` WRITE;

/*!40000 ALTER TABLE `gen_datasource` DISABLE KEYS */;

/*!40000 ALTER TABLE `gen_datasource` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `gen_field_type`

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

-- Dumping data for table `gen_field_type`

--



LOCK TABLES `gen_field_type` WRITE;

/*!40000 ALTER TABLE `gen_field_type` DISABLE KEYS */;

INSERT INTO `gen_field_type` (`id`, `column_type`, `attr_type`, `package_name`, `create_time`) VALUES (1,'datetime','LocalDateTime','java.time.LocalDateTime','2026-10-28 05:12:37'),(2,'date','LocalDateTime','java.time.LocalDateTime','2026-10-28 05:12:37'),(3,'tinyint','Integer',NULL,'2026-10-28 05:12:37'),(4,'smallint','Integer',NULL,'2026-10-28 05:12:37'),(5,'mediumint','Integer',NULL,'2026-10-28 05:12:37'),(6,'int','Integer',NULL,'2026-10-28 05:12:37'),(7,'integer','Integer',NULL,'2026-10-28 05:12:37'),(8,'bigint','Long',NULL,'2026-10-28 05:12:37'),(9,'float','Float',NULL,'2026-10-28 05:12:37'),(10,'double','Double',NULL,'2026-10-28 05:12:37'),(11,'decimal','BigDecimal','java.math.BigDecimal','2026-10-28 05:12:37'),(12,'bit','Boolean',NULL,'2026-10-28 05:12:37'),(13,'char','String',NULL,'2026-10-28 05:12:37'),(14,'varchar','String',NULL,'2026-10-28 05:12:37'),(15,'tinytext','String',NULL,'2026-10-28 05:12:37'),(16,'text','String',NULL,'2026-10-28 05:12:37'),(17,'mediumtext','String',NULL,'2026-10-28 05:12:37'),(18,'longtext','String',NULL,'2026-10-28 05:12:37'),(19,'timestamp','LocalDateTime','java.time.LocalDateTime','2026-10-28 05:12:37'),(20,'NUMBER','Integer',NULL,'2026-10-28 05:12:37'),(21,'BINARY_INTEGER','Integer',NULL,'2026-10-28 05:12:37'),(22,'BINARY_FLOAT','Float',NULL,'2026-10-28 05:12:37'),(23,'BINARY_DOUBLE','Double',NULL,'2026-10-28 05:12:37'),(24,'VARCHAR2','String',NULL,'2026-10-28 05:12:37'),(25,'NVARCHAR','String',NULL,'2026-10-28 05:12:37'),(26,'NVARCHAR2','String',NULL,'2026-10-28 05:12:37'),(27,'CLOB','String',NULL,'2026-10-28 05:12:37'),(28,'int8','Long',NULL,'2026-10-28 05:12:37'),(29,'int4','Integer',NULL,'2026-10-28 05:12:37'),(30,'int2','Integer',NULL,'2026-10-28 05:12:37'),(31,'numeric','BigDecimal','java.math.BigDecimal','2026-10-28 05:12:37');

/*!40000 ALTER TABLE `gen_field_type` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `gen_project_modify`

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

-- Dumping data for table `gen_project_modify`

--



LOCK TABLES `gen_project_modify` WRITE;

/*!40000 ALTER TABLE `gen_project_modify` DISABLE KEYS */;

INSERT INTO `gen_project_modify` (`id`, `project_name`, `project_code`, `project_package`, `project_path`, `modify_project_name`, `modify_project_code`, `modify_project_package`, `exclusions`, `modify_suffix`, `modify_tmp_path`, `create_time`) VALUES (1,'icejz-boot','icejz','net.icejz','D:/framework/icejz/icejz-boot','demo-boot','demo','com.demo','.git,.idea,target,logs','java,xml,yml,txt',NULL,'2026-10-28 05:12:37'),(2,'icejz-cloud','icejz','net.icejz','D:/framework/icejz/icejz-cloud','demo-cloud','demo','com.demo','.git,.idea,target,logs','java,xml,yml,txt',NULL,'2026-10-28 05:12:37');

/*!40000 ALTER TABLE `gen_project_modify` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `gen_table`

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

-- Dumping data for table `gen_table`

--



LOCK TABLES `gen_table` WRITE;

/*!40000 ALTER TABLE `gen_table` DISABLE KEYS */;

INSERT INTO `gen_table` (`id`, `table_name`, `class_name`, `table_comment`, `author`, `email`, `package_name`, `version`, `generator_type`, `backend_path`, `frontend_path`, `module_name`, `function_name`, `form_layout`, `table_type`, `sub_table`, `table_operation`, `auth_level`, `open_type`, `request_url`, `authority`, `tree_id`, `tree_pid`, `tree_label`, `left_title`, `left_from`, `left_table_name`, `left_url`, `left_relation_field`, `datasource_id`, `baseclass_id`, `create_time`) VALUES (20,'gen_test_member','GenTestMember','单表测试','ice_jz','960681673@qq.com','net.icejz','',1,'D:/framework/icejz/icejz-boot/icejz-boot-new','D:/framework/icejz/icejz-admin','test','member',1,0,NULL,'[\"query\",\"insert\",\"update\",\"delete\",\"export\",\"import\"]',0,0,'/test/member','test:member',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,'2026-10-28 05:12:37'),(21,'gen_test_tree','GenTestTree','树表测试','ice_jz','960681673@qq.com','net.icejz','',1,'D:/framework/icejz/icejz-boot/icejz-boot-new','D:/framework/icejz/icejz-admin','test','tree',1,1,NULL,'[\"query\",\"insert\",\"update\",\"delete\",\"export\"]',0,0,'/test/tree','test:tree','id','parent_id','tree_name',NULL,NULL,NULL,NULL,NULL,0,NULL,'2026-10-28 05:12:37'),(22,'gen_test_goods','GenTestGoods','商品管理','ice_jz','960681673@qq.com','net.icejz','',1,'D:/framework/icejz/icejz-boot/icejz-boot-new','D:/framework/icejz/icejz-admin','test','goods',1,2,'[]','[\"query\",\"insert\",\"update\",\"delete\"]',0,0,'/test/goods','test:goods',NULL,NULL,NULL,'分类列表',0,'gen_test_goods_category','/test/category/list','category_id',0,NULL,'2026-10-28 05:12:37'),(23,'gen_test_goods_category','GenTestGoodsCategory','商品分类','ice_jz','960681673@qq.com','net.icejz','',1,'D:/framework/icejz/icejz-boot/icejz-boot-new','D:/framework/icejz/icejz-admin','test','category',1,1,'[]','[\"query\",\"insert\",\"update\",\"delete\"]',0,0,'/test/category','test:category','id','pid','name',NULL,NULL,NULL,NULL,NULL,0,NULL,'2026-10-28 05:12:37'),(24,'gen_test_product_info','GenTestProductInfo','产品信息','ice_jz','960681673@qq.com','net.icejz','',0,'D:/framework/icejz/icejz-boot/icejz-boot-new','D:/framework/icejz/icejz-admin','test','info',1,0,NULL,'[\"query\",\"insert\",\"update\",\"delete\",\"export\"]',0,0,'/test/info','test:info',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,'2026-10-28 05:12:37'),(25,'gen_test_product_param','GenTestProductParam','产品参数','ice_jz','960681673@qq.com','net.icejz','',0,'D:/framework/icejz/icejz-boot/icejz-boot-new','D:/framework/icejz/icejz-admin','test','param',1,0,NULL,'[\"query\",\"insert\",\"update\",\"delete\",\"export\"]',0,0,'/test/param','test:param',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,'2026-10-28 05:12:37'),(26,'gen_test_product','GenTestProduct','产品测试','ice_jz','960681673@qq.com','net.icejz','',1,'D:/framework/icejz/icejz-boot/icejz-boot-new','D:/framework/icejz/icejz-admin','test','product',1,0,'[{\"tableName\":\"gen_test_product_info\",\"foreignKey\":\"product_id\",\"tableTitle\":\"产品信息\",\"mainRelation\":1,\"sort\":0},{\"tableName\":\"gen_test_product_param\",\"foreignKey\":\"product_id\",\"tableTitle\":\"产品参数\",\"mainRelation\":2,\"sort\":1}]','[\"query\",\"insert\",\"update\",\"delete\"]',0,1,'/test/product','test:product',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL,'2026-10-28 05:12:37');

/*!40000 ALTER TABLE `gen_table` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `gen_table_field`

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

-- Dumping data for table `gen_table_field`

--



LOCK TABLES `gen_table_field` WRITE;

/*!40000 ALTER TABLE `gen_table_field` DISABLE KEYS */;

INSERT INTO `gen_table_field` (`id`, `table_id`, `field_name`, `field_type`, `field_comment`, `attr_name`, `attr_type`, `package_name`, `sort`, `auto_fill`, `primary_pk`, `base_field`, `form_item`, `form_required`, `form_type`, `form_dict`, `form_validator`, `grid_item`, `grid_sort`, `query_item`, `query_type`, `query_form_type`, `create_time`) VALUES (220,20,'id','bigint','ID','id','Long',NULL,0,'DEFAULT',1,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(221,20,'name','varchar','姓名','name','String',NULL,1,'DEFAULT',0,0,1,1,'input',NULL,NULL,1,0,0,'=','input','2026-10-28 05:12:37'),(222,20,'gender','tinyint','性别','gender','Integer',NULL,2,'DEFAULT',0,0,1,1,'radio','user_gender',NULL,1,0,1,'=','select','2026-10-28 05:12:37'),(223,20,'age','int','年龄','age','Integer',NULL,3,'DEFAULT',0,0,1,1,'number',NULL,NULL,1,0,0,'=','input','2026-10-28 05:12:37'),(224,20,'tenant_id','bigint','租户ID','tenantId','Long',NULL,4,'DEFAULT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(225,20,'version','int','版本号','version','Integer',NULL,5,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(226,20,'deleted','tinyint','删除标识','deleted','Integer',NULL,6,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(227,20,'create_time','datetime','创建时间','createTime','LocalDateTime','java.time.LocalDateTime',7,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(228,21,'id','bigint','ID','id','Long',NULL,0,'DEFAULT',1,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(229,21,'tree_name','varchar','名称','treeName','String',NULL,1,'DEFAULT',0,0,1,1,'input',NULL,NULL,1,0,1,'=','input','2026-10-28 05:12:37'),(230,21,'parent_id','bigint','上级ID','parentId','Long',NULL,2,'DEFAULT',0,0,1,0,'treeselect',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(231,21,'tenant_id','bigint','租户ID','tenantId','Long',NULL,3,'DEFAULT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(232,21,'create_time','datetime','创建时间','createTime','LocalDateTime','java.time.LocalDateTime',4,'INSERT',0,0,0,0,'input',NULL,NULL,1,0,1,'=','date','2026-10-28 05:12:37'),(233,22,'id','bigint','ID','id','Long',NULL,0,'DEFAULT',1,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(234,22,'name','varchar','名称','name','String',NULL,1,'DEFAULT',0,0,1,1,'input',NULL,NULL,1,0,1,'like','input','2026-10-28 05:12:37'),(235,22,'intro','varchar','介绍','intro','String',NULL,2,'DEFAULT',0,0,1,1,'input',NULL,NULL,1,0,0,'=','input','2026-10-28 05:12:37'),(236,22,'category_id','bigint','分类ID','categoryId','Long',NULL,3,'DEFAULT',0,0,1,1,'input',NULL,NULL,1,0,0,'=','input','2026-10-28 05:12:37'),(237,22,'tenant_id','bigint','租户ID','tenantId','Long',NULL,4,'DEFAULT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(238,22,'deleted','tinyint','删除标识','deleted','Integer',NULL,5,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(239,22,'creator','bigint','创建者','creator','Long',NULL,6,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(240,22,'create_time','datetime','创建时间','createTime','LocalDateTime','java.time.LocalDateTime',7,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(241,22,'updater','bigint','更新者','updater','Long',NULL,8,'INSERT_UPDATE',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(242,22,'update_time','datetime','更新时间','updateTime','LocalDateTime','java.time.LocalDateTime',9,'INSERT_UPDATE',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(243,23,'id','bigint','ID','id','Long',NULL,0,'DEFAULT',1,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(244,23,'name','varchar','名称','name','String',NULL,2,'DEFAULT',0,0,1,1,'input',NULL,NULL,1,0,1,'like','input','2026-10-28 05:12:37'),(245,23,'pid','bigint','上级ID','pid','Long',NULL,1,'DEFAULT',0,0,1,0,'treeselect',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(246,23,'tenant_id','bigint','租户ID','tenantId','Long',NULL,3,'DEFAULT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(247,23,'deleted','tinyint','删除标识','deleted','Integer',NULL,4,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(248,23,'creator','bigint','创建者','creator','Long',NULL,5,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(249,23,'create_time','datetime','创建时间','createTime','LocalDateTime','java.time.LocalDateTime',6,'INSERT',0,0,0,0,'input',NULL,NULL,1,0,1,'=','datetime','2026-10-28 05:12:37'),(250,23,'updater','bigint','更新者','updater','Long',NULL,7,'INSERT_UPDATE',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(251,23,'update_time','datetime','更新时间','updateTime','LocalDateTime','java.time.LocalDateTime',8,'INSERT_UPDATE',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(252,24,'id','bigint','ID','id','Long',NULL,0,'DEFAULT',1,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(253,24,'images','varchar','图片','images','String',NULL,1,'DEFAULT',0,0,1,1,'image',NULL,NULL,1,0,0,'=','input','2026-10-28 05:12:37'),(254,24,'intro','varchar','介绍','intro','String',NULL,2,'DEFAULT',0,0,1,1,'editor',NULL,NULL,1,0,0,'=','input','2026-10-28 05:12:37'),(255,24,'product_id','bigint','产品ID','productId','Long',NULL,3,'DEFAULT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(256,24,'tenant_id','bigint','租户ID','tenantId','Long',NULL,4,'DEFAULT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(257,24,'version','int','版本号','version','Integer',NULL,5,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(258,24,'deleted','tinyint','删除标识','deleted','Integer',NULL,6,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(259,24,'creator','bigint','创建者','creator','Long',NULL,7,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(260,24,'create_time','datetime','创建时间','createTime','LocalDateTime','java.time.LocalDateTime',8,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(261,24,'updater','bigint','更新者','updater','Long',NULL,9,'INSERT_UPDATE',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(262,24,'update_time','datetime','更新时间','updateTime','LocalDateTime','java.time.LocalDateTime',10,'INSERT_UPDATE',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(263,25,'id','bigint','ID','id','Long',NULL,0,'DEFAULT',1,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(264,25,'param_name','varchar','参数名称','paramName','String',NULL,1,'DEFAULT',0,0,1,1,'input',NULL,NULL,1,0,0,'=','input','2026-10-28 05:12:37'),(265,25,'param_value','varchar','参数值','paramValue','String',NULL,2,'DEFAULT',0,0,1,1,'input',NULL,NULL,1,0,0,'=','input','2026-10-28 05:12:37'),(266,25,'product_id','bigint','产品ID','productId','Long',NULL,3,'DEFAULT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(267,25,'tenant_id','bigint','租户ID','tenantId','Long',NULL,4,'DEFAULT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(268,25,'version','int','版本号','version','Integer',NULL,5,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(269,25,'deleted','tinyint','删除标识','deleted','Integer',NULL,6,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(270,25,'creator','bigint','创建者','creator','Long',NULL,7,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(271,25,'create_time','datetime','创建时间','createTime','LocalDateTime','java.time.LocalDateTime',8,'INSERT',0,0,0,0,'input',NULL,NULL,1,0,0,'=','input','2026-10-28 05:12:37'),(272,25,'updater','bigint','更新者','updater','Long',NULL,9,'INSERT_UPDATE',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(273,25,'update_time','datetime','更新时间','updateTime','LocalDateTime','java.time.LocalDateTime',10,'INSERT_UPDATE',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(274,26,'id','bigint','ID','id','Long',NULL,0,'DEFAULT',1,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(275,26,'name','varchar','名称','name','String',NULL,1,'DEFAULT',0,0,1,1,'input',NULL,NULL,1,0,1,'like','input','2026-10-28 05:12:37'),(276,26,'tenant_id','bigint','租户ID','tenantId','Long',NULL,2,'DEFAULT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(277,26,'version','int','版本号','version','Integer',NULL,3,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(278,26,'deleted','tinyint','删除标识','deleted','Integer',NULL,4,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(279,26,'creator','bigint','创建者','creator','Long',NULL,5,'INSERT',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(280,26,'create_time','datetime','创建时间','createTime','LocalDateTime','java.time.LocalDateTime',6,'INSERT',0,0,0,0,'input',NULL,NULL,1,0,1,'=','datetime','2026-10-28 05:12:37'),(281,26,'updater','bigint','更新者','updater','Long',NULL,7,'INSERT_UPDATE',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37'),(282,26,'update_time','datetime','更新时间','updateTime','LocalDateTime','java.time.LocalDateTime',8,'INSERT_UPDATE',0,0,0,0,'input',NULL,NULL,0,0,0,'=','input','2026-10-28 05:12:37');

/*!40000 ALTER TABLE `gen_table_field` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `gen_test_goods`

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

-- Dumping data for table `gen_test_goods`

--



LOCK TABLES `gen_test_goods` WRITE;

/*!40000 ALTER TABLE `gen_test_goods` DISABLE KEYS */;

/*!40000 ALTER TABLE `gen_test_goods` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `gen_test_goods_category`

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

-- Dumping data for table `gen_test_goods_category`

--



LOCK TABLES `gen_test_goods_category` WRITE;

/*!40000 ALTER TABLE `gen_test_goods_category` DISABLE KEYS */;

/*!40000 ALTER TABLE `gen_test_goods_category` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `gen_test_member`

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

-- Dumping data for table `gen_test_member`

--



LOCK TABLES `gen_test_member` WRITE;

/*!40000 ALTER TABLE `gen_test_member` DISABLE KEYS */;

/*!40000 ALTER TABLE `gen_test_member` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `gen_test_product`

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

-- Dumping data for table `gen_test_product`

--



LOCK TABLES `gen_test_product` WRITE;

/*!40000 ALTER TABLE `gen_test_product` DISABLE KEYS */;

/*!40000 ALTER TABLE `gen_test_product` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `gen_test_product_info`

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

-- Dumping data for table `gen_test_product_info`

--



LOCK TABLES `gen_test_product_info` WRITE;

/*!40000 ALTER TABLE `gen_test_product_info` DISABLE KEYS */;

/*!40000 ALTER TABLE `gen_test_product_info` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `gen_test_product_param`

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

-- Dumping data for table `gen_test_product_param`

--



LOCK TABLES `gen_test_product_param` WRITE;

/*!40000 ALTER TABLE `gen_test_product_param` DISABLE KEYS */;

/*!40000 ALTER TABLE `gen_test_product_param` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `gen_test_tree`

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

-- Dumping data for table `gen_test_tree`

--



LOCK TABLES `gen_test_tree` WRITE;

/*!40000 ALTER TABLE `gen_test_tree` DISABLE KEYS */;

/*!40000 ALTER TABLE `gen_test_tree` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `iot_device`

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

-- Dumping data for table `iot_device`

--



LOCK TABLES `iot_device` WRITE;

/*!40000 ALTER TABLE `iot_device` DISABLE KEYS */;

INSERT INTO `iot_device` (`id`, `code`, `name`, `type`, `uid`, `secret`, `app_version`, `battery_percent`, `temperature`, `status`, `running_status`, `protocol_type`, `up_time`, `down_time`, `tenant_id`, `creator`, `create_time`, `updater`, `update_time`, `version`, `deleted`) VALUES (1,'test-tcp','testTCP',1,'test12345678','',NULL,NULL,NULL,1,1,'TCP','2026-11-11 04:20:14',NULL,NULL,10000,'2026-10-28 05:13:35',10000,'2026-11-11 04:20:14',74,0);

/*!40000 ALTER TABLE `iot_device` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `iot_device_event_log`

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

) ENGINE=InnoDB AUTO_INCREMENT=75 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='设备事件日志';

/*!40101 SET character_set_client = @saved_cs_client */;



--

-- Dumping data for table `iot_device_event_log`

--



LOCK TABLES `iot_device_event_log` WRITE;

/*!40000 ALTER TABLE `iot_device_event_log` DISABLE KEYS */;

INSERT INTO `iot_device_event_log` (`id`, `device_id`, `event_type`, `event_uid`, `event_payload`, `event_time`, `tenant_id`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,1,1,NULL,'设备上报运行状态 ： 在线','2026-10-30 19:43:56',0,0,0,NULL,'2026-10-30 19:43:56',NULL,'2026-10-30 19:43:56'),(2,1,1,NULL,'设备上报运行状态 ： 在线','2026-10-30 19:49:17',0,0,0,NULL,'2026-10-30 19:49:17',NULL,'2026-10-30 19:49:17'),(3,1,1,NULL,'设备上报运行状态 ： 在线','2026-10-30 22:36:25',0,0,0,NULL,'2026-10-30 22:36:25',NULL,'2026-10-30 22:36:25'),(4,1,1,NULL,'设备上报运行状态 ： 在线','2026-10-31 16:10:10',0,0,0,NULL,'2026-10-31 16:10:10',NULL,'2026-10-31 16:10:10'),(5,1,1,NULL,'设备上报运行状态 ： 在线','2026-10-31 16:58:23',0,0,0,NULL,'2026-10-31 16:58:23',NULL,'2026-10-31 16:58:23'),(6,1,1,NULL,'设备上报运行状态 ： 在线','2026-10-31 19:38:17',0,0,0,NULL,'2026-10-31 19:38:17',NULL,'2026-10-31 19:38:17'),(7,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-01 03:31:55',0,0,0,NULL,'2026-11-01 03:31:55',NULL,'2026-11-01 03:31:55'),(8,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-01 03:36:57',0,0,0,NULL,'2026-11-01 03:36:57',NULL,'2026-11-01 03:36:57'),(9,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-01 03:39:09',0,0,0,NULL,'2026-11-01 03:39:09',NULL,'2026-11-01 03:39:09'),(10,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-01 16:10:09',0,0,0,NULL,'2026-11-01 16:10:09',NULL,'2026-11-01 16:10:09'),(11,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-01 17:30:11',0,0,0,NULL,'2026-11-01 17:30:11',NULL,'2026-11-01 17:30:11'),(12,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-01 22:04:50',0,0,0,NULL,'2026-11-01 22:04:50',NULL,'2026-11-01 22:04:50'),(13,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-01 22:38:06',0,0,0,NULL,'2026-11-01 22:38:06',NULL,'2026-11-01 22:38:06'),(14,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-01 22:42:22',0,0,0,NULL,'2026-11-01 22:42:22',NULL,'2026-11-01 22:42:22'),(15,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-01 22:50:29',0,0,0,NULL,'2026-11-01 22:50:29',NULL,'2026-11-01 22:50:29'),(16,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-01 23:04:23',0,0,0,NULL,'2026-11-01 23:04:23',NULL,'2026-11-01 23:04:23'),(17,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-01 23:05:15',0,0,0,NULL,'2026-11-01 23:05:15',NULL,'2026-11-01 23:05:15'),(18,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-01 23:11:01',0,0,0,NULL,'2026-11-01 23:11:01',NULL,'2026-11-01 23:11:01'),(19,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-01 23:47:11',0,0,0,NULL,'2026-11-01 23:47:11',NULL,'2026-11-01 23:47:11'),(20,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-01 23:50:03',0,0,0,NULL,'2026-11-01 23:50:03',NULL,'2026-11-01 23:50:03'),(21,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-02 02:08:47',0,0,0,NULL,'2026-11-02 02:08:47',NULL,'2026-11-02 02:08:47'),(22,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-02 03:20:48',0,0,0,NULL,'2026-11-02 03:20:48',NULL,'2026-11-02 03:20:48'),(23,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-02 03:57:08',0,0,0,NULL,'2026-11-02 03:57:08',NULL,'2026-11-02 03:57:08'),(24,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-02 04:37:34',0,0,0,NULL,'2026-11-02 04:37:34',NULL,'2026-11-02 04:37:34'),(25,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-02 04:45:20',0,0,0,NULL,'2026-11-02 04:45:20',NULL,'2026-11-02 04:45:20'),(26,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-02 04:51:00',0,0,0,NULL,'2026-11-02 04:51:00',NULL,'2026-11-02 04:51:00'),(27,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-02 05:07:52',0,0,0,NULL,'2026-11-02 05:07:52',NULL,'2026-11-02 05:07:52'),(28,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-02 12:48:57',0,0,0,NULL,'2026-11-02 12:48:57',NULL,'2026-11-02 12:48:57'),(29,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-02 12:56:26',0,0,0,NULL,'2026-11-02 12:56:26',NULL,'2026-11-02 12:56:26'),(30,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-02 13:07:40',0,0,0,NULL,'2026-11-02 13:07:40',NULL,'2026-11-02 13:07:40'),(31,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-02 13:31:51',0,0,0,NULL,'2026-11-02 13:31:51',NULL,'2026-11-02 13:31:51'),(32,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-02 13:35:29',0,0,0,NULL,'2026-11-02 13:35:29',NULL,'2026-11-02 13:35:29'),(33,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-02 17:15:34',0,0,0,NULL,'2026-11-02 17:15:34',NULL,'2026-11-02 17:15:34'),(34,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-02 17:18:24',0,0,0,NULL,'2026-11-02 17:18:24',NULL,'2026-11-02 17:18:24'),(35,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-03 03:25:09',0,0,0,NULL,'2026-11-03 03:25:09',NULL,'2026-11-03 03:25:09'),(36,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-03 03:34:21',0,0,0,NULL,'2026-11-03 03:34:21',NULL,'2026-11-03 03:34:21'),(37,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-03 04:54:56',0,0,0,NULL,'2026-11-03 04:54:56',NULL,'2026-11-03 04:54:56'),(38,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-03 04:58:37',0,0,0,NULL,'2026-11-03 04:58:37',NULL,'2026-11-03 04:58:37'),(39,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-03 05:02:31',0,0,0,NULL,'2026-11-03 05:02:31',NULL,'2026-11-03 05:02:31'),(40,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-03 05:09:09',0,0,0,NULL,'2026-11-03 05:09:09',NULL,'2026-11-03 05:09:09'),(41,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-03 05:27:54',0,0,0,NULL,'2026-11-03 05:27:54',NULL,'2026-11-03 05:27:54'),(42,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-03 05:35:10',0,0,0,NULL,'2026-11-03 05:35:10',NULL,'2026-11-03 05:35:10'),(43,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-03 05:42:47',0,0,0,NULL,'2026-11-03 05:42:47',NULL,'2026-11-03 05:42:47'),(44,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-03 05:53:59',0,0,0,NULL,'2026-11-03 05:53:59',NULL,'2026-11-03 05:53:59'),(45,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-03 06:05:17',0,0,0,NULL,'2026-11-03 06:05:17',NULL,'2026-11-03 06:05:17'),(46,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-03 06:13:08',0,0,0,NULL,'2026-11-03 06:13:08',NULL,'2026-11-03 06:13:08'),(47,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-03 06:20:16',0,0,0,NULL,'2026-11-03 06:20:16',NULL,'2026-11-03 06:20:16'),(48,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-03 06:39:07',0,0,0,NULL,'2026-11-03 06:39:07',NULL,'2026-11-03 06:39:07'),(49,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-03 06:49:27',0,0,0,NULL,'2026-11-03 06:49:27',NULL,'2026-11-03 06:49:27'),(50,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-03 15:40:00',0,0,0,NULL,'2026-11-03 15:40:00',NULL,'2026-11-03 15:40:00'),(51,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-03 22:15:00',0,0,0,NULL,'2026-11-03 22:15:00',NULL,'2026-11-03 22:15:00'),(52,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-04 00:10:43',0,0,0,NULL,'2026-11-04 00:10:43',NULL,'2026-11-04 00:10:43'),(53,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-04 01:26:21',0,0,0,NULL,'2026-11-04 01:26:21',NULL,'2026-11-04 01:26:21'),(54,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-04 03:40:42',0,0,0,NULL,'2026-11-04 03:40:42',NULL,'2026-11-04 03:40:42'),(55,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-04 04:21:47',0,0,0,NULL,'2026-11-04 04:21:47',NULL,'2026-11-04 04:21:47'),(56,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-04 04:43:51',0,0,0,NULL,'2026-11-04 04:43:51',NULL,'2026-11-04 04:43:51'),(57,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-04 04:55:06',0,0,0,NULL,'2026-11-04 04:55:06',NULL,'2026-11-04 04:55:06'),(58,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-04 05:18:20',0,0,0,NULL,'2026-11-04 05:18:20',NULL,'2026-11-04 05:18:20'),(59,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-04 05:25:02',0,0,0,NULL,'2026-11-04 05:25:02',NULL,'2026-11-04 05:25:02'),(60,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-04 05:43:55',0,0,0,NULL,'2026-11-04 05:43:55',NULL,'2026-11-04 05:43:55'),(61,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-04 14:41:57',0,0,0,NULL,'2026-11-04 14:41:57',NULL,'2026-11-04 14:41:57'),(62,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-04 14:49:53',0,0,0,NULL,'2026-11-04 14:49:53',NULL,'2026-11-04 14:49:53'),(63,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-04 15:09:12',0,0,0,NULL,'2026-11-04 15:09:12',NULL,'2026-11-04 15:09:12'),(64,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-04 15:36:36',0,0,0,NULL,'2026-11-04 15:36:36',NULL,'2026-11-04 15:36:36'),(65,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-04 15:47:39',0,0,0,NULL,'2026-11-04 15:47:39',NULL,'2026-11-04 15:47:39'),(66,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-04 16:49:05',0,0,0,NULL,'2026-11-04 16:49:05',NULL,'2026-11-04 16:49:05'),(67,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-04 16:59:34',0,0,0,NULL,'2026-11-04 16:59:34',NULL,'2026-11-04 16:59:34'),(68,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-04 17:03:45',0,0,0,NULL,'2026-11-04 17:03:45',NULL,'2026-11-04 17:03:45'),(69,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-05 02:51:08',0,0,0,NULL,'2026-11-05 02:51:08',NULL,'2026-11-05 02:51:08'),(70,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-06 21:23:09',0,0,0,NULL,'2026-11-06 21:23:09',NULL,'2026-11-06 21:23:09'),(71,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-10 13:51:03',0,0,0,NULL,'2026-11-10 13:51:03',NULL,'2026-11-10 13:51:03'),(72,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-10 15:01:29',0,0,0,NULL,'2026-11-10 15:01:29',NULL,'2026-11-10 15:01:29'),(73,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-11 03:35:05',0,0,0,NULL,'2026-11-11 03:35:05',NULL,'2026-11-11 03:35:05'),(74,1,1,NULL,'设备上报运行状态 ： 在线','2026-11-11 04:20:15',0,0,0,NULL,'2026-11-11 04:20:15',NULL,'2026-11-11 04:20:15');

/*!40000 ALTER TABLE `iot_device_event_log` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `iot_device_service_log`

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

-- Dumping data for table `iot_device_service_log`

--



LOCK TABLES `iot_device_service_log` WRITE;

/*!40000 ALTER TABLE `iot_device_service_log` DISABLE KEYS */;

/*!40000 ALTER TABLE `iot_device_service_log` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `member_user`

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

-- Dumping data for table `member_user`

--



LOCK TABLES `member_user` WRITE;

/*!40000 ALTER TABLE `member_user` DISABLE KEYS */;

/*!40000 ALTER TABLE `member_user` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `schedule_job`

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

-- Dumping data for table `schedule_job`

--



LOCK TABLES `schedule_job` WRITE;

/*!40000 ALTER TABLE `schedule_job` DISABLE KEYS */;

INSERT INTO `schedule_job` (`id`, `job_name`, `job_group`, `bean_name`, `method`, `params`, `cron_expression`, `status`, `concurrent`, `remark`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,'测试任务','system','testTask','run','123','0 * * * * ? *',0,0,'',14,0,10000,'2026-10-28 05:14:01',10000,'2026-10-28 05:14:01');

/*!40000 ALTER TABLE `schedule_job` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `schedule_job_log`

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

-- Dumping data for table `schedule_job_log`

--



LOCK TABLES `schedule_job_log` WRITE;

/*!40000 ALTER TABLE `schedule_job_log` DISABLE KEYS */;

/*!40000 ALTER TABLE `schedule_job_log` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_ai_chat_message`

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

) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='AI对话消息';

/*!40101 SET character_set_client = @saved_cs_client */;



--

-- Dumping data for table `sys_ai_chat_message`

--



LOCK TABLES `sys_ai_chat_message` WRITE;

/*!40000 ALTER TABLE `sys_ai_chat_message` DISABLE KEYS */;

INSERT INTO `sys_ai_chat_message` (`id`, `session_id`, `user_id`, `role`, `content`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,1,10000,'user','如何生成业务代码？',0,0,10000,'2026-11-03 22:32:29',10000,'2026-11-03 22:32:29'),(2,1,10000,'assistant','在 ICEJZ 平台生成业务代码，通常可以按以下思路操作（具体入口名称可能因你的项目模板略有差异）：\n\n1. **进入代码生成入口**\n   - 打开对应项目/应用 → 找到「代码生成」或「研发工具」模块。\n   - 选择目标业务对象（如数据表、模型、接口定义）。\n\n2. **配置生成参数**\n   - 选择模板：常见有 CRUD、API 服务、前端页面、DTO/VO 等。\n   - 指定包名、模块名、作者、生成路径。\n   - 勾选需要生成的层：Controller / Service / Mapper / Entity / 前端页面等。\n\n3. **预览并生成**\n   - 点击「预览」确认生成文件结构和内容。\n   - 确认无误后点击「生成」，代码会输出到指定目录或直接写入代码库。\n\n4. **后续接入**\n   - 根据生成结果补充业务逻辑、权限配置和接口文档。\n   - 如平台支持，可绑定 Git 仓库自动提交。\n\n如果你告诉我你当前使用的是哪个模块（比如低代码建模、数据库表生成、API 编排），我可以给你更具体的步骤。',0,0,10000,'2026-11-03 22:32:29',10000,'2026-11-03 22:32:29'),(3,2,10000,'user','用户权限怎么配？',0,0,10000,'2026-11-03 22:32:36',10000,'2026-11-03 22:32:36'),(4,2,10000,'assistant','用户权限配置通常分三步走：\n\n1. **确定角色**：先明确用户属于哪种角色（如管理员、开发、测试、访客），不同角色对应不同权限范围。\n2. **分配权限**：在平台「系统管理 / 1权限管理」里，按角色勾选可访问的模块和操作（查看、编辑、删除、发布等）。\n3. **绑定用户**：把用户加入对应角色或用户组，权限即生效。\n\n小提示：\n- 遵循最小权限原则，只给必要的权限。\n- 权限变更后建议让用户重新登录验证。\n- 如果是项目级权限，还需在项目设置里单独配置成员角色。\n\n你是在哪个具体模块配权限？我可以给更精确的步骤。',0,0,10000,'2026-11-03 22:32:36',10000,'2026-11-03 22:32:36');

/*!40000 ALTER TABLE `sys_ai_chat_message` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_ai_chat_session`

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

) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='AI对话会话';

/*!40101 SET character_set_client = @saved_cs_client */;



--

-- Dumping data for table `sys_ai_chat_session`

--



LOCK TABLES `sys_ai_chat_session` WRITE;

/*!40000 ALTER TABLE `sys_ai_chat_session` DISABLE KEYS */;

INSERT INTO `sys_ai_chat_session` (`id`, `user_id`, `title`, `last_msg_time`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,10000,'如何生成业务代码？','2026-11-03 22:32:29',1,0,10000,'2026-11-03 22:32:29',10000,'2026-11-03 22:32:29'),(2,10000,'用户权限怎么配？','2026-11-03 22:32:35',1,0,10000,'2026-11-03 22:32:35',10000,'2026-11-03 22:32:36');

/*!40000 ALTER TABLE `sys_ai_chat_session` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_ai_model`

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

-- Dumping data for table `sys_ai_model`

--



LOCK TABLES `sys_ai_model` WRITE;

/*!40000 ALTER TABLE `sys_ai_model` DISABLE KEYS */;

INSERT INTO `sys_ai_model` (`id`, `name`, `provider`, `api_type`, `base_url`, `api_key`, `model_name`, `temperature`, `max_tokens`, `system_prompt`, `is_default`, `sort`, `status`, `remark`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES
(1, '本地 Ollama', 'ollama', 0, 'http://127.0.0.1:11434/v1', '', 'qwen2.5', 0.70, 2048, '你是 ICEJZ 平台助手小冰，语气友好、简洁，擅长帮助用户理解平台功能、系统配置与研发协作问题。', 0, 0, 0, '默认禁用，启动 Ollama 后改为启用', 2, 0, 10000, '2026-10-29 16:59:38', 10000, '2026-11-03 22:27:13'),
(2, '小冰 · DeepSeek', 'deepseek', 1, 'https://api.deepseek.com/v1', '', 'deepseek-chat', 0.70, 4096, '你是 ICEJZ 平台助手小冰，语气友好、简洁，擅长帮助用户理解平台功能、系统配置与研发协作问题。', 1, 0, 1, 'DeepSeek 官方 OpenAI 兼容接口，请填写 API Key 后使用', 2, 0, 10000, '2026-10-30 05:19:03', 10000, '2026-11-03 22:26:48');


/*!40000 ALTER TABLE `sys_ai_model` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_attachment`

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

-- Dumping data for table `sys_attachment`

--



LOCK TABLES `sys_attachment` WRITE;

/*!40000 ALTER TABLE `sys_attachment` DISABLE KEYS */;

/*!40000 ALTER TABLE `sys_attachment` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_captcha_config`

--



DROP TABLE IF EXISTS `sys_captcha_config`;

/*!40101 SET @saved_cs_client     = @@character_set_client */;

/*!50503 SET character_set_client = utf8mb4 */;

CREATE TABLE `sys_captcha_config` (

  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',

  `tenant_id` bigint DEFAULT '10000' COMMENT '租户ID',

  `enabled` tinyint NOT NULL DEFAULT '0' COMMENT '账号登录验证码开关 0关 1开',

  `pc_type` varchar(32) NOT NULL DEFAULT 'spec' COMMENT 'PC管理端账号登录验证码类型',

  `app_type` varchar(32) NOT NULL DEFAULT 'spec' COMMENT '移动端登录验证码类型',

  `sms_type` varchar(32) NOT NULL DEFAULT 'spec' COMMENT '短信发送前图形验证码类型',

  `turnstile_site_key` varchar(256) DEFAULT '' COMMENT 'Turnstile Site Key',

  `turnstile_secret_key` varchar(256) DEFAULT '' COMMENT 'Turnstile Secret Key',

  `pow_difficulty` int NOT NULL DEFAULT '3' COMMENT 'PoW 前导0个数',

  `remark` varchar(200) DEFAULT NULL COMMENT '备注',

  `version` int DEFAULT '0' COMMENT '版本号',

  `deleted` tinyint DEFAULT '0' COMMENT '删除标识  0：正常   1：已删除',

  `creator` bigint DEFAULT NULL COMMENT '创建者',

  `create_time` datetime DEFAULT NULL COMMENT '创建时间',

  `updater` bigint DEFAULT NULL COMMENT '更新者',

  `update_time` datetime DEFAULT NULL COMMENT '更新时间',

  PRIMARY KEY (`id`),

  KEY `idx_tenant_deleted` (`tenant_id`,`deleted`)

) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='验证码配置';

/*!40101 SET character_set_client = @saved_cs_client */;



--

-- Dumping data for table `sys_captcha_config`

--



LOCK TABLES `sys_captcha_config` WRITE;

/*!40000 ALTER TABLE `sys_captcha_config` DISABLE KEYS */;

INSERT INTO `sys_captcha_config` (`id`, `tenant_id`, `enabled`, `pc_type`, `app_type`, `sms_type`, `turnstile_site_key`, `turnstile_secret_key`, `pow_difficulty`, `remark`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES
(1, 10000, 1, 'pattern', 'curve', 'spec', '16676607452', '', 3, '由 sys_params 迁移', 8, 0, 10000, '2026-11-04 04:51:24', 10000, '2026-11-04 05:30:18');


/*!40000 ALTER TABLE `sys_captcha_config` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_chat_allow`

--



DROP TABLE IF EXISTS `sys_chat_allow`;

/*!40101 SET @saved_cs_client     = @@character_set_client */;

/*!50503 SET character_set_client = utf8mb4 */;

CREATE TABLE `sys_chat_allow` (

  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',

  `type` tinyint NOT NULL COMMENT '1用户-用户 2机构-机构 3用户-机构',

  `src_id` bigint NOT NULL COMMENT '源ID（用户或机构）',

  `dst_id` bigint NOT NULL COMMENT '目标ID（用户或机构）',

  `status` tinyint NOT NULL DEFAULT '1' COMMENT '1启用 0停用',

  `remark` varchar(200) DEFAULT NULL COMMENT '备注',

  `version` int DEFAULT '0' COMMENT '版本号',

  `deleted` tinyint DEFAULT '0' COMMENT '删除标识',

  `creator` bigint DEFAULT NULL COMMENT '创建者',

  `create_time` datetime DEFAULT NULL COMMENT '创建时间',

  `updater` bigint DEFAULT NULL COMMENT '更新者',

  `update_time` datetime DEFAULT NULL COMMENT '更新时间',

  PRIMARY KEY (`id`),

  KEY `idx_chat_allow_type` (`type`,`status`),

  KEY `idx_chat_allow_src` (`src_id`),

  KEY `idx_chat_allow_dst` (`dst_id`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='聊天白名单例外';

/*!40101 SET character_set_client = @saved_cs_client */;



--

-- Dumping data for table `sys_chat_allow`

--



LOCK TABLES `sys_chat_allow` WRITE;

/*!40000 ALTER TABLE `sys_chat_allow` DISABLE KEYS */;

/*!40000 ALTER TABLE `sys_chat_allow` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_chat_conversation`

--



DROP TABLE IF EXISTS `sys_chat_conversation`;

/*!40101 SET @saved_cs_client     = @@character_set_client */;

/*!50503 SET character_set_client = utf8mb4 */;

CREATE TABLE `sys_chat_conversation` (

  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',

  `type` tinyint NOT NULL COMMENT '1单聊 2群聊',

  `title` varchar(100) DEFAULT NULL COMMENT '群名称/单聊可空',

  `avatar` varchar(255) DEFAULT NULL COMMENT '头像',

  `owner_id` bigint DEFAULT NULL COMMENT '群主/创建人',

  `direct_key` varchar(64) DEFAULT NULL COMMENT '单聊唯一键 minId_maxId',

  `last_msg_id` bigint DEFAULT NULL COMMENT '最后消息ID',

  `last_msg_content` varchar(500) DEFAULT NULL COMMENT '最后消息摘要',

  `last_msg_time` datetime DEFAULT NULL COMMENT '最后消息时间',

  `last_msg_type` tinyint DEFAULT NULL COMMENT '最后消息类型',

  `status` tinyint NOT NULL DEFAULT '1' COMMENT '1正常 0解散',

  `tenant_id` bigint DEFAULT NULL COMMENT '租户',

  `version` int DEFAULT '0' COMMENT '版本号',

  `deleted` tinyint DEFAULT '0' COMMENT '删除标识',

  `creator` bigint DEFAULT NULL COMMENT '创建者',

  `create_time` datetime DEFAULT NULL COMMENT '创建时间',

  `updater` bigint DEFAULT NULL COMMENT '更新者',

  `update_time` datetime DEFAULT NULL COMMENT '更新时间',

  PRIMARY KEY (`id`),

  UNIQUE KEY `uk_chat_direct_key` (`direct_key`),

  KEY `idx_chat_conv_owner` (`owner_id`),

  KEY `idx_chat_conv_last_time` (`last_msg_time`)

) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='聊天会话';

/*!40101 SET character_set_client = @saved_cs_client */;



--

-- Dumping data for table `sys_chat_conversation`

--



LOCK TABLES `sys_chat_conversation` WRITE;

/*!40000 ALTER TABLE `sys_chat_conversation` DISABLE KEYS */;

INSERT INTO `sys_chat_conversation` (`id`, `type`, `title`, `avatar`, `owner_id`, `direct_key`, `last_msg_id`, `last_msg_content`, `last_msg_time`, `last_msg_type`, `status`, `tenant_id`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,2,'研发总部',NULL,10000,NULL,3,'一小时后开会','2026-11-10 14:02:19',0,1,10000,4,0,10000,'2026-11-10 13:58:59',10000,'2026-11-10 14:02:19'),(2,1,NULL,NULL,10000,'10000_10001',5,'来一下办公室','2026-11-10 14:04:35',0,1,10000,2,0,10000,'2026-11-10 14:04:26',10000,'2026-11-10 14:04:35');

/*!40000 ALTER TABLE `sys_chat_conversation` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_chat_member`

--



DROP TABLE IF EXISTS `sys_chat_member`;

/*!40101 SET @saved_cs_client     = @@character_set_client */;

/*!50503 SET character_set_client = utf8mb4 */;

CREATE TABLE `sys_chat_member` (

  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',

  `conversation_id` bigint NOT NULL COMMENT '会话ID',

  `user_id` bigint NOT NULL COMMENT '用户ID',

  `role` tinyint NOT NULL DEFAULT '0' COMMENT '0成员 1管理员 2群主',

  `mute` tinyint NOT NULL DEFAULT '0' COMMENT '0否 1免打扰',

  `last_read_msg_id` bigint DEFAULT '0' COMMENT '已读到的消息ID',

  `join_time` datetime DEFAULT NULL COMMENT '加入时间',

  `version` int DEFAULT '0' COMMENT '版本号',

  `deleted` tinyint DEFAULT '0' COMMENT '删除标识',

  `creator` bigint DEFAULT NULL COMMENT '创建者',

  `create_time` datetime DEFAULT NULL COMMENT '创建时间',

  `updater` bigint DEFAULT NULL COMMENT '更新者',

  `update_time` datetime DEFAULT NULL COMMENT '更新时间',

  PRIMARY KEY (`id`),

  UNIQUE KEY `uk_chat_member` (`conversation_id`,`user_id`),

  KEY `idx_chat_member_user` (`user_id`)

) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='聊天成员';

/*!40101 SET character_set_client = @saved_cs_client */;



--

-- Dumping data for table `sys_chat_member`

--



LOCK TABLES `sys_chat_member` WRITE;

/*!40000 ALTER TABLE `sys_chat_member` DISABLE KEYS */;

INSERT INTO `sys_chat_member` (`id`, `conversation_id`, `user_id`, `role`, `mute`, `last_read_msg_id`, `join_time`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,1,10000,2,0,3,'2026-11-10 13:58:59',6,0,10000,'2026-11-10 13:58:59',10000,'2026-11-10 14:02:19'),(2,1,10001,0,0,0,'2026-11-10 13:58:59',0,0,10000,'2026-11-10 13:58:59',10000,'2026-11-10 13:58:59'),(3,1,10002,0,0,0,'2026-11-10 13:58:59',0,0,10000,'2026-11-10 13:58:59',10000,'2026-11-10 13:58:59'),(4,1,10003,0,0,0,'2026-11-10 13:58:59',0,0,10000,'2026-11-10 13:58:59',10000,'2026-11-10 13:58:59'),(5,1,10004,0,0,0,'2026-11-10 13:58:59',0,0,10000,'2026-11-10 13:58:59',10000,'2026-11-10 13:58:59'),(6,2,10000,2,0,5,'2026-11-10 14:04:26',3,0,10000,'2026-11-10 14:04:26',10000,'2026-11-10 14:04:35'),(7,2,10001,0,0,0,'2026-11-10 14:04:26',0,0,10000,'2026-11-10 14:04:26',10000,'2026-11-10 14:04:26');

/*!40000 ALTER TABLE `sys_chat_member` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_chat_message`

--



DROP TABLE IF EXISTS `sys_chat_message`;

/*!40101 SET @saved_cs_client     = @@character_set_client */;

/*!50503 SET character_set_client = utf8mb4 */;

CREATE TABLE `sys_chat_message` (

  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',

  `conversation_id` bigint NOT NULL COMMENT '会话ID',

  `sender_id` bigint NOT NULL COMMENT '发送人',

  `sender_name` varchar(64) DEFAULT NULL COMMENT '发送人姓名',

  `msg_type` tinyint NOT NULL DEFAULT '0' COMMENT '0文本 1图片 2文件 9系统',

  `content` varchar(4000) DEFAULT NULL COMMENT '文本内容/系统文案',

  `file_url` varchar(500) DEFAULT NULL COMMENT '文件地址',

  `file_name` varchar(255) DEFAULT NULL COMMENT '文件名',

  `file_size` bigint DEFAULT NULL COMMENT '文件大小字节',

  `status` tinyint NOT NULL DEFAULT '1' COMMENT '1正常 0撤回',

  `version` int DEFAULT '0' COMMENT '版本号',

  `deleted` tinyint DEFAULT '0' COMMENT '删除标识',

  `creator` bigint DEFAULT NULL COMMENT '创建者',

  `create_time` datetime DEFAULT NULL COMMENT '创建时间',

  `updater` bigint DEFAULT NULL COMMENT '更新者',

  `update_time` datetime DEFAULT NULL COMMENT '更新时间',

  PRIMARY KEY (`id`),

  KEY `idx_chat_msg_conv` (`conversation_id`,`id`),

  KEY `idx_chat_msg_sender` (`sender_id`)

) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='聊天消息';

/*!40101 SET character_set_client = @saved_cs_client */;



--

-- Dumping data for table `sys_chat_message`

--



LOCK TABLES `sys_chat_message` WRITE;

/*!40000 ALTER TABLE `sys_chat_message` DISABLE KEYS */;

INSERT INTO `sys_chat_message` (`id`, `conversation_id`, `sender_id`, `sender_name`, `msg_type`, `content`, `file_url`, `file_name`, `file_size`, `status`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,1,10000,'超级管理员',9,'超级管理员 创建了群聊「研发总部」',NULL,NULL,NULL,1,0,0,10000,'2026-11-10 13:58:59',10000,'2026-11-10 13:58:59'),(2,1,10000,'超级管理员',0,'消息已撤回',NULL,NULL,NULL,0,1,0,10000,'2026-11-10 13:59:24',10000,'2026-11-10 13:59:55'),(3,1,10000,'超级管理员',0,'一小时后开会',NULL,NULL,NULL,1,0,0,10000,'2026-11-10 14:02:19',10000,'2026-11-10 14:02:19'),(4,2,10000,'超级管理员',9,'超级管理员 发起了会话',NULL,NULL,NULL,1,0,0,10000,'2026-11-10 14:04:26',10000,'2026-11-10 14:04:26'),(5,2,10000,'超级管理员',0,'来一下办公室',NULL,NULL,NULL,1,0,0,10000,'2026-11-10 14:04:35',10000,'2026-11-10 14:04:35');

/*!40000 ALTER TABLE `sys_chat_message` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_chat_scope_org`

--



DROP TABLE IF EXISTS `sys_chat_scope_org`;

/*!40101 SET @saved_cs_client     = @@character_set_client */;

/*!50503 SET character_set_client = utf8mb4 */;

CREATE TABLE `sys_chat_scope_org` (

  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',

  `role_id` bigint NOT NULL COMMENT '角色ID',

  `org_id` bigint NOT NULL COMMENT '机构ID',

  `version` int DEFAULT '0' COMMENT '版本号',

  `deleted` tinyint DEFAULT '0' COMMENT '删除标识',

  `creator` bigint DEFAULT NULL COMMENT '创建者',

  `create_time` datetime DEFAULT NULL COMMENT '创建时间',

  `updater` bigint DEFAULT NULL COMMENT '更新者',

  `update_time` datetime DEFAULT NULL COMMENT '更新时间',

  PRIMARY KEY (`id`),

  KEY `idx_chat_scope_role` (`role_id`),

  KEY `idx_chat_scope_org` (`org_id`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色聊天自定义机构';

/*!40101 SET character_set_client = @saved_cs_client */;



--

-- Dumping data for table `sys_chat_scope_org`

--



LOCK TABLES `sys_chat_scope_org` WRITE;

/*!40000 ALTER TABLE `sys_chat_scope_org` DISABLE KEYS */;

/*!40000 ALTER TABLE `sys_chat_scope_org` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_dict_data`

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

) ENGINE=InnoDB AUTO_INCREMENT=78 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='字典数据';

/*!40101 SET character_set_client = @saved_cs_client */;



--

-- Dumping data for table `sys_dict_data`

--



LOCK TABLES `sys_dict_data` WRITE;

/*!40000 ALTER TABLE `sys_dict_data` DISABLE KEYS */;

INSERT INTO `sys_dict_data` (`id`, `dict_type_id`, `dict_label`, `dict_value`, `label_class`, `remark`, `sort`, `tenant_id`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,1,'停用','0','danger','',1,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(2,1,'正常','1','primary','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(3,2,'男','0','primary','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(4,2,'女','1','success','',1,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(5,2,'未知','2','warning','',2,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(6,3,'正常','1','primary','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(7,3,'封禁','0','danger','',1,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(8,4,'全部数据','0','','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(9,4,'本机构及子机构数据','1','','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(10,4,'本机构数据','2','','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(11,4,'本人数据','3','','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(12,4,'自定义数据','4','','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(13,5,'禁用','0','danger','',1,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(14,5,'启用','1','primary','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(15,6,'失败','0','danger','',1,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(16,6,'成功','1','primary','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(17,7,'登录成功','0','primary','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(18,7,'退出成功','1','warning','',1,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(19,7,'验证码错误','2','danger','',2,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(20,7,'账号密码错误','3','danger','',3,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(21,8,'否','0','primary','',1,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(22,8,'是','1','danger','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(23,9,'是','1','danger','',1,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(24,9,'否','0','primary','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(25,10,'其它','0','info','',10,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(26,10,'查询','1','primary','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(27,10,'新增','2','success','',1,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(28,10,'修改','3','warning','',2,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(29,10,'删除','4','danger','',3,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(30,10,'导出','5','info','',4,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(31,10,'导入','6','info','',5,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(32,11,'阿里云','0','','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(33,11,'腾讯云','1','','',1,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(34,11,'七牛云','2','','',2,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(35,11,'华为云','3','','',3,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(36,12,'本地','-1','','',0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(37,12,'阿里云','0','','',1,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(38,13,'手持设备','1','primary','',0,10000,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(39,13,'柜体','2','primary','',1,10000,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(40,13,'传感设备','3','primary','',2,10000,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(41,14,'离线状态','0','danger',NULL,0,10000,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(42,14,'在线状态','1','success',NULL,1,10000,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(43,15,'远程锁定','LOCK',NULL,NULL,0,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(44,15,'远程解锁','UNLOCK',NULL,NULL,1,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(45,15,'登录','SIGN_ON',NULL,NULL,2,NULL,0,1,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(46,15,'登出','SIGN_OFF',NULL,NULL,3,NULL,0,1,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(47,15,'OTA升级','OTA_UPGRADE',NULL,NULL,4,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(48,16,'MQTT','MQTT',NULL,NULL,0,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(49,16,'TCP','TCP',NULL,NULL,1,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(50,16,'UDP','UDP',NULL,NULL,2,NULL,0,1,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(51,16,'BLE','BLE',NULL,NULL,3,NULL,0,1,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(52,16,'CoAP','CoAP',NULL,NULL,4,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(53,16,'LwM2M','LwM2M',NULL,NULL,4,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(54,16,'Modbus','Modbus',NULL,NULL,4,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(55,17,'运行状态','RUNNING_STATUS',NULL,NULL,0,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(56,17,'APP版本','APP_VERSION',NULL,NULL,1,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(57,17,'电池电量百分比','BATTERY_PERCENT',NULL,NULL,2,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(58,17,'温度','TEMPERATURE',NULL,NULL,3,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(59,18,'下线','OFFLINE','danger',NULL,1,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(60,18,'上线','ONLINE','primary',NULL,2,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(61,18,'登录','SIGN_ON','primary',NULL,3,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(62,18,'退出登录','SIGN_OFF','danger',NULL,4,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(63,18,'OTA升级','OTA_UPGRADE','primary',NULL,5,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(64,18,'设备远程锁定','LOCK','primary',NULL,6,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(65,18,'设备远程解锁','UNLOCK','primary',NULL,7,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(66,18,'APP版本信息','APP_VERSION_REPORT','primary',NULL,8,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(67,18,'电池电量','BATTERY_PERCENT_REPORT','primary',NULL,9,NULL,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(68,18,'温度','TEMPERATURE_REPORT','primary',NULL,0,NULL,10,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(69,19,'默认','default','','',0,10000,0,0,10000,'2026-10-28 05:14:01',10000,'2026-10-28 05:14:01'),(70,19,'系统','system','','',1,10000,0,0,10000,'2026-10-28 05:14:01',10000,'2026-10-28 05:14:01'),(71,20,'暂停','0','danger','',0,10000,0,0,10000,'2026-10-28 05:14:01',10000,'2026-10-28 05:14:01'),(72,20,'正常','1','primary','',1,10000,0,0,10000,'2026-10-28 05:14:01',10000,'2026-10-28 05:14:01'),(73,21,'通知','0','primary','',0,10000,0,0,10000,'2026-11-01 17:22:04',10000,'2026-11-01 17:22:04'),(74,21,'公告','1','success','',1,10000,0,0,10000,'2026-11-01 17:22:04',10000,'2026-11-01 17:22:04'),(75,21,'私信','2','warning','',2,10000,0,0,10000,'2026-11-01 17:22:04',10000,'2026-11-01 17:22:04'),(76,22,'草稿','0','info','',0,10000,0,0,10000,'2026-11-01 17:22:04',10000,'2026-11-01 17:22:04'),(77,22,'已发送','1','primary','',1,10000,0,0,10000,'2026-11-01 17:22:04',10000,'2026-11-01 17:22:04');

/*!40000 ALTER TABLE `sys_dict_data` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_dict_type`

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

) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='字典类型';

/*!40101 SET character_set_client = @saved_cs_client */;



--

-- Dumping data for table `sys_dict_type`

--



LOCK TABLES `sys_dict_type` WRITE;

/*!40000 ALTER TABLE `sys_dict_type` DISABLE KEYS */;

INSERT INTO `sys_dict_type` (`id`, `dict_type`, `dict_name`, `dict_source`, `dict_sql`, `remark`, `sort`, `pid`, `has_child`, `tenant_id`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,'post_status','状态',0,NULL,'岗位管理',0,NULL,0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(2,'user_gender','性别',0,NULL,'用户管理',0,NULL,0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(3,'user_status','状态',0,NULL,'用户管理',0,NULL,0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(4,'role_data_scope','数据范围',0,NULL,'角色管理',0,NULL,0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(5,'enable_disable','状态',0,NULL,'功能状态：启用 | 禁用 ',0,NULL,0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(6,'success_fail','状态',0,NULL,'操作状态：成功 | 失败',0,NULL,0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(7,'login_operation','操作信息',0,NULL,'登录管理',0,NULL,0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(8,'params_type','系统参数',0,NULL,'参数管理',0,NULL,0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(9,'user_super_admin','用户是否是超管',0,NULL,'用户是否是超管',0,NULL,0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(10,'log_operate_type','操作类型',0,NULL,'操作日志',0,NULL,0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(11,'sms_platform','短信平台类型',0,NULL,'短信管理',0,NULL,0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(12,'mail_platform','邮件平台类型',0,NULL,'邮件管理',0,NULL,0,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(13,'device_type','设备类型',0,NULL,'设备类型',0,NULL,0,10000,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(14,'device_running_status','设备运行状态',0,NULL,'设备运行状态：离线|在线|待机|使用中|OTA升级中',0,NULL,0,10000,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(15,'device_command','设备指令',0,NULL,'设备服务具备的功能',0,NULL,0,10000,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(16,'device_protocol_type','设备协议类型',0,NULL,'设备协议类型',0,NULL,0,10000,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(17,'device_property','设备属性',0,NULL,'设备通用属性：运行状态|APP版本|电池电量百分比|温度',0,NULL,0,10000,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(18,'device_event_type','事件类型',0,NULL,'事件日志类型',0,NULL,0,10000,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(19,'schedule_group','任务组名',0,NULL,'定时任务',0,NULL,0,10000,0,0,10000,'2026-10-28 05:14:01',10000,'2026-10-28 05:14:01'),(20,'schedule_status','状态',0,NULL,'定时任务',0,NULL,0,10000,0,0,10000,'2026-10-28 05:14:01',10000,'2026-10-28 05:14:01'),(21,'message_type','消息类型',0,NULL,'站内消息',0,NULL,0,10000,0,0,10000,'2026-11-01 17:22:00',10000,'2026-11-01 17:22:00'),(22,'message_status','消息状态',0,NULL,'站内消息',0,NULL,0,10000,0,0,10000,'2026-11-01 17:22:03',10000,'2026-11-01 17:22:03');

/*!40000 ALTER TABLE `sys_dict_type` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_log_login`

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

) ENGINE=InnoDB AUTO_INCREMENT=117 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='登录日志';

/*!40101 SET character_set_client = @saved_cs_client */;



--

-- Dumping data for table `sys_log_login`

--



LOCK TABLES `sys_log_login` WRITE;

/*!40000 ALTER TABLE `sys_log_login` DISABLE KEYS */;

INSERT INTO `sys_log_login` (`id`, `username`, `ip`, `address`, `user_agent`, `status`, `operation`, `tenant_id`, `create_time`) VALUES (1,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,2,NULL,'2026-10-29 04:23:57'),(2,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-10-29 04:24:12'),(3,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,1,NULL,'2026-10-29 04:35:41'),(4,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-10-29 04:36:16'),(5,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,1,NULL,'2026-10-29 04:37:14'),(6,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-10-29 05:14:56'),(7,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,1,NULL,'2026-10-29 05:32:18'),(8,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-10-29 05:37:54'),(9,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,1,NULL,'2026-10-29 15:15:03'),(10,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-10-29 15:15:12'),(11,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT; Windows NT 10.0; zh-CN) WindowsPowerShell/5.1.22621.6133',0,2,NULL,'2026-10-29 15:17:27'),(12,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-10-29 18:18:12'),(13,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,1,NULL,'2026-10-29 23:13:04'),(14,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-10-29 23:56:20'),(15,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,1,NULL,'2026-10-30 04:45:42'),(16,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-10-30 04:49:56'),(17,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,1,NULL,'2026-10-30 04:50:20'),(18,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-10-30 04:52:23'),(19,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,1,NULL,'2026-10-30 06:06:23'),(20,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,3,NULL,'2026-10-30 06:08:16'),(21,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-10-30 06:08:37'),(22,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,1,NULL,'2026-10-30 06:12:55'),(23,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-10-31 17:09:52'),(24,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-11-01 16:16:46'),(25,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,1,NULL,'2026-11-01 16:20:00'),(26,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,2,NULL,'2026-11-01 16:20:18'),(27,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,2,NULL,'2026-11-01 16:20:26'),(28,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-11-01 16:20:32'),(29,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-11-01 17:30:21'),(30,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-11-02 03:03:33'),(31,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,1,NULL,'2026-11-02 03:24:51'),(32,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-11-02 03:25:10'),(33,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',0,3,NULL,'2026-11-02 03:57:29'),(34,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',0,3,NULL,'2026-11-02 03:59:39'),(35,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,1,NULL,'2026-11-02 04:05:27'),(36,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,2,NULL,'2026-11-02 04:05:44'),(37,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,2,NULL,'2026-11-02 04:05:51'),(38,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,2,NULL,'2026-11-02 04:05:57'),(39,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 QQBrowser/21.4.9121.400',1,0,NULL,'2026-11-02 04:11:19'),(40,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-11-02 05:08:11'),(41,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 QQBrowser/21.4.9121.400',0,2,NULL,'2026-11-02 05:08:38'),(42,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 QQBrowser/21.4.9121.400',1,0,NULL,'2026-11-02 05:08:44'),(43,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-11-02 12:56:48'),(44,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,1,NULL,'2026-11-02 12:57:20'),(45,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-11-02 12:57:27'),(46,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 QQBrowser/21.4.9121.400',0,2,NULL,'2026-11-02 13:32:29'),(47,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 QQBrowser/21.4.9121.400',1,0,NULL,'2026-11-02 13:32:35'),(48,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 QQBrowser/21.4.9121.400',1,1,NULL,'2026-11-02 13:32:45'),(49,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-11-03 03:28:07'),(50,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 QQBrowser/22.3.7007.400',0,2,NULL,'2026-11-03 04:24:27'),(51,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 QQBrowser/22.3.7007.400',0,2,NULL,'2026-11-03 04:24:30'),(52,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 QQBrowser/22.3.7007.400',1,0,NULL,'2026-11-03 04:31:03'),(53,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 QQBrowser/22.3.7007.400',1,1,NULL,'2026-11-03 04:31:06'),(54,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 QQBrowser/22.3.7007.400',1,0,NULL,'2026-11-03 04:32:32'),(55,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,1,NULL,'2026-11-03 04:57:48'),(56,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-11-03 04:58:44'),(57,'chenkai','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 QQBrowser/22.3.7007.400',1,0,NULL,'2026-11-03 05:15:06'),(58,'chenkai','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 QQBrowser/22.3.7007.400',0,3,NULL,'2026-11-03 06:16:57'),(59,'chenkai','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 QQBrowser/22.3.7007.400',0,3,NULL,'2026-11-03 06:17:01'),(60,'chenkai','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 QQBrowser/22.3.7007.400',0,3,NULL,'2026-11-03 06:20:20'),(61,'chenkai','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 QQBrowser/22.3.7007.400',0,3,NULL,'2026-11-03 06:20:20'),(62,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 QQBrowser/22.3.7007.400',1,0,NULL,'2026-11-03 06:22:32'),(63,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 QQBrowser/22.3.7007.400',1,1,NULL,'2026-11-03 06:22:39'),(64,'chenkai','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 QQBrowser/22.3.7007.400',1,0,NULL,'2026-11-03 06:22:53'),(65,'chenkai','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 QQBrowser/22.3.7007.400',1,0,NULL,'2026-11-03 06:30:19'),(66,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-11-03 15:56:48'),(67,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',1,0,NULL,'2026-11-03 17:47:48'),(68,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-11-03 22:26:03'),(69,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',1,1,NULL,'2026-11-03 23:11:40'),(70,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',1,0,NULL,'2026-11-03 23:11:57'),(71,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',1,1,NULL,'2026-11-04 00:08:00'),(72,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',1,0,NULL,'2026-11-04 00:10:58'),(73,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',1,1,NULL,'2026-11-04 00:12:06'),(74,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',1,0,NULL,'2026-11-04 00:12:52'),(75,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',1,1,NULL,'2026-11-04 00:13:01'),(76,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',1,0,NULL,'2026-11-04 01:16:37'),(77,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',1,1,NULL,'2026-11-04 01:24:29'),(78,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',1,0,NULL,'2026-11-04 01:24:41'),(79,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-11-04 01:25:02'),(80,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,2,NULL,'2026-11-04 01:25:06'),(81,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-11-04 01:25:10'),(82,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,2,NULL,'2026-11-04 01:26:41'),(83,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-11-04 01:26:49'),(84,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,1,NULL,'2026-11-04 01:28:48'),(85,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-11-04 01:28:54'),(86,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',1,0,NULL,'2026-11-04 01:31:16'),(87,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-11-04 01:31:35'),(88,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',1,1,NULL,'2026-11-04 02:21:06'),(89,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',1,0,NULL,'2026-11-04 02:21:18'),(90,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-11-04 03:02:17'),(91,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,2,NULL,'2026-11-04 03:02:19'),(92,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-11-04 03:02:23'),(93,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-11-04 03:32:09'),(94,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-11-04 04:22:35'),(95,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 17_0_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0.1 Mobile/21A360 Safari/604.1 wechatdevtools/2.01.2510250 MicroMessenger/8.0.5 Language/zh_CN webview/ hash/70138262 sid/yKblaoZAmZ',1,0,NULL,'2026-11-04 05:01:30'),(96,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 17_0_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0.1 Mobile/21A360 Safari/604.1 wechatdevtools/2.01.2510250 MicroMessenger/8.0.5 Language/zh_CN webview/ hash/70138262 sid/yKblaoZAmZ',1,1,NULL,'2026-11-04 05:02:01'),(97,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-11-04 05:18:43'),(98,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 17_0_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0.1 Mobile/21A360 Safari/604.1 wechatdevtools/2.01.2510250 MicroMessenger/8.0.5 Language/zh_CN webview/ hash/70138262 sid/yKblaoZAmZ',1,0,NULL,'2026-11-04 05:32:30'),(99,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',1,0,NULL,'2026-11-04 05:32:50'),(100,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',0,2,NULL,'2026-11-04 05:32:50'),(101,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-11-04 14:50:20'),(102,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 17_0_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0.1 Mobile/21A360 Safari/604.1 wechatdevtools/2.01.2510250 MicroMessenger/8.0.5 Language/zh_CN webview/ hash/70138262 sid/lqOcRCzsai',1,0,NULL,'2026-11-04 14:56:32'),(103,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 17_0_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0.1 Mobile/21A360 Safari/604.1 wechatdevtools/2.01.2510250 MicroMessenger/8.0.5 Language/zh_CN webview/ hash/70138262 sid/lqOcRCzsai',1,1,NULL,'2026-11-04 15:09:50'),(104,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 17_0_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0.1 Mobile/21A360 Safari/604.1 wechatdevtools/2.01.2510250 MicroMessenger/8.0.5 Language/zh_CN webview/ hash/70138262 sid/lqOcRCzsai',1,0,NULL,'2026-11-04 17:05:45'),(105,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',1,0,NULL,'2026-11-04 18:07:42'),(106,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 17_0_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0.1 Mobile/21A360 Safari/604.1 wechatdevtools/2.01.2510250 MicroMessenger/8.0.5 Language/zh_CN webview/ hash/70138262 sid/lqOcRCzsai',1,0,NULL,'2026-11-05 01:29:06'),(107,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 17_0_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0.1 Mobile/21A360 Safari/604.1 wechatdevtools/2.01.2510250 MicroMessenger/8.0.5 Language/zh_CN webview/ hash/70138262 sid/lqOcRCzsai',1,1,NULL,'2026-11-05 02:21:00'),(108,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 17_0_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0.1 Mobile/21A360 Safari/604.1 wechatdevtools/2.01.2510250 MicroMessenger/8.0.5 Language/zh_CN webview/ hash/70138262 sid/lqOcRCzsai',1,0,NULL,'2026-11-05 02:39:33'),(109,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',1,0,NULL,'2026-11-05 03:01:31'),(110,'admin','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',1,0,NULL,'2026-11-05 03:54:53'),(111,'','127.0.0.1',NULL,'curl/8.21.0',0,1,NULL,'2026-11-05 19:09:38'),(112,'admin','127.0.0.1',NULL,'',1,0,NULL,'2026-11-05 19:10:14'),(113,'admin','127.0.0.1',NULL,'',1,0,NULL,'2026-11-05 19:12:01'),(114,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',1,0,NULL,'2026-11-06 21:24:33'),(115,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36 Edg/157.0.0.0',0,2,NULL,'2026-11-11 03:40:25'),(116,'admin','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36 Edg/157.0.0.0',1,0,NULL,'2026-11-11 03:40:31');

/*!40000 ALTER TABLE `sys_log_login` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_log_operate`

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

) ENGINE=InnoDB AUTO_INCREMENT=113 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='操作日志';

/*!40101 SET character_set_client = @saved_cs_client */;



--

-- Dumping data for table `sys_log_operate`

--



LOCK TABLES `sys_log_operate` WRITE;

/*!40000 ALTER TABLE `sys_log_operate` DISABLE KEYS */;

INSERT INTO `sys_log_operate` (`id`, `module`, `name`, `req_uri`, `req_method`, `req_params`, `ip`, `address`, `user_agent`, `operate_type`, `duration`, `status`, `user_id`, `real_name`, `result_msg`, `tenant_id`, `create_time`) VALUES (1,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":null,\"email\":\"960681673@qq.com\",\"gender\":0,\"mobile\":\"18816881688\",\"realName\":\"admin\"}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,88,1,10000,'admin',NULL,10000,'2026-10-29 04:37:06'),(2,'文件上传','上传','/sys/file/upload','POST','{\"file\":\"[ignore]\"}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',2,710,1,10000,'admin',NULL,10000,'2026-10-29 05:52:01'),(3,'用户管理','修改登录用户签名','/sys/user/signature','PUT','{\"signature\":{\"signature\":\"http://localhost:8080/upload/20261029/admin_21112.png\"}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,100,1,10000,'admin',NULL,10000,'2026-10-29 05:52:01'),(4,'文件上传','上传','/sys/file/upload','POST','{\"file\":\"[ignore]\"}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',2,186,1,10000,'admin',NULL,10000,'2026-10-29 16:47:57'),(5,'用户管理','修改登录用户签名','/sys/user/signature','PUT','{\"signature\":{\"signature\":\"http://localhost:8080/upload/20261029/admin_60474.png\"}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,38,1,10000,'admin',NULL,10000,'2026-10-29 16:47:57'),(6,'AI助手','对话','/sys/ai/chat','POST','{\"vo\":{\"history\":[],\"message\":\"你好\",\"modelId\":null}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,44,0,10000,'admin',NULL,10000,'2026-10-30 00:11:52'),(7,'AI助手','对话','/sys/ai/chat','POST','{\"vo\":{\"history\":[],\"message\":\"你好\",\"modelId\":null}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,26,0,10000,'admin',NULL,10000,'2026-10-30 00:14:52'),(8,'工作台记事','保存记事','/sys/workbench/note','POST','{\"vo\":{\"content\":\"别忘了换配置信息\",\"createTime\":null,\"id\":null,\"noteDate\":\"2026-10-31\",\"noteType\":\"nudge\"}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',2,103,1,10000,'admin',NULL,10000,'2026-10-30 05:17:53'),(9,'AI助手','测试模型','/sys/ai/model/test/2','POST','{\"id\":2}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,461,0,10000,'admin',NULL,10000,'2026-10-30 05:21:03'),(10,'AI助手','测试模型','/sys/ai/model/test/2','POST','{\"id\":2}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,858,0,10000,'admin',NULL,10000,'2026-10-30 05:21:43'),(11,'AI助手','测试模型','/sys/ai/model/test/2','POST','{\"id\":2}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,576,0,10000,'admin',NULL,10000,'2026-10-30 05:24:53'),(12,'AI助手','测试模型','/sys/ai/model/test/2','POST','{\"id\":2}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,569,1,10000,'admin',NULL,10000,'2026-10-30 05:26:53'),(13,'AI助手','对话','/sys/ai/chat','POST','{\"vo\":{\"history\":[],\"message\":\"你好\",\"modelId\":null}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,867,1,10000,'admin',NULL,10000,'2026-10-30 05:27:13'),(14,'AI助手','对话','/sys/ai/chat','POST','{\"vo\":{\"history\":[{\"content\":\"你好\",\"role\":\"user\"},{\"content\":\"你好呀！我是 ICEJZ 平台助手小冰，很高兴见到你 😊\\n\\n有什么可以帮你的吗？比如平台功能、系统配置、研发协作相关的问题，都可以问我～\",\"role\":\"assistant\"}],\"message\":\"平台功能是什么\",\"modelId\":null}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,1622,1,10000,'admin',NULL,10000,'2026-10-30 05:28:43'),(15,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":null,\"email\":\"960681673@qq.com\",\"gender\":1,\"mobile\":\"13800138000\",\"realName\":\"admin\"}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,38,1,10000,'admin',NULL,10000,'2026-10-30 05:56:33'),(16,'AI助手','对话','/sys/ai/chat','POST','{\"vo\":{\"history\":[],\"message\":\"怎么打开工作台？\",\"modelId\":null,\"sessionId\":null}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,409,0,10000,'超级管理员',NULL,10000,'2026-10-31 17:10:12'),(17,'AI助手','对话','/sys/ai/chat','POST','{\"vo\":{\"history\":[],\"message\":\"怎么打开工作台？\",\"modelId\":null,\"sessionId\":null}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,137,0,10000,'超级管理员',NULL,10000,'2026-10-31 17:10:32'),(18,'AI助手','对话','/sys/ai/chat','POST','{\"vo\":{\"history\":[],\"message\":\"怎么打开工作台？\",\"modelId\":null,\"sessionId\":null}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,26,0,10000,'超级管理员',NULL,10000,'2026-11-01 01:57:05'),(19,'AI助手','对话','/sys/ai/chat','POST','{\"vo\":{\"history\":[{\"content\":\"怎么打开工作台？\",\"role\":\"user\"},{\"content\":\"模型鉴权失败啦～多半是 API Key 没填、填错或已失效（DeepSeek 常见提示 Authentication Fails）。\\n请到「系统配置 · AI助手」打开当前默认模型，补全/更新 API Key，保存后再试。\\n（这和系统提示词无关，改提示词解决不了 401。）\",\"role\":\"assistant\"}],\"message\":\"好吧\",\"modelId\":null,\"sessionId\":null}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,23,0,10000,'超级管理员',NULL,10000,'2026-11-01 01:57:35'),(20,'AI助手','对话','/sys/ai/chat','POST','{\"vo\":{\"history\":[],\"message\":\"11\",\"modelId\":null,\"sessionId\":null}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,27,0,10000,'超级管理员',NULL,10000,'2026-11-01 01:57:55'),(21,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":null,\"email\":\"960681673@qq.com\",\"gender\":2,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,42,1,10000,'超级管理员',NULL,10000,'2026-11-01 04:05:11'),(22,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":null,\"email\":\"960681673@qq.com\",\"gender\":1,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,18,1,10000,'超级管理员',NULL,10000,'2026-11-01 04:08:21'),(23,'AI助手','对话','/sys/ai/chat','POST','{\"vo\":{\"history\":[],\"message\":\"nih\",\"modelId\":null,\"sessionId\":null}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,21,0,10000,'超级管理员',NULL,10000,'2026-11-01 17:02:23'),(24,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"chinese\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"spec\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,124,1,10000,'超级管理员',NULL,10000,'2026-11-02 03:34:11'),(25,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"arithmetic\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"spec\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,90,1,10000,'超级管理员',NULL,10000,'2026-11-02 03:51:42'),(26,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"pattern\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"spec\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,173,1,10000,'超级管理员',NULL,10000,'2026-11-02 04:00:11'),(27,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"block_puzzle\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"spec\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,126,1,10000,'超级管理员',NULL,10000,'2026-11-02 04:03:21'),(28,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"block_puzzle\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"block_puzzle\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36 QQBrowser/21.4.9121.400',3,50,1,10000,'超级管理员',NULL,10000,'2026-11-02 04:24:32'),(29,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"block_puzzle\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"arithmetic\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,139,1,10000,'超级管理员',NULL,10000,'2026-11-02 05:08:35'),(30,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"block_puzzle\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"arithmetic\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,139,1,10000,'超级管理员',NULL,10000,'2026-11-02 12:48:50'),(31,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"block_puzzle\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"pattern\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,161,1,10000,'超级管理员',NULL,10000,'2026-11-02 13:21:33'),(32,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"block_puzzle\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"block_puzzle\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,159,1,10000,'超级管理员',NULL,10000,'2026-11-03 03:31:43'),(33,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"block_puzzle\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"click_word\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,156,1,10000,'超级管理员',NULL,10000,'2026-11-03 03:36:35'),(34,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"block_puzzle\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"pow\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,112,1,10000,'超级管理员',NULL,10000,'2026-11-03 03:45:05'),(35,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"block_puzzle\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"turnstile\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,77,1,10000,'超级管理员',NULL,10000,'2026-11-03 03:45:25'),(36,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"block_puzzle\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"pow\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,68,1,10000,'超级管理员',NULL,10000,'2026-11-03 03:46:25'),(37,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"block_puzzle\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"turnstile\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"960681673.\",\"turnstileSiteKey\":\"960681673\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,56,1,10000,'超级管理员',NULL,10000,'2026-11-03 03:47:05'),(38,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"block_puzzle\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"turnstile\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"\",\"turnstileSiteKey\":\"\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,71,1,10000,'超级管理员',NULL,10000,'2026-11-03 03:47:45'),(39,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"block_puzzle\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"pattern\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"\",\"turnstileSiteKey\":\"\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,83,1,10000,'超级管理员',NULL,10000,'2026-11-03 03:47:55'),(40,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"spec\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"pattern\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"\",\"turnstileSiteKey\":\"\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,64,1,10000,'超级管理员',NULL,10000,'2026-11-03 04:02:06'),(41,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"spec\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"spec\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,54,1,10000,'超级管理员',NULL,10000,'2026-11-03 04:24:26'),(42,'用户管理','下线指定登录设备','/sys/user/device/9972d3318136425abd37a8a5178a74b0','DELETE','{\"accessToken\":\"9972d3318136425abd37a8a5178a74b0\",\"request\":\"[ignore]\"}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,25,1,10000,'超级管理员',NULL,10000,'2026-11-03 04:55:39'),(43,'菜单管理','修改','/sys/menu','PUT','{\"vo\":{\"authority\":\"sys:login:security\",\"children\":[],\"createTime\":\"2026-11-03 04:44:23\",\"icon\":\"icon-insurance-fill\",\"id\":82,\"name\":\"登录安全\",\"openStyle\":0,\"parentName\":null,\"pid\":1,\"sort\":7,\"type\":0,\"url\":\"sys/config/login-security/index\"}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,28,1,10000,'超级管理员',NULL,10000,'2026-11-03 04:57:29'),(44,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"spec\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"pattern\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,245,1,10000,'超级管理员',NULL,10000,'2026-11-03 05:14:22'),(45,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"spec\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"pattern\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,109,1,10000,'超级管理员',NULL,10000,'2026-11-03 05:14:22'),(46,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"spec\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"pattern\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,90,1,10000,'超级管理员',NULL,10000,'2026-11-03 05:14:53'),(47,'登录安全配置','保存登录安全配置','/sys/login/security','PUT','{\"vo\":{\"multiDeviceLogin\":true,\"multiDeviceMax\":5}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,19,1,10000,'超级管理员',NULL,10000,'2026-11-03 05:21:33'),(48,'登录安全配置','保存登录安全配置','/sys/login/security','PUT','{\"vo\":{\"multiDeviceLogin\":true,\"multiDeviceMax\":3}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,48,1,10000,'超级管理员',NULL,10000,'2026-11-03 05:51:49'),(49,'用户管理','保存当前用户多设备登录设置','/sys/user/login-security','PUT','{\"vo\":{\"effectiveMultiDeviceLogin\":null,\"effectiveMultiDeviceMax\":null,\"multiDeviceLogin\":null,\"multiDeviceMax\":null,\"systemMultiDeviceLogin\":null,\"systemMultiDeviceMax\":null}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,41,1,10000,'超级管理员',NULL,10000,'2026-11-03 05:59:29'),(50,'用户管理','封禁/解封用户','/sys/user/status','PUT','{\"vo\":{\"banDuration\":\"5m\",\"banExpireTime\":null,\"id\":10001,\"reason\":null,\"sendNotify\":true,\"status\":0}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,142,1,10000,'超级管理员',NULL,10000,'2026-11-03 06:16:42'),(51,'用户管理','封禁/解封用户','/sys/user/status','PUT','{\"vo\":{\"banDuration\":null,\"banExpireTime\":null,\"id\":10001,\"reason\":null,\"sendNotify\":true,\"status\":1}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,46,1,10000,'超级管理员',NULL,10000,'2026-11-03 06:23:10'),(52,'用户管理','封禁/解封用户','/sys/user/status','PUT','{\"vo\":{\"banDuration\":\"5m\",\"banExpireTime\":null,\"id\":10001,\"reason\":null,\"sendNotify\":true,\"status\":0}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,39,1,10000,'超级管理员',NULL,10000,'2026-11-03 06:23:30'),(53,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"click_word\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"pattern\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,77,1,10000,'超级管理员',NULL,10000,'2026-11-03 17:44:56'),(54,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":\"https://oss.mlh.jucheng.icu/logo.png\",\"email\":\"960681673@qq.com\",\"gender\":0,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,45,1,10000,'超级管理员',NULL,10000,'2026-11-03 22:16:03'),(55,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":\"https://oss.mlh.jucheng.icu/logo.png\",\"email\":\"960681673@qq.com\",\"gender\":1,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,29,1,10000,'超级管理员',NULL,10000,'2026-11-03 22:16:03'),(56,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":\"https://oss.mlh.jucheng.icu/logo.png\",\"email\":\"960681673@qq.com\",\"gender\":0,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,18,1,10000,'超级管理员',NULL,10000,'2026-11-03 22:16:43'),(57,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":\"https://oss.mlh.jucheng.icu/logo.png\",\"email\":\"960681673@qq.com\",\"gender\":1,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,12,1,10000,'超级管理员',NULL,10000,'2026-11-03 22:16:43'),(58,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":\"https://oss.mlh.jucheng.icu/logo.png\",\"email\":\"960681673@qq.com\",\"gender\":0,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,22,1,10000,'超级管理员',NULL,10000,'2026-11-03 22:16:43'),(59,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":\"https://oss.mlh.jucheng.icu/logo.png\",\"email\":\"960681673@qq.com\",\"gender\":1,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,17,1,10000,'超级管理员',NULL,10000,'2026-11-03 22:16:53'),(60,'AI助手','对话','/sys/ai/chat','POST','{\"vo\":{\"history\":[],\"message\":\"如何生成业务代码？\",\"modelId\":null,\"sessionId\":null}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,2843,1,10000,'超级管理员',NULL,10000,'2026-11-03 22:32:34'),(61,'AI助手','对话','/sys/ai/chat','POST','{\"vo\":{\"history\":[],\"message\":\"用户权限怎么配？\",\"modelId\":null,\"sessionId\":null}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',0,1548,1,10000,'超级管理员',NULL,10000,'2026-11-03 22:32:44'),(62,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":\"https://oss.mlh.jucheng.icu/logo.png\",\"email\":\"960681673@qq.com\",\"gender\":2,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,12,1,10000,'超级管理员',NULL,10000,'2026-11-03 22:52:34'),(63,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":\"https://oss.mlh.jucheng.icu/logo.png\",\"email\":\"960681673@qq.com\",\"gender\":1,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,10,1,10000,'超级管理员',NULL,10000,'2026-11-03 22:52:34'),(64,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":\"https://oss.mlh.jucheng.icu/logo.png\",\"email\":\"960681673@qq.com\",\"gender\":0,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,11,1,10000,'超级管理员',NULL,10000,'2026-11-03 22:52:34'),(65,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":\"https://oss.mlh.jucheng.icu/logo.png\",\"email\":\"960681673@qq.com\",\"gender\":2,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,10,1,10000,'超级管理员',NULL,10000,'2026-11-03 23:03:44'),(66,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":\"https://oss.mlh.jucheng.icu/logo.png\",\"email\":\"960681673@qq.com\",\"gender\":0,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,12,1,10000,'超级管理员',NULL,10000,'2026-11-03 23:03:54'),(67,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":\"https://oss.mlh.jucheng.icu/logo.png\",\"email\":\"960681673@qq.com\",\"gender\":2,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,18,1,10000,'超级管理员',NULL,10000,'2026-11-03 23:03:54'),(68,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":\"https://oss.mlh.jucheng.icu/logo.png\",\"email\":\"960681673@qq.com\",\"gender\":0,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,12,1,10000,'超级管理员',NULL,10000,'2026-11-03 23:03:54'),(69,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":\"https://oss.mlh.jucheng.icu/logo.png\",\"email\":\"960681673@qq.com\",\"gender\":1,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,14,1,10000,'超级管理员',NULL,10000,'2026-11-03 23:03:54'),(70,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":\"https://oss.mlh.jucheng.icu/logo.png\",\"email\":\"960681673@qq.com\",\"gender\":2,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,13,1,10000,'超级管理员',NULL,10000,'2026-11-03 23:03:54'),(71,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":\"https://oss.mlh.jucheng.icu/logo.png\",\"email\":\"960681673@qq.com\",\"gender\":0,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,12,1,10000,'超级管理员',NULL,10000,'2026-11-03 23:03:54'),(72,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":\"https://oss.mlh.jucheng.icu/logo.png\",\"email\":\"960681673@qq.com\",\"gender\":2,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,10,1,10000,'超级管理员',NULL,10000,'2026-11-03 23:03:54'),(73,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":\"https://oss.mlh.jucheng.icu/logo.png\",\"email\":\"960681673@qq.com\",\"gender\":1,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,14,1,10000,'超级管理员',NULL,10000,'2026-11-03 23:05:04'),(74,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":\"https://oss.mlh.jucheng.icu/logo.png\",\"email\":\"960681673@qq.com\",\"gender\":2,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,18,1,10000,'超级管理员',NULL,10000,'2026-11-03 23:05:04'),(75,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":\"https://oss.mlh.jucheng.icu/logo.png\",\"email\":\"960681673@qq.com\",\"gender\":0,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,15,1,10000,'超级管理员',NULL,10000,'2026-11-03 23:05:04'),(76,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":null,\"email\":\"960681673@qq.com\",\"gender\":2,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,18,1,10000,'超级管理员',NULL,10000,'2026-11-03 23:05:24'),(77,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":null,\"email\":\"960681673@qq.com\",\"gender\":1,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,13,1,10000,'超级管理员',NULL,10000,'2026-11-03 23:05:24'),(78,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":\"https://oss.mlh.jucheng.icu/logo.png\",\"email\":\"960681673@qq.com\",\"gender\":2,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,12,1,10000,'超级管理员',NULL,10000,'2026-11-03 23:05:34'),(79,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":\"https://oss.mlh.jucheng.icu/logo.png\",\"email\":\"960681673@qq.com\",\"gender\":1,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,16,1,10000,'超级管理员',NULL,10000,'2026-11-03 23:05:34'),(80,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":\"https://oss.mlh.jucheng.icu/logo.png\",\"email\":\"960681673@qq.com\",\"gender\":2,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,11,1,10000,'超级管理员',NULL,10000,'2026-11-03 23:05:44'),(81,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":\"https://oss.mlh.jucheng.icu/logo.png\",\"email\":\"960681673@qq.com\",\"gender\":0,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,11,1,10000,'超级管理员',NULL,10000,'2026-11-03 23:05:44'),(82,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":\"https://oss.mlh.jucheng.icu/logo.png\",\"email\":\"960681673@qq.com\",\"gender\":2,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,12,1,10000,'超级管理员',NULL,10000,'2026-11-04 00:07:55'),(83,'用户管理','下线指定登录设备','/sys/user/device/2b9f891caf424d22915c5eccd0d7f1ad','DELETE','{\"accessToken\":\"2b9f891caf424d22915c5eccd0d7f1ad\",\"request\":\"[ignore]\"}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,10,1,10000,'超级管理员',NULL,10000,'2026-11-04 01:31:35'),(84,'用户管理','保存当前用户多设备登录设置','/sys/user/login-security','PUT','{\"vo\":{\"effectiveMultiDeviceLogin\":null,\"effectiveMultiDeviceMax\":null,\"multiDeviceLogin\":null,\"multiDeviceMax\":null,\"systemMultiDeviceLogin\":null,\"systemMultiDeviceMax\":null}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,7,1,10000,'超级管理员',NULL,10000,'2026-11-04 02:20:56'),(85,'用户管理','下线指定登录设备','/sys/user/device/fd01a25b351b4103ad302df07f818127','DELETE','{\"accessToken\":\"fd01a25b351b4103ad302df07f818127\",\"request\":\"[ignore]\"}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,13,1,10000,'超级管理员',NULL,10000,'2026-11-04 02:20:56'),(86,'用户管理','下线指定登录设备','/sys/user/device/05a750a2ec7649c782b828ecff3d24b8','DELETE','{\"accessToken\":\"05a750a2ec7649c782b828ecff3d24b8\",\"request\":\"[ignore]\"}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,11,1,10000,'超级管理员',NULL,10000,'2026-11-04 03:31:47'),(87,'用户管理','下线指定登录设备','/sys/user/device/7e07750482d8497483cf9f022e29edd4','DELETE','{\"accessToken\":\"7e07750482d8497483cf9f022e29edd4\",\"request\":\"[ignore]\"}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1',3,9,1,10000,'超级管理员',NULL,10000,'2026-11-04 03:31:47'),(88,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"block_puzzle\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"pattern\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,84,1,10000,'超级管理员',NULL,10000,'2026-11-04 04:23:10'),(89,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"pattern\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"pattern\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,71,1,10000,'超级管理员',NULL,10000,'2026-11-04 04:30:00'),(90,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"spec\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"pattern\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,55,1,10000,'超级管理员',NULL,10000,'2026-11-04 04:30:10'),(91,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"click_word\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"pattern\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,39,1,10000,'超级管理员',NULL,10000,'2026-11-04 04:56:20'),(92,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"curve\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"pattern\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,21,1,10000,'超级管理员',NULL,10000,'2026-11-04 04:56:40'),(93,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"arithmetic\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"pattern\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,29,1,10000,'超级管理员',NULL,10000,'2026-11-04 05:01:00'),(94,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"curve\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"pattern\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,15,1,10000,'超级管理员',NULL,10000,'2026-11-04 05:05:10'),(95,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"curve\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"pattern\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,14,1,10000,'超级管理员',NULL,10000,'2026-11-04 05:06:40'),(96,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"rotate\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"pattern\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,18,1,10000,'超级管理员',NULL,10000,'2026-11-04 05:16:10'),(97,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"rotate\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"pattern\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,22,1,10000,'超级管理员',NULL,10000,'2026-11-04 05:19:04'),(98,'验证码配置','保存分端验证码配置','/sys/captcha/config','PUT','{\"vo\":{\"appType\":\"curve\",\"enabled\":true,\"mobileType\":\"spec\",\"pcType\":\"pattern\",\"powDifficulty\":3,\"smsType\":\"spec\",\"turnstileSecretKey\":\"16676607452qwer.\",\"turnstileSiteKey\":\"16676607452\",\"typeOptions\":[]}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/156.0.0.0 Safari/537.36 Edg/156.0.0.0',3,42,1,10000,'超级管理员',NULL,10000,'2026-11-04 05:30:21'),(99,'用户管理','下线指定登录设备','/sys/user/device/50c3189c8990406499c1dc627b999763','DELETE','{\"accessToken\":\"50c3189c8990406499c1dc627b999763\",\"request\":\"[ignore]\"}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 17_0_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0.1 Mobile/21A360 Safari/604.1 wechatdevtools/2.01.2510250 MicroMessenger/8.0.5 Language/zh_CN webview/ hash/70138262 sid/lqOcRCzsai',3,18,1,10000,'超级管理员',NULL,10000,'2026-11-05 03:09:52'),(100,'文件上传','上传','/sys/file/upload','POST','{\"file\":\"[ignore]\"}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 17_0_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0.1 Mobile/21A360 Safari/604.1 wechatdevtools/2.01.2510250 MicroMessenger/8.0.5 Language/zh_CN webview/',2,174,1,10000,'超级管理员',NULL,10000,'2026-11-05 03:43:23'),(101,'用户管理','修改登录用户头像','/sys/user/avatar','PUT','{\"avatar\":{\"avatar\":\"http://localhost:8080/upload/20261105/omEG1bJp3ruQ8c8932f64b039a9963936b4da238ab7e_13393.png\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 17_0_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0.1 Mobile/21A360 Safari/604.1 wechatdevtools/2.01.2510250 MicroMessenger/8.0.5 Language/zh_CN webview/ hash/70138262 sid/lqOcRCzsai',3,15,1,10000,'超级管理员',NULL,10000,'2026-11-05 03:43:23'),(102,'文件上传','上传','/sys/file/upload','POST','{\"file\":\"[ignore]\"}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 17_0_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0.1 Mobile/21A360 Safari/604.1 wechatdevtools/2.01.2510250 MicroMessenger/8.0.5 Language/zh_CN webview/',2,10,1,10000,'超级管理员',NULL,10000,'2026-11-05 03:43:23'),(103,'用户管理','修改登录用户头像','/sys/user/avatar','PUT','{\"avatar\":{\"avatar\":\"http://localhost:8080/upload/20261105/T4FbsRzGaDY1d4d014afa827fd74abb80afde503c759_13401.png\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 17_0_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0.1 Mobile/21A360 Safari/604.1 wechatdevtools/2.01.2510250 MicroMessenger/8.0.5 Language/zh_CN webview/ hash/70138262 sid/lqOcRCzsai',3,9,1,10000,'超级管理员',NULL,10000,'2026-11-05 03:43:23'),(104,'文件上传','上传','/sys/file/upload','POST','{\"file\":\"[ignore]\"}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 17_0_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0.1 Mobile/21A360 Safari/604.1 wechatdevtools/2.01.2510250 MicroMessenger/8.0.5 Language/zh_CN webview/',2,10,1,10000,'超级管理员',NULL,10000,'2026-11-05 03:49:13'),(105,'用户管理','修改登录用户头像','/sys/user/avatar','PUT','{\"avatar\":{\"avatar\":\"http://localhost:8080/upload/20261105/UHWsq_i5IGGR93f054954bd11d1fe1365ca3907dbfd3_13747.png\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 17_0_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0.1 Mobile/21A360 Safari/604.1 wechatdevtools/2.01.2510250 MicroMessenger/8.0.5 Language/zh_CN webview/ hash/70138262 sid/lqOcRCzsai',3,8,1,10000,'超级管理员',NULL,10000,'2026-11-05 03:49:13'),(106,'用户管理','修改登录用户信息','/sys/user/info','PUT','{\"vo\":{\"avatar\":\"http://localhost:8080/upload/20261105/UHWsq_i5IGGR93f054954bd11d1fe1365ca3907dbfd3_13747.png\",\"email\":\"960681673@qq.com\",\"gender\":1,\"mobile\":\"13800138000\",\"realName\":\"超级管理员\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 17_0_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0.1 Mobile/21A360 Safari/604.1 wechatdevtools/2.01.2510250 MicroMessenger/8.0.5 Language/zh_CN webview/ hash/70138262 sid/lqOcRCzsai',3,20,1,10000,'超级管理员',NULL,10000,'2026-11-05 03:49:13'),(107,'工作台记事','保存记事','/sys/workbench/note','POST','{\"vo\":{\"content\":\"14：00更新系统\",\"createTime\":null,\"id\":null,\"noteDate\":\"2026-11-05\",\"noteType\":\"remind\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 17_0_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0.1 Mobile/21A360 Safari/604.1 wechatdevtools/2.01.2510250 MicroMessenger/8.0.5 Language/zh_CN webview/ hash/70138262 sid/lqOcRCzsai',2,11,1,10000,'超级管理员',NULL,10000,'2026-11-05 04:06:43'),(108,'工作台记事','保存记事','/sys/workbench/note','POST','{\"vo\":{\"content\":\"更新用户信息\",\"createTime\":null,\"id\":null,\"noteDate\":\"2026-11-06\",\"noteType\":\"memo\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 17_0_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0.1 Mobile/21A360 Safari/604.1 wechatdevtools/2.01.2510250 MicroMessenger/8.0.5 Language/zh_CN webview/ hash/70138262 sid/lqOcRCzsai',2,8,1,10000,'超级管理员',NULL,10000,'2026-11-05 04:11:13'),(109,'工作台记事','保存记事','/sys/workbench/note','POST','{\"vo\":{\"content\":\"更新机构信息\",\"createTime\":null,\"id\":null,\"noteDate\":\"2026-11-06\",\"noteType\":\"remind\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 17_0_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0.1 Mobile/21A360 Safari/604.1 wechatdevtools/2.01.2510250 MicroMessenger/8.0.5 Language/zh_CN webview/ hash/70138262 sid/lqOcRCzsai',2,7,1,10000,'超级管理员',NULL,10000,'2026-11-05 04:11:23'),(110,'工作台记事','保存记事','/sys/workbench/note','POST','{\"vo\":{\"content\":\"更新\",\"createTime\":null,\"id\":null,\"noteDate\":\"2026-11-06\",\"noteType\":\"nudge\"}}','127.0.0.1','内网IP','Mozilla/5.0 (iPhone; CPU iPhone OS 17_0_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0.1 Mobile/21A360 Safari/604.1 wechatdevtools/2.01.2510250 MicroMessenger/8.0.5 Language/zh_CN webview/ hash/70138262 sid/lqOcRCzsai',2,9,1,10000,'超级管理员',NULL,10000,'2026-11-05 04:32:44'),(111,'即时通讯','创建群聊','/sys/chat/conversation/group','POST','{\"vo\":{\"avatar\":null,\"memberIds\":[10001,10002,10003,10004],\"title\":\"研发总部\"}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36 Edg/157.0.0.0',2,76,1,10000,'超级管理员',NULL,10000,'2026-11-10 13:59:07'),(112,'即时通讯','发起单聊','/sys/chat/conversation/direct','POST','{\"vo\":{\"userId\":10001}}','127.0.0.1','内网IP','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/157.0.0.0 Safari/537.36 Edg/157.0.0.0',2,39,1,10000,'超级管理员',NULL,10000,'2026-11-10 14:04:27');

/*!40000 ALTER TABLE `sys_log_operate` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_mail_config`

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

-- Dumping data for table `sys_mail_config`

--



LOCK TABLES `sys_mail_config` WRITE;

/*!40000 ALTER TABLE `sys_mail_config` DISABLE KEYS */;

INSERT INTO `sys_mail_config` (`id`, `platform`, `group_name`, `mail_host`, `mail_port`, `mail_from`, `mail_pass`, `region_id`, `endpoint`, `access_key`, `secret_key`, `status`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES
(1, -1, 'test', NULL, NULL, 'baba_tv@163.com', '', '', '', '', '', 1, 1, 0, 10000, '2026-10-28 05:12:20', 10000, '2026-10-28 05:12:20');


/*!40000 ALTER TABLE `sys_mail_config` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_mail_log`

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

-- Dumping data for table `sys_mail_log`

--



LOCK TABLES `sys_mail_log` WRITE;

/*!40000 ALTER TABLE `sys_mail_log` DISABLE KEYS */;

/*!40000 ALTER TABLE `sys_mail_log` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_menu`

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

  `client_type` tinyint NOT NULL DEFAULT '0' COMMENT '客户端 0PC 1APP 2小程序',

  `open_style` tinyint DEFAULT NULL COMMENT '打开方式   0：内部   1：外部',

  `icon` varchar(255) DEFAULT NULL COMMENT '菜单图标',

  `sort` int DEFAULT NULL COMMENT '排序',

  `version` int DEFAULT NULL COMMENT '版本号',

  `deleted` tinyint DEFAULT NULL COMMENT '删除标识  0：正常   1：已删除',

  `creator` bigint DEFAULT NULL COMMENT '创建者',

  `create_time` datetime DEFAULT NULL COMMENT '创建时间',

  `updater` bigint DEFAULT NULL COMMENT '更新者',

  `update_time` datetime DEFAULT NULL COMMENT '更新时间',

  PRIMARY KEY (`id`),

  KEY `idx_menu_pid` (`pid`)

) ENGINE=InnoDB AUTO_INCREMENT=409 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='菜单管理';

/*!40101 SET character_set_client = @saved_cs_client */;



--

-- Dumping data for table `sys_menu`

--



LOCK TABLES `sys_menu` WRITE;

/*!40000 ALTER TABLE `sys_menu` DISABLE KEYS */;

INSERT INTO `sys_menu` (`id`, `pid`, `name`, `url`, `authority`, `type`, `client_type`, `open_style`, `icon`, `sort`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,NULL,'系统管理',NULL,NULL,0,0,0,'icon-setting',2,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(2,1,'菜单管理','sys/menu/index',NULL,0,0,0,'icon-menu',1,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(3,2,'查看','','sys:menu:list',1,0,0,'',0,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(4,2,'新增','','sys:menu:save',1,0,0,'',1,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(5,2,'修改','','sys:menu:update,sys:menu:info',1,0,0,'',2,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(6,2,'删除','','sys:menu:delete',1,0,0,'',3,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(7,1,'数据字典','sys/dict/type','',0,0,0,'icon-book',2,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(8,7,'查询','','sys:dict:page',1,0,0,'',0,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(9,7,'新增','','sys:dict:save',1,0,0,'',2,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(10,7,'修改','','sys:dict:update,sys:dict:info',1,0,0,'',1,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(11,7,'删除','','sys:dict:delete',1,0,0,'',3,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(12,NULL,'组织权限','','',0,0,0,'icon-apartment',1,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(13,12,'岗位管理','sys/post/index','',0,0,0,'icon-post',4,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(14,13,'查询','','sys:post:page',1,0,0,'',0,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(15,13,'新增','','sys:post:save',1,0,0,'',1,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(16,13,'修改','','sys:post:update,sys:post:info',1,0,0,'',2,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(17,13,'删除','','sys:post:delete',1,0,0,'',3,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(18,12,'机构管理','sys/org/index','',0,0,0,'icon-org',3,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(19,18,'查询','','sys:org:list',1,0,0,'',0,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(20,18,'新增','','sys:org:save',1,0,0,'',1,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(21,18,'修改','','sys:org:update,sys:org:info',1,0,0,'',2,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(22,18,'删除','','sys:org:delete',1,0,0,'',3,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(23,12,'角色管理','sys/role/index','',0,0,0,'icon-team',2,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(24,23,'查询','','sys:role:page',1,0,0,'',0,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(25,23,'新增','','sys:role:save,sys:role:menu,sys:org:list',1,0,0,'',1,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(26,23,'修改','','sys:role:update,sys:role:info,sys:role:menu,sys:org:list,sys:user:page',1,0,0,'',2,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(27,23,'删除','','sys:role:delete',1,0,0,'',3,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(28,12,'用户管理','sys/user/index','',0,0,0,'icon-user',1,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(29,28,'查询','','sys:user:page',1,0,0,'',0,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(30,28,'新增','','sys:user:save,sys:role:list',1,0,0,'',1,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(31,28,'修改','','sys:user:update,sys:user:info,sys:role:list',1,0,0,'',2,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(32,28,'删除','','sys:user:delete',1,0,0,'',3,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(33,NULL,'开发工具','','',0,0,0,'icon-codelibrary',4,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(34,NULL,'运维中心','','',0,0,0,'icon-monitor',3,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(35,34,'登录日志','sys/log/login','sys:log:login',0,0,0,'icon-login',1,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(36,28,'导入','','sys:user:import',1,0,0,'',5,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(37,28,'导出','','sys:user:export',1,0,0,'',6,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(38,1,'参数管理','sys/params/index','sys:params:all',0,0,0,'icon-control',3,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(39,33,'接口文档','{{apiUrl}}/doc.html',NULL,0,0,1,'icon-api',2,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(40,34,'操作日志','sys/log/operate','sys:operate:all',0,0,0,'icon-file-text',2,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(41,1,'系统配置','sys/config/index',NULL,0,0,0,'icon-sliders',4,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(42,41,'短信配置','','sys:sms:config',1,0,0,'',0,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(43,41,'邮件配置','','sys:mail:config',1,0,0,'',1,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(44,41,'第三方登录','','sys:third:config',1,0,0,'',2,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(45,NULL,'基础工具','','',0,0,0,'icon-wrench-fill',5,0,1,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(46,33,'短信发送','sys/tool/sms/index','sys:sms:log',0,0,0,'icon-message',3,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(47,33,'邮件发送','sys/tool/mail/index','sys:mail:log',0,0,0,'icon-mail',4,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(48,33,'附件管理','sys/attachment/index',NULL,0,0,0,'icon-folder-fill',5,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-30 05:39:43'),(49,48,'查看','','sys:attachment:page',1,0,0,'',0,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(50,48,'上传','','sys:attachment:save',1,0,0,'',1,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(51,48,'删除','','sys:attachment:delete',1,0,0,'',1,0,0,10000,'2026-10-28 05:12:20',10000,'2026-10-28 05:12:20'),(53,33,'代码生成器','{{apiUrl}}/maku-generator/index.html','',0,0,0,'icon-rocket',1,0,0,10000,'2026-10-28 05:12:36',10000,'2026-10-30 05:39:43'),(54,NULL,'物联网平台',NULL,NULL,0,0,0,'icon-deploymentunit',5,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-30 05:39:43'),(55,54,'设备列表','iot/device/index',NULL,0,0,0,'icon-laptop',1,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-30 05:39:43'),(56,55,'查看','','iot:device:page',1,0,0,'',0,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(57,55,'新增','','iot:device:save',1,0,0,'',1,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(58,55,'修改','','iot:device:update,iot:device:info',1,0,0,'',2,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(59,55,'删除','','iot:device:delete',1,0,0,'',3,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(60,55,'下发指令','','iot:device:send',1,0,0,'',4,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(61,55,'上报数据','','iot:device:report',1,0,0,'',5,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(62,55,'设备事件日志','','iot:device_event_log:page',1,0,0,'',5,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(63,55,'设备服务日志','','iot:device_service_log:page',1,0,0,'',5,0,0,10000,'2026-10-28 05:13:35',10000,'2026-10-28 05:13:35'),(64,34,'系统监控','','',0,0,0,'icon-dashboard',4,0,0,10000,'2026-10-28 05:13:54',10000,'2026-10-30 05:39:43'),(65,64,'服务监控','monitor/server/index','monitor:server:all',0,0,0,'icon-sever',1,0,0,10000,'2026-10-28 05:13:54',10000,'2026-10-30 05:39:43'),(66,64,'缓存监控','monitor/cache/index','monitor:cache:all',0,0,0,'icon-cloud-server',2,0,0,10000,'2026-10-28 05:13:54',10000,'2026-10-30 05:39:43'),(67,64,'在线用户','monitor/user/index','monitor:user:all',0,0,0,'icon-team',3,0,0,10000,'2026-10-28 05:13:54',10000,'2026-10-30 05:39:43'),(68,34,'定时任务','quartz/schedule/index',NULL,0,0,0,'icon-reloadtime',3,0,0,10000,'2026-10-28 05:14:01',10000,'2026-10-30 05:39:43'),(69,68,'查看','','schedule:page',1,0,0,'',0,0,0,10000,'2026-10-28 05:14:01',10000,'2026-10-28 05:14:01'),(70,68,'新增','','schedule:save',1,0,0,'',1,0,0,10000,'2026-10-28 05:14:01',10000,'2026-10-28 05:14:01'),(71,68,'修改','','schedule:update,schedule:info',1,0,0,'',2,0,0,10000,'2026-10-28 05:14:01',10000,'2026-10-28 05:14:01'),(72,68,'删除','','schedule:delete',1,0,0,'',3,0,0,10000,'2026-10-28 05:14:01',10000,'2026-10-28 05:14:01'),(73,68,'立即运行','','schedule:run',1,0,0,'',2,0,0,10000,'2026-10-28 05:14:01',10000,'2026-10-28 05:14:01'),(74,68,'日志','','schedule:log',1,0,0,'',4,0,0,10000,'2026-10-28 05:14:01',10000,'2026-10-28 05:14:01'),(75,1,'AI助手','sys/config/ai/index','sys:ai:config',0,0,0,'icon-robot',5,0,0,10000,'2026-10-29 16:59:32',10000,'2026-10-30 05:39:43'),(76,1,'消息管理','sys/message/index',NULL,0,0,0,'icon-message-fill',6,0,0,10000,'2026-11-01 17:22:04',10000,'2026-11-01 17:22:04'),(77,76,'查询','','sys:message:page',1,0,0,'',0,0,0,10000,'2026-11-01 17:22:04',10000,'2026-11-01 17:22:04'),(78,76,'发送','','sys:message:save',1,0,0,'',1,0,0,10000,'2026-11-01 17:22:04',10000,'2026-11-01 17:22:04'),(79,76,'详情','','sys:message:info',1,0,0,'',2,0,0,10000,'2026-11-01 17:22:04',10000,'2026-11-01 17:22:04'),(80,76,'删除','','sys:message:delete',1,0,0,'',3,0,0,10000,'2026-11-01 17:22:04',10000,'2026-11-01 17:22:04'),(81,1,'验证码配置','sys/config/captcha/index','sys:captcha:config',0,0,0,'icon-safetycertificate',8,0,0,10000,'2026-11-02 03:14:46',10000,'2026-11-02 03:17:16'),(82,1,'登录安全','sys/config/login-security/index','sys:login:security',0,0,0,'icon-insurance-fill',7,0,0,10000,'2026-11-03 04:44:23',10000,'2026-11-03 04:57:27'),(200,NULL,'APP工作台',NULL,NULL,0,1,0,'icon-appstore',0,0,0,10000,'2026-11-06 20:33:50',10000,'2026-11-06 20:33:50'),(201,200,'用户管理','/pages/sys/user/index',NULL,0,1,0,'/static/icons/user.svg',1,0,0,10000,'2026-11-06 20:33:50',10000,'2026-11-06 20:33:50'),(202,200,'我的消息','/pages/message/inbox',NULL,0,1,0,'/static/icons/msg.svg',2,0,0,10000,'2026-11-06 20:33:50',10000,'2026-11-06 20:33:50'),(203,200,'小冰助手','/pages/assistant/chat',NULL,0,1,0,'/static/mascot/xiaobing-head.png',3,0,0,10000,'2026-11-06 20:33:50',10000,'2026-11-06 20:33:50'),(204,200,'个人资料','/pages/usercenter/userinfo/userinfo',NULL,0,1,0,'/static/icons/profile.svg',4,0,0,10000,'2026-11-06 20:33:50',10000,'2026-11-06 20:33:50'),(300,NULL,'小程序工作台',NULL,NULL,0,2,0,'icon-mobile',0,0,0,10000,'2026-11-06 20:33:50',10000,'2026-11-06 20:33:50'),(301,300,'用户管理','/pages/sys/user/index',NULL,0,2,0,'/images/icons/user.svg',1,0,0,10000,'2026-11-06 20:33:50',10000,'2026-11-06 20:33:50'),(302,300,'我的消息','/pages/message/inbox',NULL,0,2,0,'/images/icons/msg.svg',2,0,0,10000,'2026-11-06 20:33:50',10000,'2026-11-06 20:33:50'),(303,300,'小冰助手','/pages/assistant/chat',NULL,0,2,0,'/images/mascot/xiaobing-head.png',3,0,0,10000,'2026-11-06 20:33:50',10000,'2026-11-06 20:33:50'),(304,300,'个人资料','/pages/usercenter/userinfo/userinfo',NULL,0,2,0,'/images/icons/profile.svg',4,0,0,10000,'2026-11-06 20:33:50',10000,'2026-11-06 20:33:50'),(400,NULL,'即时通讯','sys/chat/index',NULL,0,0,0,'icon-message',0,0,0,10000,'2026-11-06 21:27:07',10000,'2026-11-06 21:27:07'),(401,400,'进入聊天','','sys:chat:page',1,0,0,'',0,0,0,10000,'2026-11-06 21:27:07',10000,'2026-11-06 21:27:07'),(402,400,'发起单聊','','sys:chat:direct',1,0,0,'',1,0,0,10000,'2026-11-06 21:27:07',10000,'2026-11-06 21:27:07'),(403,400,'创建群聊','','sys:chat:group',1,0,0,'',2,0,0,10000,'2026-11-06 21:27:07',10000,'2026-11-06 21:27:07'),(404,400,'会话管控','','sys:chat:manage',1,0,0,'',3,0,0,10000,'2026-11-06 21:27:07',10000,'2026-11-06 21:27:07'),(405,400,'发送文件','','sys:chat:file',1,0,0,'',4,0,0,10000,'2026-11-06 21:27:07',10000,'2026-11-06 21:27:07'),(406,400,'聊天权限','sys/chat/allow',NULL,0,0,0,'icon-safetycertificate',5,0,0,10000,'2026-11-10 14:09:04',10000,'2026-11-10 14:09:04'),(407,406,'查看','','sys:chat:acl',1,0,0,'',0,0,0,10000,'2026-11-10 14:09:04',10000,'2026-11-10 14:09:04'),(408,406,'配置','','sys:chat:acl',1,0,0,'',1,0,0,10000,'2026-11-10 14:09:04',10000,'2026-11-10 14:09:04');

/*!40000 ALTER TABLE `sys_menu` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_message`

--



DROP TABLE IF EXISTS `sys_message`;

/*!40101 SET @saved_cs_client     = @@character_set_client */;

/*!50503 SET character_set_client = utf8mb4 */;

CREATE TABLE `sys_message` (

  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',

  `title` varchar(200) DEFAULT NULL COMMENT 'title',

  `content` varchar(4000) DEFAULT NULL COMMENT 'content',

  `type` tinyint DEFAULT NULL COMMENT 'type',

  `receiver_type` tinyint DEFAULT NULL COMMENT 'receiver_type',

  `sender_id` bigint DEFAULT NULL COMMENT 'sender_id',

  `sender_name` varchar(100) DEFAULT NULL COMMENT 'sender_name',

  `status` tinyint DEFAULT NULL COMMENT 'status',

  `send_time` datetime DEFAULT NULL COMMENT 'send_time',

  `tenant_id` bigint DEFAULT NULL COMMENT 'tenant_id',

  `version` int DEFAULT NULL COMMENT 'version',

  `deleted` tinyint DEFAULT NULL COMMENT 'deleted',

  `creator` bigint DEFAULT NULL COMMENT 'creator',

  `create_time` datetime DEFAULT NULL COMMENT 'create_time',

  `updater` bigint DEFAULT NULL COMMENT 'updater',

  `update_time` datetime DEFAULT NULL COMMENT 'update_time',

  PRIMARY KEY (`id`),

  KEY `idx_status_send` (`status`,`send_time`)

) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='sys_message';

/*!40101 SET character_set_client = @saved_cs_client */;



--

-- Dumping data for table `sys_message`

--



LOCK TABLES `sys_message` WRITE;

/*!40000 ALTER TABLE `sys_message` DISABLE KEYS */;

INSERT INTO `sys_message` (`id`, `title`, `content`, `type`, `receiver_type`, `sender_id`, `sender_name`, `status`, `send_time`, `tenant_id`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,'欢迎使用 ICEJZ 消息中心','你好！站内消息系统已启用。你可以在「系统管理 - 消息管理」发送通知/公告/私信，用户可在「我的消息」与顶部铃铛查看未读。',0,0,10000,'超级管理员',1,'2026-11-01 17:22:30',10000,0,0,10000,'2026-11-01 17:22:30',10000,'2026-11-01 17:22:30'),(2,'账号封禁通知','您的账号已被管理员封禁。\n封禁时长：2026-11-03 06:21:40.067709400\n封禁期间将无法登录系统，如有疑问请联系管理员。',0,1,10000,'超级管理员',1,'2026-11-03 06:16:40',10000,0,0,10000,'2026-11-03 06:16:40',10000,'2026-11-03 06:16:40'),(3,'账号解封通知','您的账号已解除封禁，可重新登录使用。',0,1,10000,'超级管理员',1,'2026-11-03 06:23:01',10000,0,0,10000,'2026-11-03 06:23:01',10000,'2026-11-03 06:23:01'),(4,'账号封禁通知','您的账号已被管理员封禁。\n封禁时长：2026-11-03 06:28:24.704994\n封禁期间将无法登录系统，如有疑问请联系管理员。',0,1,10000,'超级管理员',1,'2026-11-03 06:23:25',10000,0,0,10000,'2026-11-03 06:23:25',10000,'2026-11-03 06:23:25');

/*!40000 ALTER TABLE `sys_message` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_message_user`

--



DROP TABLE IF EXISTS `sys_message_user`;

/*!40101 SET @saved_cs_client     = @@character_set_client */;

/*!50503 SET character_set_client = utf8mb4 */;

CREATE TABLE `sys_message_user` (

  `id` bigint NOT NULL AUTO_INCREMENT COMMENT 'id',

  `message_id` bigint DEFAULT NULL COMMENT 'message_id',

  `receiver_id` bigint DEFAULT NULL COMMENT 'receiver_id',

  `receiver_name` varchar(100) DEFAULT NULL COMMENT 'receiver_name',

  `read_status` tinyint DEFAULT NULL COMMENT 'read_status',

  `read_time` datetime DEFAULT NULL COMMENT 'read_time',

  `version` int DEFAULT NULL COMMENT 'version',

  `deleted` tinyint DEFAULT NULL COMMENT 'deleted',

  `creator` bigint DEFAULT NULL COMMENT 'creator',

  `create_time` datetime DEFAULT NULL COMMENT 'create_time',

  `updater` bigint DEFAULT NULL COMMENT 'updater',

  `update_time` datetime DEFAULT NULL COMMENT 'update_time',

  PRIMARY KEY (`id`),

  KEY `idx_receiver_read` (`receiver_id`,`read_status`),

  KEY `idx_message` (`message_id`)

) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='sys_message_user';

/*!40101 SET character_set_client = @saved_cs_client */;



--

-- Dumping data for table `sys_message_user`

--



LOCK TABLES `sys_message_user` WRITE;

/*!40000 ALTER TABLE `sys_message_user` DISABLE KEYS */;

INSERT INTO `sys_message_user` (`id`, `message_id`, `receiver_id`, `receiver_name`, `read_status`, `read_time`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,1,10000,'超级管理员',1,'2026-11-01 17:30:29',1,0,10000,'2026-11-01 17:22:48',10000,'2026-11-01 17:30:29'),(2,1,10001,'陈凯',1,'2026-11-03 06:23:12',1,0,10000,'2026-11-01 17:22:48',10001,'2026-11-03 06:23:12'),(3,1,10002,'林悦',0,NULL,0,0,10000,'2026-11-01 17:22:48',10000,'2026-11-01 17:22:48'),(4,1,10003,'周琪',0,NULL,0,0,10000,'2026-11-01 17:22:48',10000,'2026-11-01 17:22:48'),(5,1,10004,'孙浩',0,NULL,0,0,10000,'2026-11-01 17:22:48',10000,'2026-11-01 17:22:48'),(6,1,10005,'万宁',0,NULL,0,0,10000,'2026-11-01 17:22:48',10000,'2026-11-01 17:22:48'),(7,1,10006,'何佳',0,NULL,0,0,10000,'2026-11-01 17:22:48',10000,'2026-11-01 17:22:48'),(8,2,10001,'陈凯',1,'2026-11-03 06:23:12',1,0,10000,'2026-11-03 06:16:40',10001,'2026-11-03 06:23:12'),(9,3,10001,'陈凯',1,'2026-11-03 06:23:12',1,0,10000,'2026-11-03 06:23:01',10001,'2026-11-03 06:23:12'),(10,4,10001,'陈凯',0,NULL,0,0,10000,'2026-11-03 06:23:25',10000,'2026-11-03 06:23:25');

/*!40000 ALTER TABLE `sys_message_user` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_org`

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

-- Dumping data for table `sys_org`

--



LOCK TABLES `sys_org` WRITE;

/*!40000 ALTER TABLE `sys_org` DISABLE KEYS */;

INSERT INTO `sys_org` (`id`, `pid`, `name`, `sort`, `leader_id`, `tenant_id`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,NULL,'ICEJZ 总部',1,10000,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(2,1,'研发中心',1,10001,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(3,1,'运维中心',2,10005,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(4,1,'产品中心',3,10006,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(5,2,'平台研发组',1,10001,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(6,2,'物联网研发组',2,10001,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27');

/*!40000 ALTER TABLE `sys_org` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_params`

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

) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='参数管理';

/*!40101 SET character_set_client = @saved_cs_client */;



--

-- Dumping data for table `sys_params`

--



LOCK TABLES `sys_params` WRITE;

/*!40000 ALTER TABLE `sys_params` DISABLE KEYS */;

INSERT INTO `sys_params` (`id`, `param_name`, `param_type`, `param_key`, `param_value`, `remark`, `tenant_id`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES
(1, '用户登录-验证码开关', 1, 'LOGIN_CAPTCHA', 'true', '是否开启账号登录图形验证码（true：开启，false：关闭）', 10000, 24, 0, 10000, '2026-10-28 05:12:20', 10000, '2026-11-04 04:30:10'),
(2, 'AI机器人名称', 1, 'AI_ROBOT_NAME', '小冰', 'ICEJZ IP 助手名称', 10000, 0, 0, 10000, '2026-10-29 16:59:37', 10000, '2026-10-29 16:59:37'),
(3, 'AI机器人欢迎语', 1, 'AI_ROBOT_WELCOME', '你好，我是 ICEJZ 小冰，有什么可以帮你的？', '助手欢迎语', 10000, 0, 0, 10000, '2026-10-29 16:59:37', 10000, '2026-10-29 16:59:37'),
(4, 'AI机器人开关', 1, 'AI_ROBOT_ENABLED', 'true', '是否启用助手入口', 10000, 0, 0, 10000, '2026-10-29 16:59:37', 10000, '2026-10-29 16:59:37'),
(5, '用户登录-验证码类型(默认)', 1, 'LOGIN_CAPTCHA_TYPE', 'pattern', '兼容旧配置；分端未配置时回退', 10000, 24, 0, 10000, '2026-10-31 00:25:41', 10000, '2026-11-04 04:30:10'),
(6, 'Turnstile站点公钥', 1, 'TURNSTILE_SITE_KEY', '16676607452', 'Cloudflare Turnstile Site Key', 10000, 24, 0, 10000, '2026-10-31 16:54:20', 10000, '2026-11-04 04:30:10'),
(7, 'Turnstile密钥', 1, 'TURNSTILE_SECRET_KEY', '', 'Cloudflare Turnstile Secret Key', 10000, 24, 0, 10000, '2026-10-31 16:54:21', 10000, '2026-11-04 04:30:10'),
(8, 'PoW验证码难度', 1, 'CAPTCHA_POW_DIFFICULTY', '3', 'PoW 前导0个数，建议2~4，越大越慢', 10000, 24, 0, 10000, '2026-10-31 16:54:22', 10000, '2026-11-04 04:30:10'),
(9, '短信发送最小间隔秒', 1, 'SMS_CODE_INTERVAL_SECONDS', '60', '同一手机号两次发短信的最小间隔（秒）', 10000, 0, 0, 10000, '2026-10-31 16:54:24', 10000, '2026-10-31 16:54:24'),
(10, '短信每小时发送上限', 1, 'SMS_CODE_HOUR_LIMIT', '10', '同一手机号每小时最多发送次数', 10000, 0, 0, 10000, '2026-10-31 16:54:24', 10000, '2026-10-31 16:54:24'),
(11, 'PC管理端-账号登录验证码类型', 1, 'LOGIN_CAPTCHA_TYPE_PC', 'pattern', 'PC 管理端账号登录使用的验证码类型', 10000, 24, 0, 10000, '2026-11-02 03:14:46', 10000, '2026-11-04 04:30:10'),
(12, '移动端登录验证码类型', 1, 'LOGIN_CAPTCHA_TYPE_APP', 'spec', 'App / 小程序 / H5 登录使用的验证码类型', 10000, 24, 0, 10000, '2026-11-02 03:14:46', 10000, '2026-11-04 04:30:10'),
(13, '短信发送-图形验证码类型', 1, 'LOGIN_CAPTCHA_TYPE_SMS', 'spec', 'PC/App 发短信前图形验证码类型', 10000, 24, 0, 10000, '2026-11-02 03:14:46', 10000, '2026-11-04 04:30:10'),
(14, '多设备登录开关', 1, 'MULTI_DEVICE_LOGIN', 'true', '是否允许多设备同时登录（true：多设备；false：单设备互踢）', 10000, 2, 0, 10000, '2026-11-03 04:44:20', 10000, '2026-11-03 05:51:48'),
(15, '多设备登录数量上限', 1, 'MULTI_DEVICE_MAX', '3', '多设备模式下同一账号最多同时在线会话数，超出踢最早', 10000, 2, 0, 10000, '2026-11-03 04:44:21', 10000, '2026-11-03 05:51:48');


/*!40000 ALTER TABLE `sys_params` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_post`

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

-- Dumping data for table `sys_post`

--



LOCK TABLES `sys_post` WRITE;

/*!40000 ALTER TABLE `sys_post` DISABLE KEYS */;

INSERT INTO `sys_post` (`id`, `post_code`, `post_name`, `sort`, `status`, `tenant_id`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,'CTO','技术负责人',1,1,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(2,'BE','后端工程师',2,1,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(3,'FE','前端工程师',3,1,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(4,'OPS','运维工程师',4,1,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(5,'PM','产品经理',5,1,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(6,'IOT','物联网工程师',6,1,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27');

/*!40000 ALTER TABLE `sys_post` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_role`

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

  `chat_scope` tinyint DEFAULT '1' COMMENT '聊天范围 0全部 1本机构及下级 2本机构 4自定义',

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

-- Dumping data for table `sys_role`

--



LOCK TABLES `sys_role` WRITE;

/*!40000 ALTER TABLE `sys_role` DISABLE KEYS */;

INSERT INTO `sys_role` (`id`, `name`, `role_code`, `remark`, `data_scope`, `chat_scope`, `org_id`, `tenant_id`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,'系统管理员','ROLE_ADMIN','平台全部菜单与权限，含组织、系统配置与安全策略',0,0,1,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-11-03 05:41:20'),(2,'研发工程师','ROLE_DEV','开发工具、物联网设备维护、字典查询与 AI 配置；无组织与系统安全权限',1,1,2,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-11-03 05:40:57'),(3,'运维工程师','ROLE_OPS','日志监控、定时任务、在线用户；设备与附件只读排查；消息查询',1,1,3,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-11-03 05:40:58'),(4,'产品成员','ROLE_PM','接口文档、附件查看与物联网设备只读浏览',2,1,4,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-11-03 05:40:59');

/*!40000 ALTER TABLE `sys_role` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_role_data_scope`

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

-- Dumping data for table `sys_role_data_scope`

--



LOCK TABLES `sys_role_data_scope` WRITE;

/*!40000 ALTER TABLE `sys_role_data_scope` DISABLE KEYS */;

/*!40000 ALTER TABLE `sys_role_data_scope` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_role_menu`

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

) ENGINE=InnoDB AUTO_INCREMENT=279 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='角色菜单关系';

/*!40101 SET character_set_client = @saved_cs_client */;



--

-- Dumping data for table `sys_role_menu`

--



LOCK TABLES `sys_role_menu` WRITE;

/*!40000 ALTER TABLE `sys_role_menu` DISABLE KEYS */;

INSERT INTO `sys_role_menu` (`id`, `role_id`, `menu_id`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,1,1,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(2,1,2,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(3,1,3,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(4,1,4,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(5,1,5,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(6,1,6,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(7,1,7,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(8,1,8,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(9,1,9,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(10,1,10,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(11,1,11,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(12,1,12,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(13,1,13,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(14,1,14,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(15,1,15,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(16,1,16,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(17,1,17,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(18,1,18,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(19,1,19,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(20,1,20,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(21,1,21,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(22,1,22,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(23,1,23,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(24,1,24,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(25,1,25,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(26,1,26,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(27,1,27,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(28,1,28,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(29,1,29,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(30,1,30,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(31,1,31,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(32,1,32,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(33,1,33,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(34,1,34,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(35,1,35,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(36,1,36,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(37,1,37,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(38,1,38,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(39,1,39,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(40,1,40,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(41,1,41,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(42,1,42,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(43,1,43,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(44,1,44,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(45,1,46,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(46,1,47,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(47,1,48,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(48,1,49,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(49,1,50,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(50,1,51,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(51,1,53,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(52,1,54,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(53,1,55,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(54,1,56,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(55,1,57,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(56,1,58,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(57,1,59,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(58,1,60,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(59,1,61,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(60,1,62,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(61,1,63,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(62,1,64,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(63,1,65,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(64,1,66,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(65,1,67,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(66,1,68,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(67,1,69,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(68,1,70,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(69,1,71,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(70,1,72,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(71,1,73,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(72,1,74,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(73,1,75,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(179,1,76,0,0,10000,'2026-11-01 17:22:04',10000,'2026-11-01 17:22:04'),(180,1,77,0,0,10000,'2026-11-01 17:22:04',10000,'2026-11-01 17:22:04'),(181,1,78,0,0,10000,'2026-11-01 17:22:04',10000,'2026-11-01 17:22:04'),(182,1,79,0,0,10000,'2026-11-01 17:22:04',10000,'2026-11-01 17:22:04'),(183,1,80,0,0,10000,'2026-11-01 17:22:04',10000,'2026-11-01 17:22:04'),(184,1,81,0,0,10000,'2026-11-02 03:14:46',10000,'2026-11-02 03:14:46'),(185,1,82,0,0,10000,'2026-11-03 04:44:24',10000,'2026-11-03 04:44:24'),(186,2,1,0,0,10000,'2026-11-03 05:41:05',10000,'2026-11-03 05:41:05'),(187,2,7,0,0,10000,'2026-11-03 05:41:05',10000,'2026-11-03 05:41:05'),(188,2,8,0,0,10000,'2026-11-03 05:41:05',10000,'2026-11-03 05:41:05'),(189,2,33,0,0,10000,'2026-11-03 05:41:05',10000,'2026-11-03 05:41:05'),(190,2,39,0,0,10000,'2026-11-03 05:41:05',10000,'2026-11-03 05:41:05'),(191,2,46,0,0,10000,'2026-11-03 05:41:05',10000,'2026-11-03 05:41:05'),(192,2,47,0,0,10000,'2026-11-03 05:41:05',10000,'2026-11-03 05:41:05'),(193,2,48,0,0,10000,'2026-11-03 05:41:05',10000,'2026-11-03 05:41:05'),(194,2,49,0,0,10000,'2026-11-03 05:41:05',10000,'2026-11-03 05:41:05'),(195,2,50,0,0,10000,'2026-11-03 05:41:05',10000,'2026-11-03 05:41:05'),(196,2,51,0,0,10000,'2026-11-03 05:41:05',10000,'2026-11-03 05:41:05'),(197,2,53,0,0,10000,'2026-11-03 05:41:05',10000,'2026-11-03 05:41:05'),(198,2,54,0,0,10000,'2026-11-03 05:41:05',10000,'2026-11-03 05:41:05'),(199,2,55,0,0,10000,'2026-11-03 05:41:05',10000,'2026-11-03 05:41:05'),(200,2,56,0,0,10000,'2026-11-03 05:41:05',10000,'2026-11-03 05:41:05'),(201,2,57,0,0,10000,'2026-11-03 05:41:05',10000,'2026-11-03 05:41:05'),(202,2,58,0,0,10000,'2026-11-03 05:41:05',10000,'2026-11-03 05:41:05'),(203,2,59,0,0,10000,'2026-11-03 05:41:05',10000,'2026-11-03 05:41:05'),(204,2,60,0,0,10000,'2026-11-03 05:41:05',10000,'2026-11-03 05:41:05'),(205,2,61,0,0,10000,'2026-11-03 05:41:05',10000,'2026-11-03 05:41:05'),(206,2,62,0,0,10000,'2026-11-03 05:41:05',10000,'2026-11-03 05:41:05'),(207,2,63,0,0,10000,'2026-11-03 05:41:05',10000,'2026-11-03 05:41:05'),(208,2,75,0,0,10000,'2026-11-03 05:41:05',10000,'2026-11-03 05:41:05'),(217,3,1,0,0,10000,'2026-11-03 05:41:06',10000,'2026-11-03 05:41:06'),(218,3,33,0,0,10000,'2026-11-03 05:41:06',10000,'2026-11-03 05:41:06'),(219,3,34,0,0,10000,'2026-11-03 05:41:06',10000,'2026-11-03 05:41:06'),(220,3,35,0,0,10000,'2026-11-03 05:41:06',10000,'2026-11-03 05:41:06'),(221,3,40,0,0,10000,'2026-11-03 05:41:06',10000,'2026-11-03 05:41:06'),(222,3,48,0,0,10000,'2026-11-03 05:41:06',10000,'2026-11-03 05:41:06'),(223,3,49,0,0,10000,'2026-11-03 05:41:06',10000,'2026-11-03 05:41:06'),(224,3,54,0,0,10000,'2026-11-03 05:41:06',10000,'2026-11-03 05:41:06'),(225,3,55,0,0,10000,'2026-11-03 05:41:06',10000,'2026-11-03 05:41:06'),(226,3,56,0,0,10000,'2026-11-03 05:41:06',10000,'2026-11-03 05:41:06'),(227,3,62,0,0,10000,'2026-11-03 05:41:06',10000,'2026-11-03 05:41:06'),(228,3,63,0,0,10000,'2026-11-03 05:41:06',10000,'2026-11-03 05:41:06'),(229,3,64,0,0,10000,'2026-11-03 05:41:06',10000,'2026-11-03 05:41:06'),(230,3,65,0,0,10000,'2026-11-03 05:41:06',10000,'2026-11-03 05:41:06'),(231,3,66,0,0,10000,'2026-11-03 05:41:06',10000,'2026-11-03 05:41:06'),(232,3,67,0,0,10000,'2026-11-03 05:41:06',10000,'2026-11-03 05:41:06'),(233,3,68,0,0,10000,'2026-11-03 05:41:06',10000,'2026-11-03 05:41:06'),(234,3,69,0,0,10000,'2026-11-03 05:41:06',10000,'2026-11-03 05:41:06'),(235,3,70,0,0,10000,'2026-11-03 05:41:06',10000,'2026-11-03 05:41:06'),(236,3,71,0,0,10000,'2026-11-03 05:41:06',10000,'2026-11-03 05:41:06'),(237,3,72,0,0,10000,'2026-11-03 05:41:06',10000,'2026-11-03 05:41:06'),(238,3,73,0,0,10000,'2026-11-03 05:41:06',10000,'2026-11-03 05:41:06'),(239,3,74,0,0,10000,'2026-11-03 05:41:06',10000,'2026-11-03 05:41:06'),(240,3,76,0,0,10000,'2026-11-03 05:41:06',10000,'2026-11-03 05:41:06'),(241,3,77,0,0,10000,'2026-11-03 05:41:06',10000,'2026-11-03 05:41:06'),(242,3,79,0,0,10000,'2026-11-03 05:41:06',10000,'2026-11-03 05:41:06'),(248,4,33,0,0,10000,'2026-11-03 05:41:08',10000,'2026-11-03 05:41:08'),(249,4,39,0,0,10000,'2026-11-03 05:41:08',10000,'2026-11-03 05:41:08'),(250,4,48,0,0,10000,'2026-11-03 05:41:08',10000,'2026-11-03 05:41:08'),(251,4,49,0,0,10000,'2026-11-03 05:41:08',10000,'2026-11-03 05:41:08'),(252,4,54,0,0,10000,'2026-11-03 05:41:08',10000,'2026-11-03 05:41:08'),(253,4,55,0,0,10000,'2026-11-03 05:41:08',10000,'2026-11-03 05:41:08'),(254,4,56,0,0,10000,'2026-11-03 05:41:08',10000,'2026-11-03 05:41:08'),(255,1,200,0,0,10000,'2026-11-06 20:33:50',10000,'2026-11-06 20:33:50'),(256,1,201,0,0,10000,'2026-11-06 20:33:50',10000,'2026-11-06 20:33:50'),(257,1,202,0,0,10000,'2026-11-06 20:33:50',10000,'2026-11-06 20:33:50'),(258,1,203,0,0,10000,'2026-11-06 20:33:50',10000,'2026-11-06 20:33:50'),(259,1,204,0,0,10000,'2026-11-06 20:33:50',10000,'2026-11-06 20:33:50'),(260,1,300,0,0,10000,'2026-11-06 20:33:50',10000,'2026-11-06 20:33:50'),(261,1,301,0,0,10000,'2026-11-06 20:33:50',10000,'2026-11-06 20:33:50'),(262,1,302,0,0,10000,'2026-11-06 20:33:50',10000,'2026-11-06 20:33:50'),(263,1,303,0,0,10000,'2026-11-06 20:33:50',10000,'2026-11-06 20:33:50'),(264,1,304,0,0,10000,'2026-11-06 20:33:50',10000,'2026-11-06 20:33:50'),(270,1,400,0,0,10000,'2026-11-06 21:27:07',10000,'2026-11-06 21:27:07'),(271,1,401,0,0,10000,'2026-11-06 21:27:07',10000,'2026-11-06 21:27:07'),(272,1,402,0,0,10000,'2026-11-06 21:27:07',10000,'2026-11-06 21:27:07'),(273,1,403,0,0,10000,'2026-11-06 21:27:07',10000,'2026-11-06 21:27:07'),(274,1,404,0,0,10000,'2026-11-06 21:27:07',10000,'2026-11-06 21:27:07'),(275,1,405,0,0,10000,'2026-11-06 21:27:07',10000,'2026-11-06 21:27:07'),(276,1,406,0,0,10000,'2026-11-10 14:09:04',10000,'2026-11-10 14:09:04'),(277,1,407,0,0,10000,'2026-11-10 14:09:04',10000,'2026-11-10 14:09:04'),(278,1,408,0,0,10000,'2026-11-10 14:09:04',10000,'2026-11-10 14:09:04');

/*!40000 ALTER TABLE `sys_role_menu` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_sms_config`

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

-- Dumping data for table `sys_sms_config`

--



LOCK TABLES `sys_sms_config` WRITE;

/*!40000 ALTER TABLE `sys_sms_config` DISABLE KEYS */;

/*!40000 ALTER TABLE `sys_sms_config` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_sms_log`

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

-- Dumping data for table `sys_sms_log`

--



LOCK TABLES `sys_sms_log` WRITE;

/*!40000 ALTER TABLE `sys_sms_log` DISABLE KEYS */;

/*!40000 ALTER TABLE `sys_sms_log` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_third_login`

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

-- Dumping data for table `sys_third_login`

--



LOCK TABLES `sys_third_login` WRITE;

/*!40000 ALTER TABLE `sys_third_login` DISABLE KEYS */;

/*!40000 ALTER TABLE `sys_third_login` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_third_login_config`

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

-- Dumping data for table `sys_third_login_config`

--



LOCK TABLES `sys_third_login_config` WRITE;

/*!40000 ALTER TABLE `sys_third_login_config` DISABLE KEYS */;

INSERT INTO `sys_third_login_config` (`id`, `open_type`, `client_id`, `client_secret`, `redirect_uri`, `agent_id`, `tenant_id`, `version`, `deleted`, `create_time`) VALUES (1,'feishu','cli_a541d3aa03f8500b','','http://localhost:8080/sys/third/callback/feishu','',10000,0,0,'2026-10-28 05:12:20');

/*!40000 ALTER TABLE `sys_third_login_config` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_user`

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

  `status` tinyint DEFAULT NULL COMMENT '状态  0：停用   1：正常',

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

-- Dumping data for table `sys_user`

--



LOCK TABLES `sys_user` WRITE;

/*!40000 ALTER TABLE `sys_user` DISABLE KEYS */;

INSERT INTO `sys_user` (`id`, `username`, `password`, `real_name`, `avatar`, `signature`, `gender`, `email`, `mobile`, `org_id`, `leader_id`, `super_admin`, `status`, `ban_reason`, `ban_time`, `ban_expire_time`, `multi_device_login`, `multi_device_max`, `tenant_id`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (10000,'admin','207cf410532f92a47dee245ce9b11ff71f578ebd763eb3bbea44ebd043d018fb','超级管理员','http://localhost:8080/upload/20261105/UHWsq_i5IGGR93f054954bd11d1fe1365ca3907dbfd3_13747.png','http://localhost:8080/upload/20261029/admin_60474.png',1,'960681673@qq.com','13800138000',1,NULL,1,1,NULL,NULL,NULL,NULL,NULL,10000,0,0,10000,'2026-10-28 05:12:20',10000,'2026-11-05 03:49:10'),(10001,'chenkai','207cf410532f92a47dee245ce9b11ff71f578ebd763eb3bbea44ebd043d018fb','陈凯',NULL,NULL,0,'chenkai@icejz.net','13800010001',2,10000,0,1,NULL,NULL,NULL,NULL,NULL,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(10002,'linyue','207cf410532f92a47dee245ce9b11ff71f578ebd763eb3bbea44ebd043d018fb','林悦',NULL,NULL,1,'linyue@icejz.net','13800010002',5,10001,0,1,NULL,NULL,NULL,NULL,NULL,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(10003,'zhouqi','207cf410532f92a47dee245ce9b11ff71f578ebd763eb3bbea44ebd043d018fb','周琪',NULL,NULL,0,'zhouqi@icejz.net','13800010003',5,10001,0,1,NULL,NULL,NULL,NULL,NULL,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(10004,'sunhao','207cf410532f92a47dee245ce9b11ff71f578ebd763eb3bbea44ebd043d018fb','孙浩',NULL,NULL,0,'sunhao@icejz.net','13800010004',6,10001,0,1,NULL,NULL,NULL,NULL,NULL,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(10005,'wanning','207cf410532f92a47dee245ce9b11ff71f578ebd763eb3bbea44ebd043d018fb','万宁',NULL,NULL,1,'wanning@icejz.net','13800010005',3,10000,0,1,NULL,NULL,NULL,NULL,NULL,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(10006,'hejia','207cf410532f92a47dee245ce9b11ff71f578ebd763eb3bbea44ebd043d018fb','何佳',NULL,NULL,1,'hejia@icejz.net','13800010006',4,10000,0,1,NULL,NULL,NULL,NULL,NULL,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27');

/*!40000 ALTER TABLE `sys_user` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_user_post`

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

-- Dumping data for table `sys_user_post`

--



LOCK TABLES `sys_user_post` WRITE;

/*!40000 ALTER TABLE `sys_user_post` DISABLE KEYS */;

INSERT INTO `sys_user_post` (`id`, `user_id`, `post_id`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,10000,1,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(2,10001,1,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(3,10002,2,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(4,10003,3,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(5,10004,6,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(6,10005,4,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(7,10006,5,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27');

/*!40000 ALTER TABLE `sys_user_post` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_user_role`

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

-- Dumping data for table `sys_user_role`

--



LOCK TABLES `sys_user_role` WRITE;

/*!40000 ALTER TABLE `sys_user_role` DISABLE KEYS */;

INSERT INTO `sys_user_role` (`id`, `role_id`, `user_id`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,1,10000,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(2,1,10001,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(3,2,10002,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(4,2,10003,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(5,2,10004,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(6,3,10005,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27'),(7,4,10006,0,0,10000,'2026-10-30 06:00:27',10000,'2026-10-30 06:00:27');

/*!40000 ALTER TABLE `sys_user_role` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_user_token`

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

) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户Token';

/*!40101 SET character_set_client = @saved_cs_client */;



--

-- Dumping data for table `sys_user_token`

--



LOCK TABLES `sys_user_token` WRITE;

/*!40000 ALTER TABLE `sys_user_token` DISABLE KEYS */;

-- sanitized: skipped data for `sys_user_token`


/*!40000 ALTER TABLE `sys_user_token` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Table structure for table `sys_workbench_note`

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

) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='工作台日历记事';

/*!40101 SET character_set_client = @saved_cs_client */;



--

-- Dumping data for table `sys_workbench_note`

--



LOCK TABLES `sys_workbench_note` WRITE;

/*!40000 ALTER TABLE `sys_workbench_note` DISABLE KEYS */;

INSERT INTO `sys_workbench_note` (`id`, `user_id`, `note_date`, `note_type`, `content`, `version`, `deleted`, `creator`, `create_time`, `updater`, `update_time`) VALUES (1,10000,'2026-10-31','nudge','别忘了换配置信息',0,0,10000,'2026-10-30 05:17:45',10000,'2026-10-30 05:17:45'),(2,10000,'2026-11-05','remind','14：00更新系统',0,0,10000,'2026-11-05 04:06:43',10000,'2026-11-05 04:06:43'),(3,10000,'2026-11-06','memo','更新用户信息',0,0,10000,'2026-11-05 04:11:08',10000,'2026-11-05 04:11:08'),(4,10000,'2026-11-06','remind','更新机构信息',0,0,10000,'2026-11-05 04:11:17',10000,'2026-11-05 04:11:17'),(5,10000,'2026-11-06','nudge','更新',0,0,10000,'2026-11-05 04:32:41',10000,'2026-11-05 04:32:41');

/*!40000 ALTER TABLE `sys_workbench_note` ENABLE KEYS */;

UNLOCK TABLES;



--

-- Dumping routines for database 'icejz_boot'

--

/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;



/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;

/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;

/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;

/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;

/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;



-- Dump completed on 2026-11-11  5:53:34


SET FOREIGN_KEY_CHECKS = 1;
