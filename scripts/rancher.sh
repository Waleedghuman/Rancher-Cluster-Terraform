#!/bin/bash

# # install kubectl
# sudo snap install kubectl --classic
# sudo snap install helm --classic
# configure kubectl
# mkdir -p /home/ubuntu/.kube
# sudo cp /etc/rancher/rke2/rke2.yaml /home/ubuntu/.kube/config
# sudo chmod 644 /home/ubuntu/.kube/config
RANCHER_HOSTNAME="$1"
export KUBECONFIG=/home/ubuntu/.kube/config

helm --kubeconfig $KUBECONFIG repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm --kubeconfig $KUBECONFIG repo add jetstack https://charts.jetstack.io
helm --kubeconfig $KUBECONFIG repo update

kubectl create namespace cattle-system
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.crds.yaml
helm --kubeconfig $KUBECONFIG repo update

# Install the cert-manager Helm chart
helm --kubeconfig $KUBECONFIG install cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --create-namespace \
    --version v1.11.0

# Wait for cert-manager pods to be ready
kubectl wait --for=condition=Ready --timeout=600s -n cert-manager --all pods

helm --kubeconfig $KUBECONFIG install rancher rancher-stable/rancher \
    --version 2.7.9 \
    --namespace cattle-system \
    --set hostname=$RANCHER_HOSTNAME \
    --set global.cattle.psp.enabled=false \
    --set bootstrapPassword=admin
# Wait for rancher pods to be ready
kubectl wait --for=condition=Ready --timeout=600s -n cattle-system --all pods

echo ""
echo ""
echo "                    *************************************************************************************************************************************************************"
echo "                    *                                                                                                                                                           *"
echo "                    *                                     Copy and paste the following address into your web browser's address bar:                                             *"
echo "                    *                                                                                                                                                           *"
echo "                    *                                                            http://$RANCHER_HOSTNAME                                                           *"
echo "                    *                                                                                                                                                           *"
echo "                    *************************************************************************************************************************************************************"
echo ""
echo ""