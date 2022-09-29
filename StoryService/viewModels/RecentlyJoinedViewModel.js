const recentlyJoinedService = require("../services/RecentlyJoinedService");
const UserCore = require("../models/UserCore");

const getRecents = async (req, res) => {

    const userCore = bundleUserCore(req);
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


const bundleUserCore = (req) => {
    const userCore = {
        userBasic: {
            uid: req.body.UserCore.userBasic.uid,
            name: req.body.UserCore.userBasic.name,
            birthdate: req.body.UserCore.userBasic.birthdate,
            gender: req.body.UserCore.userBasic.gender,
            sexuality: req.body.UserCore.userBasic.sexuality,
            dateJoined: req.body.UserCore.userBasic.dateJoined
        },
        ageRangePreference: {
            maxAge: req.body.UserCore.ageRangePreference.maxAge,
            minAge: req.body.UserCore.ageRangePreference.minAge,
        },
        searchRadiusComponents: {
            willingToTravel: req.body.UserCore.searchRadiusComponents.willingToTravel,
            location: {
                coordinates: req.body.UserCore.searchRadiusComponents.location.coordinates
            }
        }
    }

    return userCore
}