#' Align templates and images
#'
#' @param stimuli list of class stimlist
#' @param pt1 The first point to align (defaults to 0)
#' @param pt2 The second point to align (defaults to 1)
#' @param x1 The x-coordinate to align the first point to
#' @param y1 The y-coordinate to align the first point to
#' @param x2 The x-coordinate to align the second point to
#' @param y2 The y-coordinate to align the second point to
#' @param width The width of the aligned image
#' @param height The height of the aligned image
#' @param ref_img The reference image (by index or name) to get coordinates and dimensions from if they are NULL (defaults to average of all images if NULL)
#' @param fill background color if cropping goes outside the original image
#' @param patch whether to use the patch function to set the background color
#' @param procrustes Whether to do a procrustes alignment
#'
#' @return stimlist with aligned tems and/or images
#' @export
#'
#' @examples
#' # load stimuli and crop/rotate differently
#' stimuli <- demo_stim() %>% 
#'   crop(c(0.8, 0.9), c(1.0, 0.9), x_off = c(0, 0.2)) %>%
#'   rotate(c(-5, + 5))
#'
#' # align to bottom-centre of nose (average position)
#' one_pt <- align(stimuli, pt1 = 55, pt2 = 55)
#'
#' # align to pupils of second image
#' two_pt <- align(stimuli, ref_img = 2)
#'
#' # procrustes align to average position
#' proc <- align(stimuli, procrustes = TRUE)
#' draw_tem(proc)

align <- function(stimuli, pt1 = 0, pt2 = 1,
                  x1 = NULL, y1 = NULL, x2 = NULL, y2 = NULL,
                  width = NULL, height = NULL, ref_img = NULL,
                  fill = wm_opts("fill"), patch = FALSE,
                  procrustes = FALSE) {
  stimuli <- validate_stimlist(stimuli, TRUE)

  # if values NULL, default to ref_img points
  if (is.null(ref_img)) {
    avg <- average_tem(stimuli)
    ref_points <- avg[[1]]$points
    width <- width %||% width(avg)[[1]]
    height <- height %||% height(avg)[[1]]
  } else {
    ref_points <- stimuli[[ref_img]]$points
    width <- width %||% stimuli[[ref_img]]$width
    height <- height %||% stimuli[[ref_img]]$height
  }
  x1 <- x1 %||% ref_points[1, pt1+1]
  y1 <- y1 %||% ref_points[2, pt1+1]
  x2 <- x2 %||% ref_points[1, pt2+1]
  y2 <- y2 %||% ref_points[2, pt2+1]
  

  if (pt1 == pt2) {
    # align points are the same, so no resize needed,
    # make sure that left and right align coordinates are the same
    x2 <- x1
    y2 <- y1
  }

  # procrustes align ----
  if (isTRUE(procrustes)) {
    # procrustes align coordinates
    data <- tems_to_array(stimuli)
    coords <- procrustes_align(data, ref_img)

    # calculate size multiplier
    orig_avg <- apply(data, c(1, 2), mean)
    pro_avg <- apply(coords, c(1, 2), mean)

    oEyeWidth <- (orig_avg[pt1+1, ] - orig_avg[pt2+1, ])^2 %>%
      sum() %>% sqrt(.)
    pEyeWidth <- (pro_avg[pt1+1, ] - pro_avg[pt2+1, ])^2 %>%
      sum() %>% sqrt(.)
    mult <- oEyeWidth/pEyeWidth

    # resize and convert to webmorph coordinates
    pts <- dim(coords)[[1]]
    for (i in 1:dim(coords)[[3]]) {
      coords[, , i] <- coords[, , i] *
        rep(c(mult, -mult), each = pts) +
        rep(c(width/2, height/2), each = pts)
    }

    # get align points for each image
    x1 <- coords[pt1+1, 1, ]
    x2 <- coords[pt2+1, 1, ]
    y1 <- coords[pt1+1, 2, ]
    y2 <- coords[pt2+1, 2, ]
  }

  suppressWarnings({
    n <- length(stimuli)
    x1 <- rep_len(x1, n)
    y1 <- rep_len(y1, n)
    x2 <- rep_len(x2, n)
    y2 <- rep_len(y2, n)
    fill <- rep_len(fill, n)
    #patch <- rep_len(patch, n)
  })


  # calculate rotation and resize parameters for each image
  rotate <- c()
  newsize <- c()

  for (i in seq_along(stimuli)) {
    # calculate aligned rotation and inter-point width
    rotate_aligned <- ifelse(x1[i] - x2[i] == 0, pi/2,
                             atan((y1[i] - y2[i])/(x1[i] - x2[i])))
    aEyeWidth = sqrt(`^`(x1[i]-x2[i], 2) + `^`(y1[i]-y2[i], 2))


    o_pts <- stimuli[[i]]$points
    ox1 <- o_pts[1, pt1+1]
    oy1 <- o_pts[2, pt1+1]
    ox2 <- o_pts[1, pt2+1]
    oy2 <- o_pts[2, pt2+1]

    # calculate rotation
    rotate_orig <- ifelse(ox1 - ox2 == 0, pi/2,
                    atan((oy1 - oy2)/(ox1 - ox2)))
    rotate[i] <- -(rotate_orig - rotate_aligned) / (pi/180)

    # calculate resize needed
    oEyeWidth <- sqrt(`^`(ox1-ox2, 2) + `^`(oy1-oy2, 2))
    newsize[i] <- ifelse(aEyeWidth == 0 || oEyeWidth == 0,
                        1, aEyeWidth / oEyeWidth)
  }

  newstimuli <- stimuli %>%
    rotate(degrees = rotate, fill = fill, patch = patch) %>%
    resize(newsize)

  # recalculate eye position for cropping
  x_off <- c()
  y_off <- c()
  for (i in seq_along(newstimuli)) {
    n_pts <- newstimuli[[i]]$points
    newx1 <- n_pts[1, pt1+1]
    newy1 <- n_pts[2, pt1+1]
    x_off[i] = newx1 - x1[i]
    y_off[i] = newy1 - y1[i]
  }

  crop(newstimuli, width = width, height = height,
       x_off = x_off/width(newstimuli), # in case some values < 1
       y_off = y_off/height(newstimuli),
       fill = fill, patch = patch)
}

