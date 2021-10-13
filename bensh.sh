#!/usr/bin/env bash

#deploy container
#docker run -d --restart=always -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" -e "http.cors.enabled=true" -e "http.cors.allow-origin=*" -e "http.cors.allow-headers=X-Requested-With,X-Auth-Token,Content-Type,Content-Length,Authorization" -e "http.cors.allow-credentials=true" docker.elastic.co/elasticsearch/elasticsearch:7.0.1
#docker run -d --restart=always -p 3000:3000 grafana/grafana:6.3.0
#docker run -p 1358:1358 -d appbaseio/dejavu
#### #!/bin/bash
#fio  --output-format=json --output=/tmp/fiod/1/rw/fio-result.json --client=/root/perf/snafu/hosts fiojob1
#ls -laht
#vim fiojob1
#history |grep vim
#vim /root/perf/snafu/snafu/fio_wrapper/trigger_fio.py
#rm -rf *.log*
#ls -laht
#1es=http://172.18.123.49:9200 run_snafu -v  -t fio -H /root/perf/snafu/hosts -j fiojob1 -s 1 -d /tmp/fiodagine/
curl -XDELETE http://localhost:9200/snafu-fio*
curl --silent 'http://127.0.0.1:9200/_cat/indices' | cut -d\  -f3
#1es=http://172.18.123.49:9200 run_snafu -v  -t fio -H /root/perf/snafu/hosts -j fiojob1 -s 1 -d /tmp/fiodagine/
rm -rf /tmp/dir/*
rm -rf /tmp/fiodagine/*
#es=http://172.18.123.49:9200 run_snafu -v  -t fio -H /root/perf/snafu/hosts -j fiojob1 -s 1 -d /tmp/fiodagine/
#1es=http://172.18.123.49:9200 run_snafu  -t fio -H /root/perf/snafu/hosts -j fiojob1 -s 1 -d /tmp/fiodagine/
#history |grep help
#run_snafu -t fio --help
NEW_UUID=$(uuidgen)
#clustername=ipfs2node uuid=${NEW_UUID}  test_user=baojg es=http://172.18.123.49:9200 run_snafu  -t fio --run-id fio1 -H /root/perf/snafu/hosts -j fiojob1 -s 1 -d /tmp/fiodagine/

# https://discuss.elastic.co/t/what-does-this-error-mean-data-too-large-data-for-transport-request/209345
#clustername=ipfs2node uuid=${NEW_UUID}  test_user=baojg     parallel=true ex_index=fio verify_cert=false es=http://172.18.123.49:9200 run_snafu  -t fio --run-id fio1 -H /root/perf/snafu/hosts -j fiojob1 -s 1 -d /tmp/fiodagine/
#clustername=ipfs2node uuid=${NEW_UUID}  test_user=baojg     parallel=false ex_index=fio verify_cert=false es=http://172.18.123.49:9200 run_snafu  -t fio --run-id fio1 -H /root/perf/snafu/hosts -j fiojob1 -s 1 -d /tmp/fiodagine/

# test sample 2 drop cache for hosts
#hostskdrop=/root/perf/snafu/hosts clustername=ipfs2node uuid=${NEW_UUID}  test_user=baojg     parallel=false ex_index=fio verify_cert=false es=http://172.18.123.49:9200 run_snafu  -t fio --run-id fio1 -H /root/perf/snafu/hosts -j fiojob1 -s 1 -d /tmp/fiodagine/
#hostskdrop=/root/perf/snafu/hosts clustername=ipfs2node uuid=${NEW_UUID}  test_user=baojg     parallel=false ex_index=fio verify_cert=false es=http://172.18.123.49:9200 run_snafu  -t fio --run-id fio1 -H /root/perf/snafu/hosts -j fiojob1 -s 2 -d /tmp/fiodagine/
# hist
#hostskdrop=/root/perf/snafu/hosts clustername=ipfs2node uuid=${NEW_UUID}  test_user=baojg     parallel=false ex_index=fio verify_cert=false es=http://172.18.123.49:9200 run_snafu  -t fio --run-id fio1 -H /root/perf/snafu/hosts -j fiojob1 -s 2 -d /tmp/fiodagine/ -hp True
hostskdrop=/root/perf/snafu/hosts clustername=ipfs2node uuid=${NEW_UUID}  test_user=baojg     parallel=false ex_index=fio verify_cert=false es=http://172.18.123.49:9200 run_snafu  -t fio --run-id fio1 -H /root/perf/snafu/hosts -j fiojob1 -s 2 -d /tmp/fiodagine/ --histogramprocess True
# debug
#hostskdrop=/root/perf/snafu/hosts clustername=ipfs2node uuid=${NEW_UUID}  test_user=baojg     parallel=false ex_index=fio verify_cert=false es=http://172.18.123.49:9200 run_snafu -v -t fio --run-id fio1 -H /root/perf/snafu/hosts -j fiojob1 -s 2 -d /tmp/fiodagine/ --histogramprocess True
#hostskdrop=/root/perf/snafu/hosts clustername=ipfs2node uuid=${NEW_UUID}  test_user=baojg     parallel=false ex_index=fio verify_cert=false es=http://172.18.123.49:9200 run_snafu  -t fio --run-id fio1 -H /root/perf/snafu/hosts -j fiojob1 -s 2 -d /tmp/fiodagine/ --histogramprocess

# drop cache
# then again 
NEW_UUID=$(uuidgen)
hostskdrop=/root/perf/snafu/hosts clustername=ipfs2node uuid=${NEW_UUID}  test_user=baojg     parallel=false ex_index=fio verify_cert=false es=http://172.18.123.49:9200 run_snafu  -t fio --run-id fio1 -H /root/perf/snafu/hosts -j fiojob1 -s 2 -d /tmp/fiodagine/ --histogramprocess True
