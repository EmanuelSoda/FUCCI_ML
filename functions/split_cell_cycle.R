#' Split Cell Cycle
#'
#' This function takes a data frame representing cell cycle observations and splits it into distinct cycles based on the G1, S, and G2/M phases.
#'
#' @param track A data frame containing cell cycle observations with a "phase" column indicating the cell cycle phase.
#'
#' @return A list of data frames, each representing a distinct cell cycle with added columns for red, orange, and green durations.
#' @details The function identifies cell cycle phases based on the provided observations and splits the data into cycles. 
#' It also checks for incorrect cycles and removes them.
#'
#' @export
#' @examples
#' # Example usage:
#' data <- read.csv("cell_cycle_data.csv")
#' cycles <- split_cell_cycle(data)
#'
#' @seealso \code{\link{change_color}}
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
    
    first_red <- NA
    last_red <- NA
    length_track <- nrow(track)
    ### A cell cycle is the time between two green observations
    
    for (frame in 1:length_track) {
        if (orange == 0 & red == 0 & green == 0 & track[frame, ]$phase == "G1") {
            first_red <- frame
        }
        
        if (orange > 0 & red > 0 & green > 0 & track[frame, ]$phase == "G1" &&
            (track[frame - 1, ]$phase == "G2/M" | track[frame - 1, ]$phase == "S")) {
            last_red <- frame
        }
        
        if (track[frame,]$phase == "G1" & green == 0 &  orange == 0) {
            red <- red + 1
        }
        
        if (track[frame, ]$phase == "G2/M" & red > 0 & green == 0) {
            orange <- orange + 1
        }
        
        if (track[frame, ]$phase == "S" & orange > 0 & red > 0)  {
            green <- green + 1
        }
        
        if (!is.na(first_red) & !is.na(last_red) 
            & red > 0 & orange > 0 & green > 0) {
            results[[i]] <- rbind(results[[i]], track[first_red:(last_red -1), ])
            results[[i]]$red_duration <- red
            results[[i]]$orange_duration <- orange
            results[[i]]$green_duration <- green
            results[[i]]$Track_Key <-
                paste0(unique(track$Track_Key), "_cycle:", i)
            i <- i + 1
            
            results[[i]] <- data.frame()
            red <- 0
            green <- 0
            orange <- 0
            first_red <- NA
            last_red <- NA
        }
    }
    
    # Check if there is a wrong cycle (it doesn't have all the phases) usually 
    # the last one.
    for(i in 1:length(results)) {
        if (length(unique(results[[i]]$phase)) != 3) {
            results[i] <- NULL
        }
    }
    
    results <- map(results, change_color)
    return(results)
}



#' Change Color
#'
#' This function adjusts the cell cycle phase colors based on specific conditions.
#'
#' @param track A data frame containing cell cycle observations with a "phase" column indicating the cell cycle phase.
#'
#' @return The modified data frame with adjusted cell cycle phase colors.
#' @details The function modifies cell cycle phase colors based on specific conditions, such as correcting orange phases before green and red phases after green.
#'
#' @export
#' @examples
#' # Example usage:
#' modified_data <- change_color(data)
#'
#' @seealso \code{\link{split_cell_cycle}}
#'
### If I have an orange before green this is actually a green
### if I have a orange after a red this is actually red
### This because the degradation is not immediate
change_color <- function(track) {
    red <-  0
    orange <- 0
    green <- 0
    last_red <- NA
    length_track <- nrow(track)
    for (frame in 1:length_track) {
        if (track[frame, ]$phase == "G1" & orange == 0 & green == 0 ) {
            red <- red + 1
        }
        
        if (track[frame, ]$phase == "G2/M" & red > 0 & green == 0) {
            orange <- orange + 1
        }
        
        if (track[frame, ]$phase == "S" & orange > 0 & red > 0) {
            green <- green + 1
        }
        
        if (red > 0 & green == 0 & track[frame, ]$phase == "G2/M") {
            last_red <- frame -1
            track[frame, "phase"] <- "G1/S" 
        }
        
        # If a see a red but the last position of red is already present is actually
        # a yellow
        if (red > 0 & green == 0 & track[frame, ]$phase == "G1" & !is.na(last_red)) {
            track[frame, "phase"] <- "G1/S" 
        }
        
    }
    return(track)
}






