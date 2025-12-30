{{/*
Common labels and naming helpers.
*/}}

{{- define "llm-council.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "llm-council.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := include "llm-council.name" . -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "llm-council.labels" -}}
app.kubernetes.io/name: {{ include "llm-council.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
{{- end -}}

{{- define "llm-council.selectorLabels" -}}
app.kubernetes.io/name: {{ include "llm-council.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "llm-council.componentName" -}}
{{- printf "%s-%s" (include "llm-council.fullname" .root) .component | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "llm-council.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "llm-council.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

