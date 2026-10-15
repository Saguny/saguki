#!/usr/bin/env bash
# Smoke test against a running server: ./smoke.sh http://127.0.0.1:8787 <SAGUKI_PASSWORD>
set -euo pipefail
URL=$1; PW=$2
j() { python -c "import json,sys; print(eval(sys.argv[1], {}, {'r': json.load(sys.stdin)}))" "$1"; }
code() { curl -s -o /dev/null -w '%{http_code}' "$@"; }
post() { curl -s -X POST -H 'content-type: application/json' "$@"; }

[ "$(code -X POST -d '{"password":"nope","device":"t"}' "$URL/login")" = 401 ] || { echo "FAIL wrong pw"; exit 1; }
TOKEN=$(post -d "{\"password\":\"$PW\",\"device\":\"smoke\"}" "$URL/login" | j "r['token']")
AUTH="authorization: Bearer $TOKEN"
[ "$(code -X POST -H 'authorization: Bearer bogus' -d '{"cursor":0,"changes":[]}' "$URL/sync")" = 401 ] || { echo "FAIL bogus token"; exit 1; }
[ "$(code -X POST -H "$AUTH" -d '{"cursor":0,"changes":[{"t":"users; drop","id":"x","m":1,"d":false,"data":{}}]}' "$URL/sync")" = 400 ] || { echo "FAIL bad table"; exit 1; }

ID="smoke-$RANDOM$RANDOM"
row() { echo "{\"t\":\"decks\",\"id\":\"$ID\",\"m\":$1,\"d\":false,\"data\":{\"id\":\"$ID\",\"name\":\"$2\"}}"; }
C0=$(post -H "$AUTH" -d '{"cursor":0,"changes":[]}' "$URL/sync" | j "r['cursor']")
post -H "$AUTH" -d "{\"cursor\":$C0,\"changes\":[$(row 100 first)]}" "$URL/sync" >/dev/null
post -H "$AUTH" -d "{\"cursor\":$C0,\"changes\":[$(row 50 older)]}" "$URL/sync" >/dev/null
[ "$(post -H "$AUTH" -d "{\"cursor\":$C0,\"changes\":[]}" "$URL/sync" | j "[c['data']['name'] for c in r['changes'] if c['id']=='$ID'][0]")" = first ] || { echo "FAIL older write won"; exit 1; }
post -H "$AUTH" -d "{\"cursor\":$C0,\"changes\":[$(row 200 newer)]}" "$URL/sync" >/dev/null
OUT=$(post -H "$AUTH" -d "{\"cursor\":$C0,\"changes\":[]}" "$URL/sync")
[ "$(echo "$OUT" | j "[c['data']['name'] for c in r['changes'] if c['id']=='$ID'][0]")" = newer ] || { echo "FAIL newer write lost"; exit 1; }
C1=$(echo "$OUT" | j "r['cursor']")
[ "$(post -H "$AUTH" -d "{\"cursor\":$C1,\"changes\":[]}" "$URL/sync" | j "len(r['changes'])")" = 0 ] || { echo "FAIL cursor"; exit 1; }
# Leave a tombstone with the required columns so real clients just store a deleted deck.
post -H "$AUTH" -d "{\"cursor\":$C1,\"changes\":[{\"t\":\"decks\",\"id\":\"$ID\",\"m\":300,\"d\":true,\"data\":{\"id\":\"$ID\",\"name\":\"smoke\",\"modified_at\":300,\"deleted\":1}}]}" "$URL/sync" >/dev/null
echo "smoke OK"
