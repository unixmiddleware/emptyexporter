EXPORTER_CONFIG="exporter-config.yaml"
COLLECTOR_BINARY="./otelcol-dev"

cat <<eoConfig > ${EXPORTER_CONFIG}
exporters:
  emptyexporter:
service:
  pipelines:
    traces:
      receivers: [otlp]
      exporters: [emptyexporter,debu]
    metrics:
      receivers: [otlp]
      exporters: [emptyexporter,debug]
    logs:
      receivers: [otlp]
      exporters: [emptyexporter,debug]
eoConfig

${COLLECTOR_BINARY} --config ${EXPORTER_CONFIG}
