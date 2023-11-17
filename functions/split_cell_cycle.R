#' @title Split tracks into single cell cycle
#' 
#' @description This function implements a simple linear O(n) method, where n is 
#' the number of frames, to split tracks containing a cell and its daughter 
#' into single-cell tracks for their entire cell cycle life.
#' 
#' @param track A data frame containing the track and the measured intensities, 
#' and optionally other information.
#' 
#' @return A list of data frames. Each data frame represents a single cell with 
#' its correct cell cycle phases. The data frames include additional columns 
#' such as 'red_duration', 'green_duration', 'orange_duration', and 'Track_Key'.
#' 
#' @details The function iterates through the frames in the input track and 
#' identifies the phases (red, green, orange) of the cell cycle. It splits the 
#' track into individual cycles, adding duration information and a unique 
#' identifier ('Track_Key') for each cycle. Any incomplete or incorrect cycles 
#' are excluded from the results.
#' 
#' @examples
#' \dontrun{
#' # Example usage:
#' track_data <- read.csv("cell_track_data.csv")
#' split_cycles_result <- split_cell_cycle(track_data)
#' }
#'
#' @seealso 
#' \code{\link{lubridate::as_date}}, \code{\link{dplyr::mutate}}, 
#' \code{\link{dplyr::group_by}}, \code{\link{dplyr::ungroup}}, 
#' \code{\link{dplyr::rbind}}
#'

split_cell_cycle <- function(track) {
    # Initialization of the three phases = colors
    red <-  0
    orange <- 0
    green <- 0
    
    # Creation of an empty list to store the splitted data.frames
    results <- list()
    i <- 1
    results[[1]] <- data.frame()
    
    length_track <- nrow(track) 
    for (frame in 1:length_track) {
        if (orange == 0 & red == 0 & track[frame, ]$phase == "S") {
            results[[i]] <- rbind(results[[i]], track[frame, ])
            green <- green + 1
        }
        
        if (track[frame, ]$phase == "G2/M" & green > 0 & red == 0) {
            results[[i]] <- rbind(results[[i]], track[frame, ])
            orange <- orange + 1
        }
        
        if (track[frame,]$phase == "G1" & green > 0 &  orange > 0) {
            results[[i]] <- rbind(results[[i]], track[frame, ])
            red <- red + 1
        }
        
        # NB: Actually after one cycle usually there is a new orange but this 
        # has to be skipped because is biologically wrong
        if (track[frame, ]$phase == "S" & green > 0 & orange > 0  & red > 0) { 
            results[[i]]$red_duration <- red
            results[[i]]$green_duration <- green
            results[[i]]$orange_duration <- orange
            results[[i]]$Track_Key <- paste0(results[[i]]$Track_Key, "_cycle:", i)
            i <- i + 1
            results[[i]] <- data.frame()
            results[[i]] <- rbind(results[[i]], track[frame,])
            red <- 0
            green <- 0
            orange <- 0
        }
        
        if (frame ==  length_track &green > 0 & orange > 0  & red > 0) { 
            results[[i]]$red_duration <- red
            results[[i]]$green_duration <- green
            results[[i]]$orange_duration <- orange
            results[[i]]$Track_Key <- paste0(results[[i]]$Track_Key, "_cycle:", i)
        }
    }
    
    # Check if there is a wrong cycle (it doesn't have all the phases) usually 
    # the last one.
    for(i in 1:length(results)) {
        if (length(unique(results[[i]]$phase)) != 3) {
            results[i] <- NULL
        }
    }
    
    return(results)
} 