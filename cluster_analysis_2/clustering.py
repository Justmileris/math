import matplotlib.pyplot as plt
import seaborn as sns; sns.set()
import numpy as np
from sklearn.datasets import make_blobs, make_moons
from sklearn.cluster import KMeans
from sklearn.metrics import pairwise_distances_argmin

X, Y = make_blobs(n_samples=100, centers=5, cluster_std=3, random_state=42)
plt.scatter(X[:, 0], X[:, 1], c=(1,0,0))
plt.savefig('imgs/clustering_1_init_points.png')
plt.show()
plt.clf()

# Scikit-Learn k-means algorithm ###########################
kmeans = KMeans(n_clusters=5)
kmeans.fit(X)
y_km = kmeans.fit_predict(X)
y_kmeans = kmeans.predict(X)

plt.scatter(X[:, 0], X[:, 1], c=y_kmeans, cmap='viridis')
centers = kmeans.cluster_centers_
plt.scatter(centers[:, 0], centers[:, 1], c=(1,0,0), s=200, alpha=0.5)
plt.savefig('imgs/clustering_2_init_classes.png')
plt.show()
plt.clf()

# K-means implementation ####################################
def find_clusters(X, n_clusters, rseed=42):
    # Randomly choose clusters
    rng = np.random.RandomState(rseed)
    i = rng.permutation(X.shape[0])[:n_clusters]
    centers = X[i]
    
    while True:
        # Assign labels based on closest center
        labels = pairwise_distances_argmin(X, centers)
        
        # Find new centers from means of points
        new_centers = np.array([X[labels == i].mean(0) for i in range(n_clusters)])
        
        # Check for convergence
        if np.all(centers == new_centers):
            break
        centers = new_centers
    
    return centers, labels

centers, labels = find_clusters(X, 5)
plt.scatter(X[:, 0], X[:, 1], c=labels, cmap='viridis')
plt.savefig('imgs/clustering_3_kmeans.png')
plt.show()
plt.clf()

# Moons example ##############################################
X, Y = make_moons(200, noise=.05, random_state=42)

# Kmeans #####################################################
labels = KMeans(2, random_state=42).fit_predict(X)
plt.scatter(X[:, 0], X[:, 1], c=labels, cmap='winter')
plt.savefig('imgs/clustering_4_moons_kmeans.png')
plt.show()
plt.clf()

# Kernelized k-means #########################################
from sklearn.cluster import SpectralClustering
model = SpectralClustering(n_clusters=2, affinity='nearest_neighbors',
                           assign_labels='kmeans')
labels = model.fit_predict(X)
plt.scatter(X[:, 0], X[:, 1], c=labels, cmap='winter')
plt.savefig('imgs/clustering_5_moons_kernelized_kmeans.png')
plt.show()
plt.clf()
