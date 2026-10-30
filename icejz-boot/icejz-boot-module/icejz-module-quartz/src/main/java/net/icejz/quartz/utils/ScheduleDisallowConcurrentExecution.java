package net.icejz.quartz.utils;

import org.quartz.DisallowConcurrentExecution;

/**
 * 禁止并发
 *
 * @author ice_jz
 * <a href="https://icejz.net">ICEJZ</a>
 *
 */
@DisallowConcurrentExecution
public class ScheduleDisallowConcurrentExecution extends AbstractScheduleJob {

}
