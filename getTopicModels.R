getTopicModels <- function(nTopics, optint, corpus){

  datadir = "C:\\Users\\marie\\Repositories\\LordOfTheRings\\mallet\\"
  importdir = "C:\\Users\\marie\\Repositories\\LordOfTheRings\\data\\LOTR\\clean\\"
  if (corpus == 1){
    importdir = paste(importdir, "justLOTRchapters", sep = "")
  } else if (corpus == 2){
    importdir = paste(importdir, "chapters", sep = "")
  }
  
  output = paste(datadir, "lotr.mallet", sep="")
  outputState = paste(datadir, "topic-state.gz", sep="")
  outputTopicKeys = paste(datadir, "lotr_keys.txt", sep="")
  outputDocTopics = paste(datadir, "lotr_composition.txt", sep="")
  
  importCommand = paste("C:\\mallet\\bin\\mallet  import-dir --input", importdir, "--output", output, "--keep-sequence --remove-stopwords", sep = " ")
  trainCommand = paste("C:\\mallet\\bin\\mallet train-topics  --input", output, "--num-topics", nTopics, "--optimize-interval",  optint, "--output-state", outputState,  "--output-topic-keys", outputTopicKeys, "--output-doc-topics", outputDocTopics, sep = " ")
  
  MALLET_HOME <- "c:/mallet" # location of the bin directory
  Sys.setenv("MALLET_HOME" = MALLET_HOME)
  Sys.setenv(PATH = "c:/Program Files/Java/jdk1.8.0_131/jre/bin")
  
  
  shell(shQuote(paste(importCommand, trainCommand, sep = " && ")), invisible = FALSE)
  
  outputDocTopicsResult <-read.delim(outputDocTopics, header=F, sep="\t")
  outputTopicKeysResult <- read.delim(outputTopicKeys, header=F, sep="\t")
  
  csvTopics = paste(datadir, "topic_model_table.csv", sep = "") 
  csvKeys = paste(datadir, "topic_keys_table.csv", sep = "") 
  write.csv(outputDocTopicsResult, csvTopics)
  write.csv(outputTopicKeysResult, csvKeys)

  outputDocTopicsResult$V1 = NULL  
  outputDocTopicsResult$V2 = NULL
  topicTrans = t(outputDocTopicsResult)
  print(dim(topicTrans))
  print(dim(outputTopicKeysResult[,c(2,3)]))
  

  getTopicModels = cbind(outputTopicKeysResult[,c(2,3)], topicTrans)
  
}
