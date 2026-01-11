{{/*
Expand the name of the chart.
*/}}
{{- define "travelo.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "travelo.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "travelo.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "travelo.labels" -}}
helm.sh/chart: {{ include "travelo.chart" . }}
{{ include "travelo.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "travelo.selectorLabels" -}}
app.kubernetes.io/name: {{ include "travelo.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
MySQL labels
*/}}
{{- define "travelo.mysql.labels" -}}
{{ include "travelo.labels" . }}
app.kubernetes.io/component: mysql
{{- end }}

{{/*
Backend labels
*/}}
{{- define "travelo.backend.labels" -}}
{{ include "travelo.labels" . }}
app.kubernetes.io/component: backend
{{- end }}

{{/*
Frontend labels
*/}}
{{- define "travelo.frontend.labels" -}}
{{ include "travelo.labels" . }}
app.kubernetes.io/component: frontend
{{- end }}

{{/*
Proxy labels
*/}}
{{- define "travelo.proxy.labels" -}}
{{ include "travelo.labels" . }}
app.kubernetes.io/component: proxy
{{- end }}
