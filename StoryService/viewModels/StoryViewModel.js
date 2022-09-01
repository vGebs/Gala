const storyService = require("../services/StoryService");

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
            }

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
        } catch(e) {
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

const getStories = (req, res) => {

}

module.exports = {
    postStory,
    getStory,
    getStories
}

