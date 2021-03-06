
############################################################################
#########                                                          #########
#########       THIS FILE NO MORE DEALS WITH RECOVERED CASES       #########
#########                                                          #########
############################################################################

#########               Diamond Princess is also removed           #########

# Setting the working directory
setwd("~/Documents/A-tracking-of-COVID-19/COVID-19/")

#------------------ VARIABLES -----------------#

####   Daily Data   ####
#   (cols = no. of days)      ---->     Tables = 3 each   (9)

#   One Country (rows = No. of State) =         One.Country.States.daily.<Confirmed/Deaths/Recovered>
#   One Country (aggrigate i.e. 1-row) =        One.Country.Aggregate.daily.<Confirmed/Deaths/Recovered>
#   All Country (rows = No. of Countries) =     All.Countries.daily.<Confirmed/Deaths/Recovered>


####   Till-Date Data   ####
#   (cols = Confirm, Deaths, Recovered)      ---->     Tables = 1 each    (3)

#   One Country (rows = No. of State) =         One.Country.States.summary
#   One Country (aggrigate i.e. 1-row) =        One.Country.Aggregate.summary
#   All Country (rows = No. of Countries) =     All.Countries.summary



####   Bulk Data   ####
#   TO BE CREATED

#----------------------------------------------#



#####  LIBRARIES  #####
# loading library for string operations
library(stringr)


#----------------------------------------------#



### data files (csv) ###

# Main
Confirmed <- read.csv("cleaned/time_series_19-covid-Confirmed.csv")
Deaths <- read.csv("cleaned/time_series_19-covid-Deaths.csv")
#Recovered <- read.csv("cleaned/time_series_19-covid-Recovered.csv")

# sorting Countrywise
Confirmed = Confirmed[order(Confirmed$Country.Region),]
Deaths = Deaths[order(Deaths$Country.Region),]
#Recovered = Recovered[order(Recovered$Country.Region),]

row.names(Confirmed) <- NULL
row.names(Deaths) <- NULL
#row.names(Recovered) <- NULL
#####################


# Hubei
Hubei.Confirmed = read.csv("cleaned/Hubei/time_series_19-covid-Confirmed.csv")
Hubei.Deaths = read.csv("cleaned/Hubei/time_series_19-covid-Deaths.csv")
#Hubei.Recovered = read.csv("cleaned/Hubei/time_series_19-covid-Recovered.csv")

# Cruise
Diamond.Princess.Confirmed = read.csv("cleaned/Diamond-Princess/time_series_19-covid-Confirmed.csv")
Diamond.Princess.Deaths = read.csv("cleaned/Diamond-Princess/time_series_19-covid-Deaths.csv")
#Diamond.Princess.Recovered = read.csv("cleaned/Diamond-Princess/time_series_19-covid-Recovered.csv")


#View(Confirmed)
#View(Deaths)
#View(Recovered)

#View(Hubei.Confirmed)
#View(Hubei.Deaths)
#View(Hubei.Recovered)

#View(Diamond.Princess.Confirmed)
#View(Diamond.Princess.Deaths)
#View(Diamond.Princess.Recovered)


#----------------------------------------------#


# Removing outlier i.e. Hubei
Hubei.Confirmed <- cbind(Hubei.Confirmed[,1], Hubei.Confirmed[,5:ncol(Hubei.Confirmed)])
Hubei.Deaths <- cbind(Hubei.Deaths[,1], Hubei.Deaths[,5:ncol(Hubei.Deaths)])
#Hubei.Recovered <- cbind(Hubei.Recovered[,1], Hubei.Recovered[,5:ncol(Hubei.Recovered)])

names <- c("State", colnames(Hubei.Confirmed[2:ncol(Hubei.Confirmed)]))
colnames(Hubei.Confirmed) <- names
colnames(Hubei.Deaths) <- names
#colnames(Hubei.Recovered) <- names
#----------------------------------------------#

# Removing outlier i.e. Diamond Princess
Diamond.Princess.Confirmed <- cbind(Diamond.Princess.Confirmed[,1], Diamond.Princess.Confirmed[,5:ncol(Diamond.Princess.Confirmed)])
Diamond.Princess.Deaths <- cbind(Diamond.Princess.Deaths[,1], Diamond.Princess.Deaths[,5:ncol(Diamond.Princess.Deaths)])
#Diamond.Princess.Recovered <- cbind(Diamond.Princess.Recovered[,1], Diamond.Princess.Recovered[,5:ncol(Diamond.Princess.Recovered)])

