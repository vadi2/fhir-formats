#!/usr/bin/env bash

# FHIR Formats

# Copyright (C) 2016-2017, 2022 Vadim Peretokin

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#      http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Set default FHIR version to STU3
version="STU3"

# Parse command line argument
while getopts ":r:" opt; do
  case $opt in
    r)
      # Set FHIR version
      version=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Create folder for data
mkdir $version

# Change to folder
cd $version

# Remove existing JSON files
rm *.json

# Download FHIR profiles and types
if [ "$version" = "STU3" ]; then
  wget http://hl7.org/fhir/STU3/profiles-types.json
  wget http://hl7.org/fhir/STU3/profiles-resources.json
elif [ "$version" = "R4" ]; then
  wget http://hl7.org/fhir/R4/profiles-types.json
  wget http://hl7.org/fhir/R4/profiles-resources.json
elif [ "$version" = "R5" ]; then
  wget http://hl7.org/fhir/R5/profiles-types.json
  wget http://hl7.org/fhir/R5/profiles-resources.json
else
  echo "Error: Invalid FHIR version specified"
  exit 1
fi
