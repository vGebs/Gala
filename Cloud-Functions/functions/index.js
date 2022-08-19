const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

//FCM Payload info: https://customer.io/docs/push-custom-payloads/#fcm-custom-push-payload

exports.onMatchDeletion = functions.firestore.document("Matches/{docID}")
    .onDelete(async (snap, context) => {
        const snapDoc = snap.data();

        //we need to get the UIDs from the array

        let matchedArray = snapDoc.matched;
        let uid1 = "";
        let uid2 = "";

        for (let i = 0; i < matchedArray.length; i++) {
            if (i == 0) {
                uid1 = matchedArray[i];
            } else if (i == 1) {
                uid2 = matchedArray[i];
            }
        }

        console.log("User 1 uid: " + uid1);
        console.log("User 2 uid: " + uid2);

        let messageCollection = db.collection("Messages");
        let snapsCollection = db.collection("Snaps");

        if (uid1 != "" && uid2 != "") {
            //we then need to fetch all messages:
            // to user1 - from user2
            // to user2 - from user1

            try {
                const toUser1Query = await messageCollection.where("toID", "==", uid1).where("fromID", "==", uid2).get();

                toUser1Query.forEach((doc) => {
                    //we now have to delete all messages 
                    let docID = doc.id;

                    messageCollection.doc(docID).delete();
                });
            } catch (e) {
                console.log("onMatchDeletion: Failed to fetch messages to UID1 -> " + uid1);
                console.log("onMatchDeletion-err: " + e);
            }

            try {
                const toUser2Query = await messageCollection.where("toID", "==", uid2).where("fromID", "==", uid1).get();

                toUser2Query.forEach((doc) => {
                    //we now have to delete all messages 
                    let docID = doc.id;

                    messageCollection.doc(docID).delete();
                });
            } catch (e) {
                console.log("onMatchDeletion: Failed to fetch messages to UID2 -> " + uid2);
                console.log("onMatchDeletion-err: " + e);
            }

            //we then need to fetch all snaps
            // to user1 - from user2
            // to user2 - from user1

            try {
                const toUser1Query = await snapsCollection.where("toID", "==", uid1).where("fromID", "==", uid2).get();

                //we then to delete all snap docs
                toUser1Query.forEach((doc) => {
                    let docID = doc.id;

                    snapsCollection.doc(docID).delete();
                });
            } catch (e) {
                console.log("onMatchDeletion: Failed to fetch snaps to UID1 -> " + uid1);
                console.log("onMatchDeletion-err: " + e);
            }

            try {
                const toUser2Query = await snapsCollection.where("toID", "==", uid2).where("fromID", "==", uid1).get();

                //we then to delete all snap docs
                toUser2Query.forEach((doc) => {
                    let docID = doc.id;

                    snapsCollection.doc(docID).delete();
                });
            } catch (e) {
                console.log("onMatchDeletion: Failed to fetch snaps to UID2 -> " + uid2);
                console.log("onMatchDeletion-err: " + e);
            }


            //we then need to delete the snap asset folder for that user 
            //Delete: Snaps/user1UID/user2UID
            //Delete: Snaps/user2UID/user1UID
            try {
                await admin.storage().bucket("gala-e23aa.appspot.com").deleteFiles({
                    prefix: `Snaps/${uid1}/${uid2}`
                });
            } catch (e) {
                console.log("onMatchDeletion: Failed to delete snap assets to UID1 -> " + uid1);
                console.log("onMatchDeletion-err: " + e);
            }

            try {
                await admin.storage().bucket("gala-e23aa.appspot.com").deleteFiles({
                    prefix: `Snaps/${uid2}/${uid1}`
                });
            } catch (e) {
                console.log("onMatchDeletion: Failed to delete snap assets to UID2 -> " + uid2);
                console.log("onMatchDeletion-err: " + e);
            }
        }
    })

exports.snapNotification = functions.firestore.document("Snaps/{docID}")
    .onCreate(async (snap, context) => {
        //on new snap we need to send a notification to the toID

        const snapDoc = snap.data();

        const fcmTokenCollection = db.collection("FCM Tokens");
        const notificationsCollection_toID = db.collection("Notifications").doc(snapDoc.toID)
        let badgeCount = 1;

        try {
            const notificationsDoc = await notificationsCollection_toID.get();

            if (notificationsDoc.exists) {
                const notifications = notificationsDoc.data();
                badgeCount = notifications.notifications.length;

                let flag = false;
                for (let i = 0; i < badgeCount; i++) {
                    if (snapDoc.fromID == notifications.notifications[i]) {
                        flag = true
                        break;
                    }
                }

                if (!flag) {
                    notificationsCollection_toID.update({
                        notifications: admin.firestore.FieldValue.arrayUnion(snapDoc.fromID)
                    })
                    badgeCount++;
                }

            } else {
                //there is no such document, so push a new one
                const data = {
                    notifications: [snapDoc.fromID]
                };

                notificationsCollection_toID.set(data);
            }

        } catch (e) {
            console.log("snapNotification-err: " + e)
        }

        try {
            const toIDToken = await fcmTokenCollection.doc(snapDoc.toID).get();
            const toIDTokenDoc = toIDToken.data();

            if (toIDTokenDoc.loggedIn == 1) {
                const payload = {
                    "token": toIDTokenDoc.token,
                    "notification": {
                        "title": snapDoc.fromName,
                        "body": "Sent you a snap"
                    },
                    "apns": {
                        "payload": {
                            "aps": {
                                "badge": badgeCount
                            }
                        }
                    }
                };

                admin.messaging().send(payload).then((value) => {
                    console.log("sent notification");
                });
            }

        } catch (e) {
            console.log("snapNotification-err" + e);
        }
    })

