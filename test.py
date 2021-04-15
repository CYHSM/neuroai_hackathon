import pytest
import pandas as pd


@pytest.fixture
def all_data():
    data_path = "SORTED_CLUSTERS/sorted_clusters.pkl"
    df = pd.read_pickle(data_path)
    return df


@pytest.fixture
def session_data(all_data):
    session_id = "M0_2017-11-15_14-52-15_of"
    session_data = all_data.loc[all_data["session_id"] == session_id]
    return session_data


def test_if_multiple_tetrodes_per_session():
    import glob

    sessions = glob.glob("*.png")
    sessions = [i.split("session_id")[1][:-4] for i in sessions]
    num_of_sessions_total = len(sessions)
    unique_sessions = set(sessions)
    assert unique_sessions != num_of_sessions_total


def test_average_firing_maps():
    pass


def test_stack_firing_maps():
    pass
