# Readlock Blueprint: struktura kursu, nawyki, UX i model biznesowy

Dokument jest wewnetrznym punktem odniesienia dla zespolu Readlock. Zbiera to, co rzeczywiscie wiadomo z badan i raportow publicznych (2024-2026) na temat projektowania aplikacji do codziennej mikronauki na telefonie. Zamiast powtarzac wsrednie liczby krazace po blogach produktowych, flagujemy co jest zweryfikowane, co jest przyblizone i co jest folklorem.

Readlock to aplikacja mobilna, w ktorej uzytkownik przesuwa palcem przez edukacyjne mikro-tresci. Kurs dzieli sie na segmenty, segment na pakiety, pakiet na slajdy. Kategoria tresci: non-fiction (psychologia, design, ekonomia, historia, filozofia). Konkurencja koncepcyjna: Duolingo, Blinkist, Headway, Brilliant, Shortform, Imprint.

---

## 1. Dlugosc sesji i struktura lekcji

**5-15 minut na sesje to konsensus, nie prawo.** Systematyczne przeglady z 2024 roku (ScienceDirect, Nature Scientific Reports) wskazuja ten przedzial jako optymalny dla pamieci roboczej doroslego uzytkownika. Pojedyncza mikro-lekcja w zakresie 3-7 minut daje wystarczajace zanurzenie bez przeciazenia. Krotsze sesje (<3 min) tworza nawyk, ale czesto sa za plytkie, zeby czegos naprawde nauczyc. Dluzsze niz 15 minut trafiaja w sufit uwagi.

**Chunking dziala, nadmierne chunkowanie szkodzi.** Rozbijanie tresci na mniejsze fragmenty poprawia zrozumienie w badaniach nad czytaniem (EFL, L1). To samo badanie pokazuje jednak, ze zbyt male kawalki, np. jedno zdanie na slajd, niszcza kontekst i spowalniaja czytelnika. Zdrowy przedzial dla Readlock: 3-5 zdan na slajd, 40-80 slow.

**Paging bije scrolling na zmeczenie wzroku.** Eye-trackingowe badanie z PMC 2025 na studentach czytajacych na telefonie wykazalo, ze model "jedna strona na raz" (dokladnie to, co Readlock robi przez swipe) daje mniej zmeczenia wzroku niz ciagle przewijanie. To jeden z nielicznych mocnych argumentow za swipe-per-screen w edukacji.

**Liczba lekcji na ksiazke nie jest ustalona branzowo.** Brilliant ma kursy o roznych rozmiarach (od ~19 do ~25+ lekcji w konkretnych tematach). Blinkist robi jeden "blink" na ksiazke. Duolingo nie operuje pojeciem "lekcja per ksiazka". Dla Readlock rozsadny projekt to 15-25 pakietow na ksiazke, podzielone na 2-4 segmenty po 3-5 pakietow. To decyzja produktowa, nie cytowana norma.

---

## 2. Pierwsza sesja i retencja

**"Wygrana" w pierwszej sesji jest jednym z najmocniejszych predyktorow retencji.** Ta obserwacja powtarza sie we wszystkich raportach branzowych (AppsFlyer, Enable3, Mistplay). Pojedyncze peer-reviewed badanie z twardym oknem "10-15 minut" nie istnieje - to liczba branzowa, nie naukowa. Zasada ktora jest udokumentowana: uzytkownik, ktory w pierwszej sesji wykonal jedna znaczaca akcje, zostaje w aplikacji znaczaco dluzej niz ten, ktory tylko przeszedl onboarding.

Wniosek dla Readlock: pierwszy pakiet pierwszej ksiazki musi dac czytelnikowi konkretna nowa idee z imieniem i anchorem z codziennego zycia. Nie "zrobiles onboarding", nie "wybrales kurs", tylko "rozumiesz nowa rzecz, ktorej nie rozumiales 5 minut temu". Ten pakiet jest "darmowy" nie dlatego, ze taki jest model, tylko dlatego, ze ma wyjatkowo zadbany copy i strukture.