exports.messageNotification = functions.firestore.document("Messages/{docID}")
    .onCreate(async (snap, context) => {
        //on new message we need to send a notification to the toID

        const messageDoc = snap.data();

        const fcmTokenCollection = db.collection("FCM Tokens");
        const notificationsCollection_toID = db.collection("Notifications").doc(messageDoc.toID);
        let badgeCount = 1;

        try {
            const notificationsDoc = await notificationsCollection_toID.get();

            if (notificationsDoc.exists) {
                const notifications = notificationsDoc.data();
                badgeCount = notifications.notifications.length;

                let flag = false;
                for (let i = 0; i < badgeCount; i++) {
                    if (messageDoc.fromID == notifications.notifications[i]) {
                        flag = true
                        break;
                    }
                }

                if (!flag) {
                    notificationsCollection_toID.update({
                        notifications: admin.firestore.FieldValue.arrayUnion(messageDoc.fromID)
                    })
                    badgeCount++;
                }

            } else {
                //there is no such document, so push a new one
                const data = {
                    notifications: [messageDoc.fromID]
                };

                notificationsCollection_toID.set(data);
            }

        } catch (e) {
            console.log("messageNotification-err: " + e);
        }

        try {
            const toIDToken = await fcmTokenCollection.doc(messageDoc.toID).get();
            const toIDTokenDoc = toIDToken.data();

            if (toIDTokenDoc.loggedIn == 1) {
                const payload = {
                    "token": toIDTokenDoc.token,
                    "notification": {
                        "title": messageDoc.fromName,
                        "body": "Sent you a message"
                    },
                    "apns": {
                        "payload": {
                            "aps": {
                                "badge": badgeCount
                            }
                        }
                    }
                };

                admin.messaging().send(payload).then((value) => {
                    console.log("sent notification")
                });
            }

        } catch (e) {
            console.log("messageNotification-err" + e)
        }
    })

