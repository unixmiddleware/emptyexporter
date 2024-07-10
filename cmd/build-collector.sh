#!/usr/bin/env bash

OCB_BINARY="./ocb"
OTEL_VERSION="0.104.0"
VVER="v${OTEL_VERSION}"
OCBFILE="ocb_0.104.0_linux_amd64"
OCB_URL="https://github.com/open-telemetry/opentelemetry-collector/releases/download/cmd%2Fbuilder%2F${VVER}/${OCBFILE}"

CUSTOM_EXPORTER=onestream
CUSTOM_EXPORTER_NAME=${CUSTOM_EXPORTER}exporter
CUSTOM_EXPORTER_VERSION=1.0.0
CUSTOM_EXPORTER_VVER=v${CUSTOM_EXPORTER_VERSION}
CUSTOM_COLLECTOR_NAME=otelcol-${CUSTOM_EXPORTER}
CUSTOM_COLLECTOR_DESCRIPTION="Customer OTEL Collector for ${CUSTOM_EXPORTER}"

CUSTOM_COLLECTOR_REF="https://opentelemetry.io/docs/collector/custom-collector/"

GOBIN=$(go env GOBIN)
GO_BINARY=/usr/bin/go

BUILDER_CONFIG="builder-config.yaml"

if [[ ! -s ${OCB_BINARY} ]]
then
  curl --proto '=https' --tlsv1.2 -fL -o ocb ${OCB_URL}
  [ -f ${OCB_BINARY} ]  && chmod u+x ${OCB_BINARY} && file ${OCB_BINARY}
fi


BuilderConfig() {
cat <<- eoCAT
dist:
  name: ${CUSTOM_COLLECTOR_NAME}
  description: ${CUSTOM_COLLECTOR_DESCRIPTION}
  output_path: ./${CUSTOM_COLLECTOR_NAME}
  otelcol_version: ${OTEL_VERSION}
  version: ${CUSTOM_EXPORTER_VERSION}
  go: ${GO_BINARY}

exporters:
  - gomod: go.opentelemetry.io/collector/exporter/debugexporter ${VVER}
  - gomod: go.opentelemetry.io/collector/exporter/otlpexporter ${VVER}

processors:
  - gomod: go.opentelemetry.io/collector/processor/batchprocessor ${VVER}

receivers:
  - gomod: go.opentelemetry.io/collector/receiver/otlpreceiver ${VVER}
  - gomod: github.com/open-telemetry/opentelemetry-collector-contrib/receiver/filelogreceiver ${VVER}

eoCAT
}

BuilderConfig > ${BUILDER_CONFIG}
[ -e ${BUILDER_CONFIG} ] && ls -l ${BUILDER_CONFIG}

./${OCB_BINARY} --config ${BUILDER_CONFIG}