**Benchmarki retencji kategorii edukacyjnej (2025).** Mediana D1 ~26%, D7 ~13%, D30 ~7% (Mistplay / Enable3). Dobre aplikacje edukacyjne lapia D1 ~30%, D7 ~15%. Duolingo siedzi wysoko powyzej mediany - DAU/MAU 37,2% w Q2 FY25 (list do akcjonariuszy), w Q3 2025 DAU przekroczylo 50 milionow (+36% YoY). To kamienie milowe, nie cele.

---

## 3. Nawyki: co naprawde dziala

**"66 dni do nawyku" jest prawdziwe jako badanie, nie jako regula.** Oryginal Lally i inni (2010, European Journal of Social Psychology) mial 82 uczestnikow, ktorzy wybrali sobie codzienne zachowanie. Srednia czas do automatyzacji wyniosl 66 dni, ale **rozrzut byl od 18 do 254 dni**. Replikacja z 2022 roku (Diefenbacher, UCL) potwierdza ogolny wzorzec, ale podkresla silna zaleznosc od kontekstu. Niektore nowsze prace podaja ~56 dni w innych populacjach. Regula nie ma. Jest "tygodnie, nie dni".

Konsekwencja dla Readlock: nie obiecujemy "30-dniowego wyzwania, ktore zmieni twoje zycie". To kopia stylu konkurencji bez pokrycia. Mozemy pokazywac "X dni od pierwszej lekcji" bez deklarowania, ze nawyk sie juz uformowal.

**Streaks dzialaja, ale wiedzmy co dokladnie robia.** Duolingo publicznie potwierdza, ze serie to ich glowna mechanika wzrostu. Streak Freeze obniza churn wsrod uzytkownikow zagrozonych o ~21% (liczba firmowa, nie peer-reviewed). Ponad 9 milionow uzytkownikow Duolingo ma serie dluzsza niz rok (wywiad z Jacksonem Shuttleworthem, 2024).

Wazne zastrzezenie: akademickie przeglady gamifikacji edukacyjnej regularnie pokazuja, ze streaks i XP **maksymalizuja zaangazowanie, ale niekoniecznie uczenie sie**. Uzytkownik moze wracac codziennie dla serii, a nie pamietac nic z tego, czego sie uczyl. Readlock, jesli ma byc aplikacja ktora naprawde uczy, musi miec streaks jako **jedna z** mechanik retencji, nie jedyna i nie glowna.

**Co z badan nawykowych jest solidne przez wszystkie publikacje:** staly sygnal, niska bariera wejscia, mala codzienna akcja, widoczny postep. Odznaki, rankingi, tabele wynikow sa dekoracja - pomagaja retencji, nie sa przyczyna uczenia sie. Jesli ktoras mechanika ma byc wycieta, wycinamy tabele wynikow, nie serie.

---

## 4. Obciazenie poznawcze

Readlock juz ma dobre zasady copy na poziomie zdania i slajdu (patrz `lockie/copywriting/guides/readlock_course_copywriting_guide.md`). Na poziomie struktury kursu wazne jest, zeby tych zasad nie rozwadniac:

- Jedna glowna idea na pakiet, nie trzy.
- Jeden koncept na slajd, nie dwa.
- Kazda abstrakcja ma jeden anchor z codziennego zycia (nie dwa - drugi oznacza, ze pierwszy byl za slaby).
- Widoczne granice miedzy sekcjami (tytul pakietu, biala przestrzen) obnizaja obciazenie pamieci roboczej.

To sa rzeczy, ktore badania nad pamiecia dlugoterminowa potwierdzaja od dekad. Nie sa nowosciom i nie potrzebuja nowych cytowanych liczb.

---

## 5. Nawigacja: swipe vs przyciski

**Google wycofal nieskonczony scroll w wynikach wyszukiwania 25 czerwca 2024.** Jako przyczyne firma podala dwa punkty: (1) ladowanie wynikow bez zadania uzytkownika marnowalo zasoby, (2) **"auto-ladowanie nie zwiekszalo satysfakcji uzytkownika"**. Drugi punkt jest kluczowy. Infinite scroll wyglada na zaangazowanie, ale nie przesuwa metryk satysfakcji. Satysfakcja wymaga poczucia konca i poczatku.

