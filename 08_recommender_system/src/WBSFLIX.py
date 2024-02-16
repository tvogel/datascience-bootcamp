import streamlit as st
import os
import tmdb

st.set_page_config(
  page_title="WBSFLIX",
  page_icon="🎬",
)

st.image(os.path.join(os.path.dirname(__file__), '../images/WBSFLIX_LOGO_GROUP_1.png'))

st.title("Movie Recommendations&nbsp;:popcorn:")



'''
__Building Personalized Movie Recommendations with Streamlit__

Introducing :red[WBSFLIX], an online DVD store in a small town near Berlin.
We've developed a recommendation system to enhance the user experience and
emulate the personalized touch of the store owner, _Pumbaa_&nbsp;:heart:.


Brought to you by group 1: Matthias, Roberto, Sebastian, Tilman
'''

tmdb.footer()