names <- c("Loaction", colnames(Diamond.Princess.Confirmed[2:ncol(Diamond.Princess.Confirmed)]))
colnames(Diamond.Princess.Confirmed) <- names
colnames(Diamond.Princess.Deaths) <- names
#colnames(Diamond.Princess.Recovered) <- names
#----------------------------------------------#

# Some interesting facts
Countries = levels(Confirmed$Country.Region)


#######################
#####  Functions  #####
#######################

###   processing daily data   ###

##################
country.spread.daily <- function(dfName, country) {
  df <- get(dfName)
  df = df[which(str_detect(df$Country.Region, country)),]
  df = cbind(States = df[,1], Country = df[,2], df[,5:ncol(df)])
  row.names(df) <- NULL
  
  return (df)
}


country.aggregate.daily  <-  function(dfName, country) {
  
  temp = country.spread.daily(dfName, country)            # all states' data of a country
  #df = temp[-(1:nrow(temp)),]                             # structure of required dataframe
  df = temp[1,] 
  
  df[3:ncol(temp)] = apply(   temp[,3:ncol(temp)],
                            2,
                            sum
                        )                               # applying sum of all the states' values
  df = df[2:ncol(df)]                                   # removing column 'States'
  
  row.names(df) <- NULL
  
  return(df)
}


countries.daily <-  function(dfName, cList = Countries) {
  
  n = length(cList)       # number of countries
  
  flag = 0
  
  for (i in cList) {
    
    if(flag == 0) {
      df = country.aggregate.daily(dfName, i)
      flag = 1
    } else {
      temp = country.aggregate.daily(dfName, i)
      df = rbind(df, temp)
    }
    
  }
  
  row.names(df) <- NULL
  
  return(df)
}
##################



###   processing data till date   ###

##################
states.summarizer = function(cName) {
  
  C <- country.spread.daily("Confirmed", cName)
  D <- country.spread.daily("Deaths", cName)
  #R <- country.spread.daily("Recovered", cName)
  
  allStates <- as.character(C$State)   # list of states in given country
  
  ###### overall data of the country (all states) ######
  df = data.frame(
    States = allStates,
    Confirmed = apply(C[, 3:ncol(C)], 1, max),
    Deaths = apply(D[, 3:ncol(D)], 1, max),
    #Recovered = apply(R[, 3:ncol(R)], 1, max),
    #"Active Cases" = apply(C[, 3:ncol(C)], 1, max) - (apply(D[, 3:ncol(D)], 1, max) + apply(R[, 3:ncol(R)], 1, max)),
    #"Closed Cases" = apply(D[, 3:ncol(D)], 1, max) + apply(R[, 3:ncol(R)], 1, max)
    "Active Cases" = apply(C[, 3:ncol(C)], 1, max) - apply(D[, 3:ncol(D)], 1, max),    # excluding recovered
    "Closed Cases" = apply(D[, 3:ncol(D)], 1, max)
  )
  
  return(df)
}


country.summarizer = function(cName) {
  df = states.summarizer(cName)
  temp = df[1,]
  
  c = data.frame(Country = factor(cName))
  temp[2:ncol(df)] = apply(   df[,2:ncol(df)],
                              2,
                              sum
  )
  df = cbind(c, temp[2:ncol(temp)])               # replace state name with country
  
  return(df)
}


total.summarizer <-  function(cList = Countries) { # country wise
  
  n = length(cList)       # number of countries
  df = country.summarizer(cList[1])
  
  for (i in 2:n) {
    temp = country.summarizer(cList[i])
    df = rbind(df, temp)
  }
  row.names(df) <- NULL
  
  return(df)
}
##################



