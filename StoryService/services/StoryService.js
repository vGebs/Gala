const Story = require("../models/Story");
const StoryView = require("../models/StoryView");

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

const getStoriesForUser = async (userCore) => {
    if (userCore) {
        try {

            let queryParams = {
                "uid": {
                    $eq: userCore.userBasic.uid
                }
            };

            const posts = await Story.find(queryParams).exec();

            if (posts.length > 0) {
                userCore["posts"] = posts

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

const viewStory = async (storyView) => {
    try {
        const newStoryView = new StoryView(storyView);

        await newStoryView.save()

        console.log("StoryService: Successfully viewed story");
    } catch (e) {
        throw e
    }
}

module.exports = {
    postStory,
    getStory,
    getStoriesForUser,
    viewStory
}