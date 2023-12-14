{{/* vim: set filetype=mustache: */}}

{{- define "acs-admin-password" -}}
{{- trunc 16 (sha256sum (cat .Values.masterKey "acs-admin-password")) -}}
{{- end -}}

{{- define "openshift-users" -}}
{{- $stash := dict "result" (list "admin")  -}}
{{- range $user := .Values.openshift.users }}
{{- $_ := printf "%s-user" $user | append $stash.result | set $stash "result" -}}
{{- end -}}
{{- toJson $stash.result -}}
{{- end -}}

{{- define "openshift-htpasswd" -}}
{{- range (include "openshift-users" . | fromJsonArray) }}
{{ htpasswd . (trunc 8 (sha256sum (cat $.Values.masterKey "openshift-htpasswd" .))) }}
{{- end -}}
{{- end -}}

{{- define "openshift-users-txt" -}}
{{- range (include "openshift-users" . | fromJsonArray) }}
{{ . }}:{{ trunc 8 (sha256sum (cat $.Values.masterKey "openshift-htpasswd" .)) }}
{{- end -}}
{{- end -}}
