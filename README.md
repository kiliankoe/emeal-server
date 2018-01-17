# 🌯 emeal-server

[![Travis](https://img.shields.io/travis/kiliankoe/emeal-server.svg?style=flat-square)](https://travis-ci.org/kiliankoe/emeal-server)

This is a minimal webapp to function as a proxy between anything requiring meal data (e.g. your app, chatbot, etc.) and the [canteen menu](https://www.studentenwerk-dresden.de/mensen/speiseplan/) of the Studentwerk Dresden. It's powered by [Vapor](https://vapor.codes) and runs on Swift.

🍲✌️

## Usage

### `/canteens`

List out all known canteens. This information is however [bundled with the app](https://github.com/kiliankoe/emeal-server/blob/master/Config/canteen.json) itself. Don't consider it dynamic. The canteens' IDs are based on their order in the linked config file.

```js
[
  {
    "name": "Mensa Reichenbachstraße",
    "city": "Dresden",
    "coordinates": {
      "latitude": 51.0342255,
      "longitude": 13.7323254
    },
    "id": 1,
    "address": "Reichenbachstr. 1, 01069 Dresden"
  },
  {
    "name": "Zeltschlösschen",
    "city": "Dresden",
    "coordinates": {
      "latitude": 51.031458,
      "longitude": 13.7264826
    },
    "id": 2,
    "address": "Nürnberger Straße 55, 01187 Dresden"
  },
  ...
]
```


### `/meals`

List all meals for the current day. The query parameters `date` and `canteen` can be used with example values `2018-01-08` or `4` (canteen id) respectively to query for specific dates or canteens.

Use a canteen's id as a URL parameter, e.g. `/meals/4` to list all known meals for a given canteen. At maximum this can include the next three weeks worth of data.

The corresponding values for the `information` can be found [here](https://github.com/kiliankoe/emeal-server/blob/master/Sources/App/Models/MealInformation.swift). Info on listed [allergens](https://www.studentenwerk-dresden.de/mensen/faq-8.html) and [additives](https://www.studentenwerk-dresden.de/mensen/zusatzstoffe.html) is provided by the Studentenwerk.

```js
[
  {
    "canteen": "Alte Mensa",
    "detailURL": "https://www.studentenwerk-dresden.de/mensen/speiseplan/details-198200.html?pni=20",
    "information": [
      "pork",
      "garlic"
    ],
    "image": null,
    "isSoldOut": false,
    "date": "2018-01-08",
    "title": "Hausgemachte frische Pasta, heute Amori in Pastasoße all'amatriciana mit Tomaten und Bauchspeck, dazu italienischer Hartkäse Grana Padano",
    "studentPrice": 2.3,
    "employeePrice": 4.05,
    "additives": [
      "2",
      "3",
      "8"
    ],
    "allergens": [
      "A",
      "A1",
      "C",
      "G"
    ]
  },
  {
    "canteen": "Alte Mensa",
    "detailURL": "https://www.studentenwerk-dresden.de/mensen/speiseplan/details-198216.html?pni=18",
    "information": [
      "vegetarian"
    ],
    "image": null,
    "isSoldOut": false,
    "date": "2018-01-08",
    "title": "Paprikaschote mit Soja-Gemüsefüllung mit Tomatensoße, dazu Bohnen- Maisgemüse und Reis",
    "studentPrice": 2.4,
    "employeePrice": 4.15,
    "additives": [],
    "allergens": [
      "A",
      "A1",
      "I"
    ]
  },
  ...
]
```


### `/search`

Search for a given keyword in all known meal titles. The keyword is supplied with the query parameter `query`, e.g. `http://server_url/search?query=burrito`. The response is a list of meals matching the query.

### `/update`

Queue an update for the application's data for a given week and day. Using this shouldn't be necessary in most cases, since the application updates everything itself at regular intervals, but sometimes it very well might be. In that case send a POST request to `/update` with a week and day identifier as form url-encoded body params.

To prevent external misuse of this endpoint, the server requires the request to come from `0.0.0.0`, e.g. localhost. An `update` script is provided for convenience. It is supplied with the week and day identifiers, e.g. `./update current monday` and basically just `curl`s the running server with the given commands.

## Installation

A `Dockerfile` exists to make installation and deployment of this app as easy as possible. Otherwise it can be built and deployed like any other [Vapor](https://vapor.codes) application.
