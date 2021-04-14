import pandas as pd
import matplotlib.pyplot as plt
import numpy as np


basic_data = pd.read_pickle("basic_info_included_data/all_mice_df.pkl")


def average_firing_maps(dataframe, session_id, tetrode):
    firing_map_size = 39
    average_firing_map = np.zeros((firing_map_size, firing_map_size))
    count = 0
    for _, row in dataframe.iterrows():
        if row["session_id"] == session_id:
            if extract_tetrode(row) == tetrode:
                count += 1
                firing_map_to_add = (
                    row["firing_maps"][0:firing_map_size, 0:firing_map_size]
                    / (row["firing_maps"][0:firing_map_size, 0:firing_map_size]).max()
                )
                average_firing_map += firing_map_to_add
                print("count", count)
    if count == 0:
        return None
    average_firing_map = average_firing_map / count
    return average_firing_map, count, tetrode


def plot_average_firing_map(dataframe, session_id, tetrode):
    average_firing_map = average_firing_maps(dataframe, session_id, tetrode)
    if average_firing_map == None:
        return
    else:
        average_firing_map, count, tetrode = average_firing_maps(
            dataframe, session_id, tetrode
        )
        plt.imshow(average_firing_map)
        plt.colorbar()
        plt.savefig(
            f"normalised/average_firing_map_tetrode_{tetrode}_cells_{count}_session_id_{session_id}.png"
        )
        plt.close()


def compute_firing_map_bias():
    pass


def plot_a_firing_map(session_data):
    plt.imshow(session_data["firing_maps"].values[0])
    plt.savefig("test_firing_map.png")
    plt.close()


def get_session_ids(df):
    session_ids = df["session_id"]
    unique_session_ids = set(session_ids)
    return unique_session_ids


def get_all_tetrodes():
    return set(basic_data["tetrode"])


def extract_tetrode(row):
    for basic_row in basic_data.iterrows():
        if (basic_row[1]["session_id"], basic_row[1]["cluster_id"]) == (
            row["session_id"],
            row["cluster_id"],
        ):
            return basic_row[1]["tetrode"]


def main():
    data_path = "SORTED_CLUSTERS/sorted_clusters.pkl"
    df = pd.read_pickle(data_path)
    session_ids = get_session_ids(df)
    for session_id in session_ids:
        tetrodes = get_all_tetrodes()
        for tetrode in tetrodes:
            plot_average_firing_map(df, session_id, tetrode)


if __name__ == "__main__":
    main()
