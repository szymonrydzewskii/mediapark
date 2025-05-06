-----------------------------------------

W SAMORZAD_SERVICE.DART JEST PODLACZENIE DO LOKALNEGO API ZROBIONEGO PRZEZE MNIE

ŻEBY ODPALIĆ SERWER Z API TRZEBA W TERMINALU WPISAĆ
 - npm install -g json-server
 - json-server --watch assets/data/gminy.json --port 3000

Jeśli serwer działa pod innym adresem niż http://localhost:3000, zmień URL w 22 lini pliku samorzad_service.dart na odpowiedni adres.

-----------------------------------------

Jest zrobiony ekran wybierania samorządów i zapisanie w SharedPreferences i tymczasowe przejście do okna które pokazuje nazwę wybranych samorządów, w późniejszym etapie będzie to po prostu zapisywane i przejdzie do głównej strony aplikacji