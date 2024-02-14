import pandas as pd
from sklearn.base import ClassifierMixin, BaseEstimator
from sklearn.metrics import roc_curve

class FalseNegativeLimitedClassifier(ClassifierMixin, BaseEstimator):
  def __init__(self, estimator, min_tpr = 1.0, threshold_margin = 0.1):
    self.estimator = estimator
    self.min_tpr = min_tpr
    self.threshold_margin = threshold_margin

  def fit(self, X, y, **estimator_fit_params):
    self.estimator.fit(X, y, **estimator_fit_params)

    roc = pd.DataFrame(
      roc_curve(y, self.estimator.predict_proba(X)[:,1]),
      index = ['fpr', 'tpr', 'threshold']
      ).T

    try:
      # find first threshold with tpr >= min_tpr
      self.threshold_ = (
        roc[lambda x: x.tpr >= self.min_tpr]
        .threshold.iloc[0]
        * (1-self.threshold_margin) # apply margin
      )
    except IndexError:
      raise ValueError(f'No threshold found for min_tpr={self.min_tpr}')

    self.is_fitted_ = True

    return self

  def predict(self, X):
    return (self.estimator.predict_proba(X)[:, 1] > self.threshold_).astype(int)
