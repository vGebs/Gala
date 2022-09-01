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
        const queryParams =  {
            uid: uid,
            pid: pid
        }
        const returnedStory = await Story.find(queryParams).exec();

        return returnedStory[0];
    } catch (e) {
        throw e;
    }
}

const getStories = async (uid) => {

}

module.exports = {
    postStory,
    getStory,
    getStories
}