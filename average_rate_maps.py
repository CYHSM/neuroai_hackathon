import pandas as pd
import matplotlib.pyplot as plt
import numpy as np


def average_firing_maps(dataframe, animal):
    firing_map_size = 39
    average_firing_map = np.zeros((firing_map_size, firing_map_size))
    animal_count = 0
    for _, row in dataframe.iterrows():
        if int(row["session_id"][1:2]) == animal:
            animal_count += 1
            firing_map_to_add = row["firing_maps"][
                0:firing_map_size, 0:firing_map_size
            ]  # firing maps are slightly different sizes
            average_firing_map += firing_map_to_add
    average_firing_map = average_firing_map / animal_count
    return average_firing_map


def plot_average_firing_map(dataframe, animal):
    average_firing_map = average_firing_maps(dataframe, animal)
    plt.imshow(average_firing_map)
    plt.savefig(f"average_firing_map_{animal}.png")
    plt.close()


def compute_firing_map_bias():
    pass


def plot_a_firing_map(session_data):
    plt.imshow(session_data["firing_maps"].values[0])
    plt.savefig("test_firing_map.png")
    plt.close()


def main():
    data_path = "SORTED_CLUSTERS/sorted_clusters.pkl"
    df = pd.read_pickle(data_path)
    animals = range(10)
    for animal in animals:
        plot_average_firing_map(df, animal)


if __name__ == "__main__":
    main()
