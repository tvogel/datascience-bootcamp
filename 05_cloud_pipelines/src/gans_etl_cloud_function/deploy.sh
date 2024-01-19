#!/bin/bash
gcloud functions deploy wbscs-cities-update \
--gen2 \
--runtime=python312 \
--region=europe-west1 \
--source=. \
--entry-point=run_etl_all \
--trigger-http
