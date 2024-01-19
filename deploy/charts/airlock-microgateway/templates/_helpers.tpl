{{/*
Expand the name of the chart.
We truncate at 49 chars because some Kubernetes name fields are limited to 63 chars (by the DNS naming spec)
and the longest explicit suffix is 14 characters.
*/}}
{{- define "airlock-microgateway.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 49 | trimSuffix "-" }}
{{- end }}

{{/*
Convert an image configuration object into an image ref string.
*/}}
{{- define "airlock-microgateway.image" -}}
    {{- if .digest -}}
        {{- printf "%s@%s" .repository .digest -}}
    {{- else if .tag -}}
        {{- printf "%s:%s" .repository .tag -}}
    {{- else -}}
        {{- printf "%s" .repository -}}
    {{- end -}}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 36 chars because some Kubernetes name fields are limited to 63 chars (by the DNS naming spec)
and the longest implicit suffix is 27 characters.
If release name contains chart name it will be used as a full name.
*/}}
{{- define "airlock-microgateway.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 36 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 36 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 36 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "airlock-microgateway.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "airlock-microgateway.sharedLabels" -}}
helm.sh/chart: {{ include "airlock-microgateway.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: {{ .Chart.Name }}
{{- with .Values.commonLabels }}
{{ toYaml .}}
{{- end }}
{{- end }}

{{/*
Common Selector labels
*/}}
{{- define "airlock-microgateway.sharedSelectorLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Restricted Container Security Context
*/}}
{{- define "airlock-microgateway.restrictedSecurityContext" -}}
allowPrivilegeEscalation: false
privileged: false
runAsNonRoot: true
capabilities:
  drop: ["ALL"]
readOnlyRootFilesystem: true
seccompProfile:
  type: RuntimeDefault
{{- end }}
