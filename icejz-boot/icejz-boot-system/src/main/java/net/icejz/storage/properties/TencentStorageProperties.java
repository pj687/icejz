package net.icejz.storage.properties;

import lombok.Data;

/**
 * 腾讯云存储配置项
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Data
public class TencentStorageProperties {
    private String accessKey;
    private String secretKey;
    private String region;
    private String bucketName;
}
