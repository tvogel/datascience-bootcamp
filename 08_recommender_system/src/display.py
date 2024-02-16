import streamlit as st
import recommenders
import tmdb

def movie_selectbox(label, key=None):
  try:
    movies_df = movie_selectbox.movies_df
    movie_titles = movie_selectbox.titles
  except AttributeError:
    movie_selectbox.movies_df = movies_df = recommenders.load_movies()
    movie_selectbox.titles = movie_titles = movies_df.title.to_list()

  index = st.selectbox(
    label,
    range(len(movie_titles)),
    key=key,
    index=None,
    format_func=lambda x: movie_titles[x]
  )
  return movies_df.index[index] if index is not None else None

def augment_recommendations(recommendations):
  return (
    recommendations
    .join(recommenders.load_movies())
    .pipe(tmdb.get_all_movie_details)
  )

def movie_table(recommendations):
  if 'rating_mean' in recommendations.columns:
    return st.dataframe(
      recommendations
      .reset_index()
      .assign(nr = lambda x: x.index + 1)
      .assign(
        rating_stars=lambda x:
          x.rating_mean.map(lambda r: '⭐'*round(r) + f' ({r:.1f})')
      )
      [['nr', 'title', 'rating_stars']]
      .rename(columns={'nr': 'Rank', 'title': 'Movie Title', 'rating_stars': 'Rating'}),
      hide_index=True
    )

  return st.dataframe(
    recommendations
    .reset_index()
    .assign(nr = lambda x: x.index + 1)
    [['nr', 'title']]
    .rename(columns={'nr': 'Rank', 'title': 'Movie Title'}),
    hide_index=True
  )

def movie_roster(recommendations):
  return st.markdown(''.join([ f'[![{r.title}]({r.poster_url})]({r.movie_url})' for r in recommendations.itertuples() if r.poster_url is not None]))
