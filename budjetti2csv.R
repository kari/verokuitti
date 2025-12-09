library(tibble)
library(glue)
library(rvest)
library(stringr)
library(dplyr)
library(purrr)
library(readr)
library(tidyr)

# Tämä on modernisoitu versio alkuperäisestä Ruby-koodista jonka toiminnasta
# herran vuonna ei ole allekirjoittaneella juurikaan takeita,
# https://gist.github.com/kari/6742443

# https://budjetti.vm.fi/sisalto.jsp?year=2014&lang=fi&maindoc=/2014/tae/hallituksenEsitys/hallituksenEsitys.xml&opennode=0:1:133:385:
# tai yhdeltä sivulta kaikki https://budjetti.vm.fi/sisalto.jsp?year=2014&lang=fi&maindoc=/2014/tae/hallituksenEsitys/hallituksenEsitys.xml&opennode=0:1:127:131:
# tässä haetaan erillisiltä sivuilta koska näin Verokuitti sen aikoinaan teki
# syistä jotka ovat jäänet historian hämärään
base_url <- "https://budjetti.vm.fi/sisalto.jsp?year=2014&lang=fi&maindoc=/2014/tae/hallituksenEsitys/hallituksenEsitys.xml&opennode=0:1:133:385:{node}:"
output_file <- "budjetti-2014-he.csv"

depts <- tibble(
  node = c(
    387,
    425,
    445,
    479,
    519,
    573,
    629,
    655,
    805,
    983,
    1115,
    1185,
    1315,
    1483,
    1533
  ),
  dept = c(
    "Eduskunta",
    "Tasavallan presidentti",
    "Valtioneuvoston kanslia",
    "Ulkoasiainministeriö",
    "Oikeusministeriö",
    "Sisäasiainministeriö",
    "Puolustusministeriö",
    "Valtiovarainministeriö",
    "Opetus- ja kulttuuriministeriö",
    "Maa- ja metsätalousministeriö",
    "Liikenne- ja viestintäministeriö",
    "Työ- ja elinkeinoministeriö",
    "Sosiaali- ja terveysministeriö",
    "Ympäristöministeriö",
    "Valtionvelan korot"
  )
)

output <- tibble()

for (i in seq_len(nrow(depts))) {
  node <- depts[i, ]$node
  dept <- depts[i, ]$dept

  doc <- read_html(glue(base_url))
  # URL-rakenne tuntuu muuttuvan vuodesta toiseen, mutta HTML on pysynyt samana soppana
  tbl <- doc |>
    html_elements("div p + table") |>
    html_table(convert = FALSE) |>
    pluck(-1) |>
    filter(X2 != "" & X5 != "—") |>
    select(c(1, 2, 5)) |>
    mutate(X5 = as.numeric(str_replace_all(X5, "\\W", "")))

  tables <- doc |>
    html_elements("div p + table")
  tbl <- tables[length(tables)] |>
    html_elements("tr") |>
    map(\(x) html_elements(x, "td"))
  tbl <- tbl[-1:-3] |> map(\(x) x[c(2, 5)])

  budget <- tibble(
    l1 = dept,
    l2 = tbl |>
      map(\(x) x[1] |>
        html_element("span") |>
        html_text()) |>
      unlist(),
    l3 = tbl |> map(\(x) x[1] |>
      html_text() |>
      str_replace_all("\u00A0", " ") |>
      str_squish()) |> unlist(),
    sum = tbl |> map(\(x) x[2] |> html_text()) |> unlist()
  ) |>
    filter(sum != "—") |>
    mutate(
      l3 = if_else(is.na(l2), l3, NA),
      l2 = if_else(l2 != "Yhteensä", l2, NA),
      sum = str_replace_all(sum, "\\W", "") |> as.numeric()
    ) |>
    fill(l2)

  output <- bind_rows(output, budget)
}

write_csv(output, output_file, col_names = FALSE, na = "")

# määrärahat yhteensä, 53 920 409
output |>
  filter(!is.na(l3)) |>
  summarise(sum = sum(sum))

# kaikkia määrärahoja ei kateta veroista vaan ne tulevat esim. Veikkaukselta,
# EU:lta tai vastaavaa.
# näistä on yleensä budjetissa mainittu, mutta siitä huolimatta nämä korjaukset
# ovat erittäin epätieteelliset. Tämä osa on puhdasta käsityötä ja numeromagiaa.
# kts. budjetti.csv korjatuille riveille
adjustments <- read_csv("budjetti-2014-he-korjaukset.csv",
  col_names = c("l1", "l2", "l3", "new_sum")
)

adjusted <- output |>
  filter(!is.na(l3)) |>
  left_join(adjustments) |>
  mutate(sum = if_else(!is.na(new_sum), new_sum, sum)) |>
  filter(sum > 0) |>
  select(!new_sum)

# pitäisi olla 50 200 607, eli -3719802
adjusted |> summarise(sum = sum(sum))

subtotals <- adjusted |>
  as.data.table() |>
  rollup(.(sum = sum(sum)), by = c("l1", "l2")) |>
  filter(!is.na(l1))

# lisää välisummat jokaisen ryhmän alkuun
adjusted |>
  bind_rows(subtotals) |>
  mutate(l1_no = match(l1, unique(l1))) |>
  group_by(l1) |>
  mutate(l2_no = if_else(is.na(l2), 0, match(l2, unique(l2)))) |>
  group_by(l1, l2) |>
  mutate(l3_no = if_else(is.na(l3), 0, row_number())) |>
  ungroup() |>
  arrange(l1_no, l2_no, l3_no, .by_group = TRUE) |>
  select(!c(l1_no, l2_no, l3_no)) |>
  write_csv("budjetti.csv", col_names = FALSE, na = "")
