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


//Make a function that is called every minute
// This function needs to retreive all messages that are older than 24hrs
// Once we get all the messages that are older than 24hrs, we delete them

exports.everyMinuteSchedule = functions.pubsub.schedule('* * * * *').onRun((context) => {
    //ok so, every minute we want to:
    //  1. Delete any old messages
    //  2. Delete any old stories
    deleteOldMessages()
    //deleteOldStories()
    return;
})

async function deleteOldMessages() {
    const tsToMillis = admin.firestore.Timestamp.now().toMillis();
    const compareDate = new Date(tsToMillis - (24 * 60 * 60 * 1000));
    const oldMessages = await db.collection("Messages/").where("openedDate", "<", compareDate).get();

    if (oldMessages.empty) {
        console.log("No messages older than 24hrs");
        return;
    } else {

        oldMessages.forEach((doc) => {
            let docRef = doc.id;
            console.log(doc.id);
            db.collection("Messages").doc(docRef).delete();
        })
    }

    return;
}

async function deleteOldStories() {

    //ok, so we need to delete old stories, but we cannot query an array in firestore
    //so, what we can do, is add a value on the stories document that stores the oldest story date then we query by that
    // once we get the old stories document, we can search the array for old dates and delete them
    // then we can update the document if there is still stories that are within 24hrs
    // if there are no stories left in the array, we delete the stories document

    // const tsToMillis = admin.firestore.Timestamp.now().toMillis();
    // const compareDate = new Date(tsToMillis - (24 * 60 * 60 * 1000));
    // const oldStories = await db.collection("Stories/").where("openedDate", "<", compareDate).get();

    // if (oldMessages.empty) {
    //     console.log("No messages older than 24hrs");
    //     return;
    // } else {

    //     oldMessages.forEach((doc) => {
    //         let docRef = doc.id;

    //         db.collection("Messages/" + docRef).delete();
    //     })
    // }

    // return;
}