# Preparations
# Steam Workshop Base URL
base_url <- "https://steamcommunity.com/sharedfiles/filedetails/?id="

# Mod List
all_mods <- readr::read_csv2(here::here("modmapping.csv"))


get_last_updated <- function(steam_id) {
  # If a mod has two steam-ids in the folder
  if (stringr::str_detect(steam_id, "/")) {
    ids <- unlist(stringr::str_split(steam_id, " / "))
    output <- purrr::map_df(ids, get_last_updated)
    return(output)
  }

  # construct the workshop URL
  constructed_url <- glue::glue("{base_url}{steam_id}")

  # Read the workshop page
  full_page <- rvest::read_html(constructed_url)

  # Find the last update date
  date_updated <- full_page |>
    rvest::html_nodes(xpath = "//*[@id=\"mainContents\"]/div[8]/div/div[2]/div[4]/div[2]/div[3]") |>
    rvest::html_text()

  # Sometimes the date is in another div, so check this if previous returns empty character
  if (length(date_updated) == 0) {
    date_updated <- full_page |>
      rvest::html_nodes(xpath = "//*[@id=\"mainContents\"]/div[8]/div/div[2]/div[3]/div[2]/div[3]") |>
      rvest::html_text()

    # Sometimes even this fails (if the mod has never been updated), then return NULL
    if (length(date_updated) == 0) {
      return(tibble::tibble(
        steam_id = steam_id,
        day = NULL,
        month = NULL,
        year = NULL,
        time = NULL
      ))
    }
  }

  # Parse the date because its in text form
  date_parsed <- date_updated |>
    stringr::str_split(pattern = "\\s") |>
    unlist() |>
    tibble::enframe() |>
    dplyr::mutate(
      value = stringr::str_remove_all(value, ","),
      type = dplyr::case_when(
        stringr::str_detect(value, "^\\d{1,2}$") ~ "day",
        stringr::str_detect(value, "^\\D{3}$") ~ "month",
        stringr::str_detect(value, "^\\d{4}$") ~ "year",
        stringr::str_detect(value, ":{1}") ~ "time",
        value == "@" ~ "drop"
      )
    ) |>
    dplyr::filter(
      type != "drop"
    ) |>
    dplyr::select(-name) |>
    tidyr::pivot_wider(
      names_from = type,
      values_from = value
    )

  # No year information if mod was updated in the current year
  if (!"year" %in% names(date_parsed)) {
    date_parsed <- date_parsed |>
      dplyr::mutate(
        year = "2024"
      )
  }

  output <- date_parsed |>
    dplyr::mutate(
      steam_id = steam_id,
      .before = day
    )

  return(output)
}

# Loop through all mods
all_mod_updates <- purrr::map_df(
  all_mods$mod_id, get_last_updated
)

# Construct a datetime column from the information
updated_times <- all_mod_updates |>
  tidyr::separate_wider_delim(time, names = c("hour", "minute"), delim = ":") |>
  tidyr::separate_wider_position(minute, widths = c("minute" = 2, "ampm" = 2)) |>
  dplyr::mutate(
    datetime = glue::glue("{year}_{month}_{day} {hour}_{minute}{ampm}"),
    datetime = lubridate::parse_date_time(datetime, "%Y_%b_%d %I_%M_%p")
  ) |>
  dplyr::select(
    steam_id,
    "last_update" = datetime
  )

# Join the tables and export
full_list <- all_mods |>
  dplyr::left_join(
    updated_times,
    by = c("mod_id" = "steam_id")
  ) |>
  dplyr::arrange(desc(last_update)) |>
  dplyr::mutate(
    time_since_update = lubridate::now() - last_update
  )

# Generate nice Output
file <- here::here("logs", glue::glue("{format(lubridate::now(), '%Y%m%d_%H%M%S')}_mod_updates.log"))
con <- file(file)
output <- knitr::kable(full_list)

writeLines(output, con)
close(con)