###   In Bulk   ###
countries.daily.bulk.summary = function(cList) { # date wise country data
  
  # structure of resulting dataset (initially blank)
  df <- data.frame(
    Country = NULL,
    Day = NULL,           # day no.
    Date = NULL,
    Confirmed = NULL,
    Deaths = NULL,
    Recovered = NULL,
    "Active Cases" = NULL,
    "Closed Cases" = NULL
  )
  
  # calculating all countries' data (date wise) through iteration
  for(i in cList) {
    this.one.confirmed = country.aggregate.daily("Confirmed", i)
    this.one.deaths = country.aggregate.daily("Deaths", i)
    #this.one.recovered = country.aggregate.daily("Recovered", i)
    
    times = ncol(this.one.confirmed)-1      # no. of days
    day = 1:times
    d = as.Date("21-01-2020", format(c("%d-%m-%Y")))
    
    date = as.character((day + d), format(c("%d-%m-%Y")))      # its lenngth is equal to --> no. of days
    date = factor(c(date), levels = date)
    
    #max(Deaths.temp[1,5:ncol(Deaths.temp)])
    confirmed = as.numeric(this.one.confirmed[1,2:ncol(this.one.confirmed)])
    
    deaths = as.numeric(this.one.deaths[1,2:ncol(this.one.deaths)])
    
    #recovered = as.numeric(this.one.recovered[1,2:ncol(this.one.recovered)])
    
    dataset <- data.frame(
      Country = rep(i, times),
      Day = factor(c(1:length(date)), levels = 1:length(date)),
      Date = date,
      Confirmed = confirmed,
      Deaths = deaths,
      #Recovered = recovered,
      #"Active Cases" = (confirmed) - (deaths + recovered),
      #"Closed Cases" = deaths + recovered
      "Active Cases" = (confirmed) - (deaths),
      "Closed Cases" = deaths
    )
    
    # joining this country
    df = rbind(df, dataset)
  }
  
  
  return(df)
}


world.daily.bulk.summary = function(dfC, dfD, dfR) { #date wise WORLD data
  
  this.one.confirmed = find.aggrigate(dfC, "World")
  this.one.deaths = find.aggrigate(dfD, "World")
  #this.one.recovered = find.aggrigate(dfR, "World")
  
  times = ncol(this.one.confirmed)-1      # no. of days
  day = 1:times
  d = as.Date("21-01-2020", format(c("%d-%m-%Y")))
  
  date = as.character((day + d), format(c("%d-%m-%Y")))      # its length is equal to --> no. of days
  date = factor(c(date), levels = date)
  
  
  confirmed = as.numeric(this.one.confirmed[1,2:ncol(this.one.confirmed)])
  
  deaths = as.numeric(this.one.deaths[1,2:ncol(this.one.deaths)])
  
  #recovered = as.numeric(this.one.recovered[1,2:ncol(this.one.recovered)])
  
  df <- data.frame(
    Location = rep("World", times),
    Day = factor(c(1:length(date)), levels = 1:length(date)),
    Date = date,
    Confirmed = confirmed,
    Deaths = deaths,
    #Recovered = recovered,
    #"Active Cases" = (confirmed) - (deaths + recovered),
    #"Closed Cases" = deaths + recovered
    "Active Cases" = (confirmed) - (deaths),
    "Closed Cases" = deaths
  )
  
  
  return(df)
}
##################



##   Datewise   ##

##################
datewise <- function(Country, yesORno, cList = Countries) {
  df = countries.daily.bulk.summary(Countries)
  df = df[ which(str_detect(df$Country, Country, negate = yesORno)), ]
  
  row.names(df) <- NULL
  return(df)
}


find.aggrigate <- function(df1, colName) { ##  adder
  first <- get(df1)
  temp = first[1,]
  
  c = data.frame(Location = colName)
  temp[2:ncol(first)] = apply(   first[,2:ncol(first)],
                              2,
                              sum
  )
  df = cbind(c, temp[2:ncol(temp)])  
  
  return(df)
}


outlier.datewise <- function(Name, df1, df2) { # hubei, dim. pr. etc..   #  function(Name, df1, df2, df3)
  get(df1) -> dfC
  get(df2) -> dfD
  #get(df3) -> dfR
  
  day = 1:(ncol(dfC)-1)
  d = as.Date("21-01-2020", format(c("%d-%m-%Y")))
  
  date = as.character((day + d), format(c("%d-%m-%Y")))      # its lenngth is equal to --> no. of days
  date = factor(c(date), levels = date)
  
  confirmed = as.numeric(dfC[1,2:ncol(dfC)])
  deaths = as.numeric(dfD[1,2:ncol(dfD)])
  #recovered = as.numeric(dfR[1,2:ncol(dfR)])
  
  df <- data.frame(
    State = rep(Name, (ncol(dfC)-1)),
    Day = factor(c(1:length(date)), levels = 1:length(date)),
    Date = date,
    Confirmed = confirmed,
    Deaths = deaths,
    #Recovered = recovered,
    #"Active Cases" = (confirmed) - (deaths + recovered),
    #"Closed Cases" = deaths + recovered
    "Active Cases" = (confirmed) - (deaths),
    "Closed Cases" = deaths
  )
  
  row.names(df) <- NULL
  
  return(df)
}
##################

