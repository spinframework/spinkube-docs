#! /bin/bash

# Generates the CRD reference docs for SpinAppExecutor and SpinApp and places them in the
# content/en/docs/reference directory

set -eo pipefail

script_dir=$(dirname "$0")

cd $script_dir

SPIN_OPERATOR_RELEASE=${SPIN_OPERATOR_RELEASE:-v0.5.0}

echo "Installing crdoc"
go install fybrik.io/crdoc@latest

echo "Downloading Spin Operator CRDs ($SPIN_OPERATOR_RELEASE)"
spin_operator_crds_file=$(mktemp)
wget https://github.com/spinkube/spin-operator/releases/download/$SPIN_OPERATOR_RELEASE/spin-operator.crds.yaml -O ${spin_operator_crds_file}

# Generate SpinAppExecutor Reference Docs
echo "Generating CRD reference docs for SpinAppExecutor"
crdoc -r ${spin_operator_crds_file} \
    -o ../content/en/docs/reference/spin-app-executor.md \
    --toc ./spin-app-executor-toc.yaml \
    --template ./spin-operator.tmpl

echo "Generating CRD reference docs for SpinApp"
# Generate SpinApp Reference Docs
crdoc -r ${spin_operator_crds_file} \
    -o ../content/en/docs/reference/spin-app.md \
    --toc ./spin-app-toc.yaml \
    --template ./spin-operator.tmpl

# Remove temporary file
rm ${spin_operator_crds_file}

echo "Done."
