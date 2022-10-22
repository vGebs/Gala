const storyService = require("../services/StoryService");
const userCoreService = require("../services/UserCoreService");
const helpers = require("../services/helpers");

const postStory = async (req, res) => {
    const uid = req.body.uid;
    const pid = req.body.pid;
    const title = req.body.title;

    const caption = req.body.caption;
    const textBoxHeight = req.body.textBoxHeight;
    const yCoordinate = req.body.yCoordinate;

    if (uid && pid) {
        //now we make the push

        let story = {
            uid: uid,
            pid: pid,
            title: title,
            caption: caption,
            textBoxHeight: textBoxHeight,
            yCoordinate: yCoordinate
        }

        try {
            await storyService.postStory(story)
            res.status(200).send();
        } catch (e) {
            console.log("StoryViewModel: Failed to post story")

            const payload = {
                error: "Failed to post story",
                description: e
            };

            res.status(500).send(payload);
        }
    } else {
        const payload = {
            error: "StoryViewModel/postStory:Failed to enter uid and/or postID"
        };

        res.status(500).send(payload);
    }
}

const getStory = async (req, res) => {
    const uid = req.body.uid;
    const pid = req.body.pid;

    if (uid && pid) {
        try {
            const returnedStory = await storyService.getStory(uid, pid);
            res.status(200).send(returnedStory);
        } catch (e) {
            const payload = {
                error: "Failed to query story"
            }

            res.status(500).send(payload);
        }
    } else {
        const payload = {
            error: "StoryViewModel/getStory: Failed to enter uid and/ or postID"
        };

        res.status(500).send(payload);
    }
}

const deleteStory = async (req, res) => {
    const uid = req.body.uid;
    const pid = req.body.pid;

    if (uid && pid) {
        try {
            await storyService.deleteStory(uid, pid);

            const payload = {
                description: "StoryViewModel/deleteStory: Success"
            };

            res.status(200).send(payload);

        } catch (e) {
            const payload = {
                error: "StoryViewModel/deleteStory: Failed to delete story",
                description: e
            };

            res.status(500).send(payload);
        }
    } else {
        const payload = {
            error: "StoryViewModel/deleteStory: Failed to enter pid and uid"
        };

        res.status(500).send(payload);
    }
};

const getExploreStories = async (req, res) => {
    // ok, so we are going to be making the story system
    // 1. Region search (on or off[off being global])
    // 2. we need to fetch 30 users that have a post 
    //  a. we need to know if they have posted, so we need to add a new field to userCore
    //  b. we do not want to fetch match stories here
    //  c. we also dont want to see stories we have already seen
    //      - We view every story by noting the uid of user watched and the postID(date).
    //      - We fetch all of the current users view and fetch
    //      - We want to see some stories we have already seen but didnt dislike/like
    //      - so we need to fetch 19 users with stories we havent seen
    //      - we also need to fetch 11 users with stories we have seen but didnt like/dislike
    // 3. once we get 30 users who have posted, we need to fetch their stories
    //  a. fetch all stories with uid as such
    // 4. once we get all the stories for that particular user, we package the 
    //      the posts into one json object
    // 5. We then add that new userPosts to an array in the object we are returning

    const userCore = helpers.bundleUserCore(req);
    const matchUIDs = req.body.matchUIDs;
    const localSearch = req.body.localSearch;

    try {
        const usersWeHaveSeen = await storyService.getUsersWithStoriesIveSeen(userCore);

        //we want to add matchUIDS and usersWeHaveSeen to a nin array
        var ninUIDs = [];
        for (var i = 0; i < usersWeHaveSeen.length; i++) {
            ninUIDs.push(usersWeHaveSeen[i].userBasic.uid)
        }
        ninUIDs = ninUIDs.concat(matchUIDs);
        ninUIDs.push(userCore.userBasic.uid);

        var usersWeHaventSeen;

        if (usersWeHaveSeen.length == 11) {
            usersWeHaventSeen = await userCoreService.getUsersWithPosts(userCore, ninUIDs, localSearch, 30);
        } else {
            const limit = 30 - usersWeHaveSeen.length;
            usersWeHaventSeen = await userCoreService.getUsersWithPosts(userCore, ninUIDs, localSearch, limit);
        }

        const getStoriesForUsers = usersWeHaveSeen.concat(usersWeHaventSeen);

        var asyncCalls = [];
        for (var i = 0; i < getStoriesForUsers.length; i++) {
            asyncCalls.push(storyService.getStoriesForUser(getStoriesForUsers[i]))
        }

        if (asyncCalls.length > 0) {
            const promise = await Promise.all(asyncCalls);

            //Filter empty objects out
            const results = promise.filter(element => {
                if (Object.keys(element).length !== 0) {
                    return true;
                }
                return false;
            })

            res.status(200).send(results);

        } else {
            res.status(200).send({message: "No Stories"});
        }

    } catch (e) {
        console.log("Error: " + e);
        const payload = {
            error: "StoryViewModel/getExploreStories: Failed to fetch explore stories",
            description: e
        };

        res.status(500).send(payload);
    }
};

const getMatchStories = async (req, res) => {

    const matchUserCores = req.body.matchUserCores;

    try {

        var asyncCalls = []

        for (var i = 0; i < matchUserCores.length; i++) {
            asyncCalls.push(storyService.getStoriesForUser(matchUserCores[i]));
        }

        const promise = await Promise.all(asyncCalls);

        //Filter empty objects out
        const results = promise.filter(element => {
            if (Object.keys(element).length !== 0) {
                return true;
            }
            return false;
        })

        console.log("StoryViewModel/getMatchStories: Successful")
        res.status(200).send(results);

    } catch (e) {
        const payload = {
            error: "StoryViewModel/getMatchStories: Failed to fetch match stories",
            description: e
        };
        res.status(500).send(payload);
    }
};

const viewStory = async (req, res) => {
    const storyView = req.body.storyView

    try {
        await storyService.viewStory(storyView);

        const payload = {
            description: "Successfully viewed story"
        };

        res.status(200).send(payload);
    } catch (e) {
        const payload = {
            error: "StoryViewModel/viewStory: Failed to view story",
            description: e
        };

        res.status(500).send(payload);
    }
}

module.exports = {
    postStory,
    getStory,
    deleteStory,
    getExploreStories,
    getMatchStories,
    viewStory
};