#-----------------------------------------------------------------------#





#################################################
#####    all about a particular Country     #####
#################################################

# just change the country name to get desired data
Country = "China"


###### country's (all states') daily data ######
One.Country.States.daily.Confirmed <- country.spread.daily("Confirmed", Country)
One.Country.States.daily.Deaths <- country.spread.daily("Deaths", Country)
#One.Country.States.daily.Recovered <- country.spread.daily("Recovered", Country)

#View(One.Country.States.daily.Confirmed)
#View(One.Country.States.daily.Deaths)
#View(One.Country.States.daily.Recovered)

################################################
One.Country.Aggregate.daily.Confirmed <- country.aggregate.daily("Confirmed", Country)
One.Country.Aggregate.daily.Deaths <- country.aggregate.daily("Deaths", Country)
#One.Country.Aggregate.daily.Recovered <- country.aggregate.daily("Recovered", Country)

#View(One.Country.Aggregate.daily.Confirmed)
#View(One.Country.Aggregate.daily.Deaths)
#View(One.Country.Aggregate.daily.Recovered)

########  All states of all Countries (Spread of all Countries)  #########
All.Countries.daily.Confirmed <- countries.daily("Confirmed")
All.Countries.daily.Deaths <- countries.daily("Deaths")
#All.Countries.daily.Recovered <- countries.daily("Recovered")

#View(All.Countries.daily.Confirmed)
#View(All.Countries.daily.Deaths)
#View(All.Countries.daily.Recovered)

###### overall data of the country (all states) ######
One.Country.States.summary = states.summarizer(Country)
One.Country.Aggregate.summary = country.summarizer(Country)
All.Countries.summary = total.summarizer(Countries)





#################################################

main = data.frame(
        "States" = NULL,
        "Country" = NULL,
        "Confirmed" = NULL,
        "Deaths" = NULL,
        "Active.Cases" = NULL,
        "Closed.Cases" = NULL
)

countries = levels(Confirmed$Country.Region)
for(cnt in countries) {
  temp = states.summarizer(cnt)
  colNameList = colnames(temp)
  
  temp = cbind(temp[,1], Country = rep(cnt, nrow(temp)), temp[,2:ncol(temp)])
  colnames(temp) <- c(colNameList[1], colnames(temp[2:6]))
  
  #############
  main = rbind(main, temp)
  
}
print(main)

write.csv(main, file = "ready_to_use/COVID-19/World/allLocationAggrigateSummary.csv", row.names = FALSE)
#################################################





Hubei.summary = data.frame(
  State = "Hubei",
  
  Confirmed = max(Hubei.Confirmed[,2:ncol(Hubei.Confirmed)]),
  Deaths = max(Hubei.Deaths[,2:ncol(Hubei.Deaths)]),
  #Recovered = max(Hubei.Recovered[,2:ncol(Hubei.Recovered)]),
  #"Active Cases" = (max(Hubei.Confirmed[,2:ncol(Hubei.Confirmed)])) - (max(Hubei.Deaths[,2:ncol(Hubei.Deaths)]) + max(Hubei.Recovered[,2:ncol(Hubei.Recovered)])),
  #"Closed Cases" = max(Hubei.Deaths[,2:ncol(Hubei.Deaths)]) + max(Hubei.Recovered[,2:ncol(Hubei.Recovered)])
  "Active Cases" = (max(Hubei.Confirmed[,2:ncol(Hubei.Confirmed)])) - max(Hubei.Deaths[,2:ncol(Hubei.Deaths)]),
  "Closed Cases" = max(Hubei.Deaths[,2:ncol(Hubei.Deaths)])
)

