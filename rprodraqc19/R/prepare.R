#' @export
prepare <- function(input) {

  if (nrow(input) > 1) {
    if (all(is.na(input$MODVAR1))) {input[, MODVAR1 := as.character(MODVAR1)]}
  }

  input[, ':='
   (JOURSEMAINE = wday(DATE),
    MOIS = month(DATE),
    ANNEE = year(DATE))]

  input[is.na(VAR4), VAR4 := "NR"]

  input[, AGE := 0]
  input[!is.na(DATE_ACHAT), AGE_ACHAT := year_diff(DATE_ACHAT, DATE)]
  input[AGE_ACHAT < -1, AGE_ACHAT := -1]
  input[AGE_ACHAT > 50, AGE_ACHAT := 50]

  input[, ':='
   (DATE = NULL,
    DATE_ACHAT = NULL)]

  input[reference_object, on = "MODVAR1 == CP13", TERRITOIRE := TERRCP13] #<<

  for (var in names(input)) {
    if (is.factor(reference_object[[var]])) {
      lvl <- levels(reference_object[[var]])
      fact <- factor(input[[var]], lvl)
      if (sum(is.na(fact))) {
        val <- sort(unique(input[[var]][is.na(fact)]))
        remp <- lvl[1]
        warning(paste("Valeur(s) (", paste0(val,collapse = ","),") du champ", var ,
                      "non comprise dans le domaine reconnu (",
                      paste(lvl, collapse = ", "),"). Le programme utilisera",
                      remp, "comme substitution."))
        fact[is.na(fact)] <- remp
      }
      input[[var]] <- fact
    }
  }

  smm <- fspmatrix(input[, names(reference_object), with = FALSE])

  return(smm)
}
