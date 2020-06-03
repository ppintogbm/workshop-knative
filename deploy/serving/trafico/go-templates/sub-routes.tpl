{{"NAME"}}{{"\t"}}{{"TAG"}}{{"\t"}}{{"WEIGHT"}}{{"\t"}}{{"URL"}}
{{- if .items}}
{{"todo"}}
{{- else if .metadata.name }}
{{ .metadata.name}}{{"\t"}}{{- range .status.traffic}}{{.tag}}{{"\t"}}{{.percent}}{{"%\t"}}{{.url}}{{"\n\t"}}{{- end}}
{{end}}