# Diamond.Princess.summary = data.frame(
  # Location = "Diamond Princess",
  
  # Confirmed = max(Diamond.Princess.Confirmed[,2:ncol(Diamond.Princess.Confirmed)]),
  # Deaths = max(Diamond.Princess.Deaths[,2:ncol(Diamond.Princess.Deaths)]),
  #Recovered = max(Diamond.Princess.Recovered[,2:ncol(Diamond.Princess.Recovered)]),
  #"Active Cases" = (max(Diamond.Princess.Confirmed[,2:ncol(Diamond.Princess.Confirmed)])) - (max(Diamond.Princess.Deaths[,2:ncol(Diamond.Princess.Deaths)]) + max(Diamond.Princess.Recovered[,2:ncol(Diamond.Princess.Recovered)])),
  #"Closed Cases" = max(Diamond.Princess.Deaths[,2:ncol(Diamond.Princess.Deaths)]) + max(Diamond.Princess.Recovered[,2:ncol(Diamond.Princess.Recovered)])
  # "Active Cases" = (max(Diamond.Princess.Confirmed[,2:ncol(Diamond.Princess.Confirmed)])) - max(Diamond.Princess.Deaths[,2:ncol(Diamond.Princess.Deaths)]),
  # "Closed Cases" = max(Diamond.Princess.Deaths[,2:ncol(Diamond.Princess.Deaths)])
# )

#View(One.Country.States.summary)
#View(One.Country.Aggregate.summary)
#View(All.Countries.summary)

#View(Hubei.summary)
#View(Diamond.Princess.summary)

##########################################
#########    about the world     #########
##########################################

allStates <- as.character(Confirmed$Province.State)
allCountries <- as.character(Confirmed$Country.Region)

####### all states of all the countries #######
bulk.summary = data.frame(
  States = allStates,
  Country = allCountries,
  
  Confirmed = apply(Confirmed[, 5:ncol(Confirmed)], 1, max),
  Deaths = apply(Deaths[, 5:ncol(Deaths)], 1, max),
  #Recovered = apply(Recovered[, 5:ncol(Recovered)], 1, max),
  #"Active Cases" = (apply(Confirmed[, 5:ncol(Confirmed)], 1, max)) - (apply(Deaths[, 5:ncol(Deaths)], 1, max) + apply(Recovered[, 5:ncol(Recovered)], 1, max)),
  #"Closed Cases" = apply(Deaths[, 5:ncol(Deaths)], 1, max) + apply(Recovered[, 5:ncol(Recovered)], 1, max)
  "Active Cases" = (apply(Confirmed[, 5:ncol(Confirmed)], 1, max)) - apply(Deaths[, 5:ncol(Deaths)], 1, max),
  "Closed Cases" = apply(Deaths[, 5:ncol(Deaths)], 1, max)
)
#View(bulk.summary)



###########################
##### on daily basis ######
###########################

# date wise summary of all the countries
dataset.countryWise = countries.daily.bulk.summary(Countries)
dataset.dateWise = dataset.countryWise[order(dataset.countryWise$Date),]
row.names(dataset.dateWise) <- NULL
#View(dataset.countryWise)
#View(dataset.dateWise)

#--------------------------------------------------------------------#
One.country.dataset.dateWise = datewise(Country, FALSE, Countries)
Rest.world.dataset.dateWise = datewise(Country, TRUE, Countries)

#View(One.country.dataset.dateWise)
#View(Rest.world.dataset.dateWise)

############
Hubei.datewise = outlier.datewise("Hubei", "Hubei.Confirmed", "Hubei.Deaths")   #         , "Hubei.Recovered")
#Diamond.Princess.datewise = outlier.datewise("Diamond Princess", "Diamond.Princess.Confirmed", "Diamond.Princess.Deaths")         #    , "Diamond.Princess.Recovered")

#View(Hubei.datewise)
#View(Diamond.Princess.datewise)



####################################################################################################################
####################################################################################################################





#   NOTHING TO BE ALTERED BELOW!!!


#################################
###   Writing to Data File    ###
#################################
#############  41  ##############

cName = "United States"

################      US     #################
# can be sorted StateWise
write.csv(country.spread.daily("Confirmed", cName), file = "ready_to_use/COVID-19/US/US_States_daily_Confirmed.csv", row.names = FALSE)
write.csv(country.spread.daily("Deaths", cName), file = "ready_to_use/COVID-19/US/US_States_daily_Deaths.csv", row.names = FALSE)
#write.csv(country.spread.daily("Recovered", cName), file = "ready_to_use/COVID-19/US/US_States_daily_Recovered.csv", row.names = FALSE)

