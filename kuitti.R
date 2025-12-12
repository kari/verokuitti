library(readr)

# kts kuitti.php ja https://www.talousviisas.fi/verokuitti/lahteet.php

# tulopuolelta Verokuitti tarkastalee
# - palkkatuloja
# - pääomatuloja
# - ALV:ia
# - tupakkaveroa
# - alkoholia
# - energiaveroa
# - ajoneuvo- ja polttoaineveroa

# Tulovero, bruttotulot vuodessa. alla esim. 2 500 e/kk
tulot <- 12*2500

# Tuloveroasteikko 2014
# https://www.finlex.fi/fi/lainsaadanto/saadoskokoelma/2013/1245#sec_1__subsec_1
tulovero <- if (tulot < 16300) {
  0
} else if (tulot < 24300) {
  8 + (tulot - 16300) * 0.065
} else if (tulot < 39700) {
  528 + (tulot - 24300) * 0.175
} else if (tulot < 71400) {
  3223 + (tulot - 39700) * 0.215
} else if (tulot < 100000) {
  10038.5 + (tulot - 71400) * 0.2975
} else {
  18547 + (tulot - 100000) * 0.3175
}

# Pääomatulovero, https://www.veronmaksajat.fi/neuvot/henkiloverotus/sijoittaminen/myyntivoitot-ja-tappiot/2023/paaomatilojen-veroprosentit-2025-1993/
pääomatulot <- 0
pääomatulovero <- if (pääomatulot < 40000) {
  0.3 * pääomatulot
} else {
  12000 + 0.32 * (pääomatulot - 40000)
}

# Kunnallisvero, https://www.veronmaksajat.fi/tutkimus-ja-tilastot/kuntaverot/#945e7427
kunnallisvero <- 0.1974 * tulot

# Tulot verojen jälkeen
tulot_verojen_jälkeen <- tulot + pääomatulot - (tulovero + pääomatulovero + kunnallisvero)

# Asumiskulut, lähde: ?
asumiskulut <- 0.2 * tulot_verojen_jälkeen

# Säästöt, lähde: Eurostat
säästöt <- 0.1 * tulot_verojen_jälkeen

# Tupakkavero
# Vero on 50% vähittäismyyntihinnasta, askin keskihinta 5 euroa
askia_päivässä <- 0
tupakkavero <- 0.5 * 5 * 365 * askia_päivässä

# Ajoneuvo- ja polttoainevero
# moottoribensiinin vero 67.29 snt/l
# - Vähäpäästöinen 120g/km, 5.3l/100km (~Toyota Yaris)
# => ajoneuvovero <- 59.13
# - Keskipäästöinen 170g/km, 7.46l/100km
# => ajoneuvovero <- 114.975
# - Suuripäästöinen 230g/km, 10.0l/100km (~VW Touareg)
# => ajoneuvovero <- 205.86
# Keskimäärin suomalainen ajoi 18 300km vuodessa
ajoneuvovero <- 0
polttoainevero <- 0 # 5.3 l/100km * 18300/100km * 67.29/100 e/l = 652,66e

# Alkoholivero
# Keskimäärin Suomessa juotiin 10l, vero 30e/l
alkoholivero <- 10*30

# Energiavero
# vero 1.69 snt/kWh
# - Kerrostalo 2550 kWh
# - Rivitalo 4800 kWh
# - Omakotitalo 18500 kWh
energiavero <- 2550*1.69/100

# ALV, painotettu kulutuksen ALV-kertymä 12%, lähde: ?
kulutus <- tulot_verojen_jälkeen - säästöt - asumiskulut
alv <- kulutus * 0.12

# Käyttäjä pystyi antamaan muita maksettuja veroja
muut_verot <- 0

verosumma <- tulovero + pääomatulovero + tupakkavero + ajoneuvovero + polttoainevero + alkoholivero + energiavero + alv + muut_verot

budjetti <- read_csv("budjetti.csv", col_names = c("l1", "l2", "l3", "sum"))

# valtion verovaroin katetut menot
valtion_tulot <- budjetti |>
  filter(!is.na(l3)) |>
  summarise(sum(sum)) |>
  pull()

budjetti |> mutate(osuus = sum/valtion_tulot*verosumma) |> select(!sum)
