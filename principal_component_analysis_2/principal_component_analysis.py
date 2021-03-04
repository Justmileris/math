import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from matplotlib import pyplot as plt

url = "https://archive.ics.uci.edu/ml/machine-learning-databases/iris/iris.data"
df = pd.read_csv(url, names=['sepal length','sepal width','petal length','petal width','target'])

############ Standardize the Data 
features = ['sepal length', 'sepal width', 'petal length', 'petal width']
# Separating out the features
x = df.loc[:, features].values
# Separating out the target
y = df.loc[:,['target']].values
# Standardizing the features
x = StandardScaler().fit_transform(x)

############ Dimensionality Reduction
pca = PCA(n_components=2)
'''
    In this example:

    If n_components=2, there is 2 PC's
    with 4 'ingredients' (columns) :
        PC1:    0.52237162 -0.26335492  0.58125401  0.56561105 and
        PC2:    0.37231836  0.92555649  0.02109478  0.06541577

    In PC1 3rd column value is the most important 'ingredient'
    In PC2 2nd column value is the most important 'ingredient'

    PC1 accounts for 73% of the variation
    PC2 accounts for 23% of the variation
'''

principalComponents = pca.fit_transform(x)
principalDf = pd.DataFrame(data = principalComponents, columns = ['PC1', 'PC2'])

plt.figure(figsize=(8, 6))
plt.bar(range(2), pca.explained_variance_ratio_, alpha=0.5, align='center', label='individual variance')
plt.legend()
plt.ylabel('Variance ratio')
plt.xlabel('Principal components')
plt.savefig('imgs/principal_component_analysis_1_variance_ratio.png')
plt.show()



finalDf = pd.concat([principalDf, df[['target']]], axis = 1)

fig = plt.figure(figsize = (8,8))
ax = fig.add_subplot(1,1,1) 
ax.set_xlabel('PC1', fontsize = 15)
ax.set_ylabel('PC 2', fontsize = 15)
ax.set_title('2 component PCA', fontsize = 20)
targets = ['Iris-setosa', 'Iris-versicolor', 'Iris-virginica']
colors = ['r', 'g', 'b']
for target, color in zip(targets,colors):
    indicesToKeep = finalDf['target'] == target
    ax.scatter(finalDf.loc[indicesToKeep, 'PC1']
               , finalDf.loc[indicesToKeep, 'PC2']
               , c = color
               , s = 50)
ax.legend(targets)
ax.grid()
plt.savefig('imgs/principal_component_analysis_2_pca.png')
plt.show()
