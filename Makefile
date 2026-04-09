#
# Makefile to generate specifications
#

.PHONY: clean all mandatory_targets json franca yaml csv ddsidl tests binary protobuf ttl s2dm ocf c overlays id jsonschema \
	extensions_json extensions_csv extensions_fidl extensions_idl extensions_jsonschema \
	extensions_artifacts signal_lint schema_compat schema_diff sdk_constants governance_targets \
	bootstrap container_export

all: clean mandatory_targets optional_targets

# All mandatory targets that shall be built and pass on each pull request for
# vehicle-signal-specification or vss-tools
mandatory_targets: clean apigear binary csv datatypes ddsidl franca go id json json-noexpand jsonschema overlays plantuml samm s2dm yaml

# Additional targets that shall be built by travis, but where it is not mandatory
# that the builds shall pass.
# This is typically intended for less maintainted tools that are allowed to break
# from time to time
# Can be run from e.g. travis with "make -k optional_targets || true" to continue
# even if errors occur and not do not halt travis build if errors occur
optional_targets: clean protobuf

TOOLSDIR?=./vss-tools
VSS_VERSION ?= 0.0
COMMON_ARGS=-u ./spec/units.yaml --strict
COMMON_VSPEC_ARG=-s ./spec/VehicleSignalSpecification.vspec
COMMON_DATATYPES_ARG=-t ./spec/VehicleDataTypes.vspec
EXT_VSPEC_ARG=-s ./spec/extensions/VehicleSignalSpecificationExtensions.vspec


# Exporters

datatypes:
	vspec export json ${COMMON_ARGS} ${COMMON_VSPEC_ARG} ${COMMON_DATATYPES_ARG} -o vss_with_datatypes.json

apigear:
	vspec export apigear ${COMMON_ARGS} ${COMMON_VSPEC_ARG} --output-dir apigear
	cd apigear && tar -czvf ../vss_apigear.tar.gz * && cd ..

binary:
	vspec export binary ${COMMON_ARGS} ${COMMON_VSPEC_ARG} -o vss.binary

csv:
	vspec export csv ${COMMON_ARGS} ${COMMON_VSPEC_ARG} -o vss.csv

ddsidl:
	vspec export ddsidl ${COMMON_ARGS} ${COMMON_VSPEC_ARG} -o vss.idl

franca:
	vspec export franca --franca-vss-version $(VSS_VERSION) ${COMMON_ARGS} ${COMMON_VSPEC_ARG} -o vss.fidl

go:
	vspec export go ${COMMON_ARGS} ${COMMON_VSPEC_ARG} -o vss.go

id:
	vspec export id ${COMMON_ARGS} ${COMMON_VSPEC_ARG} -o vss.vspec

json:
	vspec export json ${COMMON_ARGS} ${COMMON_VSPEC_ARG} -o vss.json

json-noexpand:
	vspec export json ${COMMON_ARGS} --no-expand ${COMMON_VSPEC_ARG} -o vss_noexpand.json

jsonschema:
	vspec export jsonschema ${COMMON_ARGS} ${COMMON_VSPEC_ARG} -o vss.jsonschema

extensions_json:
	vspec export json ${COMMON_ARGS} ${EXT_VSPEC_ARG} -o vss_extensions.json

extensions_csv:
	vspec export csv ${COMMON_ARGS} ${EXT_VSPEC_ARG} -o vss_extensions.csv

extensions_fidl:
	vspec export franca --franca-vss-version $(VSS_VERSION) ${COMMON_ARGS} ${EXT_VSPEC_ARG} -o vss_extensions.fidl

extensions_idl:
	vspec export ddsidl ${COMMON_ARGS} ${EXT_VSPEC_ARG} -o vss_extensions.idl

extensions_jsonschema:
	vspec export jsonschema ${COMMON_ARGS} ${EXT_VSPEC_ARG} -o vss_extensions.schema.json

plantuml:
	vspec export plantuml ${COMMON_ARGS} ${COMMON_VSPEC_ARG} -o vss.puml

protobuf:
	vspec export protobuf ${COMMON_ARGS} ${COMMON_VSPEC_ARG} -o vss.proto

samm:
	vspec export samm ${COMMON_ARGS} ${COMMON_VSPEC_ARG} --target-folder samm
	cd samm && tar -czvf ../vss_samm.tar.gz * && cd ..

s2dm:
	vspec export s2dm ${COMMON_ARGS} ${COMMON_VSPEC_ARG} -o graphql
yaml:
	vspec export yaml ${COMMON_ARGS} ${COMMON_VSPEC_ARG} -o vss.yaml

# Other

# Verifies that supported overlay combinations are syntactically correct.
overlays:
	vspec export json ${COMMON_ARGS} -l overlays/profiles/motorbike.vspec ${COMMON_VSPEC_ARG} -o vss_motorbike.json
	vspec export json ${COMMON_ARGS} -l overlays/extensions/dual_wiper_systems.vspec ${COMMON_VSPEC_ARG} -o vss_dualwiper.json
	vspec export json ${COMMON_ARGS} -l overlays/extensions/OBD.vspec ${COMMON_VSPEC_ARG} -o vss_obd.json

extensions_artifacts:
	./scripts/export_extension_artifacts.sh

signal_lint:
	python3 ./scripts/lint_extension_metadata.py

schema_compat:
	python3 ./scripts/check_schema_compat.py --base origin/master --head HEAD

schema_diff:
	./scripts/generate_diff_report.sh origin/master HEAD reports/schema-diff.md

sdk_constants:
	python3 ./scripts/generate_sdk_constants.py --metadata spec/extensions/metadata/myco_signals.json --out-dir artifacts/sdk

governance_targets: signal_lint schema_compat schema_diff

bootstrap:
	./scripts/bootstrap_vspec_toolchain.sh

container_export:
	./scripts/export_with_container.sh all

clean:
	rm -f vss.*
	rm -f vss_with_datatypes.json
	rm -f vss_extensions.json vss_extensions.csv vss_extensions.fidl vss_extensions.idl vss_extensions.schema.json
	rm -rf apigear
	rm -rf samm
