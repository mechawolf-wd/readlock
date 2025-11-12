# Roadmap do wydania aplikacji Flutter na iOS

**Cel:** Aplikacja mobilna (iOS) napisana w Flutterze, która: (1) wysyła e‑maile, (2) wysyła powiadomienia push, (3) obsługuje miesięczne płatności (Stripe), z uwzględnieniem wymogów prawnych w Polsce (i PKE) oraz międzynarodowo (UE/UK/USA/Kanada).

> **Uwaga krytyczna (App Store):** dla **cyfrowych treści/feature’ów** sprzedawanych **wewnątrz iOS** Apple wymaga **In‑App Purchase/Subscriptions (StoreKit)**. Stripe w iOS jest akceptowalny **wyłącznie** dla **fizycznych towarów/usług w świecie rzeczywistym** lub specyficznych wyjątków (np. „reader apps” z linkiem zewnętrznym w regionach/warunkach dopuszczonych przez Apple). Jeśli Twój abonament dotyczy funkcji cyfrowych, zaplanuj wariant **StoreKit** zamiast Stripe.

---

## 0) Szybki spis treści

1. Strategia monetyzacji vs. zasady Apple
2. Prawne fundamenty (Polska/UE + międzynarodowo)
3. Dane osobowe i prywatność (GDPR/UK GDPR/ATT/Privacy Labels/Privacy Manifest)
4. E‑mail (newsletter/komunikacja) – zgody, polityki, technika
5. Powiadomienia push – zgody, zasady Apple, projekt UX
6. Płatności cykliczne – Stripe/StoreKit, PSD2/SCA/SEPA, fakturowanie/VAT/OSS
7. Architektura techniczna (Flutter + backend)
8. Checklista App Store (od certyfikatów do release)
9. Dokumenty i wzorce (ToS/Polityka prywatności/DPA)
10. Ryzyka/odrzuty w review i sanity‑check
11. Harmonogram wdrożenia i „Definition of Done”

---

## 1) Strategia monetyzacji vs. zasady Apple

**Zdecyduj na starcie:**

- **Sprzedajesz cyfrowe funkcje/treści dostępne w aplikacji?**
  → użyj **In‑App Purchase / StoreKit Subscriptions** (Apple).
- **Sprzedajesz fizyczne dobra / usługi w świecie rzeczywistym (np. dostawa, kurs stacjonarny, konsultacja offline)?**
  → możesz użyć **Stripe** w aplikacji.
- **„Reader App” (np. treści już posiadane, konta, gazety, VOD)**: w niektórych jurysdykcjach Apple dopuszcza **link do zakupu poza aplikacją** (sprawdź warunki i ewentualne opłaty/„store services fees”).

**Konsekwencja dla projektu:** przygotuj dwa warianty:

- **Wariant A (StoreKit):** subskrypcje auto‑renewing, zarządzanie przez Apple ID, anulowanie po stronie Apple; backend służy do odblokowywania funkcji po zweryfikowaniu paragonu (App Store receipt) i webhookach App Store Server Notifications (V2).
- **Wariant B (Stripe – real‑world goods/services):** Stripe Billing/Checkout, obsługa PSD2/SCA, webhooks, dunning, anulacje i zwroty we własnej logice + jasne zasady w regulaminie.

---

## 2) Prawne fundamenty (Polska/UE + międzynarodowo)

### 2.1 Polska/UE – komunikacja elektroniczna i zgody

- **PKE (Prawo Komunikacji Elektronicznej)** – aktualne zasady zgód marketingowych (zastępuje m.in. dawne art. 10 UŚUDE i art. 172 Prawa telekomunikacyjnego).
- **Konsekwencje:**

  - Zbieraj **odrębne, konkretne zgody** na: (a) e‑mail marketing, (b) powiadomienia push o charakterze marketingowym (jeżeli używasz do marketingu), (c) ewentualne SMS/telefon.
  - Prowadź **rejestr zgód** (kto, kiedy, jak, treść klauzuli, source/IP/UA jeśli web) + łatwy mechanizm **wycofania**.

### 2.2 GDPR/RODO (UE) – ogólne

- Określ **administrator(a) danych** (Ty/Twoja firma) i **podmioty przetwarzające** (Stripe, dostawca e‑mail, Firebase itp.).
- Miej **Politykę prywatności** (jęz. PL + EN), **RODO‑checklistę**: podstawa prawna, okresy retencji, kategorie danych, cele, transfery poza EOG (SCC), prawa osób (dostęp, usunięcie, sprzeciw itd.), dane kontaktowe administratora i (jeśli dotyczy) IOD/DPO.
- Oceń, czy potrzebny jest **DPIA** (np. szeroka skala profilowania/monitoringu).

### 2.3 Konsument – UE/Polska