exports.listenForMatches = functions.firestore.document("Likes/{likerUID}")
    .onCreate(async (snap, context) => {
        const docRef = snap.id;
        const data = snap.data();
        const likerUID = data.likerUID;
        const likedUID = data.likedUID;

        const matchCollection = db.collection("Matches");
        const likesCollection = db.collection("Likes");
        const fcmTokenCollection = db.collection("FCM Tokens");
        const peopleThatLikeMe = await getPeopleThatLikeMe(likerUID);

        if (peopleThatLikeMe != null) {
            for (let i = 0; i < peopleThatLikeMe.length; i++) {
                if (peopleThatLikeMe[i].id == likedUID) {

                    //Add the new match to the matches collection

                    let badgeCount_liked = 1;
                    let badgeCount_liker = 1;
                    //we need to add a new notification to the Notification doc

                    const likedNotificationReference = db.collection("Notifications").doc(likedUID);
                    const likerNotificationReference = db.collection("Notifications").doc(likerUID);

                    try {
                        const likedNotificationsDoc = await likedNotificationReference.get();
                        const likerNotificationsDoc = await likerNotificationReference.get();

                        if (likedNotificationsDoc.exists) {
                            const notifications = likedNotificationsDoc.data();
                            badgeCount_liked = notifications.notifications.length;

                            let flag = false;
                            for (let i = 0; i < badgeCount_liked; i++) {
                                if (likerUID == notifications.notifications[i]) {
                                    flag = true
                                    break;
                                }
                            }

                            if (!flag) {
                                likedNotificationReference.update({
                                    notifications: admin.firestore.FieldValue.arrayUnion(likerUID)
                                })
                                badgeCount_liked++;
                            }

                        } else {
                            //there is no such document, so push a new one
                            const data = {
                                notifications: [likerUID]
                            };

                            likedNotificationReference.set(data);
                        }

                        if (likerNotificationsDoc.exists) {
                            const notifications = likerNotificationsDoc.data();
                            badgeCount_liker = notifications.notifications.length;

                            let flag = false;
                            for (let i = 0; i < badgeCount_liker; i++) {
                                if (likedUID == notifications.notifications[i]) {
                                    flag = true
                                    break;
                                }
                            }

                            if (!flag) {
                                likerNotificationReference.update({
                                    notifications: admin.firestore.FieldValue.arrayUnion(likedUID)
                                })
                                badgeCount_liker++;
                            }

                        } else {
                            //there is no such document, so push a new one
                            const data = {
                                notifications: [likedUID]
                            };

                            likerNotificationReference.set(data);
                        }

                    } catch (e) {
                        console.log("listenForMatches-err: " + e)
                    }

                    try {
                        matchCollection.add({
                            matched: [likedUID, likerUID],
                            time: admin.firestore.FieldValue.serverTimestamp()
                        })

                        const likerFCM = await fcmTokenCollection.doc(likerUID).get();
                        const likerFCMDoc = likerFCM.data();

                        const likedFCM = await fcmTokenCollection.doc(likedUID).get();
                        const likedFCMDoc = likedFCM.data();

                        const payloadToLiker = {
                            token: likerFCMDoc.token,
                            notification: {
                                title: "You matched with " + likedFCMDoc.name,
                                body: "Say hello!"
                            },
                            "apns": {
                                "payload": {
                                    "aps": {
                                        "badge": badgeCount_liker
                                    }
                                }
                            }
                        };

                        const payloadToLiked = {
                            "token": likedFCMDoc.token,
                            "notification": {
                                "title": "You matched with " + likerFCMDoc.name,
                                "body": "Say hello!"
                            },
                            "apns": {
                                "payload": {
                                    "aps": {
                                        "badge": badgeCount_liked
                                    }
                                }
                            }
                        };

                        if (likerFCMDoc.loggedIn == 1) {
                            admin.messaging().send(payloadToLiker).then((value) => {
                                console.log("sent notification")
                            });
                        } else {
                            console.log("Did not send notification")
                        }

                        if (likedFCMDoc.loggedIn === 1) {
                            admin.messaging().send(payloadToLiked).then((value) => {
                                console.log("sent notification")
                            });
                        } else {
                            console.log("Did not send notification")
                        }
                    } catch (err) {
                        console.log("listenForMatches-err: " + err);
                    }

                    //Delete both of the likes
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
    //  1. Delete any old messages (24 hrs after opened)
    //  2. Delete any outdated recentlyJoined Users (7 days)
    //  3. Delete old snaps (24 hrs after opened)    
    //  4. Delete any old stories (24 hrs)

    //deleteOldMessages()
    deleteOldRecentlyJoinedUsers()
    deleteOldStories()
    return;
})

async function deleteOldMessages() {
    const tsToMillis = admin.firestore.Timestamp.now().toMillis();
    const compareDate = new Date(tsToMillis - (24 * 60 * 60 * 1000));
    const oldMessages = await db.collection("Messages/").where("openedDate", "<", compareDate).get();

    if (oldMessages.empty) {
        console.log("No old messages to delete");
        return;
    } else {

        oldMessages.forEach((doc) => {
            let docRef = doc.id;
            db.collection("Messages").doc(docRef).delete();
        })
    }

    return;
}

async function deleteOldRecentlyJoinedUsers() {
    const tsToMillis = admin.firestore.Timestamp.now().toMillis();
    const compareDate = new Date(tsToMillis - (24 * 60 * 60 * 1000 * 7));
    const oldUsers = await db.collection("RecentlyJoined/").where("dateJoined", "<", compareDate).get();

    if (oldUsers.empty) {
        return;
    } else {

        oldUsers.forEach((doc) => {
            let docRef = doc.id;
            db.collection("RecentlyJoined").doc(docRef).delete();
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

    const tsToMillis = admin.firestore.Timestamp.now().toMillis();
    const compareDate = new Date(tsToMillis - (24 * 60 * 60 * 1000));
    const oldStories = await db.collection("Stories/").where("oldestStoryDate", "<", compareDate).get();

    if (oldStories.empty) {
        //No stories older than 24hrs
        console.log("No stories older than 24hrs");
        return;
    } else {

        oldStories.forEach((doc) => {
            let docRef = doc.id;
            // for each story document, we need to:
            //  1. check to see if there is more than 1 story
            //      a. if there is 1 story, we delete the document
            //      b. if there is more than 1 story, we remove the outdated story from the document and then we update the 'oldestStoryDate' to the postID_date of the oldest date

            let data = doc.data();

            let posts = data.posts;

            if (posts.length > 1) {
                //we need to find the oldest date
                let oldestDate = compareDate
                let index = -1;
                for (let i = 0; i < posts.length; i++) {
                    if (posts[i].id.toDate() < oldestDate) {
                        oldestDate = posts[i].id.toDate();
                        index = i;
                    }
                }

                data.posts.splice(index, 1);
                data.oldestStoryDate = data.posts[0].id;

                db.collection("Stories/").doc(docRef).set(data);

            } else if (posts.length == 1) {

                db.collection("Stories/").doc(docRef).delete().then(() => {
                    admin.storage().bucket("gala-e23aa.appspot.com").deleteFiles({
                        prefix: `Stories/${docRef}`
                    });
                });
            }
        })
    }

    return;
}