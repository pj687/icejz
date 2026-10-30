package net.icejz.storage.properties;

import lombok.Data;

/**
 * Minio存储配置项
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Data
public class MinioStorageProperties {
    private String endPoint;
    private String accessKey;
    private String secretKey;
    private String bucketName;
}