- Transparentne **warunki subskrypcji** (cena, okres, auto‑odnawianie, jak anulować, kiedy pobrania).
- **Prawo odstąpienia 14 dni** przy umowach na odległość (z wyjątkami dla treści cyfrowych po rozpoczęciu spełniania za zgodą).
- Łatwe **reklamacje/zwroty** i kontakt.

### 2.4 UK/USA/Kanada – skrót do e‑maili

- UK: **UK GDPR + PECR** (soft‑opt‑in tylko dla własnych klientów).
- USA: **CAN‑SPAM** (wymóg unsubscribe i adresu pocztowego w e‑mailach komercyjnych; zgoda nie jest obowiązkowa, ale obowiązują rygory treści i wypisów).
- Kanada: **CASL** (zasadniczo **wymaga zgody** – express lub implied, restrykcyjne zasady pozyskiwania).

---

## 3) Prywatność i Apple: ATT, Privacy Labels, Privacy Manifest

- **App Tracking Transparency (ATT):** jeśli śledzisz między aplikacjami/stronami (ad tracking, brokerzy danych) – musisz wyświetlić prośbę o zgodę (i uzasadnienie) oraz respektować odmowę.
- **App Store Privacy Details („Privacy Nutrition Labels”):** zinwentaryzuj dane zbierane przez Ciebie i SDK (Stripe/Firebase/Analytics), zadeklaruj je w App Store Connect.
- **Privacy Manifest (iOS 17+):** zadeklaruj domeny i „Required Reason APIs”, aby uniknąć blokowania i odrzutów.
- **Push:** nie wymagaj zgody push do podstawowego działania; **marketingowe push** tylko po **wyraźnym opt‑in** i z możliwością **opt‑out** w aplikacji.

---

## 4) E‑mail – zgody, treści, technika

### 4.1 Zgody i UX

- Formularz zapisu: checkbox **niezaznaczony domyślnie**, jasny cel (np. newsletter, oferty), link do Polityki prywatności, link do Regulaminu świadczenia usług drogą elektroniczną (usługa newsletter).
- Double opt‑in zalecany (dowód zgody).
- W panelu użytkownika: **zarządzanie preferencjami** (tematy, częstotliwość, „wypisz się”).

### 4.2 Treści i wymogi

- Każdy e‑mail marketingowy: **link „wypisz się”**, dane nadawcy i kontakt.
- Dziel e‑maile **transakcyjne** (potwierdzenia, reset hasła) od **marketingowych** (oferty).
- W USA dodaj **adres pocztowy** w e‑mailach komercyjnych.

### 4.3 Technika wysyłki

- Nie trzymaj sekretnych kluczy w aplikacji iOS. Wysyłkę realizuj **przez backend** (np. SendGrid/Mailgun/SES) → **webhooki** do zbierania bounce/complaints.
- Konfiguruj **SPF/DKIM/DMARC** dla domeny nadawczej.
- Buduj **eventy** (consent_granted, consent_revoked) i trzymaj **audit log**.

---

## 5) Powiadomienia push – zasady i wdrożenie

### 5.1 Zgody i zakres

- iOS prosi o systemowe pozwolenie push – **poprzedź** je ekranem pre‑permission (wyjaśnij wartości).
- Jeżeli planujesz **marketing** przez push → zbierz **osobną zgodę marketingową** (zgodną z PKE/GDPR).
- Umożliw **opt‑out** dla kategorii (transakcyjne vs. marketingowe) i **częstotliwości**.

### 5.2 Technika iOS (Flutter)

- Apple Developer: włącz **Push Notifications** i **Background Modes (Remote notifications)**.
- Utwórz **APNs key** w Apple Developer i dodaj do backendu/FCM.
- Flutter: użyj **firebase_messaging** (APNs pod spodem) + **flutter_local_notifications** dla lokalnych.
- Obsłuż token refresh, tematy/grupy, deep linki, badge’owanie.

### 5.3 Operacja

- Rate‑limity, ciche powiadomienia (content‑available) dla synchronizacji, harmonogramy czasu wysyłek, polityka retrials/retry backoff.
- Logi doręczeń (APNs response), metryki CTR/opt‑out.

---

## 6) Płatności cykliczne – Stripe/StoreKit, PSD2/SCA/SEPA, VAT/OSS

### 6.1 Decyzja płatnicza

- **Cyfrowe treści/feature’y w aplikacji iOS** → **StoreKit Subscriptions** (Apple).
- **Fizyczne dobra/usługi offline** → **Stripe** (Checkout/Payment Element/Billing).
- **UE/DMA/reader apps**: rozważ link do zakupu poza app (sprawdź opłaty/warunki dla Twojego modelu i storefrontów).

### 6.2 PSD2/SCA (UE/UK)

