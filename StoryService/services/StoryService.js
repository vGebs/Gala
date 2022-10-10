const Story = require("../models/Story");

const postStory = async (story) => {
    try {
        const newStory = new Story(story);

        await newStory.save();
        console.log("StoryService: Successfully posted story");
    } catch (e) {
        throw e
    }
}

const getStory = async (uid, pid) => {
    try {
        const queryParams = {
            uid: uid,
            pid: pid
        }
        const returnedStory = await Story.find(queryParams).exec();

        return returnedStory[0];
    } catch (e) {
        throw e;
    }
}

const getExploreStories = async (uid, matchUIDs, localSearch) => {

}

const getStoriesForUser = async (userCore) => {
    if (userCore) {
        try {

            let queryParams = {
                "userBasic.uid": userCore.userBasic.uid
            };

            const posts = await Story.find(queryParams).exec();

            if (posts.length > 0) {
                userCore["posts"] = posts
                console.log(userCore);

                return userCore;
            } else {
                return {};
            }

        } catch (e) {
            const payload = {
                error: "StoryService/getStoriesForUser: Failed to fetch users",
                description: e
            };

            throw payload;
        }
    } else {
        const payload = {
            error: "StoryService: Empty userCore"
        };

        throw payload;
    }
}

const getMatchStories = async (uid, matchUIDs) => {

}

module.exports = {
    postStory,
    getStory,
    getExploreStories,
    getStoriesForUser,
    getMatchStories
}