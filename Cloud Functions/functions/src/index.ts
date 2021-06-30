//Firebase Cloud functions tutorial: https://www.youtube.com/watch?v=DYfP-UIKxH0&list=PLl-K7zZEsYLkPZHe41m4jfAxUi0JjLgSM
//TypeScritp Handbook: https://www.typescriptlang.org/docs/handbook/intro.html
//TypeScript Course tutorial: https://www.youtube.com/watch?v=BwuLxPH8IDs&t=92s
//Learn Node.js: https://nodejs.dev/learn/introduction-to-nodejs

import * as functions from "firebase-functions"
// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript


export const helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

//User creates an account
//User enters details and adds User Profile and radius of search
//functions listen for update in user profiles and then creates a list of recently joined users in
    //their area
//we then push that array of users to their
