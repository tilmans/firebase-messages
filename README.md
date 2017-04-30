# firebase-messages

This is an Elm fork of [firebase-messages](https://github.com/RomansBermans/firebase-messages) by [@RomansBermans](https://github.com/RomansBermans)

## Setup
1. Install [Node.js](https://nodejs.org/en/download/)
2. Create a project on [Firebase](https://console.firebase.google.com/) and note down the Project ID
3. Replace the project id in the `.firebaserc` with your Project ID
4. Click **Add Firebase to your web app** and copy your Initialization Code
5. Replace the initialization DB settings in db_prod.js (Deployed instance) and create a db_local.js with the settings for your local instance. These are the same if you did not create dev keys.

## Install
```
npm install
npm run elm-github-install
```

## Start
In two separate terminals
```
npm run buildWatch
```

```
npm start
```

## Deploy
```
npm run deploy
```

## Demo
https://funproject-809c6.firebaseapp.com

## Learn More

[Firebase Bolt](https://github.com/firebase/bolt)

[Firebase Realtime Database](https://firebase.google.com/docs/database/)

[Firebase Cloud Functions](https://firebase.google.com/docs/functions/)

[Elm](http://elm-lang.org/)

[Elm Firebase](https://github.com/pairshaped/elm-firebase)