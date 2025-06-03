repo = "https://cloud.r-project.org/"
package_list <- c("yaml","ncdf4","plyr","dplyr","parallel","abind","Matrix","lattice",
    "memuse","gplots","EnvStats","gridExtra","mvtnorm","plotly","MASS","svd","e1071",
    "png","lattice","stats","repr","ggplot2","txtplot","gplots","fields","data","tools",
    "plotrix","bits","spam","MixMatrix") 

install.packages(package_list, repos=repo)