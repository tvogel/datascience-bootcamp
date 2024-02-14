import streamlit as st
import pandas as pd

st.title('Mushroom classification')

'''
This app demonstrates the use of a custom classifier that limits false negatives.
'''

st.warning(
  '''
  This is a toy example. Do not use this classifier for real-world applications.

  __Donot eat mushrooms based on the predictions of this classifier!__
  ''',
  icon='☠️')

'''
# Features

Select the features of the mushroom to predict whether it is poisonous:
'''

features = {
  'cap.shape': {
    'name': 'Cap Shape',
    'options': [('bell', 'b'), ('conical', 'c'), ('convex', 'x'), ('flat', 'f'), ('knobbed', 'k'), ('sunken', 's')]
  },
  'cap.color': {
    'name': 'Cap Color',
    'options': [('brown', 'n'), ('buff', 'b'), ('cinnamon', 'c'), ('gray', 'g'), ('green', 'r'), ('pink', 'p'), ('purple', 'u'), ('red', 'e'), ('white', 'w'), ('yellow', 'y')]
  },
  'bruises': {
    'name': 'Bruises?',
    'options': [('no', 'f'), ('yes', 't')]
  },
  'stalk.color.above.ring': {
    'name': 'Stalk Color Above Ring',
    'options': [('brown', 'n'), ('buff', 'b'), ('cinnamon', 'c'), ('gray', 'g'), ('orange', 'o'), ('pink', 'p'), ('red', 'e'), ('white', 'w'), ('yellow', 'y')]
  },
  'stalk.color.below.ring': {
    'name': 'Stalk Color Below Ring',
    'options': [('brown', 'n'), ('buff', 'b'), ('cinnamon', 'c'), ('gray', 'g'), ('orange', 'o'), ('pink', 'p'), ('red', 'e'), ('white', 'w'), ('yellow', 'y')]
  },
  'population': {
    'name': 'Population',
    'options': [('abundant', 'a'), ('clustered', 'c'), ('numerous', 'n'), ('scattered', 's'), ('several', 'v'), ('solitary', 'y')]
  }
}

query = pd.DataFrame(columns=features.keys())

for feature, meta in features.items():
  option = st.selectbox(meta['name'], meta['options'], format_func=lambda x: x[0] , key=feature)
  query[feature] = [option[1]]

import pickle
with open('./classifier.pickle', 'rb') as file:
  classifier = pickle.load(file)

prediction = classifier.predict(query)
prediction_proba = classifier.estimator.predict_proba(query)[0, 1]

color = f'color:{"red" if classifier.predict(query)[0] else "green"}'

st.markdown(f"""
# Prediction

Based on the features selected, the mushroom is predicted to be
  <div style="
    text-align:center;
    text-transform:uppercase;
    {color}"
>{'poisonous' if prediction else 'edible'}</div>

The probability of the mushroom being poisonous is
<div style="text-align:center">
{prediction_proba:.2%}
</div>
which is <span style="{color}">
{'below' if prediction_proba < classifier.threshold_ else 'above'}
</span>
the "safe" threshold of
<div style="text-align:center">
{classifier.threshold_:.2%}
</div>
used by the classifier.
""",
  unsafe_allow_html=True)
