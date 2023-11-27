# OPP-2023-lab-deploy

This repo contains the material to deploy the argoCD applications.

## Deploy ArgoCD, cluster-wide subscriptions and create namespaces (in the gitops version we have now, we can't add labels when they are created by ArgoCD)

```shell
oc apply -f gitops/ns.yaml
oc apply -f gitops/sub.yaml
oc delete clusterrolebinding self-provisioners
```

## Configure the Headquarter

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
