# gaussian_distribution

R <- rbind(c(40, -10),c(-10, 4))
M <- c(704,103)

gen_univariate_norm <- function(M, R) { # mu,Sigma
  r = length(M)
  L = t(chol(R)) # Cholesky decomposition finds a unique lower triangular matrix (function chol() finds an upper triangular matrix, so we transpose it )
  Z = rnorm(r)
  return(L %*% Z + M)
}

gen_multi_norm <- function(dim, M, R, withPlot, printMultNormCovCorAndMean, n) { #(dim - dimensions (e.g., 2 for bivariate), M - mean, R - cov matrix, withPlot - true if with plot, n - sample quantity, printMultNormCovCorAndMean - true if print new cov matrix)
  X <- matrix(0, nrow=dim, ncol=n)
  for(i in 1:n){
    X[,i] = gen_univariate_norm(M,R)
  }
  if (withPlot) {
    chartTitle = paste("Bivariate normal, n =", toString(n))
    plot(X[1,], X[2,], main=chartTitle, asp=1)
  }
  if (printMultNormCovCorAndMean) {
    print(paste("Mean X[1]: ", toString(mean(X[1]))))
    print(paste("Mean X[2]: ", toString(mean(X[2]))))
    
    print("Covariance matrix:")
    print(cov(t(X)))
    
    print("Correlation matrix:")
    print(cor(t(X)))
  }
  return(t(X))
}

gen_multi_norm(2, M, R, TRUE, TRUE, 10000)



# kernel_density_estimation

N <- 300
probabilities <- c(0.7, 0.3)
means <- c(0, 3)
sigma_second <- (0.05)^(0.5)
standardDeviations <- c(1, sigma_second)

# Sample N random uniforms U
U <- runif(N)
# Variable to store the samples from the mixture distribution                                             
rand.samples <- rep(NA,N)

# Sampling from the mixture
for(i in 1:N){
  if(U[i]<probabilities[1]){
    rand.samples[i] = rnorm(n=1, mean=means[1], sd=standardDeviations[1])
  }else{
    rand.samples[i] = rnorm(n=1, mean=means[2], sd=standardDeviations[2])
  }
}

# Density plot of the random samples
plot(density(rand.samples),main="Density Estimate of the Mixture Model")

# Plotting the true density as a sanity check
x = seq(-4, 6,.1)
truth = probabilities[1]*dnorm(x, means[1], standardDeviations[1]) + probabilities[2]*dnorm(x, means[2], standardDeviations[2])
plot(density(rand.samples, bw=3),main="Density Estimate of the Mixture Model",ylim=c(0,.6),lwd=1)
lines(x,truth,col="red",lwd=1)
legend("topleft",c("Theoretical density function","Kernel density estimation"),col=c("red","black"),lwd=1)

library(MASS)

N <- 500
p1 <- 0.5

M1 <- c(0,0)
R1 <- matrix(c(1,0,0,1),2,2)

M2 <- c(2,5)
R2 <- matrix (c(0.04, -0.5, -0.5, 20),2,2)

gen_multi_norm_mix <- function(N, p1, M1, M2, R1, R2){
  n1 <- rbinom(1,size=N,prob=p1)
  n2 <- N-n1
  data1 <- gen_multi_norm(dim = 2, M = M1, R = R1, withPlot = FALSE, printMultNormCovCorAndMean = FALSE, n = n1)
  data2 <- gen_multi_norm(dim = 2, M = M2, R = R2, withPlot = FALSE, printMultNormCovCorAndMean = FALSE, n = n2)
  return(rbind(data1, data2))
}

mult_norm_mix_data <- gen_multi_norm_mix(N, p1, M1,M2,R1,R2)
plot(mult_norm_mix_data, xlab="X1", ylab="x2")

X_1 <- kde2d(mult_norm_mix_data[,1],mult_norm_mix_data[,2],n=70)
persp(X_1, main = "Default h",phi=30,theta=230,shade=0.3, border="blue",box=FALSE)

X_2 <- kde2d(mult_norm_mix_data[,1],mult_norm_mix_data[,2],n=70, h=c(1, 5))
persp(X_2, main = "h = (1, 5)",phi=30,theta=230,shade=0.3, border="blue",box=FALSE)

X_3 <- kde2d(mult_norm_mix_data[,1],mult_norm_mix_data[,2],n=70, h=c(0.2, 5))
persp(X_3, main = "h = (0.2, 5)",phi=30,theta=230,shade=0.3, border="blue",box=FALSE)

X_4 <- kde2d(mult_norm_mix_data[,1],mult_norm_mix_data[,2],n=70, h=c(3, 5))
persp(X_4, main = "h = (3, 5)",phi=30,theta=230,shade=0.3, border="blue",box=FALSE)



X_5 <- kde2d(mult_norm_mix_data[,1],mult_norm_mix_data[,2],n=70, h=c(1, 2))
persp(X_5, main = "h = (1, 2)",phi=30,theta=230,shade=0.3, border="blue",box=FALSE)

X_6 <- kde2d(mult_norm_mix_data[,1],mult_norm_mix_data[,2],n=70, h=c(1, 8))
persp(X_6, main = "h = (1, 8)",phi=30,theta=230,shade=0.3, border="blue",box=FALSE)