- W Stripe włącz **3D Secure (3DS2)**; pierwsza płatność subskrypcji zwykle wymaga SCA, kolejne mogą korzystać z **exemption dla stałych kwot**.
- Zaimplementuj **webhooki** (invoice.payment_succeeded/failed, customer.subscription.updated).
- Zapewnij **dunning** (przypomnienia, zmiana metody, grace period).

### 6.3 SEPA Direct Debit (UE)

- Dla abonamentów w EUR możesz oferować **SEPA DD**: wymaga **mandatu** (zgoda klienta przy checkout), opóźniona informacja o niepowodzeniu, niższe opłaty kartowe, inne ryzyka chargeback.

### 6.4 VAT/fakturowanie

- Dla sprzedaży B2C w UE powyżej **10 000 EUR rocznie** – rozważ **VAT OSS** (rozliczasz VAT dla innych państw UE w jednym kwartalnym zeznaniu).
- Wystawiaj **faktury** (Stripe Invoicing/wybrany system), podawaj stawki VAT wg miejsca konsumenta (OSS), przechowuj ewidencję.

### 6.5 Polityki subskrypcji

- Jasne zasady: cykl rozliczeniowy, co obejmuje plan, jak anulować, kiedy pobieramy, polityka zwrotów i kontakt wsparcia.
- Dla StoreKit – pamiętaj, że **anulacja** jest po stronie Apple; w aplikacji pokaż link „Zarządzaj subskrypcją”.

---

## 7) Architektura techniczna (Flutter + backend)

**Warstwy:**

1. **Aplikacja Flutter (iOS):** logika UI/UX, StoreKit **lub** web‑flow Stripe (tylko dla real‑world), pobieranie tokenów push, local notifications, eventy analityczne (z respektowaniem ATT).
2. **Backend API:**

   - E‑mail: integracja z dostawcą (SendGrid/Mailgun/SES) + webhooki;
   - Płatności: Stripe Billing/Checkout/Customer Portal + webhooki;
   - Użytkownicy: profile, status subskrypcji, preferencje zgód, audyty;
   - Notyfikacje: kolejki push (APNs/FCM), zarządzanie kampaniami i segmentacją;
   - Compliance: logi zgód, eksport danych (GDPR), usuwanie konta.

3. **Baza danych:** tabele users, consents, subscriptions, invoices, email_events, push_tokens, audit_log.
4. **Panel ops:** ręczna obsługa zgód, wysyłek, raporty VAT/OSS.

**Bezpieczeństwo:**

- Klucze i sekrety **tylko w backendzie**; iOS komunikuje się tokenami krótkotrwałymi.
- Wymuś TLS, rate‑limity, re‑CAPTCHA/Proof‑of‑Work dla formularzy, rotacja kluczy, rejestrowanie dostępu.

---

## 8) Checklista App Store (iOS)

1. **Konto Apple Developer** (osoba/firma; D‑U‑N‑S dla spółki).
2. **Identyfikatory i provisioning**: App ID z capabilities (Push, Background Modes, Associated Domains jeśli linki), certyfikaty, provisioning profiles.
3. **APNs**: wygeneruj **Auth Key** (p8), skonfiguruj w FCM/backendzie; przetestuj sandbox/production.
4. **StoreKit (jeśli dotyczy)**: skonfiguruj produkty/subskrypcje, cenniki, oferty, testy w Sandbox/TestFlight.
5. **Privacy**: uzupełnij **Privacy Nutrition Labels**; dodaj **Privacy Manifest**; uzupełnij **NSPrivacyAccessedAPITypes**/**NS...UsageDescription** (kamera/lokalizacja itd.).
6. **ATT**: jeśli śledzisz – dodaj komunikat i powód; zapewnij „Continue without tracking”.
7. **Zgody**: w aplikacji ekrany do zgód **marketing e‑mail** i **marketing push** + centrum preferencji.
8. **App Store Connect**: metadane, kategorie, linki do **Polityki prywatności** i **Regulaminu** (PL/EN), zrzuty ekranu, testy na urządzeniach.
9. **Eksport kryptografii** (ITAR/EAR) – deklaracja użycia Crypto (ATS/TLS – standard).
10. **TestFlight**: QA, scenariusze płatności, odzyskiwanie zakupów (StoreKit), fallback błędów sieciowych.
11. **Wniosek o review**: notatki dla recenzenta (konta testowe, instrukcje).
12. **Release**: phased release, monitoring crashy, alerty płatności/webhooków, plan hotfix.

---

## 9) Dokumenty i wzorce

- **Polityka prywatności (PL/EN)** – cele, kategorie danych, podmioty przetwarzające (Stripe, dostawca e‑mail, Firebase), transfery poza EOG, prawa użytkownika, kontakt/IOD.
- **Regulamin świadczenia usług drogą elektroniczną / Terms of Service** – definicje, rejestracja, odpowiedzialność, zasady subskrypcji (cena, okres, odnowienia, anulacje, zwroty), reklamacje, jurysdykcja i prawo właściwe.
- **Klauzule zgód** – osobno dla e‑mail, push marketingowego, telefon/SMS (jeśli dotyczy).
- **Rejestr czynności przetwarzania (RODO)** – podstawy prawne, retencja, kategorie odbiorców.
- **DPA** z dostawcami (Stripe, e‑mail, hosting), **SCC** jeśli transfer poza EOG.
- **Procedury GDPR** – realizacja żądań (access/export/delete), data breach playbook (72h).

---

## 10) Ryzyka/odrzuty i sanity‑check

**Najczęstsze powody odrzutu:**

- Stripe/zewnętrzne płatności dla **cyfrowych** funkcji w iOS (naruszenie 3.1.1).
- Brak/nieadekwatne **Privacy Labels** lub niezgodność z SDK.
- Marketingowe push **bez wyraźnej zgody** lub bez opcji opt‑out w app.
- Brak linków do **Polityki prywatności**/**Regulaminu**.
- Brak uzasadnienia przy ATT lub użycie „Required Reason APIs” bez deklaracji.

