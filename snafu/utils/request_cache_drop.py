# this module accepts environment variables which control
# cache dropping behavior
# cache dropping is implemented by privileged pods separate from
# the benchmark pods, and these are invoked by
# HTTP GET from here.
# if no environment variables are defined, nothing happens

import http.client
import logging
import os
import time


def getPortNum(envVar, defaultPort):
    portStr = os.getenv(envVar)
    if portStr is not None:
        return int(portStr)
    return defaultPort


class RunSnafuCacheDropException(Exception):
    pass


dropKernelCachePort = getPortNum("KCACHE_DROP_PORT_NUM", 9435)
dropCephCachePort = getPortNum("CEPH_CACHE_DROP_PORT_NUM", 9437)

logger = logging.getLogger("snafu")

dbgLevel = os.getenv("DROP_CACHE_DEBUG_LEVEL")
if dbgLevel is not None:
    logger.setLevel(logging.DEBUG)
    logger.info("drop_cache debug log level")

http_debug_level = int(os.getenv("HTTP_DEBUG_LEVEL", default=0))
# cache dropping can take a while if dirty pages have to be flushed
http_timeout = int(os.getenv("HTTP_CACHEDROP_TIMEOUT", default=60))
cache_reload_time = int(os.getenv("CACHE_RELOAD_TIME", default=10))


# drop Ceph OSD cache if requested to


def drop_cache():
    # drop kernel cache if requested to

    kernel_cache_drop_pod_ips = os.getenv("kcache_drop_pod_ips")
    if kernel_cache_drop_pod_ips is not None and kernel_cache_drop_pod_ips.strip() != "":
        logger.info("kernel cache drop pods: %s" % str(kernel_cache_drop_pod_ips))
        logger.info(
            "debug lvl %d, cachedrop timeout %d, cache reload time %d"
            % (http_debug_level, http_timeout, cache_reload_time)
        )
        cached_connections = {}
        pod_ip_list = kernel_cache_drop_pod_ips.split()
        for ip in pod_ip_list:
            conn = http.client.HTTPConnection(ip, port=dropKernelCachePort, timeout=http_timeout)
            if http_debug_level > 0:
                conn.set_debuglevel(http_debug_level)
            logger.info("requesting kernel to drop cache via %s:%d" % (ip, dropKernelCachePort))
            conn.request("GET", "/DropKernelCache")
            cached_connections[ip] = conn

        # now wait for all the responses

        for ip in pod_ip_list:
            conn = cached_connections[ip]
            rsp = conn.getresponse()
            if rsp.status != http.client.OK:
                logger.error("HTTP code %d: %s" % (rsp.status, rsp.reason))
                raise RunSnafuCacheDropException("kernel cache drop %s:%d" % (ip, dropKernelCachePort))
            else:
                logger.info("kernel cache drop for %s completed" % ip)

        # give kernel a chance to reload important cache items
        # before hitting it with a workload
        time.sleep(cache_reload_time)
    # pod drop
    # vm drop ?
    # baremetalbe drop

    kernel_cache_drop_hosts_ips_file = os.getenv("hostskdrop")
    with open(kernel_cache_drop_hosts_ips_file) as f:
        import paramiko
        hosts = f.read().splitlines()
        for host in hosts: 
           paramiko.util.log_to_file('paramiko.log')
           s = paramiko.SSHClient()
           s.load_system_host_keys()
           s.connect(host, 22, 'root', '123456')
           # should umount the glusterfs ?
           # sync need to wait to reach disk ,but now cannot know.
           #stdin, stdout, stderr = s.exec_command('sync; echo 3 > /proc/sys/vm/drop_caches; sleep 60')
           stdin, stdout, stderr = s.exec_command('sync; echo 3 > /proc/sys/vm/drop_caches')
           #stdout.channel.set_combine_stderr(True)
           #output = stdout.readlines()
           #s.close()
           #del ssh, stdin, stdout, stderr
           #time.sleep(60)
           result = stdout.read()
           if not result:
               result = stderr.read()
           stdin.close()
           s.close()
           print(result.decode())
      

 #   import paramiko
 #   hostname = 'localhost'
 #   port = 22
 #   username = 'foo'
 #   password = 'xxxYYYxxx'
 #   
 #   if __name__ == "__main__":
 #       paramiko.util.log_to_file('paramiko.log')
 #       s = paramiko.SSHClient()
 #       s.load_system_host_keys()
 #       s.connect(hostname, port, username, password)
 #       stdin, stdout, stderr = s.exec_command('ifconfig')
 #       print stdout.read()
 #       s.close()

    #  drop Ceph OSD cache if requested to

    ceph_cache_drop_pod_ip = os.getenv("ceph_osd_cache_drop_pod_ip")
    if ceph_cache_drop_pod_ip is not None:
        logger.info(
            "requesting ceph to drop OSD cache via %s:%d" % (ceph_cache_drop_pod_ip, dropCephCachePort)
        )
        conn = http.client.HTTPConnection(
            ceph_cache_drop_pod_ip, port=dropCephCachePort, timeout=http_timeout
        )
        if http_debug_level > 0:
            conn.set_debuglevel(http_debug_level)
        conn.request("GET", "/DropOSDCache")
        rsp = conn.getresponse()
        if rsp.status != http.client.OK:
            logger.error("HTTP ERROR %d: %s" % (rsp.status, rsp.reason))
            raise RunSnafuCacheDropException(
                "Ceph OSD cache drop %s:%d" % (ceph_cache_drop_pod_ip, dropCephCachePort)
            )
        ceph_cache_recover_time = cache_reload_time // 2
        logger.info("ceph OSD cache drop completed, sleeping %d sec" % ceph_cache_recover_time)
        time.sleep(ceph_cache_recover_time)


if __name__ == "__main__":
    drop_cache()
