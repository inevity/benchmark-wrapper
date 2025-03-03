#!/usr/bin/env bash
datasource="Elasticsearch"
#_es=${ES_SERVER:-https://search-perfscale-dev-chmf5l4sh66lvxbnadi4bznl3a.us-west-2.es.amazonaws.com:443}
_es=${ES_SERVER:-http://172.18.123.49:9200}
_es_baseline=${ES_SERVER_BASELINE:-https://search-perfscale-dev-chmf5l4sh66lvxbnadi4bznl3a.us-west-2.es.amazonaws.com:443}
tool=${1}

#python3 -m venv ./venv
#source ./venv/bin/activate
#set -x
#git clone https://github.com/cloud-bulldozer/benchmark-comparison

pushd ../benchmark-comparison
pyenv virtualenv 3.7.10 benchcompare
#ln -s ../benchmark-comparison/config config
#ln -s ../benchmark-comparison/tolerancy-configs tolerancy-configs
#set +x
#pip3 install ../benchmark-comparison/.
#pushd ../benchmark-comparison
#ln -s benchmark-comparison/config config
#ln -s benchmark-comparison/tolerancy-configs tolerancy-configs
set +x
#pip3 install benchmark-comparison/.
pyenv activate benchcompare
pip3 install .


if [[ $? -ne 0 ]] ; then
  echo "Unable to execute compare - Failed to install touchstone"
  exit 1
fi

set -x
if [[ ${COMPARE_WITH_GOLD} == "true" ]] || [[ ${COMPARE} == "true" ]]; then
  echo "Comparing"
  touchstone_compare --database elasticsearch -url $_es_baseline $_es -u ${2} ${3} -o yaml --config config/${tool}.json --tolerancy-rules tolerancy-configs/${tool}.yaml | grep -v "ERROR"| tee compare_output_${!#}.yaml
else
  touchstone_compare --database elasticsearch -url $_es -u ${2}                    -o yaml --config config/${tool}.json --tolerancy-rules tolerancy-configs/${tool}.yaml | grep -v "ERROR"| tee compare_output_${!#}.yaml
fi
set +x

if [[ $? -ne 0 ]] ; then
  echo "Unable to execute compare - Failed to run touchstone"
  exit 1
fi

#deactivate
#rm -rf config tolerancy-configs
popd
