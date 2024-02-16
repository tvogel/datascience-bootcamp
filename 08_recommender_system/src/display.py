import streamlit as st

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
