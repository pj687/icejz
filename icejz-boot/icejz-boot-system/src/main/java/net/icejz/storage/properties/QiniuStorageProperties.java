package net.icejz.storage.properties;

import lombok.Data;

/**
 * 七牛云存储配置项
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@Data
public class QiniuStorageProperties {
    private String accessKey;
    private String secretKey;
    private String bucketName;
}
