# Verokuitti

> Valtion budjetin luvut ovat niin tolkuttoman suuria, etteivät ne enää tarkoita mitään. Valtion käyttämä raha on kuitenkin sinun ja meidän rahaa, joten mielestämme on hyvä ymmärtää, mihin fyrkat käytetään. Verokuitti kertoo arkisella tasolla, paljonko sinä olet maksanut erilaisiin tarkoituksiin.

[Verokuitti](https://www.talousviisas.fi/verokuitti/) oli vuosina 2011-2013 ylläpidetty palvelu, joka visualisoi [Suomen valtion budjetin](https://budjetti.vm.fi/) yhden veronmaksajan tasolla kaupan kuitin muodossa. Palvelu voitti 2011 Apps4Finland-gaalassa Helsingin Sanomien erikoispalkinnon vuoden parhaasta tietojournalismista. Seuraavana vuonna se oli ehdolla kansainvälisessä Data Journalism Awards -kilpailussa.

Palvelu kirvoitti jopa [kirjallisen kysymyksen Eduskunnassa vuonna 2019](https://www.eduskunta.fi/valtiopaivaasiakirjat/KK+664/2018) miksi valtio ei tarjoa vastaavaa palvelua, etenkin kun alkuperäistä Verokuittia ei oltu päivitetty enää 5 vuoteen.

[Tämä repo sisältää Quarto-dokumentin](https://kari.github.io/verokuitti/), joka käy läpi miten Verokuitti toimi n. vuonna 2013 sekä sisältää vihjeitä miten vastaavan laskelman voisi toteuttaa vuonna 2025 ja mitä haasteita siihen sisältyy.

Verokuitin alkuperäiset tekijät olivat Pär Österlund, Kari Silvennoinen ja Jon Haglund.

## Sisältö

Tämän repon tavoite on dokumentoida miten alkuperäisen Verokuitin kaksi osaa [`budjetti2csv.rb`](https://gist.github.com/kari/6742443) ja `kuitti.php` pääpiirteisesti toimivat n. vuonna 2013. Tämä on toteutettu R-koodilla [Quarto-dokumentin](https://kari.github.io/verokuitti/) avulla.

Ensimmäinen haki VM:n budjettipalvelusta numerotiedot ja muokkasi ne sopivaan muotoon. Jälkimmäinen oli vastuussa loppukäyttäjälle esitetystä käyttöliittymästä sekä syötettyjen tulotietojen perusteella käyttäjän maksamien verojen kokonaissuman arvioinnista ja verokuitin luomisesta.

## Osallistuminen

Tämä repo ottaa mielellään vastaan bugeja ja muita korjauksia, jotka selkeyttävät toimintaperiaatetta (esimerkiksi vähentämällä käytettyjen kirjastojen määrää). Mitään uusia ominaisuuksia tai suurempia muutoksia ei kuitenkaan tarvita, koska tämän repon tarkoitus on dokumentoida yli 10 vuotta vanhaa koodia.

## Lisenssi

[AGPL](https://choosealicense.com/licenses/agpl-3.0/)
