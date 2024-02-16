import streamlit as st

st.set_page_config(
  page_title="Because you watched this...",
  page_icon="🔮",
)

st.title("🔮 Because you watched this...")

'''
- This function retrieves recommendations based on _item similarity_.
- It calculates the scoring using _cosine_ similarity of user ratings between the reference item and all other items.
- The scores are attenuated by a _sigmoid_ function to underweight scores that are based on less than 10 common raters.
- The scores are _pre-computed_ and read from a pickle file.
'''

from recommenders import item_recommendations, load_movies
import pandas as pd
from display import *
import re

movies_df = load_movies()

#search_term = st.text_input('Search your favorite movie:', 'The Big Lebowski')

#search_term = re.sub(r'The', '', search_term).strip().lower()
#search_terms = search_term.split(' ')

# matches_df = (
#   movies_df
#   [lambda x:
#    x.title.apply(lambda title: all([term in title.lower() for term in search_terms]))]
#   .head(10)
# )

favorite_idx = st.selectbox('Search your favorite movie:', movies_df.index, format_func=lambda x: movies_df.loc[x].title)
number = st.radio('How many recommendations do you want?', [10, 20, 50], horizontal=True)

recommendations = item_recommendations(favorite_idx, number).iloc[1:].join(movies_df)

'# Your recommendations:'
movie_table(recommendations)


