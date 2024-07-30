#!/bin/bash
AKS_NAME=$1
RG_NAME=$2

NODE_RG=$(az aks show --name "$AKS_NAME" --resource-group "$RG_NAME" --query "nodeResourceGroup" --output tsv)

echo "{\"nodeResourceGroup\": \"$NODE_RG\"}"
