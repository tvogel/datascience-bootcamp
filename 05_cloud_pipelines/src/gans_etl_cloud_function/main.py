#!/usr/bin/env python
# coding: utf-8

import sys
import functions_framework

for _ in [ 'src' ]:
  if not _ in sys.path:
    sys.path.append(_)

import gans_cities_scraping_and_api as gans
import gans_update_report

from flask import jsonify

@functions_framework.http
def run_etl_all(request):
  """
  GCF: Run all Gans ETL functions

  Entry point for Google Cloud Function

  :param request: the flask request to process
  :return: summary of retrieved data in JSON format
  """
  gans.connect_sql()
  summary = gans.etl_all()

  gans_update_report.make_report()

  return jsonify({
    "success": True,
    "summary": summary
  })
