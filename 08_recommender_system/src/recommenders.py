import pandas as pd

def pop_recommendations(n=10, max_quantile=1.0):
  '''
  Retrieve recommendations based on popularity

  This function is using a custom scoring method

      score = rating_mean^2 * rating_count

  This overweights the rating over the count in order
  to prevent movies with many mediocre ratings to rank
  higher than movies with fewer but better ratings.

  The scores are pre-computed and read from a pickle file.

  Parameters:
  n: int
    Number of recommendations to return
  max_quantile: float
    default: all quantiles
    Maximum quantile of _number_ of ratings to consider.
    This allows to filter out the most frequently rated movies in
    order to give more visibility to "hidden gems".
  '''
  return (
    pop_recommendations.df
    [lambda x: x.count_quantile <= max_quantile]
    .head(n)
  )

def item_recommendations(ref_item, n=10):
  '''
  Retrieve recommendations based on item similarity

  The scoring is based on the cosine similarity of user ratings
  between the reference item and all other items. The score is then
  attenuated by a sigmoid function to underweight scores
  that are based on less than 10 common raters. The scores are
  pre-computed and read from a pickle file.

  Parameters:
  ref_item: int
    Reference item to base the recommendations on
  n: int
    Number of recommendations to return
  '''
  try:
    return (
        item_recommendations.df
        .loc[ref_item]
        .head(n+1)
        .set_index('movieId')
    )
  except KeyError:
    return pd.DataFrame(columns=['movieId', 'score', 'raters'])

def user_recommendations(user_id, n):
  '''
  Retrieve recommendations based on user similarity

  The scoring is using the surprise library's KNNWithZScore algorithm.
  The scores are pre-computed and read from a pickle file.

  Groups of recommendations of the same score are shuffled to
  prevent the same recommendations to be returned every time.

  Parameters:
  user_id: int
    User to retrieve recommendations for
  n: int
    Number of recommendations to return
  '''
  # Filter the testset to include only rows with the specified user_id
  #filtered_testset = [row for row in testset if row[0] == user_id]

  # Make predictions on the filtered testset
  #predictions = algo.test(filtered_testset)

  # Create a DataFrame from the predictions and return the top n predictions based on the estimated ratings ('est')
  return (
      user_recommendations.df
      .loc[user_id]
      .groupby('est')
      .sample(frac=1)
      .nlargest(n, 'est')
      .rename(columns={'iid': 'movieId', 'est': 'estimated_rating'})
      .set_index('movieId')
      [['estimated_rating']]
  )

def load_movies():
  '''
  Load the movies.csv file

  The file is located in the data directory.
  '''
  import pandas as pd
  import os
  movies_df = pd.read_csv(
    os.path.join(
      os.path.dirname(__file__),
      '../data/ml-latest-small/movies.csv'
    ),
    index_col='movieId'
  )
  links_df = pd.read_csv(
    os.path.join(
      os.path.dirname(__file__),
      '../data/ml-latest-small/links.csv'
    ),
    index_col='movieId'
  )
  return movies_df.join(links_df)

def load_ratings():
  '''
  Load the ratings.csv file

  The file is located in the data directory.
  '''
  import pandas as pd
  import os
  return pd.read_csv(
    os.path.join(
      os.path.dirname(__file__),
      '../data/ml-latest-small/ratings.csv'
    )
  )

def unpickle_data():
  '''
  Load pre-computed data from a pickle file

  This function is called at the end of the module to load
  pre-computed data from a pickle file. The data is stored in
  an lz4 compressed pickle file in the data directory.
  '''
  import pickle
  import lz4.frame
  import os
  with lz4.frame.open(
    os.path.join(
      os.path.dirname(__file__),
      '../data/recommenders.pickle.lz4'),
    'rb') as f:
      recommender_data = pickle.load(f)
  for k, v in recommender_data.items():
      globals()[k].__dict__ = v

try:
  unpickle_data()
except FileNotFoundError:
  # If the pickle file is not found, we're probably training and just
  pass

