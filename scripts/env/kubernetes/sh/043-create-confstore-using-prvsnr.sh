#!/bin/bash
#
# Copyright (c) 2021 Seagate Technology LLC and/or its Affiliates
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# For any questions about this software or licensing,
# please email opensource@seagate.com or cortx-questions@seagate.com.
#

set -e # exit immediatly on errors

source ./config.sh
source ./env.sh
source ./sh/functions.sh

set -x # print each statement before execution

add_separator RUNNING PROVISIONER TO CREATE CONFSTORE.

image_tag="$PRVSNR_CORTX_ALL_IMAGE_TAG"
if [ -z "$image_tag" ]; then
  image_tag="$S3_CORTX_ALL_IMAGE_TAG"
fi
cat k8s-blueprints/cortx-provisioner-pod.yaml.template \
  | sed "s,<prvsnr-cortx-all-image>,ghcr.io/seagate/cortx-all:${image_tag}," \
  > k8s-blueprints/cortx-provisioner-pod.yaml

# git clone https://github.com/Seagate/cortx-prvsnr -b kubernetes
git clone -b br/sachit/new-s3-config https://github.com/sachitanands/cortx-prvsnr-Kubernetes cortx-prvsnr

mkdir -p /etc/cortx/s3/solution.cpy/
cp cortx-prvsnr/test/deploy/kubernetes/solution-config/* /etc/cortx/s3/solution.cpy/

kubectl apply -f /etc/cortx/s3/solution.cpy/secrets.yaml

# cd cortx-prvsnr/test/deploy/kubernetes
#
# # --force will sometimes freeze, let's use --wait=false
# sed -i -e 's,--force,--wait=false,' ./destroy.sh
#
# sh ./deploy.sh
#
# #cp solution-config/config.yaml /etc/cortx/solution
#
# kubectl apply -f "$AUTOMATION_BASE_DIR"/k8s-blueprints/cortx-provisioner-pv.yaml --namespace cortx
# kubectl apply -f "$AUTOMATION_BASE_DIR"/k8s-blueprints/cortx-provisioner-pvc.yaml --namespace cortx
# kubectl apply -f ./solution-config/secrets.yaml --namespace cortx
# kubectl apply -f "$AUTOMATION_BASE_DIR"/k8s-blueprints/cortx-provisioner-pod.yaml --namespace cortx
#
# wait_till_pod_is_Running podnode-0 --namespace cortx
#
# # save result, as it will be deleted by destroy.sh
# cp /etc/cortx/cluster.conf "$AUTOMATION_BASE_DIR"
#
# kubectl delete -f "$AUTOMATION_BASE_DIR"/k8s-blueprints/cortx-provisioner-pod.yaml --namespace cortx
# kubectl delete -f ./solution-config/secrets.yaml --namespace cortx
# kubectl delete -f "$AUTOMATION_BASE_DIR"/k8s-blueprints/cortx-provisioner-pvc.yaml --namespace cortx
# kubectl delete -f "$AUTOMATION_BASE_DIR"/k8s-blueprints/cortx-provisioner-pv.yaml --namespace cortx
#
# sh ./destroy.sh
#
# cd - # back to main src dir
#
# # copy result confstore back to /etc/cortx
# cp cluster.conf /etc/cortx

add_separator SUCCESSFULLY CREATED CONFSTORE.
