const recentlyJoinedService = require("../services/RecentlyJoinedService");
const UserCore = require("../models/UserCore");

const getRecents = async (req, res) => {

    const userCore = bundleUserCore(req);
    const matches = req.body.matches;

    if (userCore.userBasic.uid) {
        try {
            const returnedRecents = await recentlyJoinedService.getRecents(userCore, matches);
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
            uid: req.body.userBasic.uid,
            name: req.body.userBasic.name,
            birthdate: req.body.userBasic.birthdate,
            gender: req.body.userBasic.gender,
            sexuality: req.body.userBasic.sexuality,
            dateJoined: req.body.userBasic.dateJoined
        },
        ageRangePreference: {
            maxAge: req.body.ageRangePreference.maxAge,
            minAge: req.body.ageRangePreference.minAge,
        },
        searchRadiusComponents: {
            willingToTravel: req.body.searchRadiusComponents.willingToTravel,
            location: {
                coordinates: req.body.searchRadiusComponents.location.coordinates
            }
        }
    }

    return userCore
}