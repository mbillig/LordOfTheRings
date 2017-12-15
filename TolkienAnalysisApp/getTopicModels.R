getTopicModels <- function(nTopics, optint, corpus){
  
  outdir = "./outfiles/"
  importdir = " ./data/"
  dirlist = paste(importdir, paste(corpus, collapse = importdir), sep = "")
  
  output = paste(outdir, "lotr.mallet", sep="")
  outputState = paste(outdir, "topic-state.gz", sep="")
  outputTopicKeys = paste(outdir, "lotr_keys.txt", sep="")
  outputDocTopics = paste(outdir, "lotr_composition.txt", sep="")
  
  importCommand = paste("./mallet/bin/mallet  import-dir --input", dirlist, "--output", output, "--keep-sequence --remove-stopwords", sep = " ")
  trainCommand = paste("./mallet/bin/mallet train-topics  --input", output, "--num-topics", nTopics, "--optimize-interval",  optint, "--output-state", outputState,  "--output-topic-keys", outputTopicKeys, "--output-doc-topics", outputDocTopics, sep = " ")
  
  MALLET_HOME <- "./mallet" # location of the bin directory
  Sys.setenv("MALLET_HOME" = MALLET_HOME)
  #Sys.setenv(PATH = "../../../../../Program Files/Java/jdk1.8.0_131/jre/bin")
  
  system("chmod 777 ./mallet/bin/mallet")
  #sys.chmod("./mallet/bin/mallet", mode = "777", use_umask = TRUE)
  system(importCommand)
  system(trainCommand)
  
  outputDocTopicsResult <-read.delim(outputDocTopics, header=F, sep="\t")
  outputTopicKeysResult <- read.delim(outputTopicKeys, header=F, sep="\t")
  
  #csvTopics = paste(outdir, "topic_model_table.csv", sep = "") 
  #csvKeys = paste(outdir, "topic_keys_table.csv", sep = "") 
  #write.csv(outputDocTopicsResult, csvTopics)
  #write.csv(outputTopicKeysResult, csvKeys)
  
  outputDocTopicsResult$V1 = NULL  
  outputDocTopicsResult$V2 = NULL
  topicTrans = t(outputDocTopicsResult)
  
  getTopicModels = cbind(outputTopicKeysResult[,c(2,3)], topicTrans)
  
}