**Checklist przed wysyłką:**

- [ ] Model płatności zgodny z Apple
- [ ] Zgody i preferencje działają (zapisy w DB)
- [ ] E‑maile: link wypisu, nadawca, DMARC/ DKIM
- [ ] Push: kategorie i opt‑out
- [ ] Privacy Labels/Manifest/ATT poprawnie wypełnione
- [ ] Polityka prywatności i Regulamin opublikowane (PL/EN)
- [ ] Testy subskrypcji (StoreKit lub Stripe) + edge‑case’y
- [ ] Monitoring: crashy, webhooków, płatności

---

## 11) Harmonogram wdrożenia (propozycja 4–6 tyg.)

**Tydzień 1**

- Decyzja monetizacji (StoreKit vs Stripe), macierz jurysdykcji.
- Audyt danych/SDK pod Privacy Labels/Manifest.
- Draft Polityki prywatności + Regulaminu (PL/EN).

**Tydzień 2**

- Implementacja zgód (UI + backend) i centrum preferencji.
- Konfiguracja APNs/FCM, ścieżki push (transakcyjne/marketing).

**Tydzień 3**

- Płatności: StoreKit **lub** Stripe Billing (SCA/SEPA).
- Webhooki, dunning, Customer Portal / „Manage Subscription”.

**Tydzień 4**

- E‑mail: integracja dostawcy, double opt‑in, SPF/DKIM/DMARC, eventy.
- Privacy Labels/Manifest/ATT – uzupełnienie w App Store Connect.

**Tydzień 5**

- QA/TestFlight: case’y płatności, zgody, eksport/usunięcie danych, fallbacki offline.
- Dokumenty final: Polityka/Regulamin/DPA/SCC.

**Tydzień 6**

- Wniosek o review, phased release, monitoring i runbook incydentów.

---

## „Definition of Done” – wersja 1.0

- [ ] Zgodny model sprzedaży (StoreKit dla cyfrowych; Stripe dla real‑world)
- [ ] Zgody PKE/GDPR na e‑mail/push + dowody i mechanizmy wypisu
- [ ] Privacy: Labels + Manifest + ATT (jeśli dotyczy)
- [ ] Płatności cykliczne działają (SCA/SEPA/zwroty/anulacje)
- [ ] VAT/OSS: decyzja i proces rozliczeń
- [ ] Kompletny zestaw dokumentów (ToS/Privacy/DPA)
- [ ] Pełna checklista App Store zaliczona
- [ ] Monitoring i alerting uruchomione

---

## Dodatki (narzędzia/SDK – sugestie)

- **Flutter:** in_app_purchase, purchases_flutter (RevenueCat) – dla StoreKit; stripe_js + webview (tylko dla real‑world), firebase_messaging, flutter_local_notifications.
- **Backend:** Node/Go/Python – Stripe Billing + webhooks, SendGrid/Mailgun/SES, Pub/Sub do push, Postgres + Prisma/SQLx.
- **Compliance ops:** OneTrust/Osano (rejestr zgód), Sentry/Crashlytics, Grafana/Prometheus, Loki dla logów.

---

### Tipy praktyczne

- Utrzymuj **jedno źródło prawdy** dla statusu subskrypcji (backend), niezależnie od iOS/Stripe – synchronizacja paragonów (StoreKit) albo webhooków (Stripe).
- Oddziel **transakcyjne** od **marketingowych** kanałów i zgód – ułatwia audyty i zmniejsza ryzyko prawne.
- Projektuj UX zgód tak, aby **wartość była oczywista**, a rezygnacja szybka i bez tarcia.
- Miej **plan B**: jeśli Apple zakwestionuje płatności Stripe, miej gotowy build z StoreKit (feature flag).
