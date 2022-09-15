const express = require("express")
const router = express.Router()

const recentlyJoinedViewModel = require("../viewModels/RecentlyJoinedViewModel");

router.post("/recentlyJoined/getRecents", recentlyJoinedViewModel.getRecents);
router.post("/recentlyJoined/viewRecentlyJoinedProfile", recentlyJoinedViewModel.viewRecentlyJoinedProfile);

module.exports = router