write.csv(country.aggregate.daily("Confirmed", cName), file = "ready_to_use/COVID-19/US/US_Aggregate_daily_Confirmed.csv", row.names = FALSE)
write.csv(country.aggregate.daily("Deaths", cName), file = "ready_to_use/COVID-19/US/US_Aggregate_daily_Deaths.csv", row.names = FALSE)
#write.csv(country.aggregate.daily("Recovered", cName), file = "ready_to_use/COVID-19/US/US_Aggregate_daily_Recovered.csv", row.names = FALSE)

write.csv(states.summarizer(cName), file = "ready_to_use/COVID-19/US/US_States_summary.csv", row.names = FALSE)
write.csv(country.summarizer(cName), file = "ready_to_use/COVID-19/US/US_Aggregate_summary.csv", row.names = FALSE)

write.csv(datewise(cName, FALSE, Countries), file = "ready_to_use/COVID-19/US/US_dataset_dateWise_summary.csv", row.names = FALSE)


####################################################



cName = "China"

################      HUBEI     #################
write.csv(Hubei.Confirmed, file = "ready_to_use/COVID-19/Hubei/Hubei_daily_Confirmed.csv", row.names = FALSE)
write.csv(Hubei.Deaths, file = "ready_to_use/COVID-19/Hubei/Hubei_daily_Deaths.csv", row.names = FALSE)
#write.csv(Hubei.Recovered, file = "ready_to_use/COVID-19/Hubei/Hubei_daily_Recovered.csv", row.names = FALSE)

write.csv(Hubei.summary, file = "ready_to_use/COVID-19/Hubei/Hubei_summary.csv", row.names = FALSE)
write.csv(Hubei.datewise, file = "ready_to_use/COVID-19/Hubei/Hubei_dataset_dateWise_summary.csv", row.names = FALSE)

##########      DIAMOND PRINCESS     ############
# write.csv(Diamond.Princess.Confirmed, file = "ready_to_use/COVID-19/Cruise/Diamond_Princess_daily_Confirmed.csv", row.names = FALSE)
# write.csv(Diamond.Princess.Deaths, file = "ready_to_use/COVID-19/Cruise/Diamond_Princess_daily_Deaths.csv", row.names = FALSE)
#write.csv(Diamond.Princess.Recovered, file = "ready_to_use/COVID-19/Cruise/Diamond_Princess_daily_Recovered.csv", row.names = FALSE)

# write.csv(Diamond.Princess.summary, file = "ready_to_use/COVID-19/Cruise/Diamond_Princess_summary.csv", row.names = FALSE)
# write.csv(Diamond.Princess.datewise, file = "ready_to_use/COVID-19/Cruise/Diamond_Princess_dataset_dateWise_summary.csv", row.names = FALSE)

################      CHINA     #################
# can be sorted StateWise
write.csv(country.spread.daily("Confirmed", cName), file = "ready_to_use/COVID-19/China/China_States_daily_Confirmed.csv", row.names = FALSE)
write.csv(country.spread.daily("Deaths", cName), file = "ready_to_use/COVID-19/China/China_States_daily_Deaths.csv", row.names = FALSE)
#write.csv(country.spread.daily("Recovered", cName), file = "ready_to_use/COVID-19/China/China_States_daily_Recovered.csv", row.names = FALSE)

write.csv(country.aggregate.daily("Confirmed", cName), file = "ready_to_use/COVID-19/China/China_Aggregate_daily_Confirmed.csv", row.names = FALSE)
write.csv(country.aggregate.daily("Deaths", cName), file = "ready_to_use/COVID-19/China/China_Aggregate_daily_Deaths.csv", row.names = FALSE)
#write.csv(country.aggregate.daily("Recovered", cName), file = "ready_to_use/COVID-19/China/China_Aggregate_daily_Recovered.csv", row.names = FALSE)

write.csv(states.summarizer(cName), file = "ready_to_use/COVID-19/China/China_States_summary.csv", row.names = FALSE)
write.csv(country.summarizer(cName), file = "ready_to_use/COVID-19/China/China_Aggregate_summary.csv", row.names = FALSE)

