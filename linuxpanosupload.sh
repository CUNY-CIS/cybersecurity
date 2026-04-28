#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2026 
#
# Author: Sung Lee
# Organization: City University of New York (CUNY)
# Maintainer: Sung Lee <sung.lee@cuny.edu>
# Version: 1.0.0
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# --------------------------------------------------------------------
# Palo Alto Networks PAN-OS Certificate Import & Commit Script
# --------------------------------------------------------------------
#
###############################################################################
# PURPOSE
#   Import a PEM keypair (certificate + private key) into a Palo Alto Networks
#   PAN-OS device (or Panorama template) via the XML API, then commit the change
#   only if the import succeeded.
#
# OVERVIEW
#   1) Build a combined PEM file: cert + private key (and chain if included)
#   2) POST the PEM to PAN-OS API endpoint:
#        type=import
#        category=keypair
#        certificate-name=<CERTNAME>
#        format=pem
#        passphrase=<PASSPHRASE>  (if the private key is encrypted. If there is none, you can use any generic string)
#        target-tpl=<TEMPLATE>    (if importing into a Panorama template)
#        key=<API_KEY>
#   3) Parse the response text for a success string
#   4) If successful, issue a commit
#   5) Remove the temporary combined PEM file
#
# REQUIRED INPUTS (CONFIG)
#   CERTNAME               - Friendly name to store the certificate as in PAN-OS (e.g., nodename.campus.cuny.edu)
#                            The name is case-sensitive and can have up to 63 characters. Use only letters, numbers, hyphens, and underscores.
#   FW                     - Base URL/IP of firewall or Panorama (e.g., https://fw.local or https://x.x.x.x)
#   KEY                    - PAN-OS API key with permissions to import certs & commit
#   TEMPLATE               - Panorama template name
#   TEMPLATE_STACK         - Panorama template stack name
#   CERTPATH               - Path to certificate PEM (can include chain/intermediates: full chain is recommended)
#   KEYPATH                - Path to private key PEM
#   PASSPHRASE             - Passphrase for the private key (if encrypted); it cannot be blank, if no passphrase is defined, you can use any generic string
#
# ADDITIONAL INPUTS
#   COMMIT_WAIT_INTERVAL   - Interval to wait for a commit: Set for 30 seconds
#   COMMIT_WAIT_ITERATIONS - The number of iterations to wait for a commit: Set for 20 iterations
#
# SECURITY NOTES
#   - This script writes a combined PEM to /tmp. Ensure /tmp permissions
#
# COMMON FAILURE MODES
#   - Wrong passphrase for encrypted private key
#   - Mismatched cert and key
#   - Insufficient API key permissions
#   - Wrong target template name or not applicable on standalone firewall
#   - Firewall/Panorama not reachable or TLS issues
###############################################################################


CERTNAME="NAME_OF_CERT"
FW="URL_OF_FIREWALL"
KEY="API_KEY_FOR_FIREWALL"
TEMPLATE="PANOS_TEMPLATE_NAME"
TEMPLATE_STACK="PANOS_TEMPLATE_STACK"
CERTPATH="PATH_TO_CERT_FILE_PEM_FORMAT"
KEYPATH="PATH_TO_KEY_FILE"
PASSPHRASE="PASSPHRASE_FOR_CERT"
COMMIT_WAIT_INTERVAL=30         # query commit status every 30 seconds
COMMIT_WAIT_ITERATIONS=20       # query commit status 20 times (20*30 = 600 seconds = 10 minutes)

cat $CERTPATH \
    $KEYPATH \
    > /tmp/$CERTNAME.pem

# Perform import and capture API response for certificate import
RESPONSE=$(curl --insecure -X POST \
  -F "file=@/tmp/$CERTNAME.pem" \
  "$FW/api/?type=import&category=keypair&certificate-name=$CERTNAME&format=pem&passphrase=$PASSPHRASE&target-tpl=$TEMPLATE&key=$KEY")

echo "Import response: $RESPONSE"

# Check if response contains successful response
if [[ "$RESPONSE" == *"Successfully imported"* ]]; then
  echo "Import successful, committing changes..."
  COMMIT_RESPONSE=$(curl -k "$FW/api/?type=commit&cmd=<commit></commit>&key=$KEY")

  JOB_ID=$(echo "$COMMIT_RESPONSE" | xmllint --xpath 'string(/response/result/job)' - 2>/dev/null)

  if [[ -z "$JOB_ID" ]]; then
    echo "❌Failed to get commit job ID"
    echo "$COMMIT_RESPONSE"
    exit 1
  fi

  echo "🧾Commit job ID: $JOB_ID"
  echo "Waiting for commit to complete..."

  # Try to get job status for COMMIT_WAIT_ITERATIONS times in COMMIT_WAIT_INTERVAL second intervals
  i=0
  while [ "$i" -lt $COMMIT_WAIT_ITERATIONS ]; do
    JOB_RESPONSE=$(curl -sk \
    "$FW/api/?type=op&cmd=<show><jobs><id>$JOB_ID</id></jobs></show>&key=$KEY")

    STATUS=$(echo "$JOB_RESPONSE" | xmllint --xpath 'string(//status)' - 2>/dev/null)

    if [[ "$STATUS" == "FIN" ]]; then
      break
    else
      echo "⏳Status: $STATUS"
      i=$((i + 1))
      sleep $COMMIT_WAIT_INTERVAL
    fi
  done

  RESULT=$(echo "$JOB_RESPONSE" | xmllint --xpath 'string(//job/result)' - 2>/dev/null)

  if [[ "$RESULT" == "OK" ]]; then
    echo "🎉Commit finished!"

    # Commit to Stack
    curl -k "$FW/api/?type=commit&cmd=<commit-all><template-stack><name>$TEMPLATE_STACK</name></template-stack></commit-all>&action=all&key=$KEY"
    rm /tmp/$CERTNAME.pem
  else
    echo "❌ Commit failed"
    echo "$JOB_RESPONSE"
    exit 1
  fi

else
  echo "Import failed, skipping commit"
  exit 1
fi

