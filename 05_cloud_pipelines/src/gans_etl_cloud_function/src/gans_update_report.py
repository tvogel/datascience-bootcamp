#!/usr/bin/env python
# coding: utf-8

import dotenv
import nbformat
from nbconvert import HTMLExporter
from nbconvert.preprocessors import ExecutePreprocessor, TagRemovePreprocessor
from google.cloud import storage

def upload_blob(bucket_name, contents, content_type, destination_blob_name):
  """Uploads a file to the bucket."""
  # The ID of your GCS bucket
  # bucket_name = "your-bucket-name"
  # The path to your file to upload
  # source_file_name = "local/path/to/file"
  # The ID of your GCS object
  # destination_blob_name = "storage-object-name"

  storage_client = storage.Client()
  bucket = storage_client.bucket(bucket_name)
  blob = bucket.blob(destination_blob_name)
  blob.cache_control = 'no-cache'

  # Optional: set a generation-match precondition to avoid potential race conditions
  # and data corruptions. The request to upload is aborted if the object's
  # generation number does not match your precondition. For a destination
  # object that does not yet exist, set the if_generation_match precondition to 0.
  # If the destination object already exists in your bucket, set instead a
  # generation-match precondition using its generation number.
  generation_match_precondition = None

  blob.upload_from_string(contents, content_type, if_generation_match=generation_match_precondition)

  print(
      f"{len(contents)} bytes uploaded to {destination_blob_name}."
  )


def remove_collapsed_input(notebook):
  for cell in notebook.cells:
    if cell['metadata'].get('jupyter',{}).get('source_hidden', False):
      cell.transient = {"remove_source": True}

def make_report():
  dotenv.load_dotenv()

  notebook = nbformat.read('docs/gans_cities_display.ipynb', as_version=4)

  ep = ExecutePreprocessor(timeout=600, kernel_name='python3')
  ep.preprocess(notebook, {'metadata': {'path': 'docs/'}})

  remove_collapsed_input(notebook)

  html_exporter = HTMLExporter(template_name="lab")
  output, resources = html_exporter.from_notebook_node(notebook)

  upload_blob('wbscs_gans_cities_report', output, 'text/html', 'index.html')

  #with open('docs/gans_cities_display.html', 'w') as html_file:
  #  html_file.write(output)

if __name__ == '__main__':
  make_report()