write.csv(datewise(cName, FALSE, Countries), file = "ready_to_use/COVID-19/China/China_dataset_dateWise_summary.csv", row.names = FALSE)

################      WORLD     #################
Non.China.Countries.daily.Confirmed = All.Countries.daily.Confirmed
Non.China.Countries.daily.Deaths = All.Countries.daily.Deaths[ which(str_detect(All.Countries.daily.Deaths$Country, cName, negate = T)),]
#Non.China.Countries.daily.Recovered = All.Countries.daily.Recovered[ which(str_detect(All.Countries.daily.Recovered$Country, cName, negate = T)),]
Non.China.Countries.summary = All.Countries.summary[ which(str_detect(All.Countries.summary$Country, cName, negate = T)),]
Non.China.datewise = world.daily.bulk.summary("Non.China.Countries.daily.Confirmed", "Non.China.Countries.daily.Deaths")      #             , "Non.China.Countries.daily.Recovered")

write.csv(Non.China.Countries.daily.Confirmed, file = "ready_to_use/COVID-19/World/World_Countries_daily_Confirmed.csv", row.names = FALSE)
write.csv(Non.China.Countries.daily.Deaths, file = "ready_to_use/COVID-19/World/World_Countries_daily_Deaths.csv", row.names = FALSE)
#write.csv(Non.China.Countries.daily.Recovered, file = "ready_to_use/COVID-19/World/World_Countries_daily_Recovered.csv", row.names = FALSE)

write.csv(find.aggrigate("Non.China.Countries.daily.Confirmed", "World"), file = "ready_to_use/COVID-19/World/World_Aggregate_daily_Confirmed.csv", row.names = FALSE)
write.csv(find.aggrigate("Non.China.Countries.daily.Deaths", "World"), file = "ready_to_use/COVID-19/World/World_Aggregate_daily_Deaths.csv", row.names = FALSE)
#write.csv(find.aggrigate("Non.China.Countries.daily.Recovered", "World"), file = "ready_to_use/COVID-19/World/World_Aggregate_daily_Recovered.csv", row.names = FALSE)

write.csv(Non.China.Countries.summary, file = "ready_to_use/COVID-19/World/World_Countries_summary.csv", row.names = FALSE)
write.csv(find.aggrigate("Non.China.Countries.summary", "World"), file = "ready_to_use/COVID-19/World/World_Aggregate_summary.csv", row.names = FALSE)

write.csv(Non.China.datewise, file = "ready_to_use/COVID-19/World/World_dataset_dateWise_summary.csv", row.names = FALSE)


################      Mixed     #################
write.csv(All.Countries.daily.Confirmed, file = "ready_to_use/COVID-19/Mixed/All_Countries_daily_Confirmed.csv", row.names = FALSE)
write.csv(All.Countries.daily.Deaths, file = "ready_to_use/COVID-19/Mixed/All_Countries_daily_Deaths.csv", row.names = FALSE)
#write.csv(All.Countries.daily.Recovered, file = "ready_to_use/COVID-19/Mixed/All_Countries_daily_Recovered.csv", row.names = FALSE)

write.csv(bulk.summary, file = "ready_to_use/COVID-19/Mixed/bulk_summary.csv")
write.csv(All.Countries.summary, file = "ready_to_use/COVID-19/Mixed/All_Countries_summary.csv", row.names = FALSE)
write.csv(dataset.countryWise, file = "ready_to_use/COVID-19/Mixed/countryWise_bulk_summary.csv", row.names = FALSE)
write.csv(dataset.dateWise, file = "ready_to_use/COVID-19/Mixed/dateWise_bulk_summary.csv", row.names = FALSE)

############################################



####
write.csv(Confirmed, file = "ready_to_use/COVID-19/Confirmed.csv", row.names = FALSE)
write.csv(Deaths, file = "ready_to_use/COVID-19/Deaths.csv", row.names = FALSE)
#write.csv(Recovered, file = "ready_to_use/COVID-19/Recovered.csv", row.names = FALSE)