**"70% uzytkownikow woli gesty nad przyciski" nie ma zrodla.** Cytowane jest Nielsen Norman Group, ale badania nie dalo sie znalezc. Ankieta Android Central z 2025 roku daje odwrotnosc: 81% uzytkownikow Androida wybiera trzyprzyciskowa nawigacje nad gesty. Nie piszemy "70%" nigdzie. Mozemy pisac: "nawigacja gestami to standard nowoczesnych systemow mobilnych" - to jest prawdziwe i obronialne.

**"25% szybsze zadania z gestami" i "24% redukcja obciazenia poznawczego gestami" sa folklorem.** Zadnego zrodla nie udalo sie znalezc. Wycinamy oba numery ze wszystkich materialow.

**Co jest faktycznie poparte.** Publikacja na CHI 2024 (ACM) porownala tap i swipe na poziomie zachowania. Znaleziono roznice w czasie, liczbie bledow i rozkladzie punktow dotyku, ale zaden paradygmat nie jest "lepszy do uczenia sie". Swipe jest OK jako mechanika, nie naprawia sam z siebie retencji.

**Ostrzezenie z badan TikToka.** Haliti-Sylaj i Sadiku (2024, 150 studentow) oraz systematyczny przeglad w Cyberpsychology (2024) znalazly korelacje miedzy konsumpcja krotkich filmow a samoraportowanym spadkiem uwagi i obnizonym myslenim analitycznym. Dla Readlock: swipe jest OK jako nawigacja, ale nie kopiujemy rytmu TikToka. Bez auto-advance, bez dopaminowych impulsow, bez "przesun dalej w 3 sekundy".

**Model hybrydowy dla Readlock:**

- **Wewnatrz pakietu**: swipe miedzy slajdami. Widoczny pasek postepu. Daje poczucie ruchu naprzod.
- **Miedzy pakietami**: przycisk "Ukoncz lekcje" i "Nastepny pakiet". To przycisk, nie gest - ten moment musi byc odczuty jako osiagniecie, nie jako kolejna karta na stosie.
- **Auto-advance: nigdy**. Uzytkownik przesuwa palec, gdy skonczyl czytac, a nie gdy aplikacja tak zdecydowala.
- **Szybkie wznowienie**: gdy wraca do aplikacji, otwieramy dokladnie ten slajd, na ktorym skonczyl.

---

## 6. Model biznesowy: kredyty vs abonament

Poprzedni dokument twierdzil, ze modele kredytowe daja "35% wiecej zaangazowania niz nieograniczone", "25% lepsza retencja z rollover" i "40% firm SaaS eksperymentowalo z kredytami w 2024". **Zadnej z tych liczb nie udalo sie znalezc w zadnym pierwotnym zrodle.** To sa wtornie recyklowane liczby z blogow produktowych.

**Co jest faktycznie udokumentowane:**

- **Audible ma model kredytowy z wygasaniem po 12 miesiacach.** Firma otwarcie mowi, ze wygasanie jest zamierzona mechanika zaangazowania - zapobiega gromadzeniu kredytow i wymusza zuzycie.
- **Audible w 2024 zaraportowal "mocny dwucyfrowy wzrost" nowych rejestracji** po wprowadzeniu Standard Plan w UK i Australii. To liczba kierunkowa, nie "35%".
- **Awersja do straty** (Kahneman i Tversky, 1979): wspolczynnik okolo 2,0-2,5. Strata jest odczuwana **w przyblizeniu dwa razy** mocniej niz rownowazny zysk. Praca Gala i Ruckera z 2018 roku pokazuje jednak, ze ten wspolczynnik ma moderatorow. Piszemy "w przyblizeniu dwa razy", nie "dokladnie dwa razy".

**Konsekwencje dla Readlock.** Model kredytowy ma sens, jesli dojdziemy do niego z uczciwych powodow, nie przez cytowanie fikcyjnych 35%. Uczciwe powody:

