{{/*
Create a default fully qualified name for license-guard-redis components.
*/}}
{{- define "airlock-microgateway.license-guard-redis.fullname" -}}
{{ include "airlock-microgateway.fullname" . }}-license-guard-redis
{{- end }}

{{/*
Common License Guard Redis labels
*/}}
{{- define "airlock-microgateway.license-guard-redis.labels" -}}
{{ include "airlock-microgateway.sharedLabels" . }}
{{ include "airlock-microgateway.license-guard-redis.selectorLabels" . }}
{{- end }}

{{/*
License Guard Redis Selector labels
*/}}
{{- define "airlock-microgateway.license-guard-redis.selectorLabels" -}}
{{ include "airlock-microgateway.sharedSelectorLabels" . }}
app.kubernetes.io/name: {{ include "airlock-microgateway.name" . }}-license-guard
app.kubernetes.io/component: cache
{{- end }}
