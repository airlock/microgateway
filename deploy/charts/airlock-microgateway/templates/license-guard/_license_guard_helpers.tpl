{{/*
Create a default fully qualified name for license-guard components.
*/}}
{{- define "airlock-microgateway.license-guard.fullname" -}}
{{ include "airlock-microgateway.fullname" . }}-license-guard
{{- end }}

{{/*
Common License Guard labels
*/}}
{{- define "airlock-microgateway.license-guard.labels" -}}
{{ include "airlock-microgateway.sharedLabels" . }}
{{ include "airlock-microgateway.license-guard.selectorLabels" . }}
{{- end }}

{{/*
License Guard Selector labels
*/}}
{{- define "airlock-microgateway.license-guard.selectorLabels" -}}
{{ include "airlock-microgateway.sharedSelectorLabels" . }}
app.kubernetes.io/name: {{ include "airlock-microgateway.name" . }}-license-guard
app.kubernetes.io/component: server
{{- end }}

{{/*
License Guard Affinity
*/}}
{{- define "airlock-microgateway.license-guard.affinity" -}}
{{- if empty .Values.licenseGuard.affinity -}}
{{ include "airlock-microgateway.license-guard.affinityPreset" . }}
{{- else -}}
    {{- with .Values.licenseGuard.affinity }}
      {{- toYaml . }}
    {{- end -}}
{{- end -}}
{{- end }}

{{/*
License Guard Affinity preset
*/}}
{{- define "airlock-microgateway.license-guard.affinityPreset" -}}
podAntiAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
    - podAffinityTerm:
        labelSelector:
          matchLabels:
          {{- include "airlock-microgateway.license-guard.selectorLabels" . | nindent 12 }}
        topologyKey: kubernetes.io/hostname
      weight: 100
{{- end }}