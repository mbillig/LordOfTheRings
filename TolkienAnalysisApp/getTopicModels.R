getTopicModels <- function(nTopics, optint, corpus){
  
  outdir = "./outfiles/"
  importdir = " ./data/"
  dirlist = paste(importdir, paste(corpus, collapse = importdir), sep = "")
  
  output = paste(outdir, "lotr.mallet", sep="")
  outputState = paste(outdir, "topic-state.gz", sep="")
  outputKeys = paste(outdir, "lotr_keys.txt", sep="")
  outputTopics = paste(outdir, "lotr_composition.txt", sep="")
  
  importCommand = paste("./mallet/bin/mallet  import-dir --input", dirlist, "--output", output, "--keep-sequence --remove-stopwords", sep = " ")
  trainCommand = paste("./mallet/bin/mallet train-topics  --input", output, "--num-topics", nTopics, "--optimize-interval",  optint, "--output-state", outputState,  "--output-topic-keys", outputKeys, "--output-doc-topics", outputTopics, sep = " ")
  
  MALLET_HOME <- "./mallet" # location of the bin directory
  Sys.setenv("MALLET_HOME" = MALLET_HOME)
  #Sys.setenv(PATH = "../../../../../Program Files/Java/jdk1.8.0_131/jre/bin")
  
  system("chmod 777 ./mallet/bin/mallet")
  #sys.chmod("./mallet/bin/mallet", mode = "777", use_umask = TRUE)
  system(importCommand)
  system(trainCommand)
  
  topicsDF <-read.delim(outputTopics, header=F, sep="\t")
  keysDF <- read.delim(outputKeys, header=F, sep="\t")
  
  #csvTopics = paste(outdir, "topic_model_table.csv", sep = "") 
  #csvKeys = paste(outdir, "topic_keys_table.csv", sep = "") 
  #write.csv(topicsDF, csvTopics)
  #write.csv(keysDF, csvKeys)
  
  topicsDF$V1 = NULL  
  topicsDF$V2 = NULL
  topicNames = c("Topic 1")
  for (i in 2:ncol(topicsDF)){
    topicNames = c(topicNames, paste("Topic ", i, sep = ""))
  }
  names(topicsDF) = topicNames
  
  names(keysDF) = c('key_index', 'Topic Weight', "Keywords")
  topicTrans = t(topicsDF)
  
  getTopicModels = cbind(keysDF[,c(2,3)], topicTrans)
  
}

