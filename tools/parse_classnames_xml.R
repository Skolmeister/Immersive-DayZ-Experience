# Hier muss der Pfad zu den types.xml eingefuegt werden
types_files <- fs::dir_ls(
  "/mnt/ftp_dayz/mpmissions/expansion.dayzOffline.chernarusplus/",
  regexp = ".+[^spawnable]types\\.xml$",
  recurse = TRUE
)


find_first_xml <- function(data, name) {
  xml2::xml_find_first(
    data, name
  ) |>
    xml2::xml_text()
}

extract_dayz_xml <- function(type) {
  # Extract flags as attributes
  flags <- xml2::xml_find_first(type, "flags")

  # Extract category and usage
  category_name <- xml2::xml_attr(
    xml2::xml_find_first(
      type, "category"
    ),
    "name"
  )

  usages <- xml2::xml_find_all(type, "usage") |>
    xml2::xml_attr("name") |>
    list() # Collect usage names into a list

  values <- xml2::xml_find_all(type, "value") |>
    xml2::xml_attr("name") |>
    list() # Collect value names into a list

  # Combine all into a dataframe format
  tibble::tibble(
    name = xml2::xml_attr(type, "name"),
    nominal = find_first_xml(type, "nominal"),
    lifetime = find_first_xml(type, "lifetime"),
    restock = find_first_xml(type, "restock"),
    min = find_first_xml(type, "min"),
    quantmin = find_first_xml(type, "quantmin"),
    quantmax = find_first_xml(type, "quantmax"),
    cost = find_first_xml(type, "cost"),
    count_in_cargo = xml2::xml_attr(flags, "count_in_cargo"),
    count_in_hoarder = xml2::xml_attr(flags, "count_in_hoarder"),
    count_in_map = xml2::xml_attr(flags, "count_in_map"),
    count_in_player = xml2::xml_attr(flags, "count_in_player"),
    crafted = xml2::xml_attr(flags, "crafted"),
    deloot = xml2::xml_attr(flags, "deloot"),
    category_name,
    usages = usages, # Store lists as individual column entries
    values = values, # Store lists as individual column entries
  ) |>
    dplyr::mutate(
      dplyr::across(
        -c(name, usages, values),
        as.integer
      )
    )
}

read_types_xml <- function(path) {
  try <- tryCatch(
    {
      xml <- xml2::read_xml(
        path
      )

      mod <- stringr::str_extract(
        dirname(path),
        "(?<=\\/)[^\\/]+$"
      )

      # print(mod)

      df <- xml |>
        xml2::xml_find_all("type") |>
        purrr::map_df(extract_dayz_xml)

      # Flatten usages and values to get a clearer representation
      output <- df |>
        tidyr::unnest_wider(
          c(usages, values),
          names_sep = "_"
        ) |>
        dplyr::mutate(
          mod = mod,
          .before = name
        )
    },
    error = function(cond) {
      cli::cli_alert_warning("Problem bei der XML {.path {path}}! Errormessage:")
      print(cond)
      return()
    }
  )
  return(try)
}

classnames_df <- purrr::map_df(
  types_files,
  read_types_xml,
  .progress = TRUE
)


writexl::write_xlsx(
  classnames_df,
  glue::glue(
    "{format(lubridate::today(), '%Y%m%d')}",
    "_classnames_with_attributes",
    ".xlsx"
  )
)
