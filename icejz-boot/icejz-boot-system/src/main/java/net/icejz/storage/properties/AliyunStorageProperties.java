package net.icejz.storage.properties;

import lombok.Data;

/**
 * 阿里云存储配置项
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Data
public class AliyunStorageProperties {
    private String endPoint;
    private String accessKeyId;
    private String accessKeySecret;
    private String bucketName;
}
