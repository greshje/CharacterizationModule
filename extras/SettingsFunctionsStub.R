createCharacterizationModuleSpecifications <- function(targetIds,
                                                       outcomeIds,
                                                       dechallengeStopInterval = 30,
                                                       dechallengeEvaluationWindow = 30,
                                                       timeAtRisk = data.frame(
                                                         riskWindowStart = c(1,1),
                                                         startAnchor = c("cohort start","cohort start"),
                                                         riskWindowEnd = c(0,365),
                                                         endAnchor = c("cohort end","cohort end")
                                                       ),
                                                       minPriorObservation = 0,
                                                       covariateSettings = FeatureExtraction::createDefaultCovariateSettings()) {
  #input checks
  if(!inherits(timeAtRisk, 'data.frame')){
    stop('timeAtRisk must be a data.frame')
  }
  if(nrow(timeAtRisk) == 0){
    stop('timeAtRisk must be a non-empty data.frame')
  }

  timeToEventSettings <- Characterization::createTimeToEventSettings(
    targetIds = targetIds,
    outcomeIds = outcomeIds
  )

  dechallengeRechallengeSettings <- Characterization::createDechallengeRechallengeSettings(
    targetIds = targetIds,
    outcomeIds = outcomeIds,
    dechallengeStopInterval = dechallengeStopInterval,
    dechallengeEvaluationWindow = dechallengeEvaluationWindow
  )

  aggregateCovariateSettings <- lapply(
    X = 1:nrow(timeAtRisk),
    FUN = function(i){
      Characterization::createAggregateCovariateSettings(
        targetIds = targetIds,
        outcomeIds = outcomeIds,
        minPriorObservation = minPriorObservation,
        riskWindowStart = timeAtRisk$riskWindowStart[i],
        startAnchor = timeAtRisk$startAnchor[i],
        riskWindowEnd = timeAtRisk$riskWindowEnd[i],
        endAnchor = timeAtRisk$endAnchor[i],
        covariateSettings = covariateSettings
      )
  })

  analysis <- Characterization::createCharacterizationSettings(
    timeToEventSettings = list(timeToEventSettings),
    dechallengeRechallengeSettings = list(dechallengeRechallengeSettings),
    aggregateCovariateSettings = aggregateCovariateSettings
  )

  specifications <- list(
    module = "%module%",
    version = "%version%",
    remoteRepo = "github.com",
    remoteUsername = "ohdsi",
    settings = analysis
  )
  class(specifications) <- c("CharacterizationModuleSpecifications", "ModuleSpecifications")
  return(specifications)
}
