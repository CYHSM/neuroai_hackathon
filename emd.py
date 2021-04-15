import numpy as np
from scipy.stats import wasserstein_distance


def sliced_wasserstein(X, Y, num_proj=1e6):
    """
    https://stats.stackexchange.com/a/404915
    """
    dim = X.shape[1]
    ests = []
    for _ in range(num_proj):
        # sample uniformly from the unit sphere
        dir = np.random.rand(dim)
        dir /= np.linalg.norm(dir)

        # project the data
        X_proj = X @ dir
        Y_proj = Y @ dir

        # compute 1d wasserstein
        ests.append(wasserstein_distance(X_proj, Y_proj))
    return np.mean(ests)


example_rate_map = "normalised/average_firing_map_tetrode_4_cells_4_session_id_M11_2018-03-12_17-58-58_of.npy"
rate_map = np.load(example_rate_map)

another_rate_map = "normalised/average_firing_map_tetrode_4_cells_2_session_id_M15_2018-05-19_13-26-11_of.npy"
another_rate_map = np.load(another_rate_map)
print("distance to self", sliced_wasserstein(another_rate_map, another_rate_map, 1000))
print("distance to other map", sliced_wasserstein(rate_map, another_rate_map, 1000))
