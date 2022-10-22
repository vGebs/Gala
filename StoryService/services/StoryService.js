const Story = require("../models/Story");
const StoryView = require("../models/StoryView");
const userCoreService = require("../services/UserCoreService");

const postStory = async (story) => {
    try {
        const newStory = new Story(story);

        await newStory.save();
        console.log("StoryService: Successfully posted story");
        return;
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

const deleteStory = async (uid, pid) => {
    try {
        const queryParams = {
            "uid": {
                $eq: uid
            },
            "pid": {
                $eq: pid
            }
        }

        await Story.deleteOne(queryParams);
        return;
    } catch(e) {
        throw e;
    }
}

const getUsersWithStoriesIveSeen = async (userCore) => {
    //we want to fetch 11 users who still have stories we have seen

    try {
        const queryParams = {
            viewerUID: {
                $eq: userCore.userBasic.uid
            }
        };

        const views = await StoryView.find(queryParams).limit(11);

        var asyncCalls = [];

        for(var i = 0; i < views.length; i++) {
            asyncCalls.push(userCoreService.getUser(views[i].viewedUID));
        }

        if (asyncCalls.length > 0) {
            const promise = await Promise.all(asyncCalls);
            return promise;
        } else {
            return [];
        }

    } catch(e) {
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

                const newUserCore = {
                    userBasic: userCore.userBasic,
                    searchRadiusComponents: userCore.searchRadiusComponents,
                    ageRangePreference: userCore.ageRangePreference,
                    mostRecentStory: userCore.mostRecentStory,
                    posts: posts
                };

                return newUserCore;
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
    deleteStory,
    getUsersWithStoriesIveSeen,
    getStoriesForUser,
    viewStory
}