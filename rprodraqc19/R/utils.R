year_diff <- function(time1, time2) {
  time1 <- as.POSIXlt(time1, "GMT")
  time2 <- as.POSIXlt(time2, "GMT")
  yeardiff <- time2$year - time1$year
  yeardiff <- ifelse(time2$mon < time1$mon | (time2$mon == time1$mon & time2$mday < time1$mday), yeardiff - 1, yeardiff)
  return(as.numeric(yeardiff))
}

#' @importFrom jsonlite fromJSON
#' @export
warmup <- function() {

  input <- jsonlite::fromJSON('[{"..."}]')
  setDT(input)
  replicate(3, prepare(copy(input)))

  return(invisible())
}

#' @importFrom Matrix sparseMatrix
#' @importFrom utils head tail
fspmatrix <- function(df) {
  # Building sparse matrix with sparseMatrix to save time vs sparse.model.matrix

  # Details about the df to help build triplet
  nr <- nrow(df)
  nc <- ncol(df)
  nlevels <- pmax(1, sapply(df, nlevels))
  fac <- which(sapply(df, is.factor))
  # Check that all factors have at least 2 levels
  stopifnot(min(nlevels[fac]) > 1)

  # Building the value vector removing zero positions and first levels of factors after the first factor
  x <- as.numeric(unlist(unlist(df)))
  jx <- x # for use in building j
  # Positions of values coming from factors
  pos <- as.vector(sapply(fac * nr, function(x) x - nr + (1:nr)))
  # Positions of first levels of factors after the first factor
  pos1 <- pos[-1:-nr]
  pos1 <- pos1[which(x[pos1] == 1)]
  # Replacing the values of factors with 1 for one hot encoding
  x[pos] <- 1
  # Positions of non-zero values
  nzpos <- which(x[-pos1] != 0)
  # Values to build triplet around
  x <- x[-pos1][nzpos]

  # Building the i vector, the first dim part of the triplet
  i <- rep(seq_len(nr), nc)[-pos1][nzpos]

  # Building the j vector, the second dim part of the triplet
  jnlevels <- nlevels
  jnlevels[fac[-1]] <- jnlevels[fac[-1]] - 1
  jx[-pos] <- 1
  jx[pos[-1:-nr]] <- jx[pos[-1:-nr]] - 1
  cs <- cumsum(c(0, head(jnlevels, -1)))
  j <- jx + rep(cs, each = nr)
  j <- j[-pos1][nzpos]

  # Building the dimnames vector
  tag <- TRUE
  fspnames <- as.vector(unlist(sapply(names(df), function(n) {
    clvl <- as.character(levels(df[[n]]))
    isL <- is.logical(df[[n]])
    isF <- is.factor(df[[n]])
    indx <- if (tag & isF) {
      1:length(clvl)
    } else {
      -1
    }
    if (tag & isF) tag <<- FALSE
    paste0(n, clvl[indx], ifelse(isL, "TRUE", ""))
  })))

  fspm <- sparseMatrix(i = i, j = j, x = x, dims = c(nr, tail(cs, 1) + tail(jnlevels, 1)), dimnames = list(NULL, fspnames))

  return(fspm)
}
