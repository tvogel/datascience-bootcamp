import streamlit as st
import tmdb

st.set_page_config(
  page_title="Popular Movies",
  page_icon="🌡️",
)

st.title("🌡️ Popular Movies")

'''
- Introducing Our Popularity Recommender
- We utilized the widely recognized weighted average rating formula from IMDb

The score is calculated as

$$
W = \\frac{v\cdot R + m\cdot C}{v + m}
$$

where

- R is the average rating of the movie
- C is the mean rating across all movies
- v is the number of votes for the movie
- m is the minimum votes required to be listed,\\
  in our case: the 90th percentile of the number of votes.

Source: https://en.wikipedia.org/wiki/IMDb
'''

from recommenders import pop_recommendations, load_movies
import pandas as pd
from display import *
import tmdb

skip_quantile = st.slider('Skip percentile', 0, 100, 0)/100
'Shift the slider to the right to skip the most often rated movies and find some hidden gems!'

number = st.radio('How many recommendations do you want?', [10, 20, 50], horizontal=True)

recommendations = (
  pop_recommendations(number, 1-skip_quantile)
  .pipe(augment_recommendations)
)

'# Your recommendations:'

movie_roster(recommendations)
movie_table(recommendations)

tmdb.footer()