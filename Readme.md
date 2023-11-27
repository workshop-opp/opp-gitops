# OPP-2023-lab-deploy

This repo contains the material to deploy the argoCD applications.

## Deploy ArgoCD, cluster-wide subscriptions and create namespaces (in the gitops version we have now, we can't add labels when they are created by ArgoCD)

```shell
oc apply -f gitops/ns.yaml
oc apply -f gitops/sub.yaml
oc delete clusterrolebinding self-provisioners
```

## Let's Encrypt

```sh
# Cluster DNS domain
export DOMAIN=summitconnect.sandbox2349.opentlc.com

# Get a valid certificate
sudo dnf install -y golang-github-acme-lego
lego -d "api.$DOMAIN" -d "*.apps.$DOMAIN" -a -m nmasse@redhat.com --dns route53 run

# Install it on the router
cert_dn="$(openssl x509 -noout -subject -in .lego/certificates/api.$DOMAIN.crt)"
cert_cn="${cert_dn#subject=CN = }"
kubectl create secret tls router-certs-$(date "+%Y-%m-%d") --cert=".lego/certificates/api.$DOMAIN.crt" --key=".lego/certificates/api.$DOMAIN.key" -n openshift-ingress --dry-run -o yaml > router-certs.yaml
kubectl apply -f "router-certs.yaml" -n openshift-ingress
kubectl patch ingresscontroller default -n openshift-ingress-operator --type=merge --patch-file=/dev/fd/0 <<EOF
{"spec": { "defaultCertificate": { "name": "router-certs-$(date "+%Y-%m-%d")" }}}  
EOF
```

## OpenShift GitOps

```sh
oc patch argocd openshift-gitops -n openshift-gitops -p '{"spec":{"server":{"insecure":true,"route":{"enabled": true,"tls":{"termination":"edge","insecureEdgeTerminationPolicy":"Redirect"}}}}}' --type=merge
oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:openshift-gitops:openshift-gitops-argocd-application-controller
```

## Configure the infrastructure for the workshop

Create the argoCD headquarter project

```shell
oc apply -f opp/argocd/project.yaml
```

Create the argoCD Application

```shell
oc apply -f opp/argocd/application.yaml
```

## Cleanup

```shell
oc delete -f opp/argocd/application.yaml
oc delete -f gitops/sub.yaml
oc delete -f gitops/ns.yaml
```
