# Example PDO cycle over lifespan of MERIS data


# required packages
require(reshape2)
require(ggplot2)

# working directory
setwd('..')

# load pdo data
pdo <- read.table("Data/pdo.txt", header=T)

#----------------------------------------------------#

# melt
pdomelt <- melt(pdo, id.vars = "YEAR")

# add date
for(j in 1:nrow(pdomelt)){
  pdomelt$MONTH[j] <- grep(pdomelt$variable[j],month.abb, ignore.case = T)
}
pdomelt$MONTH <- sprintf("%02d", pdomelt$MONTH)
pdomelt$date <- as.POSIXct(paste(pdomelt$YEAR,mnthnum,"01",sep="-"), format = "%Y-%m-%d")


# Make a grouping variable for each pos/neg segment
pdomelt$group <- "1"
pdomelt$group[pdomelt$value < 0] <- "-1"

# subset since 2000
pdorct <- pdomelt[pdomelt$YEAR >= 2000,]

# plot
pdoplot <- ggplot(data = pdorct) +
  geom_bar(aes(x=date,y=value,fill = group), 
           stat= "identity", position = "identity") +
  scale_fill_manual(values = c('blue', 'red'), guide="none") +
  scale_x_datetime(date_breaks = "1 year", date_labels = "%Y", expand = c(0,0)) +
  theme_bw()
pdoplot

pdf("Figures/pdo_2000-2015.pdf",height=4,width=7)
pdoplot
dev.off()



