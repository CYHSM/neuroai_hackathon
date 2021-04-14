import pytest
import pandas as pd


@pytest.fixture
def session_data():
    session_id = "M0_2017-11-15_14-52-15_of"
    data_path = "SORTED_CLUSTERS/sorted_clusters.pkl"
    df = pd.read_pickle(fp_data)
    session_data = df.loc[df["session_id"] == session_id]
    return session_data


def test_average_firing_maps():
    pass


def stack_firing_maps():
    pass
