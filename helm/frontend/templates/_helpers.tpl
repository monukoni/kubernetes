{{/*
Selector labels
*/}}
{{- define "mychart.selectorLabels" }}
app.kubernetes.io/name: {{ .Values.appName | default .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
