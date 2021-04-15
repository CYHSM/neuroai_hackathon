import numpy as np
from scipy.stats import wasserstein_distance
import glob
import matplotlib.pyplot as plt


def sliced_wasserstein(X, Y, num_proj=int(1e3)):
    """
    https://stats.stackexchange.com/a/404915
    """
    dim = X.shape[1]
    ests = []
    for _ in range(num_proj):
        # sample uniformly from the unit sphere
        direction = np.random.rand(dim)
        direction /= np.linalg.norm(direction)

        # project the data
        X_proj = X @ direction
        Y_proj = Y @ direction

        # compute 1d wasserstein
        ests.append(wasserstein_distance(X_proj, Y_proj))
    return np.mean(ests)


def simulate_border_cells():
    import numpy as np
    import matplotlib.pyplot as plt
    from scipy.ndimage import gaussian_filter

    cells = []

    firing = np.zeros((39, 39))
    firing[34:39, :] = 1
    firing /= np.sum(firing)

    cells.append(firing)

    firing = np.zeros((39, 39))
    firing[0:5, :] = 1
    firing /= np.sum(firing)

    cells.append(firing)

    firing = np.zeros((39, 39))
    firing[:, 34:39] = 1
    firing /= np.sum(firing)

    cells.append(firing)

    firing = np.zeros((39, 39))
    firing[:, 0:5] = 1
    firing /= np.sum(firing)

    cells.append(firing)
    return cells


firing_maps = glob.glob("normalised/*.npy")
simulated_cells = simulate_border_cells()
most_border_cell = None
min_distance = 1e8
previous_border_cells = []
previous_distances = []
for a_firing_map in firing_maps:
    a_firing_map = np.load(a_firing_map)
    a_firing_map /= np.sum(a_firing_map)
    current_min_distance = 1e8
    for i in range(4):
        distance = sliced_wasserstein(a_firing_map, simulated_cells[i])
        if distance < current_min_distance:
            current_min_distance = distance
    distance = current_min_distance
    if distance < min_distance:
        most_border_cell = a_firing_map
        previous_border_cells.append(a_firing_map)
        min_distance = distance
        previous_distances.append(distance)

for i, border_cells in enumerate(previous_border_cells):
    plt.imshow(border_cells)
    distance = previous_distances[i]
    plt.title(f"distance {distance}")
    plt.savefig(f"border_cell_{i}.png")
    plt.close()
