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


def test_plot_a_firing_map(session_data):
    from average_rate_maps import plot_a_firing_map

    plot_a_firing_map(session_data)


def test_average_firing_maps():
    pass


def test_stack_firing_maps():
    pass
