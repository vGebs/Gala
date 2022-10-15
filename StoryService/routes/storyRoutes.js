const express = require("express")
const router = express.Router()

const storyViewModel = require("../viewModels/StoryViewModel");

router.post("/story/postStory", storyViewModel.postStory);
router.post("/story/getStory", storyViewModel.getStory);
router.post("/story/deleteStory", storyViewModel.deleteStory);
router.post("/story/getExploreStories", storyViewModel.getExploreStories);
router.post("/story/getMatchStories", storyViewModel.getMatchStories);
router.post("/story/viewStory", storyViewModel.viewStory);

module.exports = router