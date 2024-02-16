import streamlit as st

st.set_page_config(
  page_title="Popular Movies",
  page_icon="🌡️",
)

st.title("🌡️ Popular Movies")

'''
Our first approach is a popularity-based recommender system.
We analyzed the ratings dataset to identify the most popular
movies among our users. These recommendations are displayed
prominently on the first row of the :red[WBSFLIX] site.

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

'''

from recommenders import pop_recommendations, load_movies
import pandas as pd
from display import *

movies_df = load_movies()

skip_quantile = st.slider('Skip percentile', 0, 100, 0)/100
'Shift the slider to the right to skip the most often rated movies and find some hidden gems!'

number = st.radio('How many recommendations do you want?', [10, 20, 50], horizontal=True)

recommendations = pop_recommendations(number, 1-skip_quantile).join(movies_df)

'# Your recommendations:'

movie_table(recommendations)


