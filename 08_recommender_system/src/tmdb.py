import os
import dotenv
import requests
import streamlit as st

dotenv.load_dotenv()

def get_tmdb_config():
  url = "https://api.themoviedb.org/3/configuration"

  headers = {
    "accept": "application/json",
    "Authorization": f"Bearer {os.environ['TMDB_API_KEY']}"
  }

  return requests.get(url, headers=headers).json()

def get_movie_details(movie_id: int):
  try:
    tmdb_config = get_movie_details.config
  except AttributeError:
    get_movie_details.config = tmdb_config = get_tmdb_config()

  tmdb_poster_size = get_movie_details.poster_size

  url = f"https://api.themoviedb.org/3/movie/{movie_id}?language=en-US"

  headers = {
    "accept": "application/json",
    "Authorization": f"Bearer {os.environ['TMDB_API_KEY']}"
  }

  response = requests.get(url, headers=headers).json()

  try:
    return {
      'poster_url': f"{tmdb_config['images']['base_url']}{tmdb_config['images']['poster_sizes'][tmdb_poster_size]}{response['poster_path']}",
      'movie_url': f"https://www.themoviedb.org/movie/{movie_id}"
    }
  except:
    return None

get_movie_details.poster_size = 1

def get_all_movie_details(movie_df):
  '''
  Retrieve the poster URLs for a movie DataFrame

  This function retrieves the poster URLs for a movie DataFrame
  using the TMDB API.

  Parameters:
  movie_df: DataFrame
    DataFrame with a column 'tmdbId' containing the TMDB ID of the movie

  Returns:
  DataFrame
    DataFrame with the same index as the input DataFrame and a column
    'poster_url' containing the URL of the movie poster.
  '''
  import tmdb
  details = [ get_movie_details(tmdbId) for tmdbId in movie_df.tmdbId.astype(int) ]
  return (
    movie_df
    .assign(poster_url=[detail['poster_url'] if detail is not None else None for detail in details])
    .assign(movie_url=[detail['movie_url'] if detail is not None else None for detail in details])
  )

def footer():
  st.write(
  '''
  ---
  <img style="width:5em; float:left; margin-right:2ex" src="https://www.themoviedb.org/assets/2/v4/logos/v2/blue_square_2-d537fb228cf3ded904ef09b136fe3fec72548ebc1fea3fbbd1ad9e36364db38b.svg"/>
  This product uses the TMDB API but is not endorsed or certified by TMDB.
  ''', unsafe_allow_html=True)