1. **Swiadomy wybor tytulu tworzy inwestycje.** Jesli wybieram jedna ksiazke sposrod ograniczonej puli miesiecznie, traktuje ja powaznie. Jesli mam dostep do wszystkiego, nie traktuje niczego powaznie.
2. **Wlasnosc w ramach abonamentu.** Jesli po rezygnacji z abonamentu zostaja ksiazki juz wybrane, rezygnacja boli konkretnie - tracisz mozliwosc dopisywania nowych.
3. **Bonus kredytowy za serie.** 30 dni nauki = dodatkowy kredyt ksiazkowy. Laczy streak (udokumentowana mechanika) z kredytami (mechanika wlasnosci). Petla zwrotna.

Nie jako magiczna formula "+35% engagement", tylko jako spojna logika produktowa.

---

## 7. Mobile-first: co jest prawdziwe

**"60%+ uczacych sie uzywa glownie smartfonow"** pochodzi z publikacji branzowych bez pierwotnego zrodla. Badanie MOOC z 2024 roku (Open Praxis) pokazuje, ze tylko okolo 30% uzytkownikow MOOC wchodzi przez mobile. Readlock jest blizej Duolingo niz Coursera, wiec pewnie jest wyzej, ale nie mozemy cytowac "60%+" bez wlasnego badania.

**"Mobile completion 45-80% wyzsze niz desktop" - folklor, nie znalezione zrodlo.** Wycinamy.

**Co jest rzeczywiscie solidne dla mobile-first w naszym kontekscie:**

- Jednoreczne uzycie i strefa kciuka to standardowa wiedza UX.
- Sesje w dojezdzie i w "mikro-okienkach" 5-7 minut - telefon defaultowo wygrywa.
- Tryb offline dla metra - to zadanie produktu, nie statystyka.

---

## 8. Konkretne rekomendacje dla Readlock

Skladam ponizsze punkty z tego, co zostalo sprawdzone. Kazdy jest dzialalny.

### Struktura pakietu

- Dlugosc: 5-7 minut czytania
- Liczba slajdow: 7-11 (zgodnie z obecnym formatem `.rlockie`)
- Jeden koncept na pakiet, jedno imie (Phase 4 reveal)
- Kazdy pakiet konczy sie slajdem outro, ktory domyka mysl i zapowiada nastepny

### Struktura kursu

- 15-25 pakietow na ksiazke
- 2-4 segmenty po 3-5 pakietow
- Pierwszy pakiet pierwszego segmentu oznaczony `Free`, ze szczegolnym dopracowaniem copy
- Czas ukonczenia ksiazki: 10-20 dni przy 1-2 pakietach dziennie

### Dzienne cele

- **Luzny**: 1 pakiet (~5 minut)
- **Regularny**: 2 pakiety (~10-12 minut)
- Zero "trybu intensywnego". Dzienne cele > 15-20 minut powoduja porzucenie szybciej niz brak celu.

### Retencja i nawyk

- Seria (streak) - glowna mechanika
- Zamrozenie serii (1-2 dni / miesiac) - udokumentowana redukcja churnu
- Bonus kredytu ksiazkowego za 30 dni serii - laczy mechaniki
- Powiadomienia zdarzeniowe (event-based) zamiast o stalej porze, gdy mozliwe

### UI i nawigacja

- Swipe wewnatrz pakietu miedzy slajdami
- Przycisk "Ukoncz" na koncu pakietu
- Pasek postepu widoczny caly czas
- Tryb offline dla pakietow
- Szybkie wznowienie na ostatnim slajdzie

### Metryki do monitorowania

- D1 retention (cel: >30% dla nowej kategorii)
- D7 retention (cel: >15%)
- Completion rate pakietu "Free" pierwszego segmentu (to jest prawdziwa metryka produktu)
- Czas do pierwszej "wygranej" (czas od instalacji do ukonczenia pierwszego pakietu)
- DAU/MAU (benchmark: Duolingo 37% - nieosiagalny dla nowej aplikacji, ale 15-20% to solidny cel)

---

## 9. Czego unikamy (i dlaczego)

Ta lista istnieje, zeby nie wrocilo przez copy-paste z poprzedniej wersji:

**Folklor statystyczny (wyciete, nie cytujemy):**

