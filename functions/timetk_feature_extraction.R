library(tidyverse)
#' Time Series Feature Extraction
#'
#' This function performs time series feature extraction using the timetk package.
#'
#' @param data_table The data table containing the time series data.
#' @param variable The variable of interest to extract features from.
#' @param group The grouping variable for aggregating features.
#' @param .prefix A prefix to be added to the feature names.
#' @param features A vector of features to extract.
#' @param period The period for feature calculation.
#'
#' @return A data frame with time series features.
#' @export
#'
#' @examples
#' \dontrun{
#' timetk_feature_extraction(data, value, group_var, prefix = "ts_", 
#'                            features = c("frequency", "crossing_points"), 
#'                            period = "days")
#' }
timetk_feature_extraction <- function(data_table, variable, group, .prefix, 
                                      features, period){
    variable <- enquo(variable)
    group <- enquo(group)
    result <- data_table %>%
        mutate(FRAME = lubridate::as_date(FRAME)) %>%
        group_by({{group}}) %>%
        timetk::tk_tsfeatures(
            .date_var = FRAME,
            .value    = {{ variable }},
            .period   = period,
            .features = features,
            .scale    = TRUE,
            .prefix   = .prefix
        ) %>%  ungroup()
    return(result)
    
}
