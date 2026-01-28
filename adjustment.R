library(readr)

budget <- read_csv(
  "budjetti-2014-he.csv",
  col_names = c("l1", "l2", "l3", "sum")
) |>
  filter(!is.na(l3))

# avaa legacy budjetti-2014-he-puu.csv ja mitkä rivit eroaa l3:ssa, vrt. tulojennetotus.txt
adjusted <- read_delim(
  "budjetti-2014-he-puu.csv",
  delim = ";",
  escape_double = FALSE,
  col_names = c("l1", "l2", "l3", "adjusted_sum"),
  trim_ws = TRUE
) |>
  filter(!is.na(l3), adjusted_sum > 0) |>
  mutate(l3 = str_squish(l3))

# erotus, pitäisi olla 3719802
budget |>
  full_join(adjusted) |>
  filter(adjusted_sum != sum | is.na(adjusted_sum)) |>
  mutate(diff = sum - replace_na(adjusted_sum, 0)) |>
  summarise(diff = sum(diff))

# korjaukset
budget |>
  full_join(adjusted) |>
  filter(adjusted_sum != sum | is.na(adjusted_sum)) |>
  mutate(sum = replace_na(adjusted_sum, 0)) |>
  select(!adjusted_sum) |>
  write_csv("budjetti-2014-he-korjaukset.csv", col_names = FALSE, na = "")
