# Chapter 8: Recommender Systems

<img style="max-width:40%" alt="WBSFLIX logo" src="images/WBSFLIX_LOGO_GROUP_1.png" align="right"/>

In this week, we were studying three types of recommender systems for our fictitious WBSFLIX online DVD rental shop which managed to survive the online streaming disruption thanks to the convincing recommendations given by the shop owner - and now our recommender systems.

- _popularity-based_ recommendations based on number and score of
  ratings given by users without additional context
- _item-based_ recommendations based on similarity of ratings based
  on comparing different movies w.r.t. how different users liked the movies which allows to group and recommend similar movies
- _user-based_ recommendations based on similarity of the rating
  behaviour of users w.r.t. different movies which allows to estimate preference for new movies based on past ratings for a given user

For this, we [got familiar](docs/similarities.ipynb) with the _Pearson correlation coefficient_ and _cosine simmilarity_ and then worked on the various recommenders in a [Jupyter notebook](docs/wbsflix_recommendations.ipynb) for WBSFLIX. For user-based recommendations, we were using the [surprise](https://surpriselib.com/) library.

To wrap up, we saved the resulting recommendation data-sets as Python pickles (compressed with LZ4 due to their size) which allowed us to use that data in our streamlit app

[![Movie Recommendations 🍿](images/app-preview.png)](https://wbsflix-group-1.streamlit.app/)

which was also used for our group presentation. It also shows movie posters and links to pages from [tmdb](https://www.themoviedb.org/). __Go, check it out and see if it can produce some nice recommendations for you!__

Shout out to my team-mates [Matthias Nickola](https://www.linkedin.com/in/matthiasnickola/), [Roberto Cavotti](https://www.linkedin.com/in/roberto-cavotti/) and [Sebastian Foth](https://www.linkedin.com/in/sebastianfoth/) for our joint efforts!

