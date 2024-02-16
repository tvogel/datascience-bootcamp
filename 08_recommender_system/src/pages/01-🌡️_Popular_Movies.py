import streamlit as st

st.set_page_config(
  page_title="Popular Movies",
  page_icon="🌡️",
)

st.title("🌡️ Popular Movies")

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