#' Procrustes align templates
#'
#' @param data Template points
#' @param ref_img Reference image
#'
#' @return coordinates
#' @keywords internal
#' @importFrom geomorph gpagen
#'
procrustes_align <- function(data, ref_img = NULL) {
  n <- dim(data)[3]
  if (is.null(ref_img)) {
    # calcuate average and add as img 1
    avg <- apply(data, c(1, 2), mean) %>% 
      array(dim = dim(data) - c(0, 0, 1))
    newdata <- array(c(avg, data), dim = dim(data) + c(0, 0, 1))

    data_i <- 2:(n+1)
  } else {
    # move ref image to first position
    ref <- data[, , ref_img, drop = FALSE]
    noref <- data[, , -ref_img, drop = FALSE]
    newdata <- array(c(ref, noref), dim = dim(data))
    if (ref_img == 1) {
      data_i <- 1:n
    } else {
      data_i <- c(2:ref_img, 1, (ref_img+1):n)[1:n]
    }
  }
  gpa <- geomorph::gpagen(newdata, PrinAxes = FALSE,
                          print.progress = FALSE)
  coords <- gpa$coords[, , data_i]

  # if (rotate != "guess") {
  #   rotate <- as.numeric(rotate)
  #
  #   if (rotate == 90) {
  #     coords <- geomorph::rotate.coords(gpa$coords, "rotateC")
  #   } else if (rotate == 180) {
  #     coords <- geomorph::rotate.coords(gpa$coords, "rotateC") %>%
  #       geomorph::rotate.coords("rotateC")
  #   } else if (rotate == 270) {
  #     coords <- geomorph::rotate.coords(gpa$coords, "rotateCC")
  #   } else { # rotate == 0 or anything else
  #    coords <- gpa$coords
  #  }
  # } else {
  #   ### otherwise guess best rotation ----
  #
  #   # calculate average face
  #   orig_avg <- apply(data, c(1, 2), mean)
  #   pro_avg <- apply(gpa$coords, c(1, 2), mean)
  #
  #   all_pts <- expand.grid(x = 1:nrow(orig_avg),
  #                          y = 1:nrow(orig_avg)) %>%
  #     dplyr::filter(x != y) %>%
  #     dplyr::sample_n(min(100, nrow(.)))
  #
  #   angles <- list(
  #     o = orig_avg,
  #     p0 = pro_avg,
  #     p1 = geomorph::rotate.coords(pro_avg, "rotateC"),
  #     p2 = geomorph::rotate.coords(pro_avg, "rotateC") %>%
  #       geomorph::rotate.coords("rotateC"),
  #     p3 = geomorph::rotate.coords(pro_avg, "rotateCC")
  #   ) %>%
  #     lapply(function(coords) {
  #       mapply(function(pt1, pt2) { angle_from_2pts(coords, pt1, pt2) },
  #               all_pts$x, all_pts$y)
  #     })
  #
  #   dd <- data.frame(
  #     p0 = angles$p0 - angles$o,
  #     p1 = angles$p1 - angles$o,
  #     p2 = angles$p2 - angles$o,
  #     p3 = angles$p3 - angles$o
  #   ) %>%
  #     # take care of values near +-2pi (better way?)
  #     dplyr::mutate_all(function(x) {
  #       x <- ifelse(x > 2*pi, x - (2*pi), x)
  #       x <- ifelse(x > 0, x - (2*pi), x)
  #       x <- ifelse(x < -2*pi, x + (2*pi), x)
  #       x <- ifelse(x > 0, x + (2*pi), x)
  #       x
  #     }) %>%
  #     dplyr::summarise_all(mean)
  #
  #   min_diff <- as.list(dd) %>% sapply(abs) %>% `[`(. == min(.)) %>% names()
  #   #message("rotation: ", min_diff)
  #
  #   if (min_diff == "p1") {
  #     coords <- geomorph::rotate.coords(gpa$coords, "rotateC")
  #   } else if (min_diff == "p2") {
  #     coords <- geomorph::rotate.coords(gpa$coords, "rotateC") %>%
  #       geomorph::rotate.coords("rotateC")
  #   } else if (min_diff == "p3") {
  #     coords <- geomorph::rotate.coords(gpa$coords, "rotateCC")
  #   } else { # min_diff == "p0" or anything else
  #     coords <- gpa$coords
  #   }
  # }

  dimnames(coords) <- dimnames(data)
  return(coords)
}



#' Get angle from 2 points
#'
#' @param coords The coordinate array
#' @param pt1 The first point
#' @param pt2 The second point
#'
#' @return double of angle in radians
#' @keywords internal
#'
angle_from_2pts <- function(coords, pt1 = 1, pt2 = 2) {
  x1 <- coords[[pt1,1]]
  x2 <- coords[[pt2,1]]
  y1 <- coords[[pt1,2]]
  y2 <- coords[[pt2,2]]

  atan2(y1 - y2, x1 - x2) %% (2*pi)
}
