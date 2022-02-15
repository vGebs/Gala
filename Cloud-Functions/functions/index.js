const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

exports.listenForMatches = functions.firestore.document("Likes/{likerUID}")
    .onCreate(async (snap, context) => {
        const docRef = snap.id;
        const data = snap.data();
        const likerUID = data.likerUID;
        const likedUID = data.likedUID;

        const matchCollection = db.collection("Matches");
        const likesCollection = db.collection("Likes");
        const peopleThatLikeMe = await getPeopleThatLikeMe(likerUID);

        if (peopleThatLikeMe != null) {
            for (let i = 0; i < peopleThatLikeMe.length; i++) {
                if (peopleThatLikeMe[i].id == likedUID) {
                    matchCollection.add({
                        matched: [likedUID, likerUID],
                        time: admin.firestore.FieldValue.serverTimestamp()
                    });

                    likesCollection.doc(docRef).delete();
                    likesCollection.doc(peopleThatLikeMe[i].ref).delete();
                }
            }
        }
        return;
    });


//  Make a querying function that queries all likes where likedUID == myID
//  return the likes back to listenForMatches
//  loop through the likes and check if the user likes the other user back

async function getPeopleThatLikeMe(likerUID) {
    //  Get all likes where likedUID == self.likerUID
    //  return only the uid's
    const likesRef = db.collection("Likes");

    const snap = await likesRef.where("likedUID", "==", likerUID).get();
    if (snap.empty) {
        return new Array();
    } else {
        let likes = new Array();
        snap.forEach((doc) => {
            const docRef = doc.id;
            const data = doc.data();
            const liked = data.likerUID;

            const likeObject = new Object();
            likeObject.ref = docRef;
            likeObject.id = liked;

            likes.push(likeObject);
        });

        const filteredArr = likes.reduce((acc, current) => {
            const x = acc.find(item => item.id === current.id);
            if (!x) {
                return acc.concat([current]);
            } else {
                return acc;
            }
        }, []);

        return filteredArr;
    }
}

// function uniq(a) {
//     var seen = {};
//     return a.filter(function (item) {
//         return seen.hasOwnProperty(item) ? false : (seen[item] = true);
//     });
// }

//for linting
// "functions": {
//     "predeploy": [
//       "npm --prefix \"$RESOURCE_DIR\" run lint"
//     ]
//   },