- "130% wzrost zaangazowania microlearning vs tradycyjne szkolenia"
- "80% ukonczenia microlearning vs 20% tradycyjne"
- "70% uzytkownikow woli gesty nad przyciski"
- "25% szybsze zadania z gestami"
- "24% redukcja obciazenia poznawczego z gestami"
- "35% wiekszy engagement z modeli kredytowych"
- "25% lepsza retencja z rollover kredytow"
- "40% firm SaaS eksperymentuje z kredytami (2024)"
- "Mobile completion 45-80% wyzsze niz desktop"
- "Brilliant: dokladnie 3 pytania sprawdzajace na kurs"
- "Brilliant: 30-45 lekcji na kurs"

Wszystkie brzmialy dobrze w starym dokumencie. Zadna nie przetrwala konfrontacji ze zrodlem. Zabijaja wiarygodnosc, gdy ktos z zewnatrz sprawdzi.

**Decyzje produktowe do unikniecia:**

- Rytm TikToka (auto-advance, dopamina, "przesun dalej w 3 sekundy")
- Grywalizacja ponad miarke (badges, rankingi globalne, poziomy z setkami krokow)
- Dzienne cele powyzej 15-20 minut
- Obiecywanie konkretnych liczb dni do nawyku ("30 dni i jestes nowym czlowiekiem")
- Generic nieskonczony scroll w katalogu ksiazek (Google wycofal z powodu)

---

## 10. Zrodla

Liczby przytaczane w tym dokumencie pochodza z ponizszych publikacji. Tam, gdzie nie ma zrodla, liczba nie pojawia sie w tekscie.

**Badania akademickie:**
- Lally, P. et al. (2010). How are habits formed: Modelling habit formation in the real world. *European Journal of Social Psychology*. (Badanie "66 dni".)
- Diefenbacher, S. et al. (2022). *British Journal of Health Psychology*. (Replikacja badania nawykow z kontekstem.)
- Haliti-Sylaj, T. & Sadiku, A. (2024). Impact of short reels on attention span and academic performance. (150 studentow, korelacja TikTok-uwaga.)
- Gal, D. & Rucker, D. (2018). The Loss of Loss Aversion. *Journal of Consumer Psychology*. (Moderatorzy wspolczynnika 2x.)
- Systematyczny przeglad microlearning, ScienceDirect (2024).
- Adaptive microlearning and cognitive load, Nature Scientific Reports (2024).
- ACM CHI 2024 - Tap vs Swipe behavioral differences.
- PMC (2025). Mobile reading eye-tracking: paging vs scrolling and visual fatigue.
- Cyberpsychology (2024). Short-form video use and analytic thinking.

**Raporty firmowe i publiczne:**
- Duolingo Q2 FY25 Shareholder Letter (DAU/MAU 37,2%).
- Duolingo Q3 2025 Release (50M DAU, +36% YoY).
- Audible Standard Plan launch (dwucyfrowy wzrost rejestracji, 2024).
- Audible credits policy (wygasanie 12 miesiecy).
- Google Search announcement (wycofanie continuous scroll, czerwiec 2024).

**Branzowe kompilacje (traktowac jako przyblizone):**
- Mistplay / Enable3 retention benchmarks 2025-2026.
- AppsFlyer retention reports.
- Open Praxis (2024). MOOC completion rates by device.
- Android Central gesture vs button poll (2025).
- IMARC microlearning market size.
- eLearning Industry microlearning trend reports.

**Podstawa teoretyczna:**
- Kahneman, D. & Tversky, A. (1979). Prospect Theory. (Awersja do straty.)
- Kahneman, D. (2011). *Thinking, Fast and Slow*. (System 1 i 2.)

---

## Zastrzezenie koncowe

Ten dokument nie jest ostateczny. Jest zbiorem najlepszych dostepnych informacji na kwiecien 2026. Jesli pojawi sie nowe badanie lub firma opublikuje nowa liczbe, aktualizujemy dokument i oznaczamy zmiane w commitcie. Jesli cos brzmi podejrzanie dobrze - prawdopodobnie jest folklorem. Sprawdzac przed cytowaniem.