write.csv(One.Country.States.daily.Confirmed, file = "ready_to_use/COVID-19/One_Country_States_daily_Confirmed.csv", row.names = FALSE)
write.csv(One.Country.States.daily.Deaths, file = "ready_to_use/COVID-19/One_Country_States_daily_Deaths.csv", row.names = FALSE)
#write.csv(One.Country.States.daily.Recovered, file = "ready_to_use/COVID-19/One_Country_States_daily_Recovered.csv", row.names = FALSE)
write.csv(One.Country.Aggregate.daily.Confirmed, file = "ready_to_use/COVID-19/One_Country_Aggregate_daily_Confirmed.csv", row.names = FALSE)
write.csv(One.Country.Aggregate.daily.Deaths, file = "ready_to_use/COVID-19/One_Country_Aggregate_daily_Deaths.csv", row.names = FALSE)
#write.csv(One.Country.Aggregate.daily.Recovered, file = "ready_to_use/COVID-19/One_Country_Aggregate_daily_Recovered.csv", row.names = FALSE)

write.csv(One.Country.States.summary, file = "ready_to_use/COVID-19/One_Country_States_summary.csv", row.names = FALSE)
write.csv(One.Country.Aggregate.summary, file = "ready_to_use/COVID-19/One_Country_Aggregate_summary.csv", row.names = FALSE)







################################



#################################
########   Main Three    ########
###   (Hubei, China, World)   ###
#################################

# 3 daily(aggregate) confirmed/deaths/recovered   ->> 3rows each
a = Hubei.Confirmed
b = country.aggregate.daily("Confirmed", "China")
c = find.aggrigate("Non.China.Countries.daily.Confirmed", "World")
#d = Diamond.Princess.Confirmed
colnames(a) <- colnames(c)
colnames(b) <- colnames(c)
#colnames(d) <- colnames(c)

Three.daily.Confirmed <- rbind(a, b, c)   #   , d)
##
a = Hubei.Deaths
b = country.aggregate.daily("Deaths", "China")
c = find.aggrigate("Non.China.Countries.daily.Deaths", "World")
#d = Diamond.Princess.Deaths
colnames(a) <- colnames(c)
colnames(b) <- colnames(c)
#colnames(d) <- colnames(c)

Three.daily.Deaths <- rbind(a, b, c)       #   , d)

##
# a = Hubei.Recovered
# b = country.aggregate.daily("Recovered", "China")
# c = find.aggrigate("Non.China.Countries.daily.Recovered", "World")
# d = Diamond.Princess.Recovered
# colnames(a) <- colnames(c)
# colnames(b) <- colnames(c)
# colnames(d) <- colnames(c)

# Three.daily.Recovered <- rbind(a, b, c, d)


# 3 summary    ->> 3rows,4cols
a = Hubei.summary
b = country.summarizer("China")
c = find.aggrigate("Non.China.Countries.summary", "World")
#d = Diamond.Princess.summary
colnames(a) <- colnames(c)
colnames(b) <- colnames(c)
#colnames(d) <- colnames(c)

Three.Summary <- rbind(a, b, c)      #, d)



# 3 dataset datewise 3XnoOfDays -> rows, 6cols(name, dayno., date, confirm, death, recover)
a = Hubei.datewise
b = datewise("China", FALSE, Countries)
c = Non.China.datewise
# d = Diamond.Princess.datewise
colnames(a) <- colnames(c)
colnames(b) <- colnames(c)
#colnames(d) <- colnames(c)

Three.dataset.locationWise <- rbind(a, b, c) # , d)
Three.dataset.dateWise <- Three.dataset.locationWise[order(Three.dataset.locationWise$Date), ]
row.names(Three.dataset.dateWise) <- NULL


# writting (5)
write.csv(Three.daily.Confirmed, file = "ready_to_use/COVID-19/THREE/Three_daily_Confirmed.csv", row.names = FALSE)
write.csv(Three.daily.Deaths, file = "ready_to_use/COVID-19/THREE/Three_daily_Deaths.csv", row.names = FALSE)
#write.csv(Three.daily.Recovered, file = "ready_to_use/COVID-19/THREE/Three_daily_Recovered.csv", row.names = FALSE)

write.csv(Three.Summary, file = "ready_to_use/COVID-19/THREE/Three_Summary.csv", row.names = FALSE)
write.csv(Three.dataset.locationWise, file = "ready_to_use/COVID-19/THREE/Three_dataset_locationWise.csv", row.names = FALSE)
write.csv(Three.dataset.dateWise, file = "ready_to_use/COVID-19/THREE/Three_dataset_dateWise.csv", row.names = FALSE)




#--------------------  ENDS  --------------------#
