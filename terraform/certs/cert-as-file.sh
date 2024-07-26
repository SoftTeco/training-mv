#!/bin/bash
kubectl get secret mv-tls-secret-key-and-crt -n dev -o jsonpath="{.data.tls\.crt}" | base64 --decode > tls.crt
kubectl get secret mv-tls-secret-key-and-crt -n dev -o jsonpath="{.data.tls\.key}" | base64 --decode > tls.key
