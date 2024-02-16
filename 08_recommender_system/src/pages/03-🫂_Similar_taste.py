import streamlit as st
import tmdb

st.set_page_config(
  page_title="Similar taste",
  page_icon="🫂",
)

st.title("🫂 Similar taste")

'''
- This function retrieves recommendations based on _user similarity_.
- It uses the [surprise](https://surprise.readthedocs.io/en/stable/index.html)  library's _KNNWithZScore_ algorithm to calculate the scoring.
- The scores are _pre-computed_ and read from a pickle file.
- Groups of recommendations of the same score are _shuffled_ to prevent the same recommendations from being returned every time.
'''

from recommenders import user_recommendations, load_movies, load_ratings
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

'''
Pick your top three movies to find someone with similar taste:
'''

favorite_idx = []

for i in range(3):
  favorite_idx.append( st.selectbox(f'Pick your movie {i+1}', movies_df.index, format_func=lambda x: movies_df.loc[x].title) )

'''
Pick one movie that you did not like at all:
'''

anti_idx = st.selectbox(f'Pick your anti-movie', movies_df.index, format_func=lambda x: movies_df.loc[x].title)

number = st.radio('How many recommendations do you want?', [10, 20, 50], horizontal=True)

ratings_df = load_ratings()

try:
  similar_uid = (
    ratings_df
    .set_index('userId')
    [lambda x: (x.movieId == favorite_idx[0]) & (x.rating >= 3.5)]
    .rating
    .rename('rating_1')
    .to_frame()
    .join(
      ratings_df
      .set_index('userId')
      [lambda x: (x.movieId == favorite_idx[1]) & (x.rating >= 3.5)]
      .rating
      .rename('rating_2'),
      how='inner',
    )
    .join(
      ratings_df
      .set_index('userId')
      [lambda x: (x.movieId == favorite_idx[2]) & (x.rating >= 3.5)]
      .rating
      .rename('rating_3'),
      how='inner',
    )
    .join(
      ratings_df
      .set_index('userId')
      [lambda x: (x.movieId == anti_idx) & (x.rating <= 2)]
      .rating
      .rename('rating_anti'),
      how='inner',
    )
    .sample(1)
    .index[0]
  )
except:
  similar_uid = None

if similar_uid is None:
  '__Sorry, no matching user found for you :cry:__'
else:
  f'Yay, user {similar_uid} has a similar taste as you! :tada:'

  recommendations = (
    user_recommendations(similar_uid, number).iloc[1:]
    .rename(columns={'estimated_rating': 'rating_mean'})
    .pipe(augment_recommendations)
  )

  '# Your recommendations:'

  movie_roster(recommendations)
  movie_table(recommendations)


tmdb.footer()