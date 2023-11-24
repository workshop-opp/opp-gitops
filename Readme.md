# OPP-2023-lab-deploy

This repo contains the material to deploy the argoCD applications.


## Deploy ArgoCD, cluster-wide subscriptions and create namespaces (in the gitops version we have now, we can't add labels when they are created by ArgoCD)
```shell
oc apply -f gitops/sub.yaml
oc apply -f gitops/ns.yaml
oc apply -f gitops/idp.yaml
oc delete clusterrolebinding self-provisioners
```

## Configure the Headquarter

Create the argoCD headquarter project
```shell
oc apply -f headquarter/argocd/project.yaml
```

Create the argoCD Application
```shell
oc apply -f headquarter/argocd/application.yaml
```



## Configure the Warehouse (normally, not to be used as that's the target of the lab ;) )

### All Namespaces

Create the argoCD warehouse project
```shell
oc apply -f warehouse/argocd/project.yaml
```

Create the argoCD ApplicationSet (as we are deploying 10 or more namespaces within the cluster)
```shell
oc apply -f warehouse/argocd/applicationSet.yaml
```

## Clean the warehouses

```shell
oc delete -f warehouse/argocd/applicationSet.yaml
oc delete $(oc get ns -oname | grep warehouse-*)
oc apply -f gitops/ns.yaml
oc apply -f gitops/idp.yaml
```
