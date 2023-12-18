{{/* vim: set filetype=mustache: */}}

{{- define "acs-admin-password" -}}
{{- trunc 16 (sha256sum (cat .Values.masterKey "acs-admin-password")) -}}
{{- end -}}
