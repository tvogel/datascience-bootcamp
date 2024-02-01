#!/usr/bin/env python
# coding: utf-8

# ### Harmonic distance calculation

import pandas as pd
from sklearn.metrics import pairwise_distances

# #### Spotify mapping of key index to key
note_table = [ 'C', 'C#/Db', 'D', 'D#/Eb', 'E', 'F', 'F#/Gb', 'G', 'G#/Ab', 'A', 'A#/Bb', 'B' ]

# #### Circle of fifths
# According to harmonic progression, nearby keys are harmonic. Because it's a circle, 'C' is also next to 'F'.

fifth_table = [ 7 * i % 12 for i in range(12) ]

# #### Mapping of distance between keys to harmonic distance
# That is if the distance in key index is 7, e.g. 'C' -> 'G', the distance is only 1 because it is just one fifth above. Or, the distance from 'D' to 'C' is 2 which also happens to be two fifths (downwards).

inv_fifth_table = [ (fifth_table.index(i)+5)%12 - 5 for i in range(12) ]

# #### Distance-function for comparing keys and a distance table between all keys

def key_distance(key1: int, key2: int):
  return inv_fifth_table[(key2 - key1) % 12]

# #### Metric that calculates euclidean distance but aware of the cyclic key distance:

def key_aware_metric(X, Y, key_index=None, mode_index=None, key_weight=1, mode_weight=1):
  if key_index == None:
    return (sum((X - Y)**2))**.5

  ordinary_columns = [ i for i in range(len(X)) if not i in [ key_index, mode_index ] ] # still take mode as an ordinary column, too
  sum2 = sum((X[ordinary_columns] - Y[ordinary_columns])**2)
  key_x = int(X[key_index])
  key_y = int(Y[key_index])
  if mode_index != None:
    key_x += 3 if X[mode_index] == 0 else 0
    key_y += 3 if Y[mode_index] == 0 else 0
  sum2 += (key_weight/6*key_distance(key_x, key_y))**2
  if mode_index != None:
    sum2 += (mode_weight*(X[mode_index]-Y[mode_index]))**2
  return sum2**.5

# #### And a variant of `pairwise_distances` that recognizes the `key` column and applies the `key_aware_metric`:

def key_aware_pairwise_distances(df, key_weight=1, mode_weight=1):
  try:
    key_index = df.columns.values.tolist().index('key')
  except:
    key_index = None
  try:
    mode_index = df.columns.values.tolist().index('mode')
  except:
    mode_index = None

  # print(f'key_index {key_index}, mode_index {mode_index}')

  return pairwise_distances(
    df,
    metric=key_aware_metric,
    key_index=key_index,
    mode_index=mode_index,
    key_weight=key_weight,
    mode_weight=mode_weight)

def harmonic_scale(df, unwrap=True, drop_extra=True):
  '''
  Transform (key, mode) columns into (harmonic, mode) columns in which the new "harmonic"
  column has the property that euclidean distance means harmonic distance, i.e. C major and
  G major are next to each other. In order to also relate keys across the F#/Gb to C#/Db
  break point of the circle of fifths, each row is duplicated and tranposed an octave up
  optionally.

  :param df: original data-frame, must have `key` and `mode` columns
  :param unwrap: whether to create duplicated rows transposed an octave up
  :param drop_extra: whether to drop extra columns major_key and key after transformation
  :return: new data-frame
  '''
  df = (
    df
    .assign(major_key=lambda x: (x.key + (1-x['mode']) * 3)%12)
    .assign(harmonic=lambda x: x.apply(lambda r: inv_fifth_table[r.major_key], axis=1))
  )
  if unwrap:
    df = pd.concat(
      [
        df.iloc[[row]].assign(harmonic=lambda x: x.harmonic+shift*12)
        for row in range(len(df))
        for shift in range(0,2)
      ]
    )
  if drop_extra:
    df = df.drop(['major_key', 'key'], axis=1)
  return df