const recentlyJoinedService = require("../services/RecentlyJoinedService");
const UserCore = require("../models/UserCore");
const helpers = require("../services/helpers");

const getRecents = async (req, res) => {

    const userCore = helpers.bundleUserCore(req);
    const matches = req.body.matches;
    const localSearch = req.body.localSearch;

    if (userCore.userBasic.uid) {
        try {
            const returnedRecents = await recentlyJoinedService.getRecents(userCore, matches, localSearch);
            res.status(200).send(returnedRecents);
        } catch (e) {
            const payload = {
                error: "Failed to get recently joined users",
                description: e
            };
            res.status(500).send(payload);
        }
    } else {
        const payload = {
            error: "Failed to enter uid"
        };
        res.status(500).send(payload);
    }
};

const viewRecentlyJoinedProfile = async (req, res) => {
    const currentUID = req.body.currentUID;
    const viewedUID = req.body.viewedUID;

    if (currentUID && viewedUID) {
        await recentlyJoinedService.viewRecentlyJoinedProfile(currentUID, viewedUID);
        res.status(200).send();
    } else {
        const payload = {
            error: "Failed to enter either current user ID or viewed user ID"
        }
        res.status(500).send(payload);
    }
};

module.exports = {
    getRecents,
    viewRecentlyJoinedProfile
};
