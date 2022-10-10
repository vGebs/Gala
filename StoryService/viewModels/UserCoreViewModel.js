const userCoreService = require("../services/UserCoreService");
const UserCore = require("../models/UserCore");

const createUserCore = async (req, res) => {

    const userCore = bundleUserCore(req);

    try {
        await userCoreService.createUser(userCore);
        res.status(200).send();
    } catch (e) {
        const payload = {
            error: "Failed to create UserCore",
            description: e
        };
        res.status(500).send(e);
    }
};

const getUserCore = async (req, res) => {
    const uid = req.body.uid;
    if (uid) {
        try {
            const returnedUser = await userCoreService.getUser(uid);
            res.status(200).send(returnedUser);
        } catch (e) {
            const payload = {
                error: "Failed to get user core",
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

const updateUserCore = async (req, res) => {
    const userCore = UserCore.bundleUserCore(req);
    if (userBasicIsFilled(userCore.userBasic)) {
        try {
            await userCoreService.updateUser(userCore);
            res.status(200).send();
        } catch (e) {
            const payload = {
                error: "Failed to update userCore",
                description: e
            };

            res.status(500).send(payload);
        }
    } else {
        const payload = {
            error: "Failed to enter userBasic info"
        };
        res.status(500).send(payload);
    }
};

const deleteUserCore = async (req, res) => {
    const uid = req.body.uid;
    if (uid) {
        try {
            await userCoreService.deleteUser(uid);
            res.status(200).send();
        } catch (e) {
            const payload = {
                error: "Failed to delete userCore",
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

module.exports = {
    createUserCore,
    getUserCore,
    updateUserCore,
    deleteUserCore
}

const userBasicIsFilled = (userBasic) => {
    if (userBasic.uid && userBasic.name && userBasic.birthdate && userBasic.gender && userBasic.sexuality) {
        return true
    } else {
        return false
    }
}

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

    if (req.body.mostRecentStory) {
        userCore["mostRecentStory"] = req.body.mostRecentStory
    }

    return userCore
}