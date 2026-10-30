package net.icejz;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

/**
 * 新增模块演示
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 */
@EnableFeignClients
@EnableDiscoveryClient
@SpringBootApplication
public class NewApplication {

	public static void main(String[] args) {
		SpringApplication.run(NewApplication.class, args);
